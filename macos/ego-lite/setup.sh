#!/usr/bin/env bash
set -euo pipefail

# Install the ego lite browser on macOS and wire it up for the agent CLIs.
#
# ego lite ships as a macOS app only (Linux/Windows are "Planned" on
# https://lite.ego.app/roadmap). The app bundles the `ego-browser` CLI, which is
# the connection layer every agent harness drives, so installing the app is what
# makes the `ego-browser` skill usable in pi, hermes and codex.
#
# The download/mount/install steps are the upstream installer vendored at
# `dotfiles-private/skills/ego-browser/scripts/install.sh` (ego-lite v2.0.0,
# MIT, https://github.com/citrolabs/ego-lite). Keep that copy fresh instead of
# duplicating the pinned DMG URL here. Override EGO_LITE_SKILL_DIR if the skill
# source lives somewhere else.
#
# First launch is what gives the agent this machine's Chrome state: ego lite
# asks one question, whether to migrate Chrome data. Answering yes copies the
# existing logins, cookies, extensions and bookmarks into ego lite. That step is
# GUI-only, so this script launches the app and then reports what is still
# outstanding instead of pretending the migration happened.

APP_NAME="ego lite"
APP_PATH="/Applications/$APP_NAME.app"
USER_APP_PATH="$HOME/Applications/$APP_NAME.app"
EGO_BROWSER_HELPER="ego-browser"
SKILL_DIR="${EGO_LITE_SKILL_DIR:-$HOME/dotfiles-private/skills/ego-browser}"
INSTALL_SCRIPT="$SKILL_DIR/scripts/install.sh"
PATH_CHECK_TIMEOUT="${EGO_LITE_PATH_TIMEOUT:-60}"

dry_run=0
verify_only=0

usage() {
  cat <<'EOF'
Usage: setup.sh [--dry-run | --verify]

Install the ego lite browser (macOS) from its official DMG and launch it so the
first-run onboarding can migrate Chrome data.

Options:
  --dry-run   Print what would happen without installing or launching anything
  --verify    Only report the current install and PATH status
  -h, --help  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --verify) verify_only=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

log() { printf '[ego-lite] %s\n' "$*"; }

die() {
  printf '[ego-lite] %s\n' "$*" >&2
  exit 1
}

# Same heuristic the upstream installer uses: the app counts as installed when
# its bundle actually contains a runnable ego-browser helper.
find_ego_browser_in_app() {
  local app_path="$1"
  local candidate
  [[ -d "$app_path/Contents" ]] || return 1

  for candidate in "$app_path"/Contents/Frameworks/*.framework/Versions/Current/Helpers/"$EGO_BROWSER_HELPER"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  candidate="$(find "$app_path/Contents" -type f -name "$EGO_BROWSER_HELPER" 2>/dev/null | while IFS= read -r found; do
    if [[ -x "$found" ]]; then
      printf '%s\n' "$found"
      break
    fi
  done)"
  [[ -n "$candidate" ]] || return 1
  printf '%s\n' "$candidate"
}

find_ego_lite_app() {
  local app_path
  for app_path in "$APP_PATH" "$USER_APP_PATH"; do
    if find_ego_browser_in_app "$app_path" >/dev/null 2>&1; then
      printf '%s\n' "$app_path"
      return 0
    fi
  done
  return 1
}

path_has_ego_browser() {
  command -v "$EGO_BROWSER_HELPER" >/dev/null 2>&1 ||
    [[ -x "$HOME/.local/bin/$EGO_BROWSER_HELPER" ]]
}

report_status() {
  local app_path install_state path_state
  if app_path="$(find_ego_lite_app)"; then
    install_state="installed at $app_path"
  else
    install_state="not installed"
  fi
  if path_has_ego_browser; then
    path_state="$(command -v "$EGO_BROWSER_HELPER" 2>/dev/null || printf '%s\n' "$HOME/.local/bin/$EGO_BROWSER_HELPER")"
  else
    path_state="not on PATH (finish onboarding in the app, or add ~/.local/bin)"
  fi
  printf '  app:     %s\n' "$install_state"
  printf '  command: %s\n' "$path_state"
}

wait_for_ego_browser() {
  local waited=0
  while ((waited < PATH_CHECK_TIMEOUT)); do
    if path_has_ego_browser; then
      return 0
    fi
    sleep 2
    waited=$((waited + 2))
  done
  return 1
}

print_next_steps() {
  cat <<EOF

[ego-lite] What is left for you to do in the app window that just opened:

  1. Complete onboarding. On first launch ego lite asks whether to migrate
     Chrome data. Accept it. That is the step that gives agents your existing
     logins and cookies, and it is GUI-only.
  2. Onboarding also registers the ego-browser command, normally in ~/.local/bin.

Then confirm the runtime from a terminal:

  export PATH="\$HOME/.local/bin:\$PATH"
  command -v ego-browser
  ego-browser nodejs <<<'console.log("ego-browser ready")'

Re-check this module at any time with:

  $0 --verify
EOF
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "ego lite has no official build for $(uname -s); this module is macOS-only (see https://lite.ego.app/roadmap)"
fi

log "current state:"
report_status

if [[ "$verify_only" == "1" ]]; then
  exit 0
fi

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  die "missing upstream installer: $INSTALL_SCRIPT (set EGO_LITE_SKILL_DIR to the ego-browser skill source)"
fi

if [[ "$dry_run" == "1" ]]; then
  if find_ego_lite_app >/dev/null 2>&1; then
    log "[dry-run] already installed; would launch $APP_NAME for onboarding"
  else
    log "[dry-run] would run: sh $INSTALL_SCRIPT"
  fi
  log "[dry-run] would then verify ego-browser on PATH and print onboarding steps"
  exit 0
fi

if find_ego_lite_app >/dev/null 2>&1; then
  log "already installed; opening $APP_NAME"
  open -a "$APP_NAME" || die "found the app bundle but could not open $APP_NAME"
else
  log "installing from the official DMG via $INSTALL_SCRIPT"
  # The upstream installer downloads the arch-specific DMG, strips the
  # quarantine attribute, installs to /Applications (falling back to
  # ~/Applications) and opens the app.
  sh "$INSTALL_SCRIPT" || die "ego lite installation failed"
fi

if wait_for_ego_browser; then
  log "ego-browser is ready: $(command -v "$EGO_BROWSER_HELPER" 2>/dev/null || printf '%s\n' "$HOME/.local/bin/$EGO_BROWSER_HELPER")"
else
  log "ego-browser is not on PATH yet"
  print_next_steps
  exit 0
fi

cat <<'EOF'

[ego-lite] Confirm the agent side is installed for each harness:

  python3 ~/dotfiles-private/pi/install-skills.py
  python3 ~/dotfiles-private/hermes/install-skills.py
  python3 ~/dotfiles-private/codex/install-skills.py
EOF
