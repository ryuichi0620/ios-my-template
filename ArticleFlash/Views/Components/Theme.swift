import SwiftUI

enum AppTheme {
    // Brand color: #7b5ea7
    static let brandPrimary = Color(red: 123/255, green: 94/255, blue: 167/255)

    // Primary gradient (review card) — 背景の上に白テキストを載せるので固定色でOK
    static let gradientStart = Color(red: 97/255, green: 69/255, blue: 148/255)
    static let gradientEnd = Color(red: 184/255, green: 107/255, blue: 153/255)

    static let primaryGradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Empty state gradient — ダークモードでは少し明るく
    static let emptyGradient = LinearGradient(
        colors: [
            Color(red: 133/255, green: 107/255, blue: 173/255).opacity(0.6),
            Color(red: 191/255, green: 133/255, blue: 166/255).opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Surface colors — システムカラーに置き換え
    static let surfaceElevated = Color(uiColor: .secondarySystemBackground)

    // Card colors
    static let cardBackground = Color(uiColor: .secondarySystemBackground)

    // Accent
    static let accent = brandPrimary
    static let correctGreen = Color.green
    static let incorrectOrange = Color.orange

    // Tag
    static let tagBackground = brandPrimary.opacity(0.1)
    static let tagText = brandPrimary

    // XP
    static let xpBadgeBackground = brandPrimary.opacity(0.1)
    static let xpColor = Color.yellow

    // Calendar
    static let calendarEmpty = Color(uiColor: .quaternarySystemFill)

    // Label colors — システムカラーに置き換え
    static let labelSecondary = Color(uiColor: .secondaryLabel)
    static let labelTertiary = Color(uiColor: .tertiaryLabel)

    // On-gradient text（グラデーション背景の上に載せるテキスト。常に白）
    static let onGradientText = Color.white

    // Button on gradient（グラデーション上のボタン背景）
    static let buttonOnGradient = Color(uiColor: .systemBackground)
}
