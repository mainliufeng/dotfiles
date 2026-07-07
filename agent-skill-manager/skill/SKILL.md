---
name: agent-skill-manager
description: Install, update, audit, and compare skills across Codex and Hermes using the local skill registry and fixed sync script.
---

# agent-skill-manager

Use this skill when the user wants to:
- install skills for Codex or Hermes
- update already-installed skills
- compare skill coverage across Codex and Hermes
- audit drift between the catalog and runtime directories
- sync runtime instruction docs such as `AGENTS.md`
- compare or audit rendered runtime docs against the markdown source catalog
- bootstrap skills on a fresh machine

## Read order

Before taking action, read these files in this order:
1. `assets/targets.md`
2. `assets/registries/public-skills.tsv`
3. If it exists, `~/dotfiles-private/agent-skill-manager/assets/registries/private-skills.tsv`
4. `assets/skill-catalog.md` when you need human-readable migration notes
5. If it exists, `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` when you need human-readable migration notes
6. `assets/agent-doc-catalog.md` when the request touches runtime docs
7. If it exists, `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md`

## Core behavior

1. Parse the user's intent:
   - install
   - update
   - check/audit
   - compare
   - sync-docs
   - audit-docs
   - compare-docs
2. Determine which targets are in scope:
   - codex
   - hermes
3. Detect the current platform:
   - `macos` when `uname -s` is `Darwin`
   - `archlinux` only when Linux `/etc/os-release` reports Arch or Arch-like
4. Read the relevant markdown catalogs and build a concrete action plan.
5. Skip catalog rows whose `platforms` value does not match the current platform, unless the value is `all`.
6. Prefer the fixed script over hand-written install commands:
   - `~/dotfiles/agent-skill-manager/bin/skill-manager sync --dry-run`
   - `~/dotfiles/agent-skill-manager/bin/skill-manager sync`
   - `~/dotfiles/agent-skill-manager/bin/skill-manager audit`
7. Verify using script output and runtime checks.
9. Report:
   - installed
   - updated
   - skipped
   - failed
   - rendered
   - unchanged
   - follow-up needed

## Important rules

- Do not assume Codex and Hermes use the same skill directory layout.
- Do not assume all catalog entries apply on all machines. Respect the `platforms` column.
- Treat `archlinux` as the only Linux platform currently managed by this catalog; do not broaden it to generic Linux without updating the catalog first.
- Do not check or install pure runtime built-ins. If a platform's runtime already includes a skill, omit that platform from the registry row.
- Treat `assets/registries/public-skills.tsv` plus the private registry overlay as the execution source of truth.
- Treat old Markdown catalogs as human-readable notes, not install instructions.
- A private skill listed in `~/dotfiles-private/agent-skill-manager/assets/registries/private-skills.tsv` is considered registered and may be installed without extra confirmation.
- Treat `assets/agent-doc-catalog.md` plus `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md` as the source of truth for runtime docs when the user asks to sync them.
- If a skill is missing from both catalogs, stop and ask the user whether to add it.
- If a requested fragment or doc profile is missing from both public and private doc catalogs, stop and ask before inventing it.
- When a path or runtime assumption looks stale, inspect the live machine before changing anything.
- For installs and updates: run the fixed sync script rather than manually recreating adapter behavior.
- For doc sync: render from markdown fragments and profiles instead of hand-editing generated runtime files.
- Public and private skill sources are defined by the registry `source_path`.
- The cold library is `~/.local/share/agent-skill-manager/skills/`; manual packs live there but do not enter Codex auto-discovery.
- For Hermes local/private installs, never make `~/.hermes/skills/<category>/<skill-name>` itself a directory symlink; create a real installed directory there and symlink or copy `SKILL.md` plus needed subdirs inside it.
- If Hermes shows warnings or `hermes skills list` omits a skill that exists in source, inspect whether the installed path is a top-level directory symlink before changing the source skill.

## Current scope

This first version is intentionally conservative:
- the manager skill itself can be bootstrapped by `~/dotfiles/agent-skill-manager/setup.sh`
- the rest of the registry is installed by `~/dotfiles/agent-skill-manager/bin/skill-manager`
- runtime instruction docs are also managed in dialog from markdown catalogs and fragments
- third-party imported skills should be normalized to direct GitHub sources whenever upstream repos exist
