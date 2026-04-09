# Targets

This file describes where each runtime currently expects skills to live.

## codex
- Runtime skill dir: `~/.codex/skills`
- Style: mostly flat directory per skill
- Notes:
  - Some upstream installers are Codex-native
  - Existing runtime may contain generated gstack subskills

## claude-code
- Runtime skill dir: `~/.claude/skills`
- Style: flat directory per skill
- Notes:
  - Historically shares many skills with Codex, but not all
  - Some special installs may have Claude-specific bootstrap steps

## hermes
- Runtime skill dir: `~/.hermes/skills`
- Style: category/name layout is preferred
- Suggested category for this manager: `meta/agent-skill-manager`
- Notes:
  - `SKILL.md` must remain readable in the installed path
  - Category `DESCRIPTION.md` files may be needed

