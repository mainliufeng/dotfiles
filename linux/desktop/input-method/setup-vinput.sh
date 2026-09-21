#!/usr/bin/env bash
# Install / refresh the vinput voice input stack (fcitx5 addon + daemon).
#
# Why this exists: Linux has no WeChat/Doubao-style voice input. fcitx5-vinput
# covers it, and our fork adds a second decoding pass (streaming preview +
# offline re-decode on release) which fixes English/tech terms that a Chinese
# ASR model would otherwise mangle.
#
#   1. checks build/runtime dependencies
#   2. clones or updates the fork and builds it
#   3. installs the addon, daemon, CLI and GUI (needs sudo)
#   4. downloads the two ASR models and wires them as pass 1 / pass 2
#   5. links the hotword list and starts the user service
#   6. restarts fcitx5 so the addon is actually loaded
#
# Full guide (with screenshots):
#   https://github.com/mainliufeng/fcitx5-vinput/blob/main/docs/install-and-config-zh.md
set -euo pipefail

REPO="${VINPUT_REPO:-https://github.com/mainliufeng/fcitx5-vinput.git}"
BRANCH="${VINPUT_BRANCH:-main}"
SRC="${VINPUT_SRC:-$HOME/.cache/fcitx5-vinput}"
STREAM_MODEL="${VINPUT_STREAM_MODEL:-onnx-xasr-zh-en-960ms-punct-stream}"
REFINE_MODEL="${VINPUT_REFINE_MODEL:-onnx-xasr-zh-en-punct-int8-off}"
HOTWORDS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/hotwords.txt"
HOTWORDS_DST="$HOME/.config/vinput/hotwords.txt"
LINKER="${VINPUT_LINKER:-gold}"

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "missing command: $1" >&2
        echo "install packages first: $2" >&2
        exit 1
    fi
}

check_deps() {
    local missing=()
    for pkg in cmake ninja clang clang++ gettext fcitx5; do
        command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        echo "missing: ${missing[*]}" >&2
        echo "run: sudo pacman -S --needed base-devel cmake ninja clang gettext fcitx5 pipewire qt6-base nlohmann-json libarchive openssl curl sherpa-onnx" >&2
        exit 1
    fi
}

sync_source() {
    if [ -d "$SRC/.git" ]; then
        git -C "$SRC" fetch origin
        git -C "$SRC" checkout "$BRANCH"
        git -C "$SRC" pull --ff-only origin "$BRANCH"
    else
        rm -rf "$SRC"
        git clone --branch "$BRANCH" "$REPO" "$SRC"
    fi
}

build_and_install() {
    cd "$SRC"
    cmake --preset release-clang-mold \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=$LINKER" \
        -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=$LINKER" \
        -DCMAKE_MODULE_LINKER_FLAGS="-fuse-ld=$LINKER"
    cmake --build --preset release-clang-mold -j"$(nproc)"
    sudo cmake --install "$SRC/build"
}

configure_models() {
    vinput model list --available >/dev/null
    vinput model list | grep -q "$STREAM_MODEL" || vinput model add "$STREAM_MODEL"
    vinput model list | grep -q "$REFINE_MODEL" || vinput model add "$REFINE_MODEL"
    vinput model use "$STREAM_MODEL"          # pass 1: streaming
    vinput refine set "$REFINE_MODEL"         # pass 2: offline re-decode
}

configure_hotwords() {
    if [ -f "$HOTWORDS_SRC" ]; then
        mkdir -p "$(dirname "$HOTWORDS_DST")"
        cp "$HOTWORDS_SRC" "$HOTWORDS_DST"
        vinput hotword set "$HOTWORDS_DST" >/dev/null
    fi
}

