# Targets

This file describes where each runtime currently expects skills to live.

## hermes
- Runtime skill dir: `~/.hermes/skills`
- Style: category/name layout is preferred
- Suggested category for this manager: `meta/agent-skill-manager`
- Notes:
  - `SKILL.md` must remain readable in the installed path
  - Category `DESCRIPTION.md` files may be needed

## pi
- Runtime skill dir: `~/.pi/agent/skills`
- Style: flat directory per skill
- Notes:
  - Pi discovers skills from `~/.pi/agent/skills/` and `~/.agents/skills/`
  - Direct root `.md` files in `~/.pi/agent/skills/` are discovered as individual skills
  - Pi also supports reading from other harness directories via `settings.json` `skills` array
  - Symlinks work as expected; pi treats them as regular skill directories

## cold library
- Library dir: `~/.local/share/agent-skill-manager/skills`
- Style: flat symlink registry
- Notes:
  - Every configured skill or pack gets a stable library link here first
  - Manual packs such as `gstack` stay here and do not enter runtime auto-discovery
  - Nested bundles such as `mattpocock-skills` may also expose each non-deprecated child as a flat runtime skill
