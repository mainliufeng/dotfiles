---
description: Directly run git commits with emoji conventional messages
category: version-control-git
allowed-tools: Bash, Read, Glob
---

# Codex Command: Commit

目标：Codex 直接执行 git 提交（而不是只输出命令），并使用带 emoji 的 conventional commit 模板。

## 使用方式

- 默认：自动检测已 staged 文件；如无则提示或先执行 `git add -A`（视上下文决定）。
- 可选 `--no-verify`：跳过 git hooks。
- 提交前建议已跑 lint/format/build（如未跑请在输出说明）。

## 行为说明（参考 claude-code 版本并结合现有模板）

1. 检查 staged 文件；若为 0，可根据上下文自动 `git add -A` 或提示用户。
2. 可选执行预检（lint/format/build），除非 `--no-verify`。
3. 生成 emoji+conventional message，格式：
   - 标题：`<emoji> <type>: <summary>`（type: feat|fix|docs|style|refactor|perf|test|chore，72 字内）
   - 空行
   - 正文：`- ` 开头列要点
   - 可选：Model/Co-authored-by 等附加信息
4. 自动运行 git commit（`git commit -am ...` 或使用临时文件 `git commit -F`），保持 message 一致；需要跳过 hook 时附加 `--no-verify`。
5. 提交完成后，输出最终使用的 commit message 以及已执行命令摘要（无需再给可复制命令）。

## 提交模板示例

```
✨ feat: 并发限流改为租约模式（ZSET+2m TTL）

- reqcount:v3 采用 ZSET 保存 lease_id/chat_id，score=joined_at，窗口(now-2m,+inf)过滤并发
- 租约 TTL 2 分钟自动回收，无续租；key 设双倍 TTL 防止遗留
- /internal/v1/concurrency 返回明细（chat_id、joined_at/expire_at 可读时间）
- 更新 NewConcurrencyLimiter 签名及示例，模型调用路径不变
```

## Emoji 对照（与 claude-code 一致）

- ✨ feat
- 🐛 fix
- 📚 docs
- 💎 style
- 📦 refactor
- 🚀 perf
- 🚨 test
- 🔧 chore
