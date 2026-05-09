#!/bin/bash

# 链接 commands 目录
ln -svfn ~/dotfiles/claude-code/commands ~/.claude/commands

# 链接 hooks 目录
mkdir -p ~/.claude/hooks
ln -svfn ~/dotfiles/claude-code/hooks/notify-complete.sh ~/.claude/hooks/notify-complete.sh
ln -svfn ~/dotfiles/claude-code/statusline.sh ~/.claude/statusline.sh

# 设置 hooks 脚本执行权限
chmod +x ~/dotfiles/claude-code/hooks/notify-complete.sh
chmod +x ~/dotfiles/claude-code/statusline.sh

# 如果 settings.json 不存在，则从示例创建
if [ ! -f ~/.claude/settings.json ]; then
    echo "创建 settings.json 配置文件..."
    cp ~/dotfiles/claude-code/settings.json.example ~/.claude/settings.json
    echo "✓ settings.json 已创建，包含完成通知 hook"
else
    echo "⚠ settings.json 已存在，请手动添加 hook 配置"
    echo "参考: ~/dotfiles/claude-code/settings.json.example"
fi

# 配置 MCP (Context7)
# npm install -g @upstash/context7-mcp
if command -v claude >/dev/null 2>&1; then
    claude mcp add context7 "npx -y @upstash/context7-mcp" 2>/dev/null || true
    claude mcp add chrome-devtools npx chrome-devtools-mcp@latest -s user || true

    claude plugin marketplace add anthropics/skills || true
    claude plugin install document-skills || true
    claude plugin install ralph-loop || true
else
    echo "⚠ Claude Code CLI 未安装，跳过 MCP 和 plugin 配置"
fi

echo ""
echo "✓ Claude Code hooks 配置完成"
echo "  - 完成通知 hook: ~/.claude/hooks/notify-complete.sh"
echo ""
echo "使用方法："
echo "  1. 确保已安装 jq: macOS 用 brew install jq，Arch 用 sudo pacman -S jq"
echo "  2. 重启 Claude Code 以加载 hook"
echo "  3. 执行任务完成后将收到系统通知"
