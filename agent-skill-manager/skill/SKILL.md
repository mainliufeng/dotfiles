---
name: agent-skill-manager
description: Install, update, audit, and compare skills across Codex, Claude Code, and Hermes using a single markdown-maintained control skill.
---

# agent-skill-manager

Use this skill when the user wants to:
- install skills for one or more agent runtimes
- update already-installed skills
- compare skill coverage across runtimes
- audit drift between the catalog and runtime directories
- sync runtime instruction docs such as `AGENTS.md` or `CLAUDE.md`
- compare or audit rendered runtime docs against the markdown source catalog
- bootstrap skills on a fresh machine

## Read order

Before taking action, read these files in this order:
1. `assets/targets.md`
2. `assets/skill-catalog.md`
3. If it exists, `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md`
4. `assets/agent-doc-catalog.md` when the request touches runtime docs
5. If it exists, `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md`
6. `assets/install-defaults/<target>.md` for each requested target
7. `assets/special-installs/<skill>.md` if the catalog marks that skill as special
8. `assets/verification/<target>.md` before finalizing

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
   - claude-code
   - hermes
3. Read the relevant markdown catalogs and build a concrete action plan.
4. Show a short dry-run summary before making changes.
5. Execute using the local filesystem and shell tools.
6. Verify using the target verification docs and render rules.
7. Report:
   - installed
   - updated
   - skipped
   - failed
   - rendered
   - unchanged
   - follow-up needed

## Important rules

- Do not assume all runtimes use the same skill directory layout.
- Prefer the target's default install doc unless a special-install doc exists.
- Treat the public catalog plus the private catalog overlay (when present) as the source of truth.
- A private skill listed in `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` is considered registered and may be installed without extra confirmation.
- Treat `assets/agent-doc-catalog.md` plus `~/dotfiles-private/agent-skill-manager/assets/private-agent-doc-catalog.md` as the source of truth for runtime docs when the user asks to sync them.
- If a skill is missing from both catalogs, stop and ask the user whether to add it.
- If a requested fragment or doc profile is missing from both public and private doc catalogs, stop and ask before inventing it.
- When a path or runtime assumption looks stale, inspect the live machine before changing anything.
- For installs: default to missing-only behavior unless the user asked for reinstall.
- For updates: refresh existing installs but do not silently add new catalog entries unless requested.
- For doc sync: render from markdown fragments and profiles instead of hand-editing generated runtime files.
- Public local skills resolve from `~/dotfiles/agent-skill-manager/public_skills/<skill-name>` unless a public catalog entry says otherwise.
- Private local skills resolve from `~/dotfiles-private/agent-skill-manager/private_skills/<skill-name>` unless a private overlay explicitly says otherwise.

## Current scope

This first version is intentionally conservative:
- the manager skill itself is linked by `~/dotfiles/agent-skill-manager/setup.sh`
- the rest of the catalog is managed by agent execution using these docs
- runtime instruction docs are also managed in dialog from markdown catalogs and fragments
- third-party imported skills should be normalized to direct GitHub sources whenever upstream repos exist
