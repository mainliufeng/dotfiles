# Agents MD JS TUI 实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 用 Node.js 的 TUI 选择 AGENTS.md 片段并生成最终文件，替换原来的 enable/disable 脚本。

**Architecture:** 片段继续放在 `codex/agents_md/`。新增一个 `codex/agents-md.js`，用 `prompts` 多选片段，写入 `~/.codex/agents_md.enabled`，并生成 `~/.codex/AGENTS.md`。在 `codex/` 下增加安装脚本，将 `scripts/agents-md` 指向该 TUI。`codex/link.sh` 默认用 `--defaults` 非交互初始化 `base + superpowers`。

**Tech Stack:** Node.js + prompts

### Task 1: 新增 Node.js TUI 脚本

**Files:**
- Create: `codex/agents-md.js`
- Create: `codex/package.json`

**Step 1: Write the failing test**

Skip（当前没有 JS 测试框架）。

**Step 2: Run test to verify it fails**

Skip。

**Step 3: Write minimal implementation**

实现 `codex/agents-md.js`：
- `--defaults <names...>`：若 enabled 列表不存在或为空，写入默认片段并生成（无交互）。
- `--build`：按当前 enabled 列表生成。
- 默认交互模式：用 `prompts` 多选片段（来自 `codex/agents_md/*.md`），默认勾选已启用项，保存后生成。
- 生成逻辑：将启用片段按顺序拼接，片段间插入一个空行，输出到 `~/.codex/AGENTS.md`。
- 校验片段存在，不存在则报错退出。

新增 `codex/package.json`，依赖 `prompts`，并配置 `bin` 指向 `codex/agents-md.js`。

**Step 4: Run test to verify it passes**

手动验证：
- `node codex/agents-md.js --defaults base superpowers`
- `node codex/agents-md.js --build`
- `node codex/agents-md.js`（交互）

**Step 5: Commit**

```bash
git add codex/agents-md.js codex/package.json
```

### Task 2: 增加 scripts/agents-md 安装脚本

**Files:**
- Create: `codex/install-agents-md.sh`

**Step 1: Write the failing test**

Skip。

**Step 2: Run test to verify it fails**

Skip。

**Step 3: Write minimal implementation**

创建 `codex/install-agents-md.sh`：
- 确保 `~/dotfiles/scripts` 目录存在。
- 生成/更新 `~/dotfiles/scripts/agents-md` 作为 shim，内容是 `node ~/dotfiles/codex/agents-md.js`。
- 赋予可执行权限。

**Step 4: Run test to verify it passes**

手动验证：
- `bash codex/install-agents-md.sh`
- `scripts/agents-md --defaults base superpowers`

**Step 5: Commit**

```bash
git add codex/install-agents-md.sh scripts/agents-md
```

### Task 3: 移除旧 enable/disable 脚本并更新 link.sh

**Files:**
- Delete: `codex/enable-superpowers.sh`
- Delete: `codex/disable-superpowers.sh`
- Modify: `codex/link.sh`

**Step 1: Write the failing test**

Skip。

**Step 2: Run test to verify it fails**

Skip。

**Step 3: Write minimal implementation**

- `codex/link.sh` 增加 `bash ~/dotfiles/codex/install-agents-md.sh`。
- `codex/link.sh` 改为运行 `node ~/dotfiles/codex/agents-md.js --defaults base superpowers`。
- 移除旧 enable/disable 脚本的调用。

**Step 4: Run test to verify it passes**

手动验证：
- `bash codex/link.sh`
- 检查 `~/.codex/AGENTS.md` 已由 base+superpowers 生成。

**Step 5: Commit**

```bash
git add codex/link.sh
```
