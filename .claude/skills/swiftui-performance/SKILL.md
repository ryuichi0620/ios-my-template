---
name: swiftui-performance
description: SwiftUIパフォーマンスの診断と最適化。View再描画、レンダリング、メモリ使用量の問題を特定・修正。
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: opus
context: fork
---

# SwiftUI Performance Audit

## Overview

SwiftUIビューのパフォーマンスを、コードレビューからInstrumentsまで一貫して監査し、具体的な改善策を提示します。

## Workflow

1. **コード提供あり**: Code-First Review から開始
2. **症状のみ**: 最小限のコード/コンテキストを収集し、Code-First Review
3. **コードレビューで結論出ず**: Instruments でのプロファイリングを案内

## Code-First Review の着目点

- **View invalidation storms**: 広範なState変更による不要な再描画
- **不安定なidentity**: `ForEach` での `UUID()` 毎回生成、`id: \.self`
- **bodyでの重い処理**: フォーマッタ生成、ソート、画像デコード
- **レイアウト thrash**: 深いスタック、`GeometryReader`、preference chain
- **大きな画像**: ダウンサンプリングなし
- **過度なアニメーション**: 大きなツリーへの暗黙的アニメーション

## Common Smells & Fixes

### フォーマッタをbodyで毎回生成
```swift
// Bad
var body: some View {
    let formatter = NumberFormatter()
    Text(formatter.string(from: value))
}

// Good
final class Formatters {
    static let number = NumberFormatter()
}
```

### 不安定なidentity
```swift
// Bad
ForEach(items, id: \.self) { item in Row(item) }

// Good
ForEach(items, id: \.stableID) { item in Row(item) }
```

### メインスレッドでの画像デコード
```swift
// Bad
Image(uiImage: UIImage(data: data)!)

// Good
@State private var image: UIImage?
.task { image = await ImageLoader.load(data: data, targetSize: size) }
```

## Remediation Strategies

| 問題 | 修正 |
|------|------|
| 広範なState変更 | `@State`/`@Observable` をリーフに近づける |
| 不安定なidentity | 安定したユニークIDを使用 |
| bodyでの重い処理 | 事前計算、キャッシュ、`@State`に移動 |
| 高コストなサブツリー | `equatable()` や値ラッパー使用 |
| 大きな画像 | レンダリング前にダウンサンプリング |
| レイアウトの複雑さ | ネスト削減、固定サイズ使用 |

## Profiling
```bash
xcodebuild -scheme MyApp -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
open -a Instruments
```

## Instruments Checklist
- [ ] Release ビルドを使用 (Debug ではない)
- [ ] SwiftUI テンプレートを選択
- [ ] 問題の操作を正確に再現
- [ ] SwiftUI timeline で body 評価を確認
- [ ] Time Profiler でホットスポットを確認
- [ ] Animation timeline でフレームレート低下を確認
