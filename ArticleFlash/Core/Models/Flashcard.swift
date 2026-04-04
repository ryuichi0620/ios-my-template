import Foundation
import SwiftData
import FoundationModels

@Generable
struct FlashcardCandidate: Sendable {
    @Guide(description: "記事の核心を1文で問う質問。答えを知らない人が読んで意味が分かるもの")
    var question: String

    @Guide(description: "30文字以内の簡潔な答え。キーワードが明確に含まれるもの")
    var answer: String

    @Guide(description: "関連キーワードを1〜3個")
    var tags: [String]
}

extension FlashcardCandidate: Identifiable {
    var id: String { question }
}

@Generable
struct FlashcardCandidates: Sendable {
    @Guide(description: "記事の異なる要点を問う3つのカード候補")
    var cards: [FlashcardCandidate]
}

@Model
final class Flashcard {
    var id: UUID
    var question: String
    var answer: String
    var tags: [String]
    var sourceURL: String
    var sourceTitle: String
    var createdAt: Date
    var nextReviewDate: Date?
    var isReviewed: Bool
    var correctCount: Int
    var incorrectCount: Int

    init(
        question: String,
        answer: String,
        tags: [String],
        sourceURL: String,
        sourceTitle: String
    ) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.tags = tags
        self.sourceURL = sourceURL
        self.sourceTitle = sourceTitle
        self.createdAt = Date()
        self.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        self.isReviewed = false
        self.correctCount = 0
        self.incorrectCount = 0
    }

    convenience init(from candidate: FlashcardCandidate, sourceURL: String, sourceTitle: String) {
        self.init(
            question: candidate.question,
            answer: candidate.answer,
            tags: candidate.tags,
            sourceURL: sourceURL,
            sourceTitle: sourceTitle
        )
    }
}
