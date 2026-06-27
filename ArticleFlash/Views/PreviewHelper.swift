import SwiftUI

struct ScreenshotGalleryView: View {
    @State private var currentScreen = 0

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    screenButton("Home Empty", index: 0)
                    screenButton("Home Active", index: 1)
                    screenButton("Review Input", index: 2)
                    screenButton("Review Correct", index: 3)
                    screenButton("Review Incorrect", index: 4)
                    screenButton("Review Complete", index: 5)
                    screenButton("Quiz Input", index: 6)
                    screenButton("Quiz Result", index: 7)
                    screenButton("Settings", index: 8)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)

            Group {
                switch currentScreen {
                case 0: MockHomeEmptyView()
                case 1: MockHomeActiveView()
                case 2: MockReviewInputView()
                case 3: MockReviewCorrectView()
                case 4: MockReviewIncorrectView()
                case 5: MockReviewCompleteView()
                case 6: MockQuizInputView()
                case 7: MockQuizResultView()
                case 8: SettingsView()
                default: EmptyView()
                }
            }
        }
    }

    private func screenButton(_ title: String, index: Int) -> some View {
        Button(title) { currentScreen = index }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(currentScreen == index ? AnyShapeStyle(AppTheme.accent) : AnyShapeStyle(AppTheme.surfaceElevated))
            .foregroundStyle(currentScreen == index ? .white : .primary)
            .clipShape(Capsule())
    }
}

// MARK: - Mock Home Empty

struct MockHomeEmptyView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    emptyReviewCard
                    MockWeeklySection()
                    MockRecentCardsSection()
                }
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("ArticleFlash").font(.system(size: 28, weight: .bold))
                }
                ToolbarItem(placement: .topBarTrailing) { MockXPBadge(xp: 240) }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyReviewCard: some View {
        VStack(spacing: 12) {
            Text("今日の復習はありません")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.onGradientText)
            Text("お疲れ様でした。\n明日も新しい記事を元に学習を続けましょう")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.onGradientText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(AppTheme.emptyGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.brandPrimary.opacity(0.15), radius: 12, y: 8)
        .padding(.horizontal, 20)
    }
}

// MARK: - Mock Home Active

struct MockHomeActiveView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    activeReviewCard
                    MockWeeklySection()
                    MockRecentCardsSection()
                }
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("ArticleFlash").font(.system(size: 28, weight: .bold))
                }
                ToolbarItem(placement: .topBarTrailing) { MockXPBadge(xp: 240) }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var activeReviewCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("今日の復習")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.onGradientText)
                Spacer()
                Text("🔥 7日連続")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.onGradientText)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(AppTheme.onGradientText.opacity(0.2))
                    .clipShape(Capsule())
            }
            Text("3枚")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(AppTheme.onGradientText)
            Text("未復習のカードがあります")
                .font(.system(size: 14)).foregroundStyle(AppTheme.onGradientText)
            Spacer().frame(height: 4)
            Text("復習を始める →")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.brandPrimary)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(AppTheme.buttonOnGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(24)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.brandPrimary.opacity(0.3), radius: 12, y: 8)
        .padding(.horizontal, 20)
    }
}

// MARK: - Mock Review Screens

struct MockReviewInputView: View {
    var body: some View {
        VStack(spacing: 0) {
            MockReviewHeader(current: 0, total: 3, label: "1/3")
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle().fill(AppTheme.primaryGradient).frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text("SwiftUIの@Stateと\n@Bindingの根本的な\n違いは？")
                        .font(.system(size: 28, weight: .bold))
                }
                .padding(24)
                .background(AppTheme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                Divider()
                Text("あなたの回答").font(.caption).foregroundStyle(.secondary)
                Text("回答を入力…").font(.body).foregroundStyle(.tertiary)
                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 20)
            Spacer()
            MockBottomButton(title: "回答する")
        }
    }
}

