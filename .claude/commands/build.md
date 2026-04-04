---
description: iOSプロジェクトをビルド
---

プロジェクトをビルドしてください。

1. `.xcworkspace` または `.xcodeproj` を検索
2. 利用可能なスキームを確認: `xcodebuild -list`
3. 起動中のシミュレータを確認: `xcrun simctl list devices | grep Booted`
4. ビルドを実行:
   ```
   xcodebuild -scheme <scheme> -destination 'platform=iOS Simulator,name=<device>' build
   ```
5. ビルドエラーがあれば分析して修正案を提示
