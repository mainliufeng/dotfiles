# Targets

This file describes where each runtime currently expects skills to live.

## codex
- Runtime skill dir: `~/.codex/skills`
- Style: mostly flat directory per skill
- Notes:
  - Some upstream installers are Codex-native
  - The official Codex user skill location is `$HOME/.agents/skills`, but this machine currently manages the legacy/app runtime path `~/.codex/skills`
  - Do not use `.agents/skills`, `.agent/skills`, or `~/.codex/skills` as a cold library path

## hermes
- Runtime skill dir: `~/.hermes/skills`
- Style: category/name layout is preferred
- Suggested category for this manager: `meta/agent-skill-manager`
- Notes:
  - `SKILL.md` must remain readable in the installed path
  - Category `DESCRIPTION.md` files may be needed

## cold library
- Library dir: `~/.local/share/agent-skill-manager/skills`
- Style: flat symlink registry
- Notes:
  - Every configured skill or pack gets a stable library link here first
  - Manual packs such as `gstack` and `mattpocock-skills` stay here and do not enter runtime auto-discovery
