#!/bin/bash

# Claude Code 一键安装和配置脚本

echo "🚀 开始安装和配置 Claude Code..."

# 检查是否已安装Claude Code
if ! command -v claude >/dev/null 2>&1; then
    echo "📦 正在安装 Claude Code..."
    
    # 检测操作系统
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "⚠️  Claude Code 未安装；macOS 自动安装暂未托管，跳过二进制安装"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install claude
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install claude
        else
            echo "⚠️  不支持的Linux发行版，请手动安装 Claude Code，继续配置文件安装"
        fi
    else
        echo "⚠️  不支持的操作系统，跳过 Claude Code 二进制安装"
    fi
else
    echo "✅ Claude Code 已安装"
fi

# 创建配置目录
echo "📁 创建配置目录..."
mkdir -p ~/.claude

# 复制配置文件
echo "⚙️  配置状态栏..."
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# 复制设置文件（如果不存在）
if [ ! -f ~/.claude/settings.json ]; then
    cp settings.json.example ~/.claude/settings.json
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
