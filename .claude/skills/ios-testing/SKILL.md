---
name: ios-testing
description: iOSテストの専門家。ユニットテスト、UIテスト、Swift Testing、TDDに対応。テスト作成・レビュー・修正時に使用。
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: opus
context: fork
---

# iOS Testing Expert

## Overview

iOS/Swiftプロジェクトのテスト作成、レビュー、修正を支援します。Swift Testing framework (iOS 17+) を優先し、XCTestもサポートします。

## Workflow

### 1) テスト対象の分析
- テスト対象のコードを読み、依存関係を特定
- 既存テストのパターンを確認（`rg "@Test" --type swift` / `rg "XCTestCase" --type swift`）
- テストカバレッジのギャップを特定

### 2) テスト作成方針

**Swift Testing (推奨 - iOS 17+)**
```swift
import Testing

@Suite("ViewModel Tests")
struct ViewModelTests {
    @Test("正常系: データ取得成功")
    func fetchDataSuccess() async throws {
        let sut = ViewModel(service: MockService())
        await sut.fetch()
        #expect(sut.items.count == 3)
    }

    @Test("異常系: ネットワークエラー", .tags(.error))
    func fetchDataNetworkError() async throws {
        let sut = ViewModel(service: FailingService())
        await sut.fetch()
        #expect(sut.error != nil)
    }
}
```

**XCTest (レガシー)**
```swift
final class ViewModelTests: XCTestCase {
    func testFetchDataSuccess() async throws {
        let sut = ViewModel(service: MockService())
        await sut.fetch()
        XCTAssertEqual(sut.items.count, 3)
    }
}
```

### 3) テストパターン

| パターン | 用途 |
|----------|------|
| **Protocol Mock** | 外部依存のモック化 |
| **@Observable State** | ViewModelの状態変化テスト |
| **async/await** | 非同期処理のテスト |
| **Parameterized** | 複数入力パターンのテスト |

### 4) UIテスト
```swift
import XCTest

final class AppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testNavigationFlow() throws {
        app.buttons["Start"].tap()
        XCTAssertTrue(app.navigationBars["Detail"].exists)
    }
}
```

## ビルド・テスト実行コマンド
```bash
# ユニットテスト
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:MyAppTests

# UIテスト
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:MyAppUITests
```

## Checklist
- [ ] Swift Testing (`@Test`) を優先使用
- [ ] AAA パターン (Arrange-Act-Assert) に従う
- [ ] テスト名は何をテストしているか明確に
- [ ] モックはプロトコルベースで作成
- [ ] 非同期テストは `async throws` を使用
- [ ] エッジケース・エラーケースをカバー
