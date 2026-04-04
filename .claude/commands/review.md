---
description: 変更されたSwiftコードをレビュー
---

変更されたコードをレビューしてください。

1. `git diff` で変更を確認
2. 以下の観点でレビュー:
   - **コード品質**: Swift API Design Guidelines準拠、命名、アクセス制御
   - **SwiftUI**: @Observable使用、MVパターン、View粒度
   - **並行性**: actor isolation、Sendable、data race
   - **パフォーマンス**: 不要な再描画、メモリリーク
   - **セキュリティ**: ハードコードされた秘密情報
3. 各issueについて 重大度 / ファイル:行 / 問題 / 修正案 を提示
