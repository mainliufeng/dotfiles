# Claude Code 使用指南

## 安装

### 1. 安装 Claude Code
```bash
# macOS
brew install claude

# Linux (Ubuntu/Debian)
sudo apt update && sudo apt install claude

# 或通过 npm
npm install -g @anthropic-ai/claude-code
```

### 2. 首次配置
```bash
claude auth login  # 登录Anthropic账户
```

## 状态栏配置

### 当前状态栏显示内容
- 当前目录名（蓝色）
- Git分支名（绿色）
- 未提交更改数量（黄色✎符号）
- 当前使用的Claude模型（浅灰色）
- 输出样式名称（深灰色）

### 配置文件位置
```
~/.claude/settings.json      # 主配置文件
~/.claude/statusline.sh     # 状态栏脚本（自动生成）
```

### 状态栏脚本内容
```bash
#!/bin/bash

# 读取JSON输入
input=$(cat)

# 颜色定义
COLOR_RESET="\033[0m"
COLOR_DIR="\033[38;5;39m"      # 蓝色 - 目录
COLOR_GIT="\033[38;5;114m"     # 薄荷绿 - git信息
COLOR_CHANGES="\033[38;5;220m" # 金黄色 - 更改状态
COLOR_MODEL="\033[38;5;250m"   # 浅灰色 - 模型名
COLOR_STYLE="\033[38;5;244m"   # 中灰色 - 样式名

# 提取信息
current_dir=$(echo "$input" | jq -r '.cwd')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')

# 构建状态栏
status=""

# 当前目录（basename）
status+="${COLOR_DIR}$(basename "$current_dir")${COLOR_RESET}"

# Git信息
git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$git_branch" ]; then
    git_changes=$(git status --porcelain 2>/dev/null | wc -l)
    status+=" ${COLOR_GIT}${git_branch}${COLOR_RESET}"
    if [ "$git_changes" -gt 0 ]; then
        status+=" ${COLOR_CHANGES}✎${git_changes}${COLOR_RESET}"
    fi
fi

# 模型信息
status+=" ${COLOR_MODEL}${model_name}${COLOR_RESET}"

# 输出样式
status+=" ${COLOR_STYLE}(${output_style})${COLOR_RESET}"

echo "$status"
```

## 使用方法

### 基本命令
```bash
claude              # 启动交互模式
claude --help       # 查看帮助信息
claude status       # 查看当前状态
```

### 在项目中使用
```bash
# 进入项目目录
cd /path/to/your/project

# 启动Claude Code
claude

# 现在你可以在项目上下文中与Claude对话
```

### 状态栏自定义
如需修改状态栏显示内容，编辑 `~/.claude/statusline.sh` 文件。

## 故障排除

### 状态栏不显示
1. 检查配置文件权限：
   ```bash
   chmod +x ~/.claude/statusline.sh
   ```

2. 检查配置文件格式：
   ```bash
   cat ~/.claude/settings.json
   ```

### 更新配置
```bash
# 重新加载配置
claude reload

# 或重启Claude Code
claude exit
claude
```

## 相关文件

- `statusline.sh` - 状态栏脚本（本目录副本）
- `settings.json.example` - 配置文件示例
- `install.sh` - 一键安装脚本