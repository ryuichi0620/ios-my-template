import Foundation
import FoundationModels

/// 長文記事をFoundation Modelsのトークン制限内に収めるサービス
///
/// 戦略:
///   1. 短い記事 → そのまま
///   2. 中程度 → ヒューリスティック抽出（見出し + 各段落の先頭文）
///   3. 長文 → ヒューリスティック抽出 + AI要約
struct ArticleSummarizer {

    @Generable
    struct Summary: Sendable {
        @Guide(description: "要点を箇条書きで5〜8個")
        var keyPoints: [String]
    }

    // カード生成時のトークン予算:
    //   4096 - instructions(~100) - schema(~200) - output(~600) = ~3,100トークン
    //   日本語 1文字 ≈ 1.5トークン → ~2,000文字
    //   安全マージンを取って 600文字
    private static let targetChars = 600

    /// 記事本文をカード生成に適した長さに圧縮する
    static func condense(_ text: String, title: String) async throws -> String {
        // Step 1: 短ければそのまま
        if text.count <= targetChars {
            return text
        }

        // Step 2: ヒューリスティックで重要文を抽出
        let extracted = extractKeySentences(from: text, limit: targetChars)
        if extracted.count <= targetChars {
            return extracted
        }

        // Step 3: まだ長い場合、AI非対応なら先頭切り詰め
        guard SystemLanguageModel.default.isAvailable else {
            return String(extracted.prefix(targetChars))
        }

        // Step 4: AIで要約（抽出済みテキストを入力するので短い）
        return try await aiSummarize(extracted, title: title)
    }

    // MARK: - ヒューリスティック抽出

    /// 見出し + 各段落の先頭文を抽出
    private static func extractKeySentences(from text: String, limit: Int) -> String {
        let paragraphs = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var result: [String] = []
        var totalLength = 0

        for paragraph in paragraphs {
            // 見出し（短くて句点なし）
            if paragraph.count < 60, !paragraph.contains("。") {
                result.append(paragraph)
                totalLength += paragraph.count
            } else {
                // 段落の先頭文を抽出
                if let first = firstSentence(of: paragraph) {
                    result.append(first)
                    totalLength += first.count
                }
            }

            if totalLength > limit * 2 { break }
        }

        let joined = result.joined(separator: "\n")

        // まだ長ければ先頭から切る
        if joined.count > limit * 2 {
            return String(joined.prefix(limit * 2))
        }
        return joined
    }

    /// 日本語の先頭文を取得
    private static func firstSentence(of text: String) -> String? {
        var sentence = ""
        for char in text {
            sentence.append(char)
            if char == "。" || char == "！" || char == "？" {
                return sentence
            }
            if sentence.count > 100 { break }
        }
        return sentence.isEmpty ? nil : sentence
    }

    // MARK: - AI要約

    private static func aiSummarize(_ text: String, title: String) async throws -> String {
        // AI入力を安全な長さに制限（要約のためのAI呼び出し自体が制限超過しないように）
        let safeInput = String(text.prefix(800))

        let session = LanguageModelSession(
            instructions: "テキストの要点を日本語で5〜8個、各1文で抽出"
        )

        let response = try await session.respond(
            to: safeInput,
            generating: Summary.self
        )

        let points = response.content.keyPoints
            .prefix(8)
            .map { "・\($0)" }
            .joined(separator: "\n")

        return "【\(title)】\n\(points)"
    }
}
