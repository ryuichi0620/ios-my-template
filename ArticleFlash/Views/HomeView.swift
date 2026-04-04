import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flashcard.createdAt, order: .reverse) private var allCards: [Flashcard]
    @Query(sort: \ReviewSession.date, order: .reverse) private var sessions: [ReviewSession]
    @State private var showingReview = false
    @State private var showingSettings = false

    private var pendingReviewCards: [Flashcard] {
        let now = Date()
        return allCards.filter { card in
            guard let reviewDate = card.nextReviewDate else { return false }
            return reviewDate <= now && !card.isReviewed
        }
    }

    private var totalXP: Int {
        sessions.reduce(0) { $0 + $1.xpEarned }
    }

    private var streakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasSession = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: checkDate)
            }
            if hasSession {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    private var thisWeekCards: [Flashcard] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return allCards.filter { $0.createdAt >= startOfWeek }
    }

    private var thisWeekArticleCount: Int {
        Set(thisWeekCards.map(\.sourceURL)).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    reviewCard
                    weeklyLearning
                    recentCards
                }
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("ArticleFlash")
                        .font(.system(size: 28, weight: .bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    xpBadge
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingReview) {
                ReviewView(cards: pendingReviewCards)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - XP Badge

    private var xpBadge: some View {
        HStack(spacing: 4) {
            Text("⚡")
                .font(.system(size: 14))
            Text("\(totalXP) XP")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.brandPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.xpBadgeBackground)
        .clipShape(Capsule())
    }

    // MARK: - Review Card

    @ViewBuilder
    private var reviewCard: some View {
        if pendingReviewCards.isEmpty {
            // Empty state: gradient background + white text
            VStack(spacing: 12) {
                Text("今日の復習はありません")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text("お疲れ様でした。\n明日も新しい記事を元に学習を続けましょう")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .background(AppTheme.emptyGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: AppTheme.brandPrimary.opacity(0.15), radius: 12, y: 8)
            .padding(.horizontal, 20)
        } else {
            // Active review card: deep purple gradient
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("今日の復習")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    if streakDays > 0 {
                        Text("🔥 \(streakDays)日連続")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }

                Text("\(pendingReviewCards.count)枚")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)

                Text("未復習のカードがあります")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                Spacer().frame(height: 4)

                Button {
                    showingReview = true
                } label: {
                    Text("復習を始める →")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(AppTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: AppTheme.brandPrimary.opacity(0.3), radius: 12, y: 8)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Weekly Learning

    private var weeklyLearning: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今週の学習")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Text("\(thisWeekArticleCount)記事 \(thisWeekCards.count)枚")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.labelSecondary)
            }

            weeklyCalendar
        }
        .padding(.horizontal, 20)
    }

    private var weeklyCalendar: some View {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 2), to: today)!
        let days = ["月", "火", "水", "木", "金", "土", "日"]

        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let date = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
                let cardsOnDay = allCards.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count

                VStack(spacing: 6) {
                    Text(days[index])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.labelTertiary)

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(calendarCircleColor(count: cardsOnDay))
                            .frame(width: 32, height: 32)

                        if cardsOnDay > 0 {
                            Text("\(cardsOnDay)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(AppTheme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func calendarCircleColor(count: Int) -> Color {
        switch count {
        case 0: return AppTheme.calendarEmpty
        case 1...2: return AppTheme.brandPrimary.opacity(0.6)
        case 3: return AppTheme.brandPrimary.opacity(0.8)
        default: return AppTheme.brandPrimary
        }
    }

    // MARK: - Recent Cards

    private var recentCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近のカード")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 20)

            LazyVStack(spacing: 12) {
                ForEach(allCards.prefix(5)) { card in
                    FlashcardCardView(
                        question: card.question,
                        answer: card.answer,
                        tags: card.tags,
                        date: {
                            let f = DateFormatter()
                            f.dateFormat = "M/d"
                            return f.string(from: card.createdAt)
                        }()
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
