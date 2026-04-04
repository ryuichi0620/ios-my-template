import Foundation
import SwiftData

@Model
final class ReviewSession {
    var id: UUID
    var date: Date
    var totalCards: Int
    var correctCards: Int
    var xpEarned: Int
    var isWeeklyQuiz: Bool

    init(totalCards: Int, correctCards: Int, xpEarned: Int, isWeeklyQuiz: Bool = false) {
        self.id = UUID()
        self.date = Date()
        self.totalCards = totalCards
        self.correctCards = correctCards
        self.xpEarned = xpEarned
        self.isWeeklyQuiz = isWeeklyQuiz
    }

    var scorePercentage: Int {
        guard totalCards > 0 else { return 0 }
        return Int(Double(correctCards) / Double(totalCards) * 100)
    }
}
