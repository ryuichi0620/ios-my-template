---
name: native-profiling
description: CLI経由のTime Profiler (xctrace)。CPU hotspot検出、パフォーマンス最適化、Instruments活用に対応。
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
context: fork
---

# Native App Performance Profiling (CLI)

## Overview

`xctrace` でTime Profilerを記録し、サンプルを抽出・シンボリケートし、ホットスポットを特定します。Instrumentsを開かずにCLIで完結します。

## Quick Start

### 1) Time Profiler記録

```bash
# 実行中プロセスにアタッチ
pgrep -x "AppName"
xcrun xctrace record --template 'Time Profiler' --time-limit 90s --output /tmp/App.trace --attach <pid>

# 起動して記録
xcrun xctrace record --template 'Time Profiler' --time-limit 90s --output /tmp/App.trace --launch -- /path/to/App
```

### 2) エクスポート
```bash
xcrun xctrace export --input /tmp/App.trace --toc
xcrun xctrace export --input /tmp/App.trace \
  --xpath '/trace-toc/run/data/table[@schema="time-profile"]' \
  --output /tmp/time-profile.xml
```

### 3) シンボリケート
```bash
vmmap <pid> | grep "__TEXT"
atos -o /path/to/App -l 0x100000000 <address>
```

## Available Templates
| テンプレート | 用途 |
|-------------|------|
| Time Profiler | CPUサンプリング |
| Allocations | メモリ割り当て |
| Leaks | メモリリーク検出 |
| System Trace | システムレベル活動 |
| Animation Hitches | UIパフォーマンス |

## iOS Profiling
```bash
xcrun xctrace record --template 'Time Profiler' \
  --device <simulator-udid> --time-limit 60s \
  --output /tmp/iOS-App.trace --launch -- <bundle-id>
```

## Gotchas
- **ASLR**: `__TEXT`ロードアドレスは起動毎に変化
- **ビルド不一致**: シンボルはプロファイルしたビルドと完全一致が必要
- **アイドル時間**: アイドル中のプロファイルは空データ
- **権限**: 一部操作は `sudo` が必要な場合あり
