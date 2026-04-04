---
description: Swiftコードのスタイルチェックとフォーマット
---

Swiftコードのスタイルチェックとフォーマットを実行してください。

1. SwiftLint がインストールされているか確認: `which swiftlint`
2. SwiftFormat がインストールされているか確認: `which swiftformat`
3. 変更されたファイルを特定: `git diff --name-only --diff-filter=ACMR -- '*.swift'`
4. SwiftFormat を実行 (利用可能な場合):
   ```
   swiftformat <files>
   ```
5. SwiftLint を実行 (利用可能な場合):
   ```
   swiftlint lint --path <files>
   ```
6. 警告/エラーがあれば修正を提案
