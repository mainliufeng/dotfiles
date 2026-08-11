#!/usr/bin/env bash
set -euo pipefail

QMD_VERSION="2.5.3"
KNOWLEDGE_ROOT="${KNOWLEDGE_ROOT:-$HOME/Code/self/knowledge}"
ARTICLE_INDEX_DIR="${QMD_ARTICLE_INDEX_DIR:-$HOME/.cache/knowledge-qmd/articles}"
export QMD_EMBED_MODEL="${QMD_EMBED_MODEL:-hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf}"

export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PATH="$BUN_INSTALL/bin:$PATH"

if ! command -v bun >/dev/null 2>&1; then
  echo "[qmd] bun is required; run the dotfiles bun module first" >&2
  exit 1
fi

installed_version="$(bun pm ls -g 2>/dev/null | sed -n 's/.*@tobilu\/qmd@\([^[:space:]]*\).*/\1/p' | head -n 1)"
if [[ "$installed_version" != "$QMD_VERSION" ]]; then
  echo "[qmd] installing @tobilu/qmd@$QMD_VERSION with Bun"
  bun add --global "@tobilu/qmd@$QMD_VERSION"
else
  echo "[qmd] qmd $QMD_VERSION already installed"
fi

if ! command -v qmd >/dev/null 2>&1; then
  echo "[qmd] qmd binary is missing after installation" >&2
  exit 1
fi

if [[ ! -d "$KNOWLEDGE_ROOT" ]]; then
  echo "[qmd] Knowledge repo not found; CLI installed without collections: $KNOWLEDGE_ROOT"
  exit 0
fi

article_builder="$KNOWLEDGE_ROOT/scripts/build-qmd-article-index.mjs"
if [[ ! -f "$article_builder" ]]; then
  echo "[qmd] article index builder not found: $article_builder" >&2
  exit 1
fi

node "$article_builder" --output "$ARTICLE_INDEX_DIR"

ensure_collection() {
  local name="$1"
  local collection_path="$2"
  local pattern="$3"
  local current=""
  local current_path=""
  local current_pattern=""

  current="$(qmd collection show "$name" 2>/dev/null || true)"
  if [[ -n "$current" ]]; then
    current_path="$(printf '%s\n' "$current" | sed -n 's/^  Path:[[:space:]]*//p')"
    current_pattern="$(printf '%s\n' "$current" | sed -n 's/^  Pattern:[[:space:]]*//p')"
    if [[ "$current_path" != "$collection_path" || "$current_pattern" != "$pattern" ]]; then
      echo "[qmd] replacing stale collection: $name"
      qmd collection remove "$name"
      current=""
    fi
  fi

  if [[ -z "$current" ]]; then
    qmd collection add "$collection_path" --name "$name" --mask "$pattern"
  fi
}

ensure_collection "knowledge-articles" "$ARTICLE_INDEX_DIR" "**/*.md"
ensure_collection "knowledge-topics" "$KNOWLEDGE_ROOT/research/topics" "**/*.md"
ensure_collection "knowledge-synthesis" "$KNOWLEDGE_ROOT/research/synthesis" "{20[0-9][0-9],daily-ai-news}/**/*.md"
ensure_collection "knowledge-sources" "$KNOWLEDGE_ROOT/research/sources" "**/*.md"

qmd context add qmd://knowledge-articles/ \
  "Knowledge 的文章正文投影。每份文件的 source_path 指向 content_create 中的 HTML 真源；回答前读取真源。"
qmd context add qmd://knowledge-topics/ \
  "Knowledge 的 Topic 当前结论与 Claim。优先从 Topic 定位主题，再沿显式链接读取 Synthesis 和 Source。"
qmd context add qmd://knowledge-synthesis/ \
  "Knowledge 的综合调研，不含 run logs。用于查找一次研究形成的完整判断与证据边界。"
qmd context add qmd://knowledge-sources/ \
  "Knowledge 的原始来源卡。Source 是证据入口，不自动等于当前结论；回答前检查状态和来源层级。"

config_dir="${QMD_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/qmd}"
node "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/configure-index.mjs" \
  "$config_dir/index.yml" "$QMD_EMBED_MODEL"

qmd update
qmd status
