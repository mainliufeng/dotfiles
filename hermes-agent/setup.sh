#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
INSTALL_DIR="${HERMES_INSTALL_DIR:-$HERMES_HOME/hermes-agent}"
HERMES_BIN="$INSTALL_DIR/venv/bin/hermes"
LINK_DIR="$HOME/.local/bin"
LINK_PATH="$LINK_DIR/hermes"
INSTALL_TIMEOUT="${HERMES_INSTALL_TIMEOUT:-1200}"
INSTALL_URL="https://hermes-agent.nousresearch.com/install.sh"
DESKTOP_LINK="$HOME/Applications/Hermes.app"

desktop_app_path() {
  local candidate

  for candidate in \
    "$INSTALL_DIR/apps/desktop/release/mac-arm64/Hermes.app" \
    "$INSTALL_DIR/apps/desktop/release/mac/Hermes.app"; do
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

link_hermes() {
  mkdir -p "$LINK_DIR"
  cat > "$LINK_PATH" <<EOF
#!/usr/bin/env bash
unset PYTHONPATH
unset PYTHONHOME
exec "$HERMES_BIN" "\$@"
EOF
  chmod +x "$LINK_PATH"
}

link_desktop_app() {
  local app_path

  app_path="$(desktop_app_path)" || return 1
  mkdir -p "$(dirname "$DESKTOP_LINK")"

  if [[ -e "$DESKTOP_LINK" && ! -L "$DESKTOP_LINK" ]]; then
    echo "[hermes-agent] keeping existing app at $DESKTOP_LINK"
    return 0
  fi

  ln -sfn "$app_path" "$DESKTOP_LINK"
  echo "[hermes-agent] linked desktop app: $DESKTOP_LINK -> $app_path"
}

install_is_complete() {
  [[ -x "$HERMES_BIN" ]] || return 1

  if [[ "$(uname -s)" == "Darwin" ]]; then
    desktop_app_path >/dev/null
  fi
}

if install_is_complete; then
  link_hermes
  if [[ "$(uname -s)" == "Darwin" ]]; then
    link_desktop_app
  fi
  echo "[hermes-agent] using existing install at $INSTALL_DIR"
  exit 0
fi

installer_path="$(mktemp "${TMPDIR:-/tmp}/hermes-install.XXXXXX")"
trap 'rm -f "$installer_path"' EXIT
curl -fsSL "$INSTALL_URL" -o "$installer_path"

installer_args=(--skip-setup --non-interactive)
if [[ "$(uname -s)" == "Darwin" ]]; then
  installer_args+=(--include-desktop)
fi

if command -v timeout >/dev/null 2>&1; then
  timeout "$INSTALL_TIMEOUT" bash "$installer_path" "${installer_args[@]}"
else
  bash "$installer_path" "${installer_args[@]}"
fi

if [[ ! -x "$HERMES_BIN" ]]; then
  echo "[hermes-agent] installer completed without creating $HERMES_BIN" >&2
  exit 1
fi

link_hermes

if [[ "$(uname -s)" == "Darwin" ]] && ! link_desktop_app; then
  echo "[hermes-agent] installer completed without building Hermes.app" >&2
  exit 1
fi
