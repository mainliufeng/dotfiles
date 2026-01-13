#!/bin/bash

# 链接 OpenCode 配置文件

echo "🔗 链接 OpenCode 配置文件..."

# 创建配置目录
mkdir -p ~/.config/opencode

# 链接主配置文件
if [ -f ~/dotfiles/opencode/opencode.json ]; then
    ln -svfn ~/dotfiles/opencode/opencode.json ~/.config/opencode/opencode.json
    echo "✓ opencode.json 已链接"
else
    echo "⚠️  opencode.json 不存在"
fi

# 验证配置
echo ""
echo "📋 验证配置..."
if command -v opencode >/dev/null 2>&1; then
    echo "✓ OpenCode 已安装: $(opencode --version)"
    
    # 检查插件配置
    if [ -f ~/.config/opencode/opencode.json ]; then
        plugins=$(jq -r '.plugin[]?' ~/.config/opencode/opencode.json 2>/dev/null | tr '\n' ' ' || echo "无法读取")
        echo "✓ 已配置插件: $plugins"
    fi
    
else
    echo "⚠️  OpenCode 未安装，请先运行: ./setup.sh"
fi
