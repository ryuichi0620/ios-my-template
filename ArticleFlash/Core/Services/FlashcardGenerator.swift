import Foundation
import FoundationModels

struct FlashcardGenerator {
    static func generate(
        from article: ArticleContent
    ) async throws -> [FlashcardCandidate] {
        let session = LanguageModelSession(
            instructions: """
            あなたは学習カード生成の専門家です。
            与えられた記事から、記憶に残りやすいQ&Aカードを生成してください。
            - 質問は読んで意味が分かる自己完結したものにする
            - 答えは簡潔に、キーワードを明確に含める
            - 3つの候補は記事の異なる要点をカバーする
            """
        )

        let prompt = "以下の記事から学習カードを3つ作成してください:\n\n\(article.bodyText)"

        let response = try await session.respond(
            to: prompt,
            generating: FlashcardCandidates.self
        )
        return response.content.cards
    }
}
