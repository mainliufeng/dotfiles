# agent-skill-manager

A new, isolated replacement for the old `agent_config/` flow.

Goal: install one manager skill into Codex, Claude Code, and Hermes. That skill then acts as the control plane for installing, updating, auditing, and comparing the rest of your skills.

This repo intentionally does **not** replace `~/dotfiles/agent_config` yet. Run them side-by-side until this one is proven.

## Layout

- `skill/` — the actual reusable skill that gets linked into each agent runtime
- `setup.sh` — installs the manager skill itself via symlinks
- `skill/assets/targets.md` — runtime locations and target notes
- `skill/assets/skill-catalog.md` — public human-maintained list of managed skills
- `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` — optional private overlay catalog
- `skill/assets/install-defaults/` — default installation strategy per agent
- `skill/assets/special-installs/` — exceptions like gstack and superpowers
- `skill/assets/verification/` — how to verify installs per agent

## Usage

Install the manager skill everywhere we currently support:

```bash
~/dotfiles/agent-skill-manager/setup.sh
```

Install only one target:

```bash
~/dotfiles/agent-skill-manager/setup.sh --target hermes
~/dotfiles/agent-skill-manager/setup.sh --target codex
```

Preview only:

```bash
~/dotfiles/agent-skill-manager/setup.sh --dry-run
```

## Current status

- Codex: supported
- Claude Code: supported
- Hermes: supported

## Migration plan

1. Keep `agent_config/` untouched.
2. Evolve this skill until it can reliably install/update/check the full catalog.
3. Once proven, delete or archive `agent_config/`.
