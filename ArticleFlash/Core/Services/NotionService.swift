import Foundation

actor NotionService {
    static let shared = NotionService()

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "notion_api_key") ?? ""
    }

    private var databaseId: String {
        UserDefaults.standard.string(forKey: "notion_database_id") ?? ""
    }

    var isConnected: Bool {
        !apiKey.isEmpty && !databaseId.isEmpty
    }

    func configure(apiKey: String, databaseId: String) {
        UserDefaults.standard.set(apiKey, forKey: "notion_api_key")
        UserDefaults.standard.set(databaseId, forKey: "notion_database_id")
    }

    func disconnect() {
        UserDefaults.standard.removeObject(forKey: "notion_api_key")
        UserDefaults.standard.removeObject(forKey: "notion_database_id")
    }

    func createPage(card: Flashcard) async throws {
        guard isConnected else { return }

        let payload: [String: Any] = [
            "parent": ["database_id": databaseId],
            "properties": [
                "Q": ["title": [["text": ["content": card.question]]]],
                "A": ["rich_text": [["text": ["content": card.answer]]]],
                "Tags": ["multi_select": card.tags.map { ["name": $0] }],
                "Source URL": ["url": card.sourceURL]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: payload)

        var request = URLRequest(url: URL(string: "https://api.notion.com/v1/pages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NotionError.requestFailed
        }
    }

    enum NotionError: Error, LocalizedError {
        case requestFailed

        var errorDescription: String? {
            switch self {
            case .requestFailed: return "Notion APIリクエストに失敗しました"
            }
        }
    }
}
