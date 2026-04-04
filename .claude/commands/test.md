---
description: iOSプロジェクトのテストを実行
---

テストを実行してください。

1. テストターゲットを確認: `xcodebuild -list`
2. 起動中のシミュレータを確認
3. テストを実行:
   ```
   xcodebuild test -scheme <scheme> -destination 'platform=iOS Simulator,name=<device>'
   ```
4. 失敗したテストがあれば原因を分析
5. 修正が必要なら提案してください
