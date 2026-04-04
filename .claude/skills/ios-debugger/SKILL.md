---
name: ios-debugger
description: iOSアプリのビルド、シミュレータ実行、デバッグを支援。ランタイム動作の診断、ログキャプチャ、UI操作に対応。
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
context: fork
---

# iOS Debugger Agent

## Overview

iOSプロジェクトをシミュレータでビルド・実行し、UIを操作し、ログをキャプチャしてデバッグします。

## Prerequisites
- Xcode + コマンドラインツールがインストール済み
- iOSシミュレータが起動済み
- `.xcodeproj` または `.xcworkspace` があるプロジェクト

## Core Workflow

### 1) シミュレータの確認
```bash
xcrun simctl list devices | grep -E "Booted"
# 未起動の場合
xcrun simctl boot "iPhone 16 Pro"
```

### 2) ビルド
```bash
# Workspace
xcodebuild -workspace MyApp.xcworkspace -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Project
xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### 3) インストール & 起動
```bash
# ビルド済みappを検索
find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*Debug-iphonesimulator*" | head -1

# インストール & 起動
xcrun simctl install booted /path/to/MyApp.app
xcrun simctl launch booted com.example.MyApp
```

### 4) ログキャプチャ
```bash
# アプリ固有のログ
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.example.MyApp"' --level debug

# 全ログ
xcrun simctl spawn booted log stream --level debug
```

## UI操作

| タスク | コマンド |
|--------|---------|
| スクリーンショット | `xcrun simctl io booted screenshot screenshot.png` |
| 動画録画 | `xcrun simctl io booted recordVideo video.mp4` |
| URL開く | `xcrun simctl openurl booted "myapp://deeplink"` |
| Push通知送信 | `xcrun simctl push booted com.example.MyApp notification.apns` |

## よく使うコマンド

| タスク | コマンド |
|--------|---------|
| シミュレータ一覧 | `xcrun simctl list devices` |
| 起動 | `xcrun simctl boot "iPhone 16 Pro"` |
| シャットダウン | `xcrun simctl shutdown booted` |
| リセット | `xcrun simctl erase booted` |
| アプリ削除 | `xcrun simctl uninstall booted com.example.app` |
| アプリ終了 | `xcrun simctl terminate booted com.example.app` |
| コンテナ取得 | `xcrun simctl get_app_container booted com.example.app` |

## Troubleshooting
- **ビルド失敗**: `xcodebuild -list` でスキーム名を確認
- **起動失敗**: `defaults read /path/to/MyApp.app/Info.plist CFBundleIdentifier` でバンドルID確認
- **シミュレータ未検出**: `xcrun simctl list devices available`
- **クリーンビルド**: `xcodebuild clean` or DerivedData削除
