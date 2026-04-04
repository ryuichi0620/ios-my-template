import SwiftUI

struct FlashcardCardView: View {
    let question: String
    let answer: String
    let tags: [String]
    var date: String? = nil
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Purple gradient accent (thin top edge via padding top)
            Spacer().frame(height: 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("Q: \(question)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text("A: \(answer)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.labelSecondary)
                    .lineLimit(2)

                HStack {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.tagText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.tagBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Spacer()

                    if let date {
                        Text(date)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.labelTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 12)
        }
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? AppTheme.accent : Color.clear,
                    lineWidth: isSelected ? 2.5 : 0
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
