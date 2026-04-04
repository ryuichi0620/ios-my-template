# ios-template

iOSアプリ開発のためのClaude Code設定テンプレートリポジトリ。

Agents、Skills、Commands、権限設定などのナレッジを蓄積し、新規iOSプロジェクトに即座に適用できるテンプレートとして使用します。

## 構成

```
.claude/
├── agents/          # 専門エージェント定義
│   ├── ios-architect.md
│   ├── ios-researcher.md
│   ├── ios-tester.md
│   ├── swift-reviewer.md
│   └── swiftui-specialist.md
├── commands/        # スラッシュコマンド
│   ├── build.md
│   ├── create-view.md
│   ├── fix-build.md
│   ├── review.md
│   ├── run-app.md
│   ├── swift-style.md
│   └── test.md
├── skills/          # 拡張スキル
│   ├── app-store-changelog
│   ├── github-issue-fix
│   ├── ios-debugger
│   ├── ios-testing
│   ├── native-profiling
│   ├── swift-concurrency
│   ├── swiftui-components
│   ├── swiftui-liquid-glass
│   ├── swiftui-performance
│   ├── swiftui-ui-patterns
│   └── swiftui-view-refactor
├── settings.local.json  # 権限設定
.devcontainer/           # Dev Container設定
```

## 使い方

1. このリポジトリをクローンまたはコピー
2. `.claude/` ディレクトリを対象のiOSプロジェクトに配置
3. 必要に応じて `settings.local.json` の権限設定を調整

## 主な機能

### Agents
- **ios-architect** - アーキテクチャ設計・レビュー
- **ios-researcher** - iOS API・フレームワークの調査
- **ios-tester** - テスト作成・実行
- **swift-reviewer** - Swiftコードレビュー
- **swiftui-specialist** - SwiftUI実装

### Commands
- `/build` - プロジェクトビルド
- `/create-view` - SwiftUIビュー作成
- `/fix-build` - ビルドエラー修正
- `/review` - コードレビュー
- `/run-app` - シミュレータ実行
- `/swift-style` - スタイルチェック
- `/test` - テスト実行

### Skills
SwiftUI、Swift Concurrency、パフォーマンス最適化、App Storeリリースノート生成など、iOS開発に特化したスキルセット。