struct MockReviewCorrectView: View {
    var body: some View {
        VStack(spacing: 0) {
            MockReviewHeader(current: 0, total: 3, label: "1/3")
            Spacer()
            VStack(spacing: 8) {
                Text("🎉").font(.system(size: 48))
                Text("正解！").font(.system(size: 28, weight: .bold))
                Text("+10 XP").font(.subheadline).foregroundStyle(AppTheme.xpColor)
            }
            Divider().padding(.vertical, 16).padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 16) {
                Text("SwiftUIの@Stateと@Bindingの根本的な違いは？")
                    .font(.subheadline).fontWeight(.semibold)
                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答").font(.caption2).foregroundStyle(.secondary)
                    Text("@Stateはビュー自身が持つ状態、@Bindingは親から渡される")
                        .font(.subheadline).foregroundStyle(AppTheme.correctGreen)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("模範解答").font(.caption2).foregroundStyle(.secondary)
                    Text("@Stateはビュー内部所有、@Bindingは親から渡される参照").font(.subheadline)
                }
            }.padding(.horizontal, 20)
            Spacer()
            MockBottomButton(title: "次のカード →")
        }
    }
}

struct MockReviewIncorrectView: View {
    var body: some View {
        VStack(spacing: 0) {
            MockReviewHeader(current: 1, total: 3, label: "2/3")
            Spacer()
            VStack(spacing: 8) {
                Text("💪").font(.system(size: 48))
                Text("おしい！").font(.system(size: 28, weight: .bold))
                Text("もう一度復習しましょう").font(.subheadline).foregroundStyle(.secondary)
            }
            Divider().padding(.vertical, 16).padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 16) {
                Text("@Bindingを使うべき具体的なユースケースは？")
                    .font(.subheadline).fontWeight(.semibold)
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答").font(.caption2).foregroundStyle(.secondary)
                    Text("データの永続化が必要なとき")
                        .font(.subheadline).foregroundStyle(AppTheme.incorrectOrange)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("模範解答").font(.caption2).foregroundStyle(.secondary)
                    Text("子ビューが親の状態を直接変更する必要がある場合").font(.subheadline)
                }
            }.padding(.horizontal, 20)
            Spacer()
            MockBottomButton(title: "次のカード →")
        }
    }
}

struct MockReviewCompleteView: View {
    var body: some View {
        VStack(spacing: 0) {
            MockReviewHeader(current: 2, total: 3, label: "3/3")
            Spacer()
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(AppTheme.accent.opacity(0.1)).frame(width: 80, height: 80)
                    Text("🏆").font(.system(size: 36))
                }
                Text("今日の復習完了！").font(.system(size: 28, weight: .bold))
                Text("2 / 3 正解").font(.headline)
                HStack(spacing: 4) {
                    Text("⚡"); Text("+20 XP 獲得").fontWeight(.semibold)
                }
                .font(.subheadline).padding(.horizontal, 16).padding(.vertical, 8)
                .background(AppTheme.xpColor.opacity(0.15)).clipShape(Capsule())
            }
            Spacer()
            MockBottomButton(title: "ホームに戻る")
        }
    }
}

// MARK: - Mock Quiz Screens

struct MockQuizInputView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("✕").font(.title2)
                Spacer()
                Text("週次クイズ").font(.system(size: 17, weight: .semibold))
                Spacer()
                Spacer().frame(width: 21)
            }
            .padding(.horizontal, 20).padding(.top, 12)

            MockProgressBar(current: 5, total: 12)

            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle().fill(AppTheme.primaryGradient).frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text("Foundation Modelsの\nトークン上限は？")
                        .font(.system(size: 22, weight: .bold))
                }
                .padding(24).background(AppTheme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                Divider()
                Text("あなたの回答").font(.caption).foregroundStyle(.secondary)
                Text("回答を入力…").font(.body).foregroundStyle(.tertiary)
                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 20)
            Spacer()
            MockBottomButton(title: "回答する")
        }
    }
}

