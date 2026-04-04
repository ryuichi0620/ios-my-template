---
name: app-store-changelog
description: gitヒストリーからApp Storeリリースノートを生成。What's Newテキスト、変更履歴の作成に使用。
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
context: fork
---

# App Store Changelog

## Overview

最新タグ以降のgitヒストリーからユーザー向けの変更履歴を分析し、App Storeリリースノートを生成します。

## Workflow

### 1) 変更の収集
```bash
git describe --tags --abbrev=0
git log $(git describe --tags --abbrev=0)..HEAD --oneline
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%h %s" --no-merges
```

### 2) ユーザーインパクトでトリアージ

**含める:** 新機能、UI変更、動作変更、ユーザーが気づくバグ修正、目に見えるパフォーマンス改善

**除外:** リファクタ、依存関係更新、CI変更、開発ツール、内部ログ、アナリティクス変更

グループ分け: **New**, **Improved**, **Fixed**

### 3) App Store ノートをドラフト
- 明確な動詞と平易な言葉
- 内部用語、チケットID、ファイルパスを避ける
- 5-10 bullet推奨
- 各bullet: 1文、動詞で開始

### 4) 出力フォーマット
```
What's New

- Added [機能の説明]
- Improved [改善の説明]
- Fixed [バグ修正の説明]
```

## Validation
- [ ] 全bulletが実際の変更に対応
- [ ] 重複なし
- [ ] 内部用語やファイルパスなし
- [ ] App Store文字数制限内
