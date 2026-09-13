# Happy (mobile control for Claude Code / Codex)

[Happy](https://happy.engineering) is a mobile + web client for Claude Code and
Codex. The CLI wraps the agents you already have installed, end-to-end encrypts
the session, and lets the phone take over the same conversation.

```bash
~/dotfiles/linux/services/happy/setup.sh
```

Options: `--dry-run`, `--upgrade`, `--no-start`.

The module is in `linux/services/` rather than `linux/apps/` because the point of
it is the always-on daemon, not the CLI.

## What it does

1. `npm install -g --allow-scripts=happy happy@latest`
2. Symlinks `happy.service` into `~/.config/systemd/user/`
3. `systemctl --user enable --now happy.service`

## Why there is a custom unit

`happy daemon install` only supports macOS (launchd, requires sudo). On Linux the
daemon is just a foreground process, so the unit runs `daemon start-sync` — the
long-running process that `happy daemon start` normally spawns detached —
directly under systemd. `Restart=always` keeps it up.

`Linger=yes` is already set for this user, so `WantedBy=default.target` means the
daemon starts at boot, not at desktop login.

## PATH

The unit sets `PATH` explicitly. This matters: the daemon spawns `claude` and
`codex` sessions and resolves them from `PATH`, and a systemd user service does
not read `~/.zshrc`. The curated list covers the global npm bin dir (`happy`,
`claude`, `codex`, `pi`), `~/.local/bin`, bun, opencode and the pyenv shims.

If an agent needs a tool outside that list, extend it:

```bash
systemctl --user edit happy.service   # add Environment=PATH=...
systemctl --user restart happy.service
```

## npm >= 12 and lifecycle scripts

npm 12 blocks install-time lifecycle scripts for packages that are not
allowlisted. Two consequences on this machine:

- `happy` ships bundled `difftastic` / `ripgrep` archives that a postinstall
  unpacks into `tools/unpacked`; without `--allow-scripts=happy` that dir is
  missing. The module passes the flag.
- `@anthropic-ai/claude-code` copies its native binary over a stub in its
  postinstall. When that is blocked, `claude --version` fails with
  "claude native binary not installed" and `happy claude` cannot start. Fix with
  `node "$(npm root -g)/@anthropic-ai/claude-code/install.cjs"`.

## Using it

- Sessions started here (`happy claude`, `happy codex`) can be taken over from
  the phone; pressing a key at the desk takes control back.
- The daemon also lets the phone spawn new sessions on this machine.
- `happy daemon status` / `happy doctor` for diagnostics,
  `happy doctor clean` to clean up runaway processes.
- Self-host the sync server with `happy server` if the hosted one is not wanted.

## Notes

- `happy-coder` is the former package name. Having both installed creates two
  packages that both provide the `happy` bin; keep only `happy`.
- The daemon is not tied to the graphical session, so it keeps running when the
  desktop is not logged in.
