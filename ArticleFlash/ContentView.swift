import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    // Read launch argument for screenshot mode
    private var screenshotScreen: String? {
        if let idx = CommandLine.arguments.firstIndex(of: "-screenshot"),
           idx + 1 < CommandLine.arguments.count {
            return CommandLine.arguments[idx + 1]
        }
        return nil
    }

    enum Tab {
        case home
        case quiz
    }

    var body: some View {
        if let screen = screenshotScreen {
            screenshotView(for: screen)
        } else {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)
                    .tabItem {
                        Label("ホーム", systemImage: "house.fill")
                    }

                WeeklyQuizView()
                    .tag(Tab.quiz)
                    .tabItem {
                        Label("クイズ", systemImage: "brain.head.profile")
                    }
            }
        }
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
