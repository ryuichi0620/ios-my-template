import Foundation

final class SharedStore: Sendable {
    static let shared = SharedStore()

    private let suiteName = "group.com.egoshi.ArticleFlash"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    func savePendingCard(_ card: FlashcardCandidate, sourceURL: String, sourceTitle: String) {
        let data = PendingCard(
            question: card.question,
            answer: card.answer,
            tags: card.tags,
            sourceURL: sourceURL,
            sourceTitle: sourceTitle,
            createdAt: Date()
        )

        var pending = loadPendingCards()
        pending.append(data)

        if let encoded = try? JSONEncoder().encode(pending) {
            defaults?.set(encoded, forKey: "pendingCards")
        }
    }

    func loadPendingCards() -> [PendingCard] {
        guard let data = defaults?.data(forKey: "pendingCards"),
              let cards = try? JSONDecoder().decode([PendingCard].self, from: data) else {
            return []
        }
        return cards
    }

    func clearPendingCards() {
        defaults?.removeObject(forKey: "pendingCards")
    }
}

struct PendingCard: Codable, Sendable {
    let question: String
    let answer: String
    let tags: [String]
    let sourceURL: String
    let sourceTitle: String
    let createdAt: Date
}
