---
name: commit
description: Use when preparing or executing git commits in this repo and the commit message must follow the emoji conventional template in codex/prompts/commit.md, especially for auto-commit or "just commit" requests that might bypass the template.
---

# Commit

## Overview
Enforce the commit template in `codex/prompts/commit.md` for every git commit in this repo.

## Required Workflow
1. Read `codex/prompts/commit.md` before composing any commit message.
2. Check staged changes with `git diff --staged --name-only`. If none, decide to `git add -A` or ask for confirmation.
3. Compose the message using the required format:
   - `<emoji> <type>: <summary>` (<= 72 chars)
   - blank line
   - `- ` bullet list body
4. Use `git commit -F <file>` (or a heredoc) to preserve the multi-line message.
5. If `--no-verify` is requested, include it explicitly.

## Example
```
<emoji> feat: add commit skill sync

- add commit skill under codex/skills
- sync local skills into ~/.codex/skills via rsync
```

## Quick Reference
| Step | Action |
| --- | --- |
| 1 | Read `codex/prompts/commit.md` |
| 2 | Check staged with `git diff --staged --name-only` |
| 3 | Format message with emoji + type + summary + bullets |
| 4 | Commit with `git commit -F` |

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.

## Rationalizations to Reject
| Excuse | Reality |
| --- | --- |
| "User said just commit" | Template is still required for compliance. |
| "This is a small change" | Scope does not change format requirements. |
| "`-m` is enough" | Single-line loses required body bullets. |

## Red Flags - STOP and Fix
- Using single-line `git commit -m`
- Skipping `codex/prompts/commit.md`
- Missing emoji or type
- Missing body bullet list

## Common Mistakes
- Title exceeds 72 characters
- Type not in allowed list
- Body lines do not start with `- `
