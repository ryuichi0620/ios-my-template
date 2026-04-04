---
name: swiftui-liquid-glass
description: iOS 26+ Liquid Glass APIの実装・レビュー・改善。glassEffect、GlassEffectContainer、morphingトランジションに対応。
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
context: fork
---

# SwiftUI Liquid Glass

## Overview

Liquid GlassはiOS 26+の動的マテリアルです。光学ガラスの特性と流動性を組み合わせ、コンテンツをぼかし、周囲の色と光を反射し、タッチ操作にリアルタイムで反応します。

## Core Guidelines

- ネイティブLiquid Glass APIをカスタムブラーより優先
- 複数のグラス要素には `GlassEffectContainer` を使用
- `.glassEffect(...)` はレイアウト・外観モディファイアの後に適用
- タッチ/ポインター応答要素にのみ `.interactive()`
- `#available(iOS 26, *)` でゲートし、非グラスフォールバックを提供

## Quick Snippets

### Basic Glass with Fallback
```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

### Multiple Glass Elements
```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .glassEffect()
    }
}
```

### Glass Buttons
```swift
Button("Confirm") { }.buttonStyle(.glassProminent)
Button("Cancel") { }.buttonStyle(.glass)
```

### Morphing Transitions
```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "pencil")
            .frame(width: 80, height: 80)
            .glassEffect()
            .glassEffectID("pencil", in: namespace)

        if isExpanded {
            Image(systemName: "eraser")
                .frame(width: 80, height: 80)
                .glassEffect()
                .glassEffectID("eraser", in: namespace)
        }
    }
}
```

### Customizing & Uniting
```swift
// Tint
Text("Tinted").padding()
    .glassEffect(.regular.tint(.orange).interactive(), in: .capsule)

// Union
.glassEffectUnion(id: index < 2 ? "group1" : "group2", namespace: namespace)
```

## Shape Options
- `.capsule` (default)
- `.rect(cornerRadius: CGFloat)`
- `.circle`

## Review Checklist
- [ ] `#available(iOS 26, *)` とフォールバック
- [ ] 複数グラスビューは `GlassEffectContainer` で囲む
- [ ] `glassEffect` はレイアウト/外観モディファイアの後
- [ ] `interactive()` はユーザー操作がある要素のみ
- [ ] `glassEffectID` + `@Namespace` でmorphing
- [ ] 形状、色合い、間隔の一貫性
