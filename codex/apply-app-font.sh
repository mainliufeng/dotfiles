#!/usr/bin/env bash
set -euo pipefail

codex_dir="${CODEX_HOME:-$HOME/.codex}"
state_file="$codex_dir/.codex-global-state.json"
font_family="${CODEX_APP_FONT_FAMILY:-Hack Nerd Font Mono}"

if ! command -v jq >/dev/null 2>&1; then
  echo "[codex] jq is required to update $state_file" >&2
  echo "[codex] install it with: brew install jq" >&2
  exit 1
fi

mkdir -p "$codex_dir"

if [ ! -e "$state_file" ]; then
  printf '{}\n' > "$state_file"
  chmod 600 "$state_file"
fi

tmp_state="$(mktemp)"
trap 'rm -f "$tmp_state"' EXIT

jq --arg font_family "$font_family" \
  '
  .codeFontFamily = $font_family
  | if .appearanceLightChromeTheme | type == "object" then
      .appearanceLightChromeTheme.fonts =
        ((.appearanceLightChromeTheme.fonts // {}) + {code: $font_family})
    else
      .
    end
  | if .appearanceDarkChromeTheme | type == "object" then
      .appearanceDarkChromeTheme.fonts =
        ((.appearanceDarkChromeTheme.fonts // {}) + {code: $font_family})
    else
      .
    end
  ' \
  "$state_file" > "$tmp_state"

mv "$tmp_state" "$state_file"
chmod 600 "$state_file"
trap - EXIT

echo "[codex] set app code/terminal font -> $font_family"