# --- LLM 后处理（技术纠错）-------------------------------------------------
# 凭据放 dotfiles-private，不进这个仓库。
configure_llm() {
    local env_file="$HOME/dotfiles-private/deepseek/env.sh"
    if [ ! -f "$env_file" ]; then
        echo "[skip] LLM 后处理：找不到 $env_file（缺少 DeepSeek 凭据）"
        return 0
    fi

    # 密钥只放在 dotfiles-private，通过 systemd EnvironmentFile 注入 daemon；
    # config.json 里存的是 `$DEEPSEEK_API_KEY` 这个引用，不是明文。
    mkdir -p "$HOME/.config/systemd/user/vinput-daemon.service.d"
    cat >"$HOME/.config/systemd/user/vinput-daemon.service.d/llm-env.conf" <<EOF
[Service]
EnvironmentFile=-%h/dotfiles-private/deepseek/env.sh
EOF

    # shellcheck disable=SC1090
    source "$env_file"
    local base_url="${DEEPSEEK_BASE_URL:-https://api.deepseek.com/v1}"

    vinput llm remove deepseek >/dev/null 2>&1 || true
    # extra-body 关掉推理链：DeepSeek Flash 默认输出 reasoning_content，
    # 同一句纠错实测 2.6s → 0.7s，准确率不变。
    vinput llm add deepseek -u "$base_url" -k '$DEEPSEEK_API_KEY' \
        -e '{"thinking":{"type":"disabled"}}' >/dev/null

    vinput scene edit tech-polish --prompt "$(cat "$ROOT_DIR/polish-prompt.md")" \
        --provider deepseek --model deepseek-flash --count 1 --timeout 15000 2>/dev/null \
      || vinput scene add --id tech-polish --label "技术纠错（DeepSeek Flash）" \
            --prompt "$(cat "$ROOT_DIR/polish-prompt.md")" \
            --provider deepseek --model deepseek-flash --count 1 --timeout 15000 >/dev/null

    # 热词纠不回来的同音字/术语交给 LLM；用 `vinput scene use __raw__` 可关掉
    vinput scene use tech-polish >/dev/null
    echo "[ok] LLM 后处理：deepseek/deepseek-flash（密钥走环境变量），场景 tech-polish 已激活"
}

restart_stack() {
    systemctl --user enable --now vinput-daemon.service
    systemctl --user restart vinput-daemon.service
    # A running fcitx5 never picks up a newly installed addon; -r is not
    # always enough, so replace the process outright.
    pkill -x fcitx5 2>/dev/null || true
    sleep 2
    setsid nohup fcitx5 -d --replace >/dev/null 2>&1 </dev/null &
    sleep 3
}

verify() {
    echo
    echo "=== verify ==="
    echo "daemon:        $(systemctl --user is-active vinput-daemon)"
    echo "addon loaded:  $(pgrep -x fcitx5 >/dev/null && echo 'fcitx5 running (check fcitx5 log for "Loaded addon vinput")')"
    echo "pass 1 model:  $(vinput model list 2>/dev/null | grep Active | awk '{print $1}')"
    echo "pass 2 model:  $(vinput refine get 2>/dev/null | tail -1)"
    echo "hotwords:      $(vinput hotword get 2>/dev/null | tail -1)"
    echo "capture:       $(vinput device list 2>/dev/null | grep '\[\*\]' | awk '{print $1}')"
    echo "llm provider:  $(vinput llm list 2>/dev/null | tail -n +2 | awk '{print $1}' | tr '\n' ' ')"
    echo "active scene:  $(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.config/vinput/config.json')))['scenes']['active_scene'])" 2>/dev/null)"
    echo
    echo "Usage: hold Right-Alt and speak, release to insert."
    echo "Debug both passes:  journalctl --user -u vinput-daemon | grep -E 'pass 1|pass 2'"
}

main() {
    require_cmd git "sudo pacman -S --needed git"
    check_deps
    sync_source
    build_and_install
    configure_models
    configure_hotwords
    configure_llm
    restart_stack
    verify
    echo "vinput (two-pass) is ready."
}

main "$@"
