# Special install: superpowers

`superpowers` should be treated as a bootstrap system, not just a copied skill directory.

## Current state
- Historical docs referenced a Codex path from Claude instructions.
- Live runtime should be inspected before assuming that is still correct.

## codex
Default approach:
1. Inspect whether a dedicated superpowers checkout or bootstrap binary already exists.
2. If upstream bootstrap instructions are available, use the Codex-specific flow.
3. Verify the resulting executable/path actually exists.

## claude-code
Default approach:
1. Do **not** assume Claude should call into a Codex path unless the live install proves that is intended.
2. Prefer a Claude-specific bootstrap/install flow if one exists.
3. If the only real implementation is shared with Codex, document that explicitly and verify the shared path.

## Verification
- The advertised bootstrap executable exists
- Running the bootstrap help command or equivalent succeeds
- Any generated runtime instructions point at real paths
