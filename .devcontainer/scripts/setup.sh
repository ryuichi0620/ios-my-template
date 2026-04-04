#!/bin/bash

# エラーハンドリング付きメインスクリプト

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 色付きログ用の関数
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

log_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# スクリプトを実行する関数
run_script() {
    local script_name="$1"
    local description="$2"
    
    log_info "Running: $description"
    
    if [ ! -f "$SCRIPT_DIR/$script_name" ]; then
        log_error "Script not found: $script_name"
        return 1
    fi
    
    if bash "$SCRIPT_DIR/$script_name"; then
        log_success "$description completed"
        return 0
    else
        log_error "$description failed"
        return 1
    fi
}


# メイン処理
main() {
    echo "======================================"
    echo "🚀 Development Environment Setup"
    echo "======================================"
    echo ""
    
    local failed=0

    # 環境変数の確認
    echo "🔍 Checking environment variables..."
    if [ -n "$NOTION_TOKEN" ]; then
        echo "  ✓ NOTION_TOKEN is set"
    else
        echo "  ⊘ NOTION_TOKEN not set"
    fi

    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        echo "  ✓ GITHUB_PERSONAL_ACCESS_TOKEN is set"
    else
        echo "  ⊘ GITHUB_PERSONAL_ACCESS_TOKEN not set"
    fi
    echo ""

    if [ -n "$OPENAI_API_KEY" ]; then
        echo "  ✓ OPENAI_API_KEY is set"
    else
        echo "  ⊘ OPENAI_API_KEY not set"
    fi
    echo ""

    # 各スクリプトを実行
    run_script "install-claude-code.sh" "Claude Code installation" || ((failed++))
    echo ""
    
    run_script "persist-bash-history.sh" "Bash history configuration" || ((failed++))
    echo ""
    
    # 結果サマリー
    echo "======================================"
    if [ $failed -eq 0 ]; then
        log_success "All setup completed successfully!"
    else
        log_warning "Setup completed with $failed error(s)"
    fi
    echo "======================================"
    
    return $failed
}

# スクリプト実行
main
exit $?