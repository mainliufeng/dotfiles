#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NPM_GLOBAL_HOME="${NPM_GLOBAL_HOME:-$HOME/.npm-global}"
if [ -d "$NPM_GLOBAL_HOME/bin" ]; then
    export PATH="$NPM_GLOBAL_HOME/bin:$PATH"
fi

# Claude Code 一键安装和配置脚本

echo "🚀 开始安装和配置 Claude Code..."

# 检查是否已安装Claude Code
if ! command -v claude >/dev/null 2>&1; then
    echo "📦 正在安装 Claude Code..."

    if command -v npm >/dev/null 2>&1; then
        npm install -g @anthropic-ai/claude-code
    else
        echo "⚠️  npm 未安装，跳过 Claude Code 二进制安装"
    fi
else
    echo "✅ Claude Code 已安装"
fi

# 创建配置目录
echo "📁 创建配置目录..."
mkdir -p ~/.claude

# 复制配置文件
echo "⚙️  配置状态栏..."
if [ -f ~/.claude/statusline.sh ] && cmp -s "$SCRIPT_DIR/statusline.sh" ~/.claude/statusline.sh; then
    echo "✅ 状态栏已是最新"
else
    cp "$SCRIPT_DIR/statusline.sh" ~/.claude/statusline.sh
fi
chmod +x ~/.claude/statusline.sh

# 复制设置文件（如果不存在）
if [ ! -f ~/.claude/settings.json ]; then
    cp "$SCRIPT_DIR/settings.json.example" ~/.claude/settings.json
    echo "✅ 配置文件已创建"
else
    echo "⚠️  配置文件已存在，跳过创建"
fi

# 配置API Key（通过环境变量）
echo "🔑 请设置环境变量："
echo "  export ANTHROPIC_API_KEY=your_api_key_here"
echo "  # 或将此行添加到 ~/.bashrc 或 ~/.zshrc"

echo "🎉 安装完成！"
echo ""
echo "使用方法："
echo "  claude              # 启动交互模式"
echo "  claude --help       # 查看帮助"
echo ""
echo "配置文件位置："
echo "  ~/.claude/settings.json"
echo "  ~/.claude/statusline.sh"
