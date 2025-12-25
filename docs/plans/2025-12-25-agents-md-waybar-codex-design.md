# Agents-md Waybar Codex Module Design

## Goal
Add a Waybar module that shows the current AGENTS.md fragment selection and lets the user toggle fragments directly from the bar (click to toggle, scroll to move selection). The module must expose a checkbox for every fragment via tooltip.

## Architecture
Introduce a single Waybar `custom/codex` module that executes a shell script to emit JSON (`text`, `tooltip`, `class`). The script reads fragments from `codex/agents_md/*.md`, tracks enabled fragments from `~/.codex/agents_md.enabled`, and stores a cursor for the currently selected fragment in `~/.codex/agents_md.cursor`.

## Components
- `codex/agents_md/waybar-codex.sh`: the script that outputs JSON and handles `next`, `prev`, `toggle` commands.
- `hyprland/waybar/config`: adds `custom/codex` module and binds click/scroll to script commands.
- `hyprland/waybar/style.css`: optional styling for the module and state classes.

## Data Flow
1. Waybar runs `waybar-codex.sh status` on interval to render JSON.
2. The script loads fragment names, enabled list, and cursor.
3. `text` shows `Codex` + current fragment + checkbox; `tooltip` lists all fragments with checkboxes.
4. On click, Waybar invokes `waybar-codex.sh toggle` which calls `agents-md enable|disable <name>` and updates the cursor file.
5. On scroll, Waybar invokes `waybar-codex.sh next|prev` to move selection and update the cursor file.

## Error Handling
- If no fragments are found, return a simple `text` fallback (e.g., `Codex [no fragments]`) and a tooltip note.
- If the cursor points to a missing fragment, reset to the first available fragment.
- If `~/.codex/agents_md.enabled` is missing, treat it as empty (all unchecked) but still allow toggling.

## Testing
- Run the script directly to verify JSON output and tooltip content.
- Verify click toggles update `~/.codex/agents_md.enabled` and regenerate `~/.codex/AGENTS.md`.
- Verify scroll updates the current fragment and the bar text reflects it.
