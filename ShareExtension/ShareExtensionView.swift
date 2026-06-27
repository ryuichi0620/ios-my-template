import SwiftUI
import UniformTypeIdentifiers
import FoundationModels

struct ShareExtensionView: View {
    let itemProviders: [NSItemProvider]
    let onDismiss: () -> Void

    @State private var articleContent: ArticleContent?
    @State private var candidates: [FlashcardCandidate] = []
    @State private var selectedCard: FlashcardCandidate?
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private enum Phase {
        case loading
        case streaming
        case complete
        case saved
        case error
    }

    private var phase: Phase {
        if errorMessage != nil { return .error }
        if isSaving { return .saved }
        if isLoading { return .loading }
        if isGenerating || candidates.count < 3 { return .streaming }
        return .complete
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            if let article = articleContent {
                articlePreview(article)
            }

            Divider()
                .padding(.vertical, 8)

            ScrollView {
                switch phase {
                case .loading:
                    loadingView
                case .streaming:
                    streamingView
                case .complete:
                    completeView
                case .saved:
                    savedView
                case .error:
                    errorView
                }
            }

            Spacer()

            if phase == .complete {
                saveButton
            }
        }
        .task {
            await loadAndGenerate()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button("✕") { onDismiss() }
                .font(.title2)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Article Preview

    private func articlePreview(_ article: ArticleContent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.primaryGradient)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(article.domain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()

            Text("AIがカードを作成中…")
                .font(.title3)
                .fontWeight(.semibold)

            Text("記事の要点を抽出しています")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(0..<3, id: \.self) { _ in
                skeletonCard
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: 12)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: 12)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(uiColor: .systemGray5))
                .frame(width: 200, height: 12)
        }
        .padding(16)
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Streaming View

    private var streamingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カードを生成中… ⚡")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(candidates) { card in
                FlashcardCardView(
                    question: card.question,
                    answer: card.answer,
                    tags: card.tags
                )
            }

            if candidates.count < 3 {
                skeletonCard
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Complete View

    private var completeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("保存するカードを選んでください")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(candidates) { card in
                FlashcardCardView(
                    question: card.question,
                    answer: card.answer,
                    tags: card.tags,
                    isSelected: selectedCard?.id == card.id
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCard = card
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Saved View

    private var savedView: some View {
        VStack(spacing: 16) {
            Text("✅")
                .font(.system(size: 48))
            Text("保存しました！")
                .font(.title3)
                .fontWeight(.semibold)
            Text("翌日の通知で復習をお知らせします")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: 16) {
            Text("⚠️")
                .font(.system(size: 48))

            Text(errorMessage ?? "エラーが発生しました")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button("閉じる") { onDismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(.top, 40)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveCard()
        } label: {
            Text("保存する")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
        .disabled(selectedCard == nil)
        .padding(20)
    }

    // MARK: - Actions

    private func loadAndGenerate() async {
        do {
            let url = try await extractURL()

            let article = try await ArticleExtractor.extract(from: url)
            articleContent = article
            isLoading = false
            isGenerating = true

            // Streaming: カードが1枚できるごとにUIを更新
            let finalCards = try await FlashcardGenerator.generateStreaming(
                from: article,
                onUpdate: { partialCards in
                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            candidates = partialCards
                        }
                    }
                }
            )
            candidates = finalCards
            isGenerating = false

        } catch {
            errorMessage = "カード生成に失敗しました:\n\(error.localizedDescription)"
        }
    }

    // MARK: - URL Extraction

    /// 全itemProviderからhttp/https URLを探す
    private func extractURL() async throws -> URL {
        // Pass 1: URL型から直接取得
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                if let url = try? await loadItem(from: provider, typeIdentifier: UTType.url.identifier),
                   let httpURL = normalizeToHTTP(url) {
                    return httpURL
                }
            }
        }

        // Pass 2: テキストからURL抽出
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                if let text = try? await loadText(from: provider) {
                    if let url = findHTTPURL(in: text) {
                        return url
                    }
                }
            }
        }

        // Pass 3: プロパティリスト（一部アプリが辞書形式でURLを共有）
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier("public.url") {
                if let url = try? await loadItem(from: provider, typeIdentifier: "public.url"),
                   let httpURL = normalizeToHTTP(url) {
                    return httpURL
                }
            }
        }

        // Pass 4: 最後の手段 — 全データからURLらしき文字列を探す
        for provider in itemProviders {
            for typeId in provider.registeredTypeIdentifiers {
                if let url = try? await loadItem(from: provider, typeIdentifier: typeId),
                   let httpURL = normalizeToHTTP(url) {
                    return httpURL
                }
            }
        }

        // デバッグ用: 受け取ったデータ型を表示
        let types = itemProviders.flatMap { $0.registeredTypeIdentifiers }
        throw URLError(.unsupportedURL, userInfo: [
            NSLocalizedDescriptionKey: "URLを取得できませんでした\n(受け取ったタイプ: \(types.joined(separator: ", ")))"
        ])
    }

    /// NSItemProviderからURL/文字列を読み取る
    private func loadItem(from provider: NSItemProvider, typeIdentifier: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier) { item, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                // URL型
                if let url = item as? URL {
                    continuation.resume(returning: url)
                    return
                }

                // Data → URL
                if let data = item as? Data {
                    if let url = URL(dataRepresentation: data, relativeTo: nil) {
                        continuation.resume(returning: url)
                        return
                    }
                    if let text = String(data: data, encoding: .utf8),
                       let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        continuation.resume(returning: url)
                        return
                    }
                }

                // String → URL
                if let text = item as? String,
                   let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    continuation.resume(returning: url)
                    return
                }

                // NSDictionary（一部アプリがDictionary形式でURL等を渡す）
                if let dict = item as? NSDictionary {
                    for value in dict.allValues {
                        if let text = value as? String,
                           let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
                           url.scheme == "http" || url.scheme == "https" {
                            continuation.resume(returning: url)
                            return
                        }
                    }
                }

                continuation.resume(throwing: URLError(.badURL))
            }
        }
    }

    /// NSItemProviderからテキストを読み取る
    private func loadText(from provider: NSItemProvider) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, error in
                if let error { continuation.resume(throwing: error) }
                else if let text = item as? String { continuation.resume(returning: text) }
                else if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                    continuation.resume(returning: text)
                } else { continuation.resume(throwing: URLError(.badURL)) }
            }
        }
    }

    /// 各種ブラウザのカスタムスキームをhttpsに正規化
    private func normalizeToHTTP(_ url: URL) -> URL? {
        let scheme = url.scheme?.lowercased() ?? ""

        // 既にhttp/httpsならそのまま
        if scheme == "http" || scheme == "https" {
            return url
        }

        // Google Chrome: googlechrome:// → http://, googlechromes:// → https://
        if scheme == "googlechrome" {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "http"
            return components?.url
        }
        if scheme == "googlechromes" {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            return components?.url
        }

        // Firefox: firefox://open-url?url=https://...
        if scheme == "firefox" || scheme == "firefox-focus" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
               let innerURL = URL(string: urlParam) {
                return innerURL
            }
        }

        // Brave: brave://open-url?url=https://...
        if scheme == "brave" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
               let innerURL = URL(string: urlParam) {
                return innerURL
            }
        }

        // URL文字列にhttp URLが含まれているか
        let absString = url.absoluteString
        if let httpURL = findHTTPURL(in: absString) {
            return httpURL
        }

        return nil
    }

    /// テキスト内からhttp/https URLを検出
    private func findHTTPURL(in text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // まずテキスト全体がURLかチェック
        if let url = URL(string: trimmed),
           url.scheme == "http" || url.scheme == "https" {
            return url
        }

        // NSDataDetectorでURL検出
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        let matches = detector?.matches(in: text, range: range) ?? []

        for match in matches {
            if let url = match.url, url.scheme == "https" || url.scheme == "http" {
                return url
            }
        }

        return nil
    }

    private func saveCard() {
        guard let card = selectedCard, let article = articleContent else { return }
        isSaving = true

        SharedStore.shared.savePendingCard(card, sourceURL: article.url.absoluteString, sourceTitle: article.title)

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onDismiss()
        }
    }
}
