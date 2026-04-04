---
name: swiftui-components
description: SwiftUIコンポーネントの設計・実装の専門家。ビュー作成、レイアウト、アニメーション、アクセシビリティに対応。
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
context: fork
---

# SwiftUI Components Expert

## Overview

SwiftUIのビュー設計・実装を支援します。iOS 17+のモダンAPIを優先し、再利用可能で保守性の高いコンポーネントを作成します。

## Core Principles

1. **@Observable を使用** (iOS 17+、ObservableObject は非推奨)
2. **NavigationStack を使用** (NavigationView は非推奨)
3. **MV (Model-View) パターン推奨** — 不要なViewModelを避ける
4. **小さく焦点を絞ったビュー** — compositionで構築
5. **Swift 6 厳密並行性** に準拠

## View Structure (上から下の順序)

1. Environment プロパティ
2. `private`/`public` `let` 定数
3. `@State` / その他stored properties
4. Computed `var` (非View)
5. `init`
6. `body`
7. Computed view builders / view helpers
8. Helper / async functions

## State Management

| Wrapper | 用途 |
|---------|------|
| `@State` | ローカル、一時的なビュー状態 |
| `@Binding` | 親からの双方向データフロー |
| `@Observable` | ビュー間の共有状態 (iOS 17+) |
| `@Environment` | 依存性注入、アプリ全体の関心事 |
| `@Query` | SwiftData クエリ |

## MV Pattern (推奨)

```swift
struct FeedView: View {
    @Environment(APIClient.self) private var client

    enum ViewState {
        case loading, error(String), loaded([Post])
    }

    @State private var viewState: ViewState = .loading

    var body: some View {
        NavigationStack {
            List {
                switch viewState {
                case .loading:
                    ProgressView("Loading...")
                case .error(let message):
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
                case .loaded(let posts):
                    ForEach(posts) { PostRow(post: $0) }
                }
            }
            .task { await loadFeed() }
        }
    }

    private func loadFeed() async {
        do {
            viewState = .loaded(try await client.getFeed())
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
```

## Sheet Patterns

```swift
// Item-driven (推奨)
@State private var selectedItem: Item?
.sheet(item: $selectedItem) { item in
    EditItemSheet(item: item)
}

// Sheet owns its dismiss
struct EditItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: Item

    var body: some View {
        Button("Save") {
            Task { await save(); dismiss() }
        }
    }
}
```

## Task & onChange

```swift
.task(id: searchText) {
    guard !searchText.isEmpty else { return }
    await search(query: searchText)
}

.onChange(of: isActive, initial: false) {
    guard isActive else { return }
    Task { await refresh() }
}
```

## Accessibility

```swift
Image(systemName: "heart.fill")
    .accessibilityLabel("お気に入り")
    .accessibilityHint("ダブルタップでお気に入りを切り替え")
    .accessibilityAddTraits(.isButton)
```

## Checklist
- [ ] @Observable 使用 (iOS 17+)
- [ ] NavigationStack 使用
- [ ] プロパティ順序が正しい
- [ ] bodyが長すぎる場合はサブビューに分割
- [ ] .task でデータロード
- [ ] アクセシビリティラベル追加
- [ ] Preview 追加
