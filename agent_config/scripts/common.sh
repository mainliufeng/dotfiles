#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_PATH_DEFAULT="$ROOT_DIR/config/manifest.json"
PRIVATE_MANIFEST_PATH_DEFAULT="$HOME/dotfiles-private/agent_config/config/manifest.json"

expand_path() {
  local p="$1"
  if [[ "$p" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "$p" == "~/"* ]]; then
    printf '%s\n' "$HOME/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

is_absolute_or_home_path() {
  local p="$1"
  [[ "$p" == /* || "$p" == "~" || "$p" == "~/"* ]]
}

resolve_path_from_root() {
  local root="$1"
  local p="$2"

  if is_absolute_or_home_path "$p"; then
    expand_path "$p"
  else
    printf '%s\n' "$root/$p"
  fi
}

require_bin() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Error: missing command '$name'" >&2
    exit 1
  fi
}

resolve_targets() {
  local target="$1"
  case "$target" in
    codex)
      printf '%s\n' "codex"
      ;;
    claude)
      printf '%s\n' "claude"
      ;;
    all)
      printf '%s\n' "codex" "claude"
      ;;
    *)
      echo "Error: invalid --target '$target' (use codex|claude|all)" >&2
      exit 1
      ;;
  esac
}

manifest_root_dir() {
  local manifest="$1"
  (cd "$(dirname "$manifest")/.." && pwd)
}

normalize_manifest_file() {
  local manifest="$1"
  local out_file="$2"
  local manifest_root
  manifest_root="$(manifest_root_dir "$manifest")"

  jq --arg root "$manifest_root" '
    def resolve_root_path:
      if type != "string" then .
      elif . == "~" or startswith("~/") or startswith("/") then .
      else ($root + "/" + .)
      end;

    .agent_md_fragments = (
      (.agent_md_fragments // {})
      | with_entries(.value |= resolve_root_path)
    ) |
    .skills = (
      (.skills // [])
      | map(
          if (.kind // "") == "local" and (.path? != null) then
            .path |= resolve_root_path
          else
            .
          end
        )
    ) |
    .project_overrides = (
      (.project_overrides // [])
      | map(
          if .path? != null then
            .path |= resolve_root_path
          else
            .
          end
        )
    )
  ' "$manifest" > "$out_file"
}

resolve_manifest_files() {
  local base_manifest="$1"
  local -a manifests=()
  local overlay

  manifests+=("$base_manifest")

  if [[ -n "${AGENT_CONFIG_OVERLAY_MANIFESTS:-}" ]]; then
    local old_ifs="$IFS"
    IFS=':'
    read -r -a overlay_list <<<"$AGENT_CONFIG_OVERLAY_MANIFESTS"
    IFS="$old_ifs"

    for overlay in "${overlay_list[@]}"; do
      overlay="$(expand_path "$overlay")"
      if [[ -n "$overlay" && -f "$overlay" && "$overlay" != "$base_manifest" ]]; then
        manifests+=("$overlay")
      fi
    done
  elif [[ -f "$PRIVATE_MANIFEST_PATH_DEFAULT" && "$PRIVATE_MANIFEST_PATH_DEFAULT" != "$base_manifest" ]]; then
    manifests+=("$PRIVATE_MANIFEST_PATH_DEFAULT")
  fi

  printf '%s\n' "${manifests[@]}"
}

build_merged_manifest() {
  local base_manifest="$1"
  local out_file="$2"
  local -a manifests=()
  local -a normalized_files=()
  local manifest
  local tmp_dir

  mapfile -t manifests < <(resolve_manifest_files "$base_manifest")

  tmp_dir="$(mktemp -d)"

  for manifest in "${manifests[@]}"; do
    if [[ ! -f "$manifest" ]]; then
      echo "Error: manifest not found: $manifest" >&2
      rm -rf "$tmp_dir"
      exit 1
    fi

    local normalized_file="$tmp_dir/$(basename "$manifest").normalized.$(printf '%s' "${#normalized_files[@]}").json"
    normalize_manifest_file "$manifest" "$normalized_file"
    normalized_files+=("$normalized_file")
  done

  jq -s '
    reduce .[] as $item (
      {
        version: 1,
        targets: {},
        agent_md_fragments: {},
        profiles: {},
        project_overrides: [],
        skills: []
      };
      .version = ($item.version // .version) |
      .targets += ($item.targets // {}) |
      .agent_md_fragments += ($item.agent_md_fragments // {}) |
      .profiles += ($item.profiles // {}) |
      .project_overrides += ($item.project_overrides // []) |
      .skills += ($item.skills // [])
    )
  ' "${normalized_files[@]}" > "$out_file"

  local duplicate_skill_names
  duplicate_skill_names="$(jq -r '.skills[].name' "$out_file" | sort | uniq -d)"
  if [[ -n "$duplicate_skill_names" ]]; then
    echo "Error: duplicate skill names across merged manifests:" >&2
    printf '%s\n' "$duplicate_skill_names" >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  rm -rf "$tmp_dir"
}
