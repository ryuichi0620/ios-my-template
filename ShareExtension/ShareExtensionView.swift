import SwiftUI
import UniformTypeIdentifiers
import FoundationModels

struct ShareExtensionView: View {
    let itemProvider: NSItemProvider
    let onDismiss: () -> Void

    @State private var articleContent: ArticleContent?
    @State private var candidates: [FlashcardCandidate] = []
    @State private var selectedCard: FlashcardCandidate?
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var streamingText = ""

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
            // Header
            header

            Divider()

            // Article preview
            if let article = articleContent {
                articlePreview(article)
            }

            Divider()
                .padding(.vertical, 8)

            // Content
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

            // Save button
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

            // Skeleton cards
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
        .background(Color(uiColor: .secondarySystemBackground))
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
            // Extract URL from share extension
            let url = try await extractURL()

            // Extract article content
            let article = try await ArticleExtractor.extract(from: url)
            articleContent = article
            isLoading = false
            isGenerating = true

            // Generate flashcards
            let generatedCards = try await FlashcardGenerator.generate(from: article)
            candidates = generatedCards
            isGenerating = false

        } catch {
            errorMessage = "カード生成に失敗しました: \(error.localizedDescription)"
        }
    }

    private func extractURL() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let url = item as? URL {
                        continuation.resume(returning: url)
                    } else if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: URLError(.badURL))
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let text = item as? String, let url = URL(string: text) {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: URLError(.badURL))
                    }
                }
            } else {
                continuation.resume(throwing: URLError(.unsupportedURL))
            }
        }
    }

    private func saveCard() {
        guard let card = selectedCard, let article = articleContent else { return }
        isSaving = true

        // Save to shared store for main app to pick up
        SharedStore.shared.savePendingCard(card, sourceURL: article.url.absoluteString, sourceTitle: article.title)

        // Schedule notification
        // Note: NotificationService needs the full Flashcard model,
        // but from the extension we just save to SharedStore

        // Auto-dismiss after brief delay
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            onDismiss()
        }
    }
}
