---
name: swiftui-ui-patterns
description: SwiftUIのベストプラクティスとパターン。タブ構成、画面設計、コンポーネント設計に対応。
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
context: fork
---

# SwiftUI UI Patterns

## Overview

SwiftUIビューとコンポーネントの構築におけるベストプラクティスとパターンを提供します。

## General Rules

- モダンなSwiftUI state (`@State`, `@Binding`, `@Observable`, `@Environment`) を使用
- 不要なViewModelを避ける — MV (Model-View) パターンを優先
- composition で構築、小さく焦点を絞ったビュー
- `.task` で async/await、明示的な loading/error state
- プロジェクトのフォーマッターとスタイルガイドに従う

## App-Level Setup

```swift
@main
struct MyApp: App {
    @State var client: APIClient = .init()
    @State var router: AppRouter = .init()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    tab.rootView.tag(tab)
                }
            }
            .environment(client)
            .environment(router)
        }
    }
}
```

## Sheet Best Practices
- `.sheet(item:)` を `.sheet(isPresented:)` より優先
- sheet body内で `if let` を避ける
- sheet は自身のアクションを持ち、内部で `dismiss()` を呼ぶ

## Why Not MVVM?

SwiftUIはViewModelなしで設計されている:
- Viewはstruct、軽量で使い捨て
- `@State`, `@Environment`, `@Observable` で全データフローをカバー
- ViewModelは複雑さ、間接参照、認知負荷を追加

**代わりに:**
- ビューは状態の純粋な表現
- ビジネスロジックは `@Environment` 経由で注入するサービス/モデルに
- サービスとモデルをテスト、ビューではなく
- SwiftUI Previews で視覚的回帰テスト
