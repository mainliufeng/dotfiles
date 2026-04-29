# agent-skill-manager

A markdown-driven replacement for the old `agent_config/` flow.

Goal: install one manager skill into Codex, Claude Code, and Hermes. That skill then acts as the control plane for installing, updating, auditing, and comparing the rest of your skills, and for syncing runtime instruction docs such as `AGENTS.md` and `CLAUDE.md`.

This repo now owns the manager skill, public local skills, and runtime doc catalogs that previously lived under `agent_config/`.

## Layout

- `skill/` — the actual reusable skill that gets linked into each agent runtime
- `setup.sh` — installs the manager skill itself via symlinks
- `skill/assets/targets.md` — runtime locations and target notes
- `skill/assets/skill-catalog.md` — public human-maintained list of managed skills
- `public_skills/` — public local skill source directories managed by this repo
- `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` — optional private overlay catalog
- `skill/assets/agent-doc-catalog.md` — markdown source of truth for runtime instruction docs
- `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md` — optional private overlay for runtime docs
- `skill/assets/agent-doc-fragments/` — reusable fragments for rendered runtime docs
- `skill/assets/install-defaults/` — default installation strategy per agent
- `skill/assets/special-installs/` — exceptions like gstack, impeccable, and notebooklm
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

Runtime note:

- `setup.sh` only links the manager skill itself into each runtime.
- Skill installation, updates, audits, and runtime doc sync are executed in dialog through the manager skill.
- Public local skills live under `~/dotfiles/agent-skill-manager/public_skills/`.
- Hermes caveat: do **not** install ordinary local/private skills by making `~/.hermes/skills/<category>/<skill-name>` a whole-directory symlink. For Hermes local/private skills, the installed path should be a real directory that contains `SKILL.md` plus any needed subdirs as internal symlinks or copies.
- The manager skill bootstrap symlink created by `setup.sh` is a narrow exception for the manager skill itself, not a template for all Hermes local skills.

## Current status

- Codex: supported
- Claude Code: supported
- Hermes: supported

## Migration status

1. Public local skills now live under `public_skills/`.
2. Runtime docs are described by markdown catalogs and fragments in this repo.
3. Private overlays stay in `~/dotfiles-private/agent-skill-manager/`.
4. Remaining work is catalog completeness and workflow polish, not ownership transfer from `agent_config/`.
