# OpenCode 配置

OpenCode 是一个强大的 AI 编程助手，支持终端操作和多模型协作。

## 快速开始

```bash
# 1. 安装和配置
./setup.sh

# 2. 链接配置文件
cd ~/dotfiles && ./link.sh

# 3. 配置认证
opencode auth login

# 4. 安装 superpowers (在 OpenCode 里输入以下指令)
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

## 文件说明

- `setup.sh` - 一键安装和配置脚本
- `link.sh` - 配置文件链接脚本
- `opencode.json` - OpenCode 主配置文件（插件和模型定义）

## 系统要求

- Arch Linux (使用 yay 包管理器)
- ChatGPT Plus/Pro 订阅 (用于 GPT-5.2 模型)

## 故障排除

### 版本检查
```bash
opencode --version  # 需要 ≥ 1.0.150
```

### 配置验证
```bash
cat ~/.config/opencode/opencode.json | jq '.plugin'
```

### 重新安装
```bash
# 删除现有配置
rm -rf ~/.config/opencode

# 重新运行安装
./setup.sh && cd ~/dotfiles && ./link.sh
```

## 参考资源

- [OpenCode 官方文档](https://opencode.ai/docs)
- [opencode-openai-codex-auth](https://github.com/numman-ali/opencode-openai-codex-auth)
