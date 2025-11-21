---
description: Create well-formatted git commits with conventional commit messages and emoji
category: version-control-git
allowed-tools: Bash, Read, Glob
---

# Codex Command: Commit

用于生成符合规范的 git 提交信息（带 emoji 的 conventional commit），格式要求：

1) 标题行：`<emoji> <type>: <summary>`，72 字以内，type 取 `feat|fix|docs|style|refactor|perf|test|chore`。
2) 空行分隔。
3) 正文：按照项列出本次变更的要点，使用 `- ` 开头的列表。
4) 附加信息（可选）：如 Model/Co-authored-by

建议流程：
- 先确保代码通过必要的 lint/格式化/构建检查。
- 提交应保持单一目的，拆分多逻辑改动。
- 如需跳过检查，可在命令中加 `--no-verify`。

示例：
```
✨ feat: 并发限流改为租约模式（ZSET+2m TTL）

- reqcount:v3 采用 ZSET 保存 lease_id/chat_id，score=joined_at，窗口(now-2m,+inf)过滤并发
- 租约 TTL 2 分钟自动回收，无续租；key 设双倍 TTL 防止遗留
- /internal/v1/concurrency 返回明细（chat_id、joined_at/expire_at 可读时间）
- 更新 NewConcurrencyLimiter 签名及示例，模型调用路径不变

Model: gpt-5.1-codex-max medium
Co-authored-by: Codex <codex@openai.com>
```
