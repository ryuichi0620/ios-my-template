import SwiftUI

enum AppTheme {
    // Brand color: #7b5ea7
    static let brandPrimary = Color(red: 123/255, green: 94/255, blue: 167/255)

    // Primary gradient (review card)
    static let gradientStart = Color(red: 97/255, green: 69/255, blue: 148/255)
    static let gradientEnd = Color(red: 184/255, green: 107/255, blue: 153/255)

    static let primaryGradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Empty state gradient (lighter, with opacity)
    static let emptyGradientStart = Color(red: 133/255, green: 107/255, blue: 173/255).opacity(0.6)
    static let emptyGradientEnd = Color(red: 191/255, green: 133/255, blue: 166/255).opacity(0.6)

    static let emptyGradient = LinearGradient(
        colors: [
            Color(red: 133/255, green: 107/255, blue: 173/255).opacity(0.6),
            Color(red: 191/255, green: 133/255, blue: 166/255).opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Surface colors
    static let surfaceElevated = Color(red: 242/255, green: 242/255, blue: 247/255)

    // Card colors
    static let cardBackground = Color(red: 242/255, green: 242/255, blue: 247/255)

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
    static let calendarEmpty = Color(red: 235/255, green: 235/255, blue: 240/255)

    // Label colors
    static let labelSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    static let labelTertiary = Color(red: 199/255, green: 199/255, blue: 204/255)
}
