# OpenCode 配置

OpenCode 是一个强大的 AI 编程助手，支持终端操作和多模型协作。

## 快速开始

```bash
# 1. 安装和配置 (固定配置: 无 Claude, 有 ChatGPT, 无 Gemini)
./setup.sh

# 2. 链接配置文件
cd ~/dotfiles && ./link.sh

# 3. 配置认证
opencode auth login
```

## 配置说明

### Agent 配置

- **Sisyphus**: `openai/gpt-5.2` + `high` - 主协调器，任务规划和执行
- **oracle**: `openai/gpt-5.2` + `high` - 架构设计和代码审查
- **frontend-ui-ux-engineer**: `openai/gpt-5.2-codex` + `high` - 前端UI/UX开发
- **librarian**: `zhipuai/glm-4.7` - 文档研究和代码库分析
- **explore**: `zhipuai/glm-4.7` - 快速代码库探索
- **document-writer**: `zhipuai/glm-4.7` - 技术文档编写
- **multimodal-looker**: `google/gemini-3-flash` - 多模态内容分析 (Antigravity)

### 使用技巧

#### Magic Word
在 prompt 中包含 `ultrawork` 或 `ulw` 启用最大性能模式：
- 并行 agent 执行
- 后台任务处理
- 深度探索
- 坚持执行直到完成

#### Agent 调用
```
Ask @oracle to review this design and propose an architecture
Ask @librarian how this is implemented—why does the behavior keep changing?
Ask @explore for the policy on this feature
```

## 模型切换

如果你的 OpenAI 额度用完了，可以使用统一脚本快速切换模型：

- **切换到 Premium (GPT-5.2)**: `opencode-model premium`
- **切换到 Fallback (GLM-4.7)**: `opencode-model fallback`
- **切换回默认 (Base)**: `opencode-model`

该脚本会自动覆盖 `oh-my-opencode.json` 并重新建立链接。

## 文件说明

- `setup.sh` - 一键安装和配置脚本
- `link.sh` - 配置文件链接脚本
- `opencode.json` - OpenCode 主配置文件（插件和模型定义）
- `oh-my-opencode.json` - 当前激活的 Agent 配置
- `oh-my-opencode.base.json` - 默认配置备份
- `oh-my-opencode.premium.json` - GPT-5.2 核心配置备份
- `oh-my-opencode.fallback.json` - 全 GLM-4.7 降级配置备份

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
- [oh-my-opencode GitHub](https://github.com/code-yeongyu/oh-my-opencode)
- [opencode-openai-codex-auth](https://github.com/numman-ali/opencode-openai-codex-auth)