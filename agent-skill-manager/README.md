# agent-skill-manager

A registry-driven replacement for the old `agent_config/` flow.

Goal: install one manager skill into Codex and Hermes, then use a fixed script to sync the configured skill registry into runtime skill directories. The manager skill remains the planning and review interface; `bin/skill-manager` performs the filesystem work.

This repo now owns the manager skill, public local skills, and runtime doc catalogs that previously lived under `agent_config/`.

## Layout

- `skill/` — the actual reusable skill that gets linked into each agent runtime
- `setup.sh` — bootstraps the manager skill itself
- `bin/skill-manager` — syncs and audits configured skills for Codex and Hermes
- `skill/assets/registries/public-skills.tsv` — machine-readable public skill registry
- `~/dotfiles-private/agent-skill-manager/assets/registries/private-skills.tsv` — optional private machine-readable registry
- `skill/assets/targets.md` — runtime locations and target notes
- `public_skills/` — public local skill source directories managed by this repo
- `skill/assets/agent-doc-catalog.md` — markdown source of truth for runtime instruction docs
- `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md` — optional private overlay for runtime docs
- `skill/assets/agent-doc-fragments/` — reusable fragments for rendered runtime docs

## Usage

Bootstrap the manager skill everywhere we currently support:

```bash
~/dotfiles/agent-skill-manager/setup.sh
```

Bootstrap only one target:

```bash
~/dotfiles/agent-skill-manager/setup.sh --target hermes
~/dotfiles/agent-skill-manager/setup.sh --target codex
```

Sync all configured skills:

```bash
~/dotfiles/agent-skill-manager/bin/skill-manager sync
```

Audit all configured skills:

```bash
~/dotfiles/agent-skill-manager/bin/skill-manager audit
```

Preview sync only:

```bash
~/dotfiles/agent-skill-manager/bin/skill-manager sync --dry-run
```

Runtime note:

- `setup.sh` only bootstraps the manager skill itself.
- `bin/skill-manager sync` installs the configured registry into Codex and Hermes.
- `bin/skill-manager audit` checks the configured registry without touching unrelated runtime skills.
- Public local skills live under `~/dotfiles/agent-skill-manager/public_skills/`.
- Hermes caveat: do **not** install ordinary local/private skills by making `~/.hermes/skills/<category>/<skill-name>` a whole-directory symlink. For Hermes local/private skills, the installed path should be a real directory that contains `SKILL.md` plus any needed subdirs as internal symlinks or copies.
- Broad/manual packs such as `gstack` and `mattpocock-skills` are linked into `~/.local/share/agent-skill-manager/skills/` but are not installed into Codex auto-discovery.

## Current status

- Codex: supported
- Hermes: supported

## Migration status

1. Public local skills now live under `public_skills/`.
2. Runtime docs are described by markdown catalogs and fragments in this repo.
3. Private overlays stay in `~/dotfiles-private/agent-skill-manager/`.
4. The machine-readable TSV registries are the only skill execution source of truth; legacy Markdown install notes have been removed.
