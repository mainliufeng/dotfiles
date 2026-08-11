#!/usr/bin/env bash
set -euo pipefail

DEEPTUTOR_VERSION="1.5.11"
DEEPTUTOR_HOME="${DEEPTUTOR_HOME:-$HOME/.local/share/deeptutor}"
PRIVATE_LLM_ENV="$HOME/dotfiles-private/llm/env.sh"
ALIYUN_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
MODEL_ID="deepseek-v4-flash"

umask 077

if ! command -v uv >/dev/null 2>&1; then
  echo "[deeptutor] uv is required; install the macOS Brewfile first" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "[deeptutor] Node.js 20+ is required" >&2
  exit 1
fi

node_major="$(node --version | sed -E 's/^v([0-9]+).*/\1/')"
if [[ "$node_major" -lt 20 ]]; then
  echo "[deeptutor] Node.js 20+ is required; found $(node --version)" >&2
  exit 1
fi

uv tool install --python 3.13 "deeptutor==$DEEPTUTOR_VERSION"

if [[ ! -f "$PRIVATE_LLM_ENV" ]]; then
  echo "[deeptutor] missing private environment: $PRIVATE_LLM_ENV" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$PRIVATE_LLM_ENV"
if [[ -z "${DASHSCOPE_API_KEY:-}" ]]; then
  echo "[deeptutor] DASHSCOPE_API_KEY is not set by $PRIVATE_LLM_ENV" >&2
  exit 1
fi

tool_python="$(uv tool dir)/deeptutor/bin/python"
if [[ ! -x "$tool_python" ]]; then
  echo "[deeptutor] installed tool Python not found: $tool_python" >&2
  exit 1
fi

DEEPTUTOR_HOME="$DEEPTUTOR_HOME" "$tool_python" -c \
  'from deeptutor.services.setup import init_user_directories; from pathlib import Path; import os; init_user_directories(Path(os.environ["DEEPTUTOR_HOME"]))'

settings_dir="$DEEPTUTOR_HOME/data/user/settings"
catalog_path="$settings_dir/model_catalog.json"
catalog_tmp="$(mktemp "$settings_dir/.model_catalog.json.XXXXXX")"

jq -n \
  --arg base_url "$ALIYUN_BASE_URL" \
  --arg model "$MODEL_ID" \
  '
  {
    version: 1,
    services: {
      llm: {
        active_profile_id: "aliyun-deepseek",
        active_model_id: "deepseek-v4-flash",
        profiles: [
          {
            id: "aliyun-deepseek",
            name: "Aliyun DeepSeek",
            binding: "deepseek",
            base_url: $base_url,
            api_key: env.DASHSCOPE_API_KEY,
            api_version: "",
            extra_headers: {},
            models: [
              {
                id: "deepseek-v4-flash",
                name: "DeepSeek V4 Flash",
                model: $model
              }
            ]
          }
        ]
      },
      embedding: {active_profile_id: null, active_model_id: null, profiles: []},
      search: {active_profile_id: null, profiles: []},
      tts: {active_profile_id: null, active_model_id: null, profiles: []},
      stt: {active_profile_id: null, active_model_id: null, profiles: []},
      imagegen: {active_profile_id: null, active_model_id: null, profiles: []},
      videogen: {active_profile_id: null, active_model_id: null, profiles: []}
    }
  }
  ' >"$catalog_tmp"

chmod 600 "$catalog_tmp"
mv "$catalog_tmp" "$catalog_path"

echo "[deeptutor] installed deeptutor $DEEPTUTOR_VERSION"
echo "[deeptutor] configured $MODEL_ID via Aliyun DashScope"
echo "[deeptutor] runtime home: $DEEPTUTOR_HOME"
echo "[deeptutor] launch with: deeptutor-local"
