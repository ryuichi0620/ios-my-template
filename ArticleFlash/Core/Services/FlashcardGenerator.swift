import Foundation
import FoundationModels

struct FlashcardGenerator {

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    // MARK: - Few-Shot 付き System Instructions

    private static let instructions = """
    記事からQ&Aカードを日本語で3つ生成。ルール:
    - 質問は「〜とは何か」形式で自己完結。答えは30字以内、キーワード文頭配置
    - 3つは異なる要点をカバー。タグは技術名を1〜3個
    良い例: Q:@Stateと@Bindingの違いは？ A:@Stateはビュー内部所有、@Bindingは親からの参照
    悪い例: Q:この記事について説明して（漠然）/ A:〜を理解することが重要です（曖昧）
    """

    // MARK: - Streaming 生成

    /// ストリーミングでカードを生成し、部分結果を逐次返す
    static func generateStreaming(
        from article: ArticleContent,
        onUpdate: @Sendable @escaping ([FlashcardCandidate]) -> Void
    ) async throws -> [FlashcardCandidate] {
        guard isAvailable else {
            let mock = mockCards(from: article)
            // モックでもストリーミング風に1枚ずつ返す
            for i in 0..<mock.count {
                try await Task.sleep(for: .milliseconds(400))
                onUpdate(Array(mock.prefix(i + 1)))
            }
            return mock
        }

        let session = LanguageModelSession(instructions: instructions)
        // ハードリミット: 600文字を超える場合は切り詰め（Summarizerの出力は通常これ以下）
        let safeText = String(article.bodyText.prefix(600))
        let prompt = "以下の記事から学習カードを3つ作成:\n\n\(safeText)"

        var latestCards: [FlashcardCandidate] = []

        let stream = session.streamResponse(
            to: prompt,
            generating: FlashcardCandidates.self
        )

        for try await snapshot in stream {
            if let cards = snapshot.content.cards {
                let validCards = cards.compactMap { candidate -> FlashcardCandidate? in
                    guard let q = candidate.question, let a = candidate.answer else { return nil }
                    return FlashcardCandidate(
                        question: q,
                        answer: a,
                        tags: candidate.tags?.compactMap(\.self) ?? []
                    )
                }
                if validCards.count > latestCards.count {
                    latestCards = validCards
                    onUpdate(latestCards)
                }
            }
        }

        return latestCards
    }

    // MARK: - 一括生成（フォールバック用）

    static func generate(
        from article: ArticleContent
    ) async throws -> [FlashcardCandidate] {
        guard isAvailable else {
            return mockCards(from: article)
        }

        let session = LanguageModelSession(instructions: instructions)
        let safeText = String(article.bodyText.prefix(600))
        let prompt = "以下の記事から学習カードを3つ作成:\n\n\(safeText)"

        let response = try await session.respond(
            to: prompt,
            generating: FlashcardCandidates.self
        )
        return response.content.cards
    }

    // MARK: - Mock（非対応環境用）

    private static func mockCards(from article: ArticleContent) -> [FlashcardCandidate] {
        let title = article.title
        return [
            FlashcardCandidate(
                question: "「\(title)」の主要なポイントは？",
                answer: "記事の要点を簡潔に説明できること",
                tags: ["学習"]
            ),
            FlashcardCandidate(
                question: "「\(title)」で紹介された技術的な概念は？",
                answer: String(article.bodyText.prefix(60)),
                tags: ["技術"]
            ),
            FlashcardCandidate(
                question: "「\(title)」の内容を実践するには？",
                answer: "記事の手順に従い、実際にコードを書いてみる",
                tags: ["実践"]
            ),
        ]
    }
}
