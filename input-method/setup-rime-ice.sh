#!/usr/bin/env bash
set -euo pipefail

RIME_ICE_REPO="${RIME_ICE_REPO:-https://github.com/iDvel/rime-ice.git}"
RIME_ICE_SRC="${RIME_ICE_SRC:-$HOME/.cache/rime-ice}"
RIME_DIR="${RIME_DIR:-$HOME/.local/share/fcitx5/rime}"
FCITX_PROFILE="${FCITX_PROFILE:-$HOME/.config/fcitx5/profile}"
SHARED_RIME_DIR="${SHARED_RIME_DIR:-/usr/share/rime-data}"

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "missing command: $1" >&2
        echo "install packages first: sudo pacman -S git rsync python fcitx5 fcitx5-rime librime" >&2
        exit 1
    fi
}

backup_rime_dir() {
    if [ -d "$RIME_DIR" ]; then
        local backup
        backup="$RIME_DIR.backup.$(date +%Y%m%d%H%M%S)"
        mkdir -p "$backup"
        rsync -a "$RIME_DIR/" "$backup/"
        echo "backup: $backup"
    fi
}

sync_rime_ice() {
    if [ -d "$RIME_ICE_SRC/.git" ]; then
        git -C "$RIME_ICE_SRC" pull --ff-only
    else
        rm -rf "$RIME_ICE_SRC"
        git clone --depth 1 "$RIME_ICE_REPO" "$RIME_ICE_SRC"
    fi

    mkdir -p "$RIME_DIR"
    rsync -a \
        --exclude='.git/' \
        --exclude='.github/' \
        --exclude='.gitignore' \
        "$RIME_ICE_SRC/" "$RIME_DIR/"

    cat >"$RIME_DIR/rime_ice.custom.yaml" <<'EOF'
patch:
  switches/@0/reset: 0
EOF
}

set_fcitx_default_rime() {
    mkdir -p "$(dirname "$FCITX_PROFILE")"

    python3 - "$FCITX_PROFILE" <<'PY'
from pathlib import Path
import re
import sys

profile = Path(sys.argv[1])

minimal = """[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=rime

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=rime
# Layout
Layout=

[GroupOrder]
0=Default
"""

if not profile.exists():
    profile.write_text(minimal)
    raise SystemExit

text = profile.read_text()

if re.search(r"^DefaultIM=", text, flags=re.M):
    text = re.sub(r"^DefaultIM=.*$", "DefaultIM=rime", text, count=1, flags=re.M)
else:
    text = re.sub(r"(\[Groups/0\]\n)", r"\1# Default Input Method\nDefaultIM=rime\n", text, count=1)

if not re.search(r"^Name=rime$", text, flags=re.M):
    indices = [int(m.group(1)) for m in re.finditer(r"^\[Groups/0/Items/(\d+)\]$", text, flags=re.M)]
    next_index = max(indices, default=-1) + 1
    text = text.rstrip() + f"""

[Groups/0/Items/{next_index}]
# Name
Name=rime
# Layout
Layout=
"""

if "[GroupOrder]" not in text:
    text = text.rstrip() + "\n\n[GroupOrder]\n0=Default\n"

profile.write_text(text)
PY
}

deploy_rime() {
    require_cmd rime_deployer
    rime_deployer --build "$RIME_DIR" "$SHARED_RIME_DIR" "$RIME_DIR/build"
    (cd "$RIME_DIR" && rime_deployer --set-active-schema rime_ice)
}

reload_fcitx() {
    if command -v fcitx5-remote >/dev/null 2>&1 && fcitx5-remote --check >/dev/null 2>&1; then
        fcitx5-remote -r >/dev/null 2>&1 || true
        sleep 0.3
        fcitx5-remote -o >/dev/null 2>&1 || true
        fcitx5-remote -s rime >/dev/null 2>&1 || true
        local active
        active="$(fcitx5-remote -n 2>/dev/null || true)"
        if [ -n "$active" ]; then
            echo "active input method: $active"
        else
            echo "active input method: unavailable until an input field is focused"
        fi
    else
        echo "fcitx5 is not running; start/relogin, then select Rime."
    fi
}

print_result() {
    echo "fcitx default: $(grep -m1 '^DefaultIM=' "$FCITX_PROFILE" 2>/dev/null | cut -d= -f2-)"
    echo "rime schema: $(grep -m1 'previously_selected_schema:' "$RIME_DIR/user.yaml" 2>/dev/null | awk '{print $2}')"
}

main() {
    require_cmd git
    require_cmd rsync
    require_cmd python3

    backup_rime_dir
    sync_rime_ice
    set_fcitx_default_rime
    deploy_rime
    reload_fcitx
    print_result

    echo "Rime Ice is ready: $RIME_DIR"
}

main "$@"
