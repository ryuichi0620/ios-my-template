---
name: github-issue-fix
description: GitHub issueの修正ワークフロー。issue取得、コード修正、ビルド・テスト、コミット・プッシュまでのE2Eフロー。
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
context: fork
---

# GitHub Issue Fix Flow

## Overview

GitHub issueの取り込みから修正、検証、プッシュまでを一貫して実行します。

## Workflow

### 1) Issue取り込み
```bash
gh issue view <id> --comments
gh repo view --json nameWithOwner
```

### 2) コードパスの特定
```bash
rg -n "keyword from issue"
rg -n "func relevantFunction"
```

### 3) 修正の実装
- 最小限のファイルを編集
- 既存アーキテクチャに沿う
- 動作変更がある場合はテスト追加

### 4) ビルド & テスト
```bash
swift build
swift test
```

### 5) コミット & プッシュ
```bash
git add <specific files>
git commit -m "Fix: <description>

Closes #<issue number>"
git push
```

### 6) レポート
- 何をどこで変更したか
- テスト結果
- フォローアップやブロッカー

## Branch Naming
```bash
git checkout -b fix/issue-123-fix-bug
git checkout -b feature/issue-123-add-feature
```
