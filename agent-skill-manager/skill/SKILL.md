---
name: agent-skill-manager
description: Manage the remaining Hermes and Pi skill installations using their legacy registries.
---

# Hermes / Pi Skill Manager

Use `~/dotfiles/agent-skill-manager/bin/skill-manager sync|audit --target hermes|pi|all`, optionally `--only <registry-id>` and `--dry-run` for sync. `all` means Hermes and Pi only.

Edit skill sources and the public/private TSV registries, then sync and audit the requested harness. Keep Hermes installs as real directories with internal links; Pi uses directory links. Preserve unrelated custom installs.

Codex has its own `~/dotfiles-private/codex/install-skills.py`. This manager does not install Codex skills or generate AGENTS documents.
