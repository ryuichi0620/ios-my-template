---
name: swift-concurrency
description: Swift Concurrencyのレビューと修正。Swift 6.2+の並行性コンプライアンス、actor isolation、Sendable安全性に対応。
allowed-tools: Read, Grep, Glob, Edit, Write
model: opus
context: fork
---

# Swift Concurrency Expert

## Overview

Swift 6.2+コードベースにおけるSwift Concurrencyの問題をレビュー・修正します。actor isolation、Sendable安全性、モダンな並行性パターンを最小限の変更で適用します。

## Workflow

### 1. 問題のトリアージ
- コンパイラ診断と問題のあるシンボルを確認
- プロジェクトの並行性設定を確認: Swift言語バージョン (6.2+)、strict concurrencyレベル
- approachable concurrency (デフォルトactor isolation) が有効かチェック
- 現在のactorコンテキスト確認 (`@MainActor`, `actor`, `nonisolated`)
- UIバウンドかバックグラウンド実行かを確認

### 2. 最小限の安全な修正を適用

| 問題 | 修正 |
|------|------|
| UI関連の型 | `@MainActor` でアノテート |
| MainActor型のプロトコル準拠 | `extension Foo: @MainActor SomeProtocol` |
| グローバル/静的状態 | `@MainActor` で保護、またはactorに移動 |
| バックグラウンド処理 | `nonisolated` 型の `@concurrent` async関数 |
| Sendableエラー | 不変/値型を優先、正しい場合のみ `Sendable` 追加 |

## Swift 6.2 Key Changes

### Default Actor Isolation
```swift
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        guard let data = try await item.loadTransferable(type: Data.self) else { return nil }
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

### Isolated Conformances
```swift
extension StickerModel: @MainActor Exportable {
    func export() { photoProcessor.exportAsPNG() }
}
```

### Protecting Global State
```swift
@MainActor
final class StickerLibrary {
    static let shared: StickerLibrary = .init()
}
```

### Background Processing
```swift
nonisolated struct PhotoProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedPhoto? {
        // バックグラウンドスレッドで実行
    }
}
```

## Common Patterns

### UI-Bound Class
```swift
@MainActor
final class ViewModel {
    var items: [Item] = []
    func load() async { items = try await service.fetchItems() }
}
```

### Actor for Shared Mutable State
```swift
actor Cache {
    private var storage: [String: Data] = [:]
    func get(_ key: String) -> Data? { storage[key] }
    func set(_ key: String, value: Data) { storage[key] = value }
}
```

## Migration Checklist
- [ ] Swift 6.2+ を確認
- [ ] approachable concurrency を有効化
- [ ] `SWIFT_STRICT_CONCURRENCY = complete`
- [ ] コンパイラエラーをパターンに従って修正
- [ ] ランタイムテスト実施
