#!/usr/bin/env bash
set -euo pipefail

codex_dir="$HOME/.codex"
source_config="$HOME/dotfiles/codex/config.toml"
runtime_config="$codex_dir/config.toml"

mkdir -p "$codex_dir"

if [ -L "$runtime_config" ]; then
  tmp_config="$(mktemp)"
  cp "$runtime_config" "$tmp_config"
  rm "$runtime_config"
  mv "$tmp_config" "$runtime_config"
  chmod 600 "$runtime_config"
  echo "[codex] replaced config symlink with runtime copy: $runtime_config"
elif [ ! -e "$runtime_config" ]; then
  cp "$source_config" "$runtime_config"
  chmod 600 "$runtime_config"
  echo "[codex] copied config template -> $runtime_config"
elif [ "${DOTFILES_CODEX_OVERWRITE_CONFIG:-0}" = "1" ]; then
  cp "$source_config" "$runtime_config"
  chmod 600 "$runtime_config"
  echo "[codex] overwrote runtime config from template: $runtime_config"
else
  echo "[codex] keeping existing runtime config: $runtime_config"
fi

"$HOME/dotfiles/codex/apply-app-font.sh"

mkdir -p "$codex_dir/agents"
for agent_file in "$HOME/dotfiles/codex/agents/"*.toml; do
  [ -e "$agent_file" ] || continue
  ln -sfn "$agent_file" "$codex_dir/agents/$(basename "$agent_file")"
  echo "[codex] linked agent: $(basename "$agent_file")"
done

#ln -svfn ~/dotfiles/codex/prompts ~/.codex/prompts
mkdir -p ~/.codex/skills
#rsync -a ~/dotfiles/codex/skills/ ~/.codex/skills/

superpowers_dir="$HOME/.codex/superpowers"
if [ "${DOTFILES_CODEX_ENABLE_SUPERPOWERS:-0}" = "1" ]; then
  if [ -d "$superpowers_dir" ]; then
    if [ ! -d "$superpowers_dir/.git" ]; then
      rm -rf "$superpowers_dir"
      git clone https://github.com/obra/superpowers.git "$superpowers_dir"
    else
      git -C "$superpowers_dir" pull
    fi
  else
    git clone https://github.com/obra/superpowers.git "$superpowers_dir"
  fi
else
  echo "[codex] superpowers auto-install disabled; set DOTFILES_CODEX_ENABLE_SUPERPOWERS=1 to refresh it"
fi
