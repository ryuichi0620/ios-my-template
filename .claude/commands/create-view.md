---
description: 新しいSwiftUIビューを作成
---

$ARGUMENTS の名前で新しいSwiftUIビューを作成してください。

## 要件
- iOS 17+ のモダンAPI使用
- @Observable / @State / @Environment で状態管理
- MV パターン (不要なViewModel を作らない)
- .task でデータロード
- アクセシビリティラベル追加
- #Preview 追加

## テンプレート構造
```swift
import SwiftUI

struct <ViewName>: View {
    // 1. Environment
    // 2. Constants
    // 3. @State
    // 4. Computed properties

    var body: some View {
        // Implementation
    }
}

#Preview {
    <ViewName>()
}
```
