import SwiftUI
import SwiftData

@main
struct ArticleFlashApp: App {
    let sharedStore = SharedStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Flashcard.self, ReviewSession.self])
    }
}
