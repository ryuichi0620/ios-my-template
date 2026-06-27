import Foundation
import FoundationModels

@Generable
struct JudgeResult: Sendable {
    @Guide(description: "正解ならtrue。キーワードや概念が含まれていれば表現違いでも正解")
    var isCorrect: Bool

    @Guide(description: "判定理由を1文で具体的に")
    var reason: String
}

struct ReviewJudge {

    private static let instructions = """
    回答の正誤を判定。日本語で出力。
    基準: キーワード・概念が含まれれば表現違いでも正解。部分的でも核心が欠ければ不正解。
    例: 「ビュー内部所有」≒「ビュー自身が持つ」→正解 / 「4096」≒「約4000」→正解
    """

    static func judge(
        question: String,
        correctAnswer: String,
        userAnswer: String
    ) async throws -> JudgeResult {
        guard SystemLanguageModel.default.isAvailable else {
            return fallbackJudge(correctAnswer: correctAnswer, userAnswer: userAnswer)
        }

        let session = LanguageModelSession(instructions: instructions)

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

    private static func fallbackJudge(correctAnswer: String, userAnswer: String) -> JudgeResult {
        let normalizedAnswer = correctAnswer.lowercased()
            .replacingOccurrences(of: " ", with: "")
        let normalizedUser = userAnswer.lowercased()
            .replacingOccurrences(of: " ", with: "")

        let keywords = normalizedAnswer.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
        let matchCount = keywords.filter { normalizedUser.contains($0) }.count
        let matchRatio = keywords.isEmpty ? 0.0 : Double(matchCount) / Double(keywords.count)

        let isCorrect = matchRatio >= 0.4 || normalizedUser.contains(normalizedAnswer) || normalizedAnswer.contains(normalizedUser)

        return JudgeResult(
            isCorrect: isCorrect,
            reason: isCorrect ? "キーワードが一致" : "主要なキーワードが不足"
        )
    }
}
