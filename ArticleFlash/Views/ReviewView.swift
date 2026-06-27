import SwiftUI
import SwiftData

struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let cards: [Flashcard]

    // カードのスナップショット（セッション中に配列が変わらないように）
    @State private var sessionCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var judgeResult: JudgeResult?
    @State private var isJudging = false
    @State private var correctCount = 0
    @State private var totalXP = 0
    @State private var showCompletion = false

    private var currentCard: Flashcard? {
        guard currentIndex < sessionCards.count else { return nil }
        return sessionCards[currentIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if showCompletion {
                    completionView
                } else if let card = currentCard {
                    if judgeResult != nil {
                        resultView(card: card)
                    } else {
                        inputView(card: card)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("✕") { dismiss() }
                        .font(.title2)
                }
                ToolbarItem(placement: .principal) {
                    if !showCompletion {
                        progressIndicator
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !showCompletion {
                        Text("\(currentIndex + 1)/\(sessionCards.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if sessionCards.isEmpty {
                    sessionCards = cards
                }
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<sessionCards.count, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(AppTheme.accent)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(index < currentIndex ? AppTheme.accent : Color(uiColor: .systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Input View

    private func inputView(card: Flashcard) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(AppTheme.primaryGradient)
                        .frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(card.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                }
                .padding(24)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Divider()

                Text("あなたの回答")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("回答を入力…", text: $userAnswer, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }
            .padding(.horizontal, 20)

            Spacer()

            Button {
                Task { await submitAnswer(card: card) }
            } label: {
                Text("回答する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isJudging)
            .padding(20)
        }
    }

    // MARK: - Result View

    private func resultView(card: Flashcard) -> some View {
        VStack(spacing: 0) {
            Spacer()

            if let result = judgeResult {
                VStack(spacing: 8) {
                    Text(result.isCorrect ? "🎉" : "💪")
                        .font(.system(size: 48))

                    Text(result.isCorrect ? "正解！" : "おしい！")
                        .font(.title)
                        .fontWeight(.bold)

                    if result.isCorrect {
                        Text("+10 XP")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.xpColor)
                    } else {
                        Text("もう一度復習しましょう")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()
                    .padding(.vertical, 16)

                VStack(alignment: .leading, spacing: 16) {
                    Text(card.question)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("あなたの回答")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(userAnswer)
                            .font(.subheadline)
                            .foregroundStyle(result.isCorrect ? AppTheme.correctGreen : AppTheme.incorrectOrange)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("模範解答")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(card.answer)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()

            Button {
                moveToNext()
            } label: {
                Text(currentIndex < sessionCards.count - 1 ? "次のカード →" : "結果を見る")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .padding(20)
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Text("🏆")
                        .font(.system(size: 36))
                }

                Text("今日の復習完了！")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(correctCount) / \(sessionCards.count) 正解")
                    .font(.headline)

                HStack(spacing: 4) {
                    Text("⚡")
                    Text("+\(totalXP) XP 獲得")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.xpColor.opacity(0.15))
                .clipShape(Capsule())
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("ホームに戻る")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .padding(20)
        }
    }

    // MARK: - Actions

    private func submitAnswer(card: Flashcard) async {
        isJudging = true
        do {
            let result = try await ReviewJudge.judge(
                question: card.question,
                correctAnswer: card.answer,
                userAnswer: userAnswer
            )
            judgeResult = result

            if result.isCorrect {
                correctCount += 1
                totalXP += 10
                card.isReviewed = true
                card.correctCount += 1
            } else {
                card.incorrectCount += 1
                // Re-schedule for tomorrow
                card.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
            }
        } catch {
            // Fallback: simple string matching
            let isCorrect = card.answer.lowercased().contains(userAnswer.lowercased()) ||
                           userAnswer.lowercased().contains(card.answer.lowercased())
            judgeResult = JudgeResult(isCorrect: isCorrect, reason: "")
            if isCorrect {
                correctCount += 1
                totalXP += 10
                card.isReviewed = true
            }
        }
        isJudging = false
    }

    private func moveToNext() {
        if currentIndex < sessionCards.count - 1 {
            currentIndex += 1
            userAnswer = ""
            judgeResult = nil
        } else {
            // Save session
            let session = ReviewSession(
                totalCards: cards.count,
                correctCards: correctCount,
                xpEarned: totalXP
            )
            modelContext.insert(session)
            showCompletion = true
        }
    }
}
