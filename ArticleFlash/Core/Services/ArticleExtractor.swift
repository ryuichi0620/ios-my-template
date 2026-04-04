import Foundation
import WebKit

@MainActor
final class ArticleExtractor {

    static func extract(from url: URL) async throws -> ArticleContent {
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""

        let title = extractTitle(from: html)
        let bodyText = try await extractBodyText(from: html)

        let safeText: String
        if bodyText.count > 3000 {
            safeText = String(bodyText.prefix(3000))
        } else {
            safeText = bodyText
        }

        return ArticleContent(url: url, title: title, bodyText: safeText)
    }

    private static func extractTitle(from html: String) -> String {
        if let titleRange = html.range(of: "(?<=<title>).+?(?=</title>)", options: .regularExpression) {
            return String(html[titleRange])
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .trimmingCharacters(in: .whitespacesAndNewlines)
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

        // Wait for page to load
        try await Task.sleep(for: .milliseconds(500))

        let result = try await webView.evaluateJavaScript(readabilityJS)
        return (result as? String) ?? ""
    }
}
