#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="all"
MANIFEST="$MANIFEST_PATH_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --manifest)
      MANIFEST="$2"
      shift 2
      ;;
    *)
      echo "Error: unknown arg '$1'" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found: $MANIFEST" >&2
  exit 1
fi

require_bin jq
require_bin python3
require_bin git
require_bin bun

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
INSTALLER="$CODEX_HOME_DIR/skills/.system/skill-installer/scripts/install-skill-from-github.py"
CLAUDE_SKILLS_DIR="$(expand_path "$(jq -r '.targets.claude.skills_dir' "$MANIFEST")")"

if [[ ! -f "$INSTALLER" ]]; then
  echo "Error: skill installer not found: $INSTALLER" >&2
  exit 1
fi

install_github_skill() {
  local name="$1"
  local repo="$2"
  local path="$3"
  local ref="$4"
  local dest="$5"

  if [[ -d "$dest/$name" ]]; then
    echo "[skip] $name already installed in $dest"
    return 0
  fi

  python3 "$INSTALLER" \
    --repo "$repo" \
    --path "$path" \
    --ref "$ref" \
    --name "$name" \
    --dest "$dest" \
    --method git
}

install_local_skill() {
  local name="$1"
  local src="$2"
  local dest="$3"

  if [[ -d "$dest/$name" ]]; then
    echo "[skip] $name already installed in $dest"
    return 0
  fi

  if [[ ! -d "$src" ]]; then
    echo "[skip] $name source not found: $src"
    return 0
  fi

  cp -a "$src" "$dest/$name"
  echo "Installed $name to $dest/$name"
}

ensure_amap_skill_frontmatter() {
  local skill_dir="$1"
  local skill_md="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    return 0
  fi

  if head -n1 "$skill_md" | grep -q '^---$'; then
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  {
    cat <<'YAML'
---
name: amap-jsapi-skill
description: 高德地图 JSAPI v2.0 (WebGL) 开发技能。涵盖地图生命周期管理、强制安全配置、3D 视图控制、覆盖物绘制及 LBS 服务集成。
---

YAML
    cat "$skill_md"
  } > "$tmp"

  mv "$tmp" "$skill_md"
  echo "Patched SKILL.md frontmatter for amap-jsapi-skill: $skill_md"
}

install_ui_ux_pro_max() {
  local dest="$1"
  local name="ui-ux-pro-max"
  local skill_dir="$dest/$name"
  local home_src_dir="$HOME/src/ui-ux-pro-max"
  local legacy_codex_src_dir="$CODEX_HOME_DIR/src/ui-ux-pro-max"

  if [[ -d "$skill_dir" ]]; then
    echo "[skip] $name already installed in $dest"
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  git clone \
    --filter=blob:none \
    --depth 1 \
    --sparse \
    --single-branch \
    --branch main \
    https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git \
    "$tmp_dir/repo" >/dev/null 2>&1

  git -C "$tmp_dir/repo" sparse-checkout set \
    .claude/skills/ui-ux-pro-max \
    src/ui-ux-pro-max

  if [[ ! -d "$skill_dir" ]]; then
    cp -a "$tmp_dir/repo/.claude/skills/ui-ux-pro-max" "$skill_dir"
    echo "Installed $name to $skill_dir"
  fi

  mkdir -p "$HOME/src"
  if [[ ! -d "$home_src_dir" ]]; then
    if [[ -d "$legacy_codex_src_dir" ]]; then
      cp -a "$legacy_codex_src_dir" "$home_src_dir"
    else
      cp -a "$tmp_dir/repo/src/ui-ux-pro-max" "$home_src_dir"
    fi
    echo "Installed $name source to $home_src_dir"
  else
    echo "[skip] $name source already exists: $home_src_dir"
  fi

  rm -rf "$tmp_dir"
}

install_gstack() {
  local target_name="$1"
  local dest="$2"
  local name="gstack"
  local canonical_dir="$CLAUDE_SKILLS_DIR/$name"
  local target_dir="$dest/$name"

  mkdir -p "$CLAUDE_SKILLS_DIR"

  if [[ ! -e "$canonical_dir" ]]; then
    git clone --depth 1 https://github.com/garrytan/gstack.git "$canonical_dir"
    echo "Installed $name to $canonical_dir"
  else
    echo "[skip] $name source already exists: $canonical_dir"
  fi

  if [[ "$target_dir" != "$canonical_dir" ]]; then
    mkdir -p "$dest"
    if [[ -L "$target_dir" ]]; then
      echo "[skip] $name link already exists: $target_dir"
    elif [[ -e "$target_dir" ]]; then
      echo "[skip] $name target already exists and is not a symlink: $target_dir"
    else
      ln -s "$canonical_dir" "$target_dir"
      echo "Linked $name to $target_dir -> $canonical_dir"
    fi
  fi

  if [[ "$target_name" == "codex" ]]; then
    (cd "$target_dir" && ./setup)
  else
    (cd "$canonical_dir" && ./setup)
  fi
}

mapfile -t TARGET_LIST < <(resolve_targets "$TARGET")

for target_name in "${TARGET_LIST[@]}"; do
  dest_raw="$(jq -r ".targets.${target_name}.skills_dir" "$MANIFEST")"
  dest="$(expand_path "$dest_raw")"
  mkdir -p "$dest"

  echo "== Install skills for $target_name -> $dest"

  while IFS= read -r skill_b64; do
    skill_json="$(printf '%s' "$skill_b64" | base64 -d)"

    name="$(jq -r '.name' <<<"$skill_json")"
    kind="$(jq -r '.kind' <<<"$skill_json")"

    case "$kind" in
      github)
        repo="$(jq -r '.repo' <<<"$skill_json")"
        path="$(jq -r '.path' <<<"$skill_json")"
        ref="$(jq -r '.ref // "main"' <<<"$skill_json")"
        install_github_skill "$name" "$repo" "$path" "$ref" "$dest"
        ;;
      local)
        src_path="$(jq -r '.path' <<<"$skill_json")"
        if [[ "$src_path" == /* ]]; then
          src="$src_path"
        else
          src="$ROOT_DIR/$src_path"
        fi
        install_local_skill "$name" "$src" "$dest"
        ;;
      special)
        special_id="$(jq -r '.id' <<<"$skill_json")"
        case "$special_id" in
          gstack)
            install_gstack "$target_name" "$dest"
            ;;
          ui-ux-pro-max)
            install_ui_ux_pro_max "$dest"
            ;;
          *)
            echo "[skip] unsupported special skill: $special_id"
            ;;
        esac
        ;;
      *)
        echo "[skip] unknown skill kind '$kind' for $name"
        ;;
    esac

    if [[ "$name" == "amap-jsapi-skill" ]]; then
      ensure_amap_skill_frontmatter "$dest/$name"
    fi
  done < <(jq -r --arg t "$target_name" '.skills[] | select(.targets | index($t)) | @base64' "$MANIFEST")
done
