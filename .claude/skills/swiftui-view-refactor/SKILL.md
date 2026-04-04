---
name: swiftui-view-refactor
description: SwiftUIビューのリファクタリング。構造の一貫性、依存性注入、Observation使用の標準化に対応。
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
context: fork
---

# SwiftUI View Refactor

## Overview

SwiftUIビューに一貫した構造と依存パターンを適用します。プロパティ順序、MVパターン、ViewModel管理、Observation使用に焦点を当てます。

## View Ordering (上から下)

1. Environment プロパティ
2. `private`/`public` `let` 定数
3. `@State` / その他stored properties
4. Computed `var` (非View)
5. `init`
6. `body`
7. Computed view builders / view helpers
8. Helper / async functions

## Core Guidelines

### 1) MV (Model-View) パターンを優先
- `@State`, `@Environment`, `@Query`, `task`, `onChange` でオーケストレーション
- 大きなビューはViewModelではなく、小さなサブビューに分割

### 2) 大きなbodyの分割
```swift
var body: some View {
    VStack(alignment: .leading, spacing: 16) {
        HeaderSection(title: title, isPinned: isPinned)
        DetailsSection(details: details)
        ActionsSection(onSave: onSave, onCancel: onCancel)
    }
}
```

### 3) ViewModel (既存の場合のみ)
- 新規にViewModelを導入しない (明示的要求がない限り)
- 既存のViewModelは非オプショナルに
```swift
@State private var viewModel: SomeViewModel
init(dependency: Dependency) {
    _viewModel = State(initialValue: SomeViewModel(dependency: dependency))
}
```

### 4) Observation
- `@Observable` 参照型はルートビューで `@State` として保持
- 明示的に子に渡す
- 不要なオプショナル状態を避ける

## Large-View Handling (~300行超)

```swift
struct LargeView: View {
    @Environment(Store.self) private var store
    @State private var items: [Item] = []
    var body: some View {
        List { content }.task { await loadItems() }
    }
}

// MARK: - Subviews
private extension LargeView {
    var content: some View {
        ForEach(items) { ItemRow(item: $0) }
    }
}

// MARK: - Actions
private extension LargeView {
    func loadItems() async { items = await store.fetchItems() }
}
```

## Refactor Workflow
1. プロパティ順序を整理
2. MVパターンに移行
3. 既存ViewModelがあれば非オプショナル `@State` に
4. Observation使用を確認
5. 動作は変更しない (明示的要求がない限り)

## Checklist
- [ ] プロパティ順序が正しい
- [ ] 大きなbodyがサブビューに分割されている
- [ ] 不要なViewModelが導入されていない
- [ ] `@Observable` 型がルートで `@State` として保持
- [ ] 依存性が `@Environment` で注入
- [ ] 300行超のファイルは MARK コメントで整理
- [ ] 動作が変更されていない