struct MockQuizResultView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                ZStack {
                    Circle().stroke(AppTheme.surfaceElevated, lineWidth: 8).frame(width: 120, height: 120)
                    Circle().trim(from: 0, to: 0.75)
                        .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120).rotationEffect(.degrees(-90))
                    Text("75%").font(.system(size: 32, weight: .bold))
                }
                Text("今週のスコア").font(.system(size: 20, weight: .semibold))
                Text("9 / 12 正解").font(.headline)
                HStack(spacing: 4) {
                    Text("⚡"); Text("+90 XP 獲得").fontWeight(.semibold)
                }
                .font(.subheadline).padding(.horizontal, 16).padding(.vertical, 8)
                .background(AppTheme.xpColor.opacity(0.15)).clipShape(Capsule())
            }
            Spacer().frame(height: 20)
            MockWeeklyChart()
            Spacer()
            MockBottomButton(title: "ホームに戻る")
        }
    }
}

// MARK: - Shared Components

struct MockXPBadge: View {
    let xp: Int
    var body: some View {
        HStack(spacing: 4) {
            Text("⚡").font(.system(size: 14))
            Text("\(xp) XP")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.brandPrimary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(AppTheme.xpBadgeBackground).clipShape(Capsule())
    }
}

struct MockReviewHeader: View {
    let current: Int
    let total: Int
    let label: String
    var body: some View {
        HStack {
            Text("✕").font(.title2)
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { index in
                    if index == current {
                        Capsule().fill(AppTheme.accent).frame(width: 24, height: 8)
                    } else {
                        Circle()
                            .fill(index < current ? AppTheme.accent : AppTheme.labelTertiary)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            Spacer()
            Text(label).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
    }
}

struct MockBottomButton: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppTheme.onGradientText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(20)
    }
}

struct MockProgressBar: View {
    let current: Int
    let total: Int
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.surfaceElevated).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.accent)
                        .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 8)
                }
            }
            .frame(height: 8)
            Text("\(current) / \(total)").font(.caption).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20).padding(.top, 12)
    }
}

struct MockWeeklySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今週の学習").font(.system(size: 20, weight: .bold))
                Spacer()
                Text("4記事 12枚").font(.system(size: 14)).foregroundStyle(AppTheme.labelSecondary)
            }

            HStack(spacing: 0) {
                MockCalendarDay(label: "月", count: 3)
                MockCalendarDay(label: "火", count: 0)
                MockCalendarDay(label: "水", count: 2)
                MockCalendarDay(label: "木", count: 4)
                MockCalendarDay(label: "金", count: 0)
                MockCalendarDay(label: "土", count: 0)
                MockCalendarDay(label: "日", count: 0)
            }
            .padding(.horizontal, 12).padding(.vertical, 14)
            .background(AppTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }
}

struct MockCalendarDay: View {
    let label: String
    let count: Int

    private var fillColor: Color {
        if count == 0 { return AppTheme.calendarEmpty }
        if count >= 4 { return AppTheme.brandPrimary }
        if count >= 3 { return AppTheme.brandPrimary.opacity(0.8) }
        return AppTheme.brandPrimary.opacity(0.6)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.labelTertiary)
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(fillColor).frame(width: 32, height: 32)
                if count > 0 {
                    Text("\(count)").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppTheme.onGradientText)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MockRecentCardsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近のカード").font(.system(size: 20, weight: .bold)).padding(.horizontal, 20)
            FlashcardCardView(
                question: "SwiftUIの@Stateと@Bindingの根本的な違いは？",
                answer: "@Stateはビュー内部所有、@Bindingは親から渡される参照",
                tags: ["SwiftUI", "iOS"], date: "3/28"
            ).padding(.horizontal, 20)
            FlashcardCardView(
                question: "Foundation Modelsのトークン上限は？",
                answer: "4,096トークン",
                tags: ["AI", "iOS"], date: "3/27"
            ).padding(.horizontal, 20)
        }
    }
}

struct MockWeeklyChart: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間推移").font(.subheadline).fontWeight(.semibold)
            HStack(alignment: .bottom, spacing: 16) {
                MockChartBar(height: 48, label: "1週前", isActive: false)
                MockChartBar(height: 56, label: "2週前", isActive: false)
                MockChartBar(height: 52, label: "3週前", isActive: false)
                MockChartBar(height: 60, label: "今週", isActive: true)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
    }
}

struct MockChartBar: View {
    let height: CGFloat
    let label: String
    let isActive: Bool
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? AppTheme.accent : AppTheme.accent.opacity(0.4))
                .frame(width: 32, height: height)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
