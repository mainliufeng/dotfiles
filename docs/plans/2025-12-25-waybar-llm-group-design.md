# Waybar LLM Group Design

## Goal
Move the Codex module into a dedicated LLM group that shows a single icon by default and expands on hover, keeping the right-side layout tidy.

## Approach
Add a new `group/llm` to the Waybar config with `custom/llm` (icon-only) as the first child and `custom/codex` as the second. The group uses a drawer so only the icon shows until hover. The right-side modules list swaps `custom/codex` for `group/llm`.

## Visuals
- `custom/llm` displays the `🤖` icon and uses a neutral background color.
- `custom/codex` retains its existing enabled/disabled styling.

## Data Flow
No change to the Codex module script or data. The group only affects display; hover reveals the Codex module which continues to update via its own JSON exec.

## Error Handling
No new error cases. If the Codex script fails, the group still renders the icon.

## Manual Verification
- Hover over the LLM icon to confirm Codex expands.
- Click and scroll within the Codex module to toggle/advance fragments.
