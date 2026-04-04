import Foundation
import UserNotifications

struct NotificationService {

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleTomorrowReview(for card: Flashcard) {
        let content = UNMutableNotificationContent()
        content.title = "昨日の記憶、まだ残ってる？"
        content.body = card.question
        content.sound = .default
        content.userInfo = ["cardId": card.id.uuidString]

        var components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        components.day = (components.day ?? 0) + 1

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
            ),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "review-\(card.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleWeeklyQuiz() {
        let content = UNMutableNotificationContent()
        content.title = "週次クイズの時間！"
        content.body = "今週学んだことを確認しよう"
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1  // 日曜
        components.hour = 9

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: "weekly-quiz",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
