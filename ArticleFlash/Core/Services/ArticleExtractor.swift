import Foundation
import WebKit

@MainActor
final class ArticleExtractor {

    enum ExtractionError: LocalizedError {
        case invalidURL(String)
        case fetchFailed(String)
        case emptyContent

        var errorDescription: String? {
            switch self {
            case .invalidURL(let url): return "無効なURL: \(url)"
            case .fetchFailed(let reason): return "記事の取得に失敗: \(reason)"
            case .emptyContent: return "記事の本文を抽出できませんでした"
            }
        }
    }

    static func extract(from url: URL) async throws -> ArticleContent {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            throw ExtractionError.invalidURL(url.absoluteString)
        }

        // リダイレクトを追跡して最終URLとデータを取得
        let (data, finalURL) = try await fetchWithRedirects(url: url)

        let html = String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .ascii)
            ?? ""

        guard !html.isEmpty else {
            throw ExtractionError.emptyContent
        }

        let title = extractTitle(from: html)
        let bodyText = try await extractBodyText(from: html)

        guard !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ExtractionError.emptyContent
        }

        // 長文記事は再帰的に要約してトークン制限内に収める
        let condensedText = try await ArticleSummarizer.condense(bodyText, title: title)

        return ArticleContent(url: finalURL, title: title, bodyText: condensedText)
    }

    /// リダイレクトを無効化したセッション（手動で追跡するため）
    private static let noRedirectSession: URLSession = {
        let config = URLSessionConfiguration.default
        let delegate = NoRedirectDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }()

    /// リダイレクトを手動で追跡し、最終URLとレスポンスデータを返す
    private static func fetchWithRedirects(url: URL, maxRedirects: Int = 10) async throws -> (Data, URL) {
        var currentURL = url
        var redirectCount = 0

        while redirectCount < maxRedirects {
            var request = URLRequest(url: currentURL)
            request.httpMethod = "GET"
            request.setValue(
                "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1",
                forHTTPHeaderField: "User-Agent"
            )

            let (data, response) = try await noRedirectSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExtractionError.fetchFailed("不正なレスポンス")
            }

            switch httpResponse.statusCode {
            case 200...299:
                // 成功 — HTMLの中にmetaリダイレクトがないかもチェック
                let html = String(data: data, encoding: .utf8) ?? ""
                if let metaRedirectURL = extractMetaRefreshURL(from: html, baseURL: currentURL) {
                    currentURL = metaRedirectURL
                    redirectCount += 1
                    continue
                }
                let resolvedURL = httpResponse.url ?? currentURL
                return (data, resolvedURL)

            case 301, 302, 303, 307, 308:
                // リダイレクト
                guard let location = httpResponse.value(forHTTPHeaderField: "Location"),
                      let redirectURL = URL(string: location, relativeTo: currentURL) else {
                    throw ExtractionError.fetchFailed("リダイレクト先が不正 (HTTP \(httpResponse.statusCode))")
                }
                currentURL = redirectURL.absoluteURL
                redirectCount += 1

            default:
                throw ExtractionError.fetchFailed("HTTP \(httpResponse.statusCode)")
            }
        }

        throw ExtractionError.fetchFailed("リダイレクト回数が上限を超えました")
    }

    /// HTML内の <meta http-equiv="refresh" content="0;url=..."> を検出
    private static func extractMetaRefreshURL(from html: String, baseURL: URL) -> URL? {
        let pattern = #"<meta[^>]*http-equiv\s*=\s*[\"']?refresh[\"']?[^>]*content\s*=\s*[\"']?\d+\s*;\s*url\s*=\s*([^\"'\s>]+)"#
        guard let range = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) else {
            return nil
        }

        let match = String(html[range])
        // url= 以降を抽出
        guard let urlStart = match.range(of: "url=", options: .caseInsensitive) else { return nil }
        var urlString = String(match[urlStart.upperBound...])
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"' >"))

        return URL(string: urlString, relativeTo: baseURL)?.absoluteURL
    }

    private static func extractTitle(from html: String) -> String {
        if let titleRange = html.range(of: "(?<=<title[^>]*>).+?(?=</title>)", options: .regularExpression) {
            return String(html[titleRange])
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&#39;", with: "'")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let ogRange = html.range(of: "(?<=property=\"og:title\"\\s{0,5}content=\")[^\"]+", options: .regularExpression) {
            return String(html[ogRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "タイトル不明"
    }

    private static func extractBodyText(from html: String) async throws -> String {
        let webView = WKWebView(frame: .zero)

        let readabilityJS = """
        (function() {
            var scripts = document.querySelectorAll('script, style, nav, header, footer, aside, iframe, noscript');
            scripts.forEach(function(el) { el.remove(); });

            var article = document.querySelector('article') || document.querySelector('[role="main"]') || document.querySelector('main');
            if (article) return article.innerText;

            var paragraphs = document.querySelectorAll('p');
            var text = '';
            paragraphs.forEach(function(p) {
                var t = p.innerText.trim();
                if (t.length > 30) text += t + '\\n\\n';
            });
            return text || document.body.innerText;
        })();
        """

        webView.loadHTMLString(html, baseURL: nil)

        try await Task.sleep(for: .milliseconds(500))

        let result = try await webView.evaluateJavaScript(readabilityJS)
        return (result as? String) ?? ""
    }
}

// MARK: - URLSessionDelegate（自動リダイレクト無効化）

private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // リダイレクトを自動で追わず、302等をそのまま返す
        completionHandler(nil)
    }
}
