# Code Agents Config Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将原 `codex/agents_md` 工具迁移为 `code_agents` 下的单窗 UI，支持同时配置 AGENTS/CLAUDE 与 skills，并同步到用户级或指定目录。

**Architecture:** 用 bash + yad 单窗表单完成“范围选择 + 目标路径 + 双分组多选”。确认后拼接 AGENTS/CLAUDE 文件并同步 skills 目录到 Codex/Claude 约定路径。旧命令与脚本全部移除或改为打开新 UI。

**Tech Stack:** Bash, yad, rsync/cp, Python 安装脚本（skill-installer）。

> 说明：按用户要求不做 TDD，仅保留最小手动验证步骤。

### Task 1: 准备目录与静态资源

**Files:**
- Create: `code_agents/agents_md/`
- Create: `code_agents/skills/`
- Move: `codex/agents_md/*.md`
- Move: `codex/skills/commit/`

**Step 1: 创建目录骨架**

Run: `mkdir -p code_agents/agents_md code_agents/skills`
Expected: 目录存在且为空。

**Step 2: 移动 AGENTS 片段**

```bash
mv codex/agents_md/*.md code_agents/agents_md/
```
Expected: `code_agents/agents_md` 下包含原片段。

**Step 3: 移动可选 skills**

```bash
mv codex/skills/commit code_agents/skills/
```
Expected: `code_agents/skills/commit` 存在。

### Task 2: 新 UI 脚本与安装入口

**Files:**
- Create: `code_agents/code-agents-config`
- Create: `code_agents/code-agents-config-console`
- Create: `code_agents/code-agents-config-form-changed.sh`
- Create: `code_agents/link.sh`

**Step 1: 写入表单变更钩子脚本**

```bash
#!/usr/bin/env bash
field="$1"
value="$2"
if [ "$field" = "1" ]; then
  if [ "$value" = "1" ]; then
    printf '2:@disabled@\n'
  else
    printf '2:%s\n' "${CODE_AGENTS_DEFAULT_PATH:-$HOME}"
  fi
fi
```
Expected: 用于切换用户级时禁用/恢复路径字段。

**Step 2: 写入 `code-agents-config`**

核心逻辑：收集片段与 skills，构造 yad `--form`，解析输出并同步到目标路径。

**Step 3: 写入 `code-agents-config-console`**

```bash
#!/usr/bin/env bash
export CODE_AGENTS_DEFAULT_PATH="$PWD"
exec code-agents-config
```
Expected: 终端运行时默认路径为当前目录。

**Step 4: 写入 `code_agents/link.sh`**

安装命令到 `/usr/local/bin`，并用现有安装脚本把远程 skills 同步到 `code_agents/skills`。

### Task 3: 更新关联脚本与配置

**Files:**
- Modify: `codex/link.sh`
- Modify: `codex/agents_md/waybar-codex.sh`
- Modify: `zsh/.zshrc`

**Step 1: 更新 `codex/link.sh`**

移除旧 `agents-md` 安装与默认启用逻辑，保留 superpowers，同步远程 skills 改为写入 `code_agents/skills`（使用 `--dest`）。

**Step 2: 更新 Waybar 脚本**

将 `menu` 行为改为直接执行 `code-agents-config`，移除对 `agents-md` 的依赖。

**Step 3: 更新 zsh 快捷键**

添加 `Ctrl+A` 绑定到 `code-agents-config-console`，并移除旧 `agents-md` completion 路径。

### Task 4: 删除旧命令与遗留文件

**Files:**
- Delete: `codex/agents_md/agents-md.js`
- Delete: `codex/agents_md/install.sh`
- Delete: `codex/agents_md/_agents-md`
- Delete: `codex/agents_md/package.json`
- Delete: `codex/agents_md/package-lock.json`
- Delete: `codex/agents_md/node_modules/` (目录)
- Delete: `codex/agents_md/tests/` (目录)

**Step 1: 移除旧脚本与依赖**

```bash
rm -rf codex/agents_md/agents-md.js codex/agents_md/install.sh codex/agents_md/_agents-md \
  codex/agents_md/package.json codex/agents_md/package-lock.json \
  codex/agents_md/node_modules codex/agents_md/tests
```
Expected: `agents-md` 旧命令完全移除。

### Task 5: 手动验证

**Step 1: 打开 UI**

Run: `code-agents-config`  
Expected: 单窗 UI，用户级切换后路径置灰。

**Step 2: 终端路径默认**

Run: `code-agents-config-console`  
Expected: 目标路径默认填充当前目录。

**Step 3: 同步结果检查**

选择若干片段与 skills 并确认后，检查：
- `~/.codex/AGENTS.md` 和 `~/.claude/CLAUDE.md` 更新
- `~/.codex/skills` 与 `~/.claude/skills` 按选择同步
