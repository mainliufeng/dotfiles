#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${OBSIDIAN_VAULT:-$HOME/Code/self/knowledge}"
PLUGIN_ID="obsidian-front-matter-title-plugin"
PLUGIN_VERSION="4.1.1"
PLUGIN_DIR="$VAULT_DIR/.obsidian/plugins/$PLUGIN_ID"
RELEASE_BASE="https://github.com/snezhig/obsidian-front-matter-title/releases/download/$PLUGIN_VERSION"
MAIN_SHA256="1aa8e3345610f9d51fc499a954f92221966ca60357ff630e255f2edefd341ed9"
MANIFEST_SHA256="a83265e1e8a0db3658d7121f8611650b74daa8b11760ead3579ad1953e71f136"

if [[ ! -d "$VAULT_DIR" ]]; then
  echo "[obsidian] vault not found, skipping: $VAULT_DIR"
  exit 0
fi

for command_name in curl jq; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "[obsidian] required command not found: $command_name" >&2
    exit 1
  fi
done

download_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$download_dir"
}
trap cleanup EXIT

curl -fsSL --retry 3 "$RELEASE_BASE/main.js" -o "$download_dir/main.js"
curl -fsSL --retry 3 "$RELEASE_BASE/manifest.json" -o "$download_dir/manifest.json"

checksum() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

[[ "$(checksum "$download_dir/main.js")" == "$MAIN_SHA256" ]] || {
  echo "[obsidian] checksum mismatch: main.js" >&2
  exit 1
}
[[ "$(checksum "$download_dir/manifest.json")" == "$MANIFEST_SHA256" ]] || {
  echo "[obsidian] checksum mismatch: manifest.json" >&2
  exit 1
}

mkdir -p "$PLUGIN_DIR"
install -m 0644 "$download_dir/main.js" "$PLUGIN_DIR/main.js"
install -m 0644 "$download_dir/manifest.json" "$PLUGIN_DIR/manifest.json"
install -m 0644 "$ROOT_DIR/front-matter-title.json" "$PLUGIN_DIR/data.json"

community_plugins="$VAULT_DIR/.obsidian/community-plugins.json"
mkdir -p "$(dirname "$community_plugins")"
if [[ ! -f "$community_plugins" ]]; then
  printf '[]\n' > "$community_plugins"
fi

merged_plugins="$download_dir/community-plugins.json"
jq --arg plugin "$PLUGIN_ID" \
  'if type != "array" then error("community-plugins.json must be an array") else . + [$plugin] | unique end' \
  "$community_plugins" > "$merged_plugins"
install -m 0644 "$merged_plugins" "$community_plugins"

echo "[obsidian] installed $PLUGIN_ID $PLUGIN_VERSION for $VAULT_DIR"
