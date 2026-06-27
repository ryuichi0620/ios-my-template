import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home

    // Read launch argument for screenshot mode
    private var screenshotScreen: String? {
        if let idx = CommandLine.arguments.firstIndex(of: "-screenshot"),
           idx + 1 < CommandLine.arguments.count {
            return CommandLine.arguments[idx + 1]
        }
        return nil
    }

    enum AppTab {
        case home
        case quiz
    }

    var body: some View {
        if let screen = screenshotScreen {
            screenshotView(for: screen)
        } else {
            TabView(selection: $selectedTab) {
                SwiftUI.Tab("ホーム", systemImage: "house.fill", value: AppTab.home) {
                    HomeView()
                }
                SwiftUI.Tab("クイズ", systemImage: "brain.head.profile", value: AppTab.quiz) {
                    WeeklyQuizView()
                }
            }
            .tabViewStyle(.tabBarOnly)
            .onAppear { importPendingCards() }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    importPendingCards()
                }
            }
        }
    }

    /// Share Extensionで保存されたカードをSwiftDataに取り込む
    private func importPendingCards() {
        let store = SharedStore.shared
        let pending = store.loadPendingCards()
        guard !pending.isEmpty else { return }

        for card in pending {
            let flashcard = Flashcard(
                question: card.question,
                answer: card.answer,
                tags: card.tags,
                sourceURL: card.sourceURL,
                sourceTitle: card.sourceTitle
            )
            flashcard.createdAt = card.createdAt
            modelContext.insert(flashcard)

            NotificationService.scheduleTomorrowReview(for: flashcard)
        }

        store.clearPendingCards()
    }

    @ViewBuilder
    private func screenshotView(for screen: String) -> some View {
        switch screen {
        case "home_empty": MockHomeEmptyView()
        case "home_active": MockHomeActiveView()
        case "review_input": MockReviewInputView()
        case "review_correct": MockReviewCorrectView()
        case "review_incorrect": MockReviewIncorrectView()
        case "review_complete": MockReviewCompleteView()
        case "quiz_input": MockQuizInputView()
        case "quiz_result": MockQuizResultView()
        case "settings": SettingsView()
        default: ScreenshotGalleryView()
        }
    }
}
