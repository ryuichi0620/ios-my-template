---
description: iOSシミュレータでアプリを実行
---

アプリをシミュレータで実行してください。

1. プロジェクトをビルド
2. シミュレータが起動していなければ起動: `xcrun simctl boot "iPhone 16 Pro"`
3. アプリをインストール: `xcrun simctl install booted <path-to-app>`
4. アプリを起動: `xcrun simctl launch booted <bundle-id>`
5. ログをキャプチャ: `xcrun simctl spawn booted log stream --predicate 'subsystem == "<bundle-id>"'`
