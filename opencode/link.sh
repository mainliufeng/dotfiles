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

# 链接 oh-my-opencode 配置
if [ -f ~/dotfiles/opencode/oh-my-opencode.base.json ]; then
    ln -svfn ~/dotfiles/opencode/oh-my-opencode.base.json ~/.config/opencode/oh-my-opencode.json
    echo "✓ oh-my-opencode.json 已链接"
else
    echo "⚠️  oh-my-opencode.json 不存在"
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
    
    # 检查 oh-my-opencode 配置
    if [ -f ~/.config/opencode/oh-my-opencode.json ]; then
        echo "✓ oh-my-opencode 配置已链接"
    fi
else
    echo "⚠️  OpenCode 未安装，请先运行: ./setup.sh"
fi

echo ""
echo "🎯 使用提示："
echo "  - 在 prompt 中使用 'ultrawork' 或 'ulw' 启用最大性能模式"
echo "  - 使用 '@oracle' '@librarian' '@explore' 等调用专门 agent"
echo ""
echo "📖 配置说明："
echo "  - Sisyphus/oracle: GPT-5.2 high (核心任务)"
echo "  - frontend-ui-ux-engineer: GPT-5.2-codex high (前端开发)"
echo "  - librarian/explore/document-writer: GLM-4.7 (智谱AI)"
echo "  - multimodal-looker: Gemini 3 Flash (Antigravity)"
