#!/bin/bash

# OpenCode 一键安装和配置脚本 (Arch Linux)

echo "🚀 开始安装和配置 OpenCode..."

# 1. 检查 yay 是否安装
if ! command -v yay >/dev/null 2>&1; then
    echo "❌ 请先安装 yay"
    exit 1
fi

# 2. 安装 OpenCode 和相关包
echo "📦 安装 OpenCode 包..."
yay -S opencode-bin opencode-ui-bin opencode-openai-codex-auth

# 3. 验证安装
echo "✅ 验证安装..."
opencode_version=$(opencode --version 2>/dev/null || echo "未安装")
echo "OpenCode 版本: $opencode_version"

# 4. 配置认证提示
echo "🔑 配置认证..."
echo "请运行以下命令完成认证："
echo "  opencode auth login"
echo "然后选择："
echo "  - Provider: OpenAI"
echo "  - Login method: ChatGPT Plus/Pro (Codex Subscription)"

echo ""
echo "🎉 安装完成！"
echo ""
echo "下一步："
echo "  1. 运行: opencode auth login 完成认证"
echo "  2. 运行: cd ~/dotfiles && ./link.sh 链接配置文件"
echo "  3. 在 OpenCode 里输入以下指令安装 superpowers:"
echo "     Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md"
