#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dry_run=0
force_upgrade=0
start_now=1

usage() {
  cat <<'EOF'
Usage: setup.sh [options]

Install/update the Happy CLI and run its daemon as a systemd user service, so
the phone app can reach this machine at boot.

  1. npm install -g --allow-scripts=happy happy@latest
  2. link happy.service into ~/.config/systemd/user/
  3. systemctl --user enable --now happy.service

Happy's bundled `daemon install` is macOS/launchd-only, which is why this module
ships its own unit.

Options:
  --dry-run    Print the actions without changing the machine
  --upgrade    Reinstall happy even when the installed version is current
  --no-start   Enable the service but do not start it now
  -h, --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --upgrade) force_upgrade=1; shift ;;
    --no-start) start_now=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[happy] this installer is Linux-only" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "[happy] npm is required (install nodejs/npm first)" >&2
  exit 1
fi

# 1. CLI ---------------------------------------------------------------------
# Read the installed version from package.json instead of running `happy
# --version`: any `happy` invocation auto-starts a detached daemon, which would
# then make the systemd unit exit with "daemon version matches".
npm_root="$(npm root -g 2>/dev/null)"
happy_bin="$(command -v happy || true)"
installed=""
if [[ -n "$npm_root" && -f "$npm_root/happy/package.json" ]]; then
  installed="$(node -p "require('$npm_root/happy/package.json').version" 2>/dev/null || true)"
fi

latest="$(npm view happy version 2>/dev/null || true)"
tools_dir="$npm_root/happy/tools/unpacked"

need_install=1
if [[ -n "$installed" && -n "$latest" && "$installed" == "$latest" && -d "$tools_dir" && "$force_upgrade" != "1" ]]; then
  need_install=0
  echo "[happy] CLI already current: $installed"
fi

if [[ "$need_install" == "1" ]]; then
  echo "[happy] installing happy@latest (installed: ${installed:-none}, latest: ${latest:-unknown})"
  # npm >= 12 blocks install-time lifecycle scripts unless the package is
  # allowlisted; happy's postinstall unpacks its bundled difftastic/ripgrep.
  run npm install -g --allow-scripts=happy happy@latest
  if [[ "$dry_run" != "1" ]]; then
    command -v happy >/dev/null 2>&1 || { echo "[happy] 'happy' is not on PATH after install" >&2; exit 1; }
    [[ -d "$tools_dir" ]] || echo "[happy] warning: bundled tools were not unpacked ($tools_dir missing)" >&2
  fi
fi

# 2. Service -----------------------------------------------------------------
run "$module_dir/link.sh"

if [[ "$start_now" == "1" ]]; then
  run systemctl --user enable happy.service
  if [[ "$dry_run" != "1" ]]; then
    # Stop any daemon started outside systemd (e.g. a manual `happy` run), so
    # the unit's own process becomes the daemon instead of exiting immediately.
    systemctl --user stop happy.service 2>/dev/null || true
    happy daemon stop >/dev/null 2>&1 || true
  fi
  run systemctl --user restart happy.service
  if [[ "$dry_run" != "1" ]]; then
    sleep 5
    systemctl --user --no-pager --lines=0 status happy.service || true
    echo "[happy] daemon state:"
    # Read the state file rather than `happy daemon status`: any `happy` call
    # auto-starts a daemon, which would mask a failed unit.
    cat "${HAPPY_HOME_DIR:-$HOME/.happy}/daemon.state.json" 2>/dev/null || echo "  (none)"
  fi
else
  run systemctl --user enable happy.service
fi

# 3. Checks ------------------------------------------------------------------
if [[ "$dry_run" != "1" ]]; then
  if ! claude --version >/dev/null 2>&1; then
    echo "[happy] warning: 'claude' is not usable; run 'node $(npm root -g)/@anthropic-ai/claude-code/install.cjs'" >&2
  fi
  if ! command -v codex >/dev/null 2>&1; then
    echo "[happy] warning: 'codex' is not on PATH" >&2
  fi
fi

cat <<'EOF'

[happy] done. Phone setup:
  iOS      https://apps.apple.com/app/happy-claude-code-client/id6748571505
  Android  https://play.google.com/store/apps/details?id=com.ex3ndr.happy
  Then pair this machine (happy auth / happy daemon status show the state) and
  start sessions from the app, or use `happy claude` / `happy codex` here.
EOF
