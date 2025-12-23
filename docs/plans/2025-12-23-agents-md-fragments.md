# AGENTS Fragment Management Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Generate `~/.codex/AGENTS.md` from selectable fragments and provide scripts to enable/disable fragments with defaults in `codex/link.sh`.

**Architecture:** Store fragments in `codex/agents_md/` and maintain an enabled list in `~/.codex/agents_md.enabled`. A generator script builds `~/.codex/AGENTS.md` by concatenating enabled fragments. Wrapper scripts enable/disable the Superpowers fragment and invoke the generator. `codex/link.sh` initializes defaults and builds once.

**Tech Stack:** Bash

### Task 1: Add fragment files

**Files:**
- Create: `codex/agents_md/base.md`
- Create: `codex/agents_md/superpowers.md`

**Step 1: Write the failing test**

Skip (no test harness for shell scripts in this repo).

**Step 2: Run test to verify it fails**

Skip.

**Step 3: Write minimal implementation**

- Move the current non-Superpowers content from `codex/AGENTS.md` into `codex/agents_md/base.md`.
- Put the current "Superpowers System" block into `codex/agents_md/superpowers.md`.

**Step 4: Run test to verify it passes**

Skip.

**Step 5: Commit**

```bash
git add codex/agents_md/base.md codex/agents_md/superpowers.md
```

### Task 2: Create fragment manager script

**Files:**
- Create: `codex/agents-md.sh`

**Step 1: Write the failing test**

Skip.

**Step 2: Run test to verify it fails**

Skip.

**Step 3: Write minimal implementation**

Implement a script with subcommands:
- `enable <name...>`: add fragments to `~/.codex/agents_md.enabled` if missing.
- `disable <name...>`: remove fragments from the enabled list.
- `list`: show current enabled list (one per line).
- `build`: write `~/.codex/AGENTS.md` by concatenating enabled fragments from `~/dotfiles/codex/agents_md/`, separated by a blank line.
- `defaults <name...>`: if the enabled list is missing or empty, set it to the provided defaults.

Error if a requested fragment file does not exist. Ensure `~/.codex` exists and write via a temp file to avoid partial writes.

**Step 4: Run test to verify it passes**

Manual check:
- `bash codex/agents-md.sh defaults base superpowers`
- `bash codex/agents-md.sh build`
- Verify `~/.codex/AGENTS.md` contains both fragments in order.

**Step 5: Commit**

```bash
git add codex/agents-md.sh
```

### Task 3: Add enable/disable Superpowers wrappers

**Files:**
- Create: `codex/enable-superpowers.sh`
- Create: `codex/disable-superpowers.sh`
- Modify: `codex/install-superpowers.sh`
- Modify: `codex/uninstall-superpowers.sh`

**Step 1: Write the failing test**

Skip.

**Step 2: Run test to verify it fails**

Skip.

**Step 3: Write minimal implementation**

- `enable-superpowers.sh`: run `codex/install-superpowers.sh`, then `codex/agents-md.sh enable superpowers`, then `codex/agents-md.sh build`.
- `disable-superpowers.sh`: run `codex/agents-md.sh disable superpowers`, then `codex/agents-md.sh build`.
- `install-superpowers.sh`: keep only clone + bootstrap; do not modify AGENTS.
- `uninstall-superpowers.sh`: call `codex/agents-md.sh disable superpowers` + `build` before removing `~/.codex/superpowers`.

**Step 4: Run test to verify it passes**

Manual check:
- `bash codex/enable-superpowers.sh`
- `bash codex/disable-superpowers.sh`

**Step 5: Commit**

```bash
git add codex/enable-superpowers.sh codex/disable-superpowers.sh codex/install-superpowers.sh codex/uninstall-superpowers.sh
```

### Task 4: Default fragments in link.sh

**Files:**
- Modify: `codex/link.sh`

**Step 1: Write the failing test**

Skip.

**Step 2: Run test to verify it fails**

Skip.

**Step 3: Write minimal implementation**

Replace the AGENTS copy with:
- `bash ~/dotfiles/codex/agents-md.sh defaults base superpowers`
- `bash ~/dotfiles/codex/agents-md.sh build`

Leave existing config/prompts links and Superpowers install call.

**Step 4: Run test to verify it passes**

Manual check:
- `bash codex/link.sh`
- Verify `~/.codex/AGENTS.md` generated with both fragments.

**Step 5: Commit**

```bash
git add codex/link.sh
```
