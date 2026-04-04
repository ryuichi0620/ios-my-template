import Foundation
import FoundationModels

@Generable
struct JudgeResult: Sendable {
    @Guide(description: "ユーザーの回答が正解かどうか。意味的に同じなら正解とする")
    var isCorrect: Bool

    @Guide(description: "判定の簡潔な理由（1文）")
    var reason: String
}

struct ReviewJudge {
    static func judge(
        question: String,
        correctAnswer: String,
        userAnswer: String
    ) async throws -> JudgeResult {
        let session = LanguageModelSession(
            instructions: """
            あなたは学習カードの回答を判定する専門家です。
            ユーザーの回答が模範解答と意味的に同じなら正解と判定してください。
            完全一致は必要ありません。キーポイントが含まれていれば正解です。
            """
        )

        let prompt = """
        質問: \(question)
        模範解答: \(correctAnswer)
        ユーザーの回答: \(userAnswer)

        この回答は正解ですか？
        """

        let response = try await session.respond(
            to: prompt,
            generating: JudgeResult.self
        )
        return response.content
    }
}
