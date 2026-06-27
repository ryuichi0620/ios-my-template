import SwiftUI
import SwiftData

@main
struct ArticleFlashApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Flashcard.self, ReviewSession.self])
    }
}
