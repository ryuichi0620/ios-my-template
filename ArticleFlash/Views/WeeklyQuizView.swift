import SwiftUI
import SwiftData

struct WeeklyQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flashcard.createdAt, order: .reverse) private var allCards: [Flashcard]
    @Query(
        filter: #Predicate<ReviewSession> { $0.isWeeklyQuiz },
        sort: \ReviewSession.date,
        order: .reverse
    ) private var quizSessions: [ReviewSession]

    @State private var showingQuiz = false

    private var thisWeekCards: [Flashcard] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return allCards.filter { $0.createdAt >= startOfWeek }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingQuiz {
                    QuizSessionView(
                        cards: thisWeekCards,
                        onComplete: { correct, total, xp in
                            let session = ReviewSession(
                                totalCards: total,
                                correctCards: correct,
                                xpEarned: xp,
                                isWeeklyQuiz: true
                            )
                            modelContext.insert(session)
                            showingQuiz = false
                        }
                    )
                } else {
                    quizHomeView
                }
            }
            .navigationTitle("週次クイズ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var quizHomeView: some View {
        VStack(spacing: 24) {
            Spacer()

            if let lastQuiz = quizSessions.first {
                // Show last quiz result
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color(uiColor: .systemGray5), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: CGFloat(lastQuiz.scorePercentage) / 100)
                            .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        Text("\(lastQuiz.scorePercentage)%")
                            .font(.system(size: 32, weight: .bold))
                    }

                    Text("今週のスコア")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("\(lastQuiz.correctCards) / \(lastQuiz.totalCards) 正解")
                        .font(.headline)

                    HStack(spacing: 4) {
                        Text("⚡")
                        Text("+\(lastQuiz.xpEarned) XP 獲得")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.xpColor.opacity(0.15))
                    .clipShape(Capsule())
                }

                // Weekly history chart
                weeklyChart
            } else {
                VStack(spacing: 12) {
                    Text("🧠")
                        .font(.system(size: 64))

                    Text("今週のカード: \(thisWeekCards.count)枚")
                        .font(.headline)

                    Text("毎週日曜日に週次クイズが届きます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                showingQuiz = true
            } label: {
                Text("クイズを始める")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(thisWeekCards.isEmpty)
            .padding(20)
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間推移")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(alignment: .bottom, spacing: 16) {
                ForEach(Array(quizSessions.prefix(4).reversed().enumerated()), id: \.offset) { index, session in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == 3 ? AppTheme.accent : AppTheme.accent.opacity(0.4))
                            .frame(width: 32, height: CGFloat(session.scorePercentage) * 0.6)

                        Text(index == 3 ? "今週" : "\(3 - index)週前")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
    }
}

// MARK: - Quiz Session View

struct QuizSessionView: View {
    let cards: [Flashcard]
    let onComplete: (Int, Int, Int) -> Void

    @State private var shuffledCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var judgeResult: JudgeResult?
    @State private var isJudging = false
    @State private var correctCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.accent)
                            .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(shuffledCards.count), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(currentIndex + 1) / \(shuffledCards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if let card = shuffledCards[safe: currentIndex] {
                if judgeResult != nil {
                    quizResultView(card: card)
                } else {
                    quizInputView(card: card)
                }
            }
        }
        .onAppear {
            shuffledCards = cards.shuffled()
        }
    }

    private func quizInputView(card: Flashcard) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(AppTheme.primaryGradient)
                        .frame(height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(card.question)
                        .font(.title3)
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

    private func quizResultView(card: Flashcard) -> some View {
        VStack(spacing: 0) {
            Spacer()

            if let result = judgeResult {
                VStack(spacing: 8) {
                    Text(result.isCorrect ? "🎉" : "💪")
                        .font(.system(size: 48))
                    Text(result.isCorrect ? "正解！" : "おしい！")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Divider().padding(.vertical, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text(card.question)
                        .font(.subheadline)
                        .fontWeight(.semibold)

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
                Text(currentIndex < shuffledCards.count - 1 ? "次の問題 →" : "結果を見る")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .padding(20)
        }
    }

    private func submitAnswer(card: Flashcard) async {
        isJudging = true
        do {
            let result = try await ReviewJudge.judge(
                question: card.question,
                correctAnswer: card.answer,
                userAnswer: userAnswer
            )
            judgeResult = result
            if result.isCorrect { correctCount += 1 }
        } catch {
            let isCorrect = card.answer.lowercased().contains(userAnswer.lowercased())
            judgeResult = JudgeResult(isCorrect: isCorrect, reason: "")
            if isCorrect { correctCount += 1 }
        }
        isJudging = false
    }

    private func moveToNext() {
        if currentIndex < shuffledCards.count - 1 {
            currentIndex += 1
            userAnswer = ""
            judgeResult = nil
        } else {
            let xp = correctCount * 10
            onComplete(correctCount, shuffledCards.count, xp)
        }
    }
}

// MARK: - Array Extension

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
