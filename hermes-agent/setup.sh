#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
INSTALL_DIR="${HERMES_INSTALL_DIR:-$HERMES_HOME/hermes-agent}"
HERMES_BIN="$INSTALL_DIR/venv/bin/hermes"
LINK_DIR="$HOME/.local/bin"
LINK_PATH="$LINK_DIR/hermes"
INSTALL_TIMEOUT="${HERMES_INSTALL_TIMEOUT:-1200}"

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

if [[ -x "$HERMES_BIN" ]]; then
  link_hermes
  echo "[hermes-agent] using existing install at $INSTALL_DIR"
  exit 0
fi

if command -v timeout >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | timeout "$INSTALL_TIMEOUT" bash
else
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
fi

if [[ -x "$HERMES_BIN" ]]; then
  link_hermes
fi
