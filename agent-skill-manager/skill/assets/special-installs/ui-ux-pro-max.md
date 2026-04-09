# Special install: ui-ux-pro-max

`ui-ux-pro-max` should be installed through its upstream CLI flow instead of a naive directory copy.

## Why this is special

- The runtime skill files are generated from upstream templates.
- The install also depends on bundled data/scripts that the upstream CLI keeps in sync.
- Older local installs sometimes included a separate `~/src/ui-ux-pro-max` checkout. Treat that as legacy state, not the default contract.

## codex

Preferred approach:
1. Ensure the upstream CLI is available.
2. Run:
   ```bash
   uipro init --ai codex
   ```
3. If the user explicitly asked for a global install, run:
   ```bash
   uipro init --ai codex --global
   ```

## claude-code

Preferred approach:
1. Ensure the upstream CLI is available.
2. Run:
   ```bash
   uipro init --ai claude
   ```
3. If the user explicitly asked for a global install, run:
   ```bash
   uipro init --ai claude --global
   ```

## Update behavior

- Prefer the upstream update flow when available.
- If the CLI is already installed, inspect whether `uipro update` is the least risky path before reinstalling.
- If the runtime layout differs from the expected upstream layout, inspect the live machine before changing anything.

## Verification

- The runtime skill directory exists for the requested target.
- The installed skill includes its expected scripts/assets, such as `scripts/search.py`.
- If a legacy `~/src/ui-ux-pro-max` checkout exists, report it as legacy state instead of assuming it is required.
