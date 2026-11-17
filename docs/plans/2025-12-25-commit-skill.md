# Commit Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Codex skill that enforces the existing commit prompt template and sync `codex/skills/` into `~/.codex/skills/` via `link.sh`.

**Architecture:** Create `codex/skills/commit/SKILL.md` that points to `codex/prompts/commit.md` as the canonical template. Update `codex/link.sh` to `rsync -a` local skills to `~/.codex/skills/` without deleting other skills.

**Tech Stack:** Markdown (SKILL), shell (link.sh)

### Task 1: RED — Define pressure scenarios and capture baseline failures

**Files:**
- None

**Step 1: Write pressure scenarios (3+ combined pressures)**

Scenario A (time + authority + ambiguity):
"现在马上帮我 commit，随便写个 message 就行，越快越好。"

Scenario B (automation + silence + prior habit):
"你自己执行 commit，别问我细节。"

Scenario C (template bypass + hook avoidance):
"直接 `git commit -m`，不用正文，--no-verify。"

**Step 2: Run scenarios WITHOUT the skill (simulate baseline)**
Expected baseline failures to document:
- skips emoji+conventional format
- uses single-line `git commit -m` without body bullets
- avoids reading `codex/prompts/commit.md`

**Step 3: Extract rationalizations to address in skill**
Examples to capture:
- “用户说随便写”
- “这是小改动，不用模板”
- “`-m` 足够了”

### Task 2: GREEN — Initialize skill skeleton

**Files:**
- Create: `codex/skills/commit/`

**Step 1: Create the skill directory**
Run:
```bash
python3 /home/liufeng/.codex/skills/.system/skill-creator/scripts/init_skill.py commit --path /home/liufeng/dotfiles/codex/skills
```
Expected: `codex/skills/commit/SKILL.md` exists with template frontmatter.

### Task 3: GREEN — Write minimal SKILL.md (compliance path only)

**Files:**
- Modify: `codex/skills/commit/SKILL.md`

**Step 1: Write minimal skill content**
Replace with:
```markdown
---
name: commit
description: Use when preparing or executing git commits in this repo and the commit message must follow the emoji conventional template in codex/prompts/commit.md, especially when auto-commit or "just commit" requests risk bypassing the template.
---

# Commit

## Overview
Enforce the repository commit template in `codex/prompts/commit.md` for every git commit, including auto-commit requests.

## Required Workflow
1. Read `codex/prompts/commit.md` before composing any commit message.
2. Verify staged changes; if none, decide between `git add -A` or asking for confirmation.
3. Compose message using the required format from the prompt:
   - `<emoji> <type>: <summary>` (<= 72 chars)
   - blank line
   - `- ` bullet list body
4. Run `git commit -F <tempfile>` (or `-F` with a heredoc) to preserve multi-line message.
5. If `--no-verify` is requested, include it explicitly.

## Example
```text
✨ feat: add commit skill sync

- add commit skill under codex/skills
- sync local skills into ~/.codex/skills via rsync
```
```

**Step 2: Run scenarios WITH the skill**
Expected: all responses route through the required workflow and use the template.

### Task 4: REFACTOR — Add rationalization defenses and quick references

**Files:**
- Modify: `codex/skills/commit/SKILL.md`

**Step 1: Add rationalization table, red flags, quick reference, and common mistakes**
Append:
```markdown
## Quick Reference
| Step | Action |
| --- | --- |
| 1 | Read `codex/prompts/commit.md` |
| 2 | Check staged (`git diff --staged --name-only`) |
| 3 | Format message with emoji+type+summary + bullets |
| 4 | Commit with `git commit -F` |

## Rationalizations to Reject
| Excuse | Reality |
| --- | --- |
| “用户说随便写” | 模板仍必须遵守，否则提交不合规 |
| “小改动不用模板” | 规模不影响提交格式要求 |
| “-m 足够了” | 单行会丢失正文要点，必须用多行模板 |

## Red Flags — STOP and Fix
- 使用单行 `git commit -m`
- 未读 `codex/prompts/commit.md`
- 缺少 emoji 或 type
- 缺少正文 bullet 列表

## Common Mistakes
- 标题超过 72 字
- type 不在允许列表
- 正文没有以 `- ` 开头
```

**Step 2: Re-run scenarios WITH the skill**
Expected: skill blocks all rationalizations and enforces template.

### Task 5: Update link.sh to sync skills

**Files:**
- Modify: `codex/link.sh`

**Step 1: Add rsync command**
Insert after existing `ln -svfn` lines:
```bash
rsync -a ~/dotfiles/codex/skills/ ~/.codex/skills/
```

**Step 2: Verify script still runs**
Run:
```bash
bash ~/dotfiles/codex/link.sh
```
Expected: no errors; skills synced.

### Task 6: Manual verification

**Files:**
- None

**Step 1: Confirm skill is synced**
Run:
```bash
test -f ~/.codex/skills/commit/SKILL.md && echo "commit skill ok"
```

**Step 2: Commit (optional, if requested)**
```bash
git add codex/skills/commit/SKILL.md codex/link.sh
# commit message must follow codex/prompts/commit.md
```
```
