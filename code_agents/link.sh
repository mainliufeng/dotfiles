#!/usr/bin/env bash
set -euo pipefail

bin_dir="/usr/local/bin"
needs_sudo=0
if [ "$(id -u)" -ne 0 ] && [ ! -w "$bin_dir" ]; then
  needs_sudo=1
fi

if [ "$needs_sudo" -eq 1 ]; then
  echo "Need sudo to write to $bin_dir."
  sudo mkdir -p "$bin_dir"
else
  mkdir -p "$bin_dir"
fi

install_shim() {
  local name="$1"
  local target="$2"
  local tmp_shim
  tmp_shim="$(mktemp)"
  cat <<SHIM > "$tmp_shim"
#!/usr/bin/env bash
set -euo pipefail

"$target" "\$@"
SHIM
  if [ "$needs_sudo" -eq 1 ]; then
    sudo install -m 755 "$tmp_shim" "$bin_dir/$name"
  else
    install -m 755 "$tmp_shim" "$bin_dir/$name"
  fi
  rm -f "$tmp_shim"
}

install_shim "code-agents-config" "$HOME/dotfiles/code_agents/code-agents-config"
install_shim "code-agents-config-console" "$HOME/dotfiles/code_agents/code-agents-config-console"

if [ -e "$bin_dir/agents-md" ]; then
  if [ "$needs_sudo" -eq 1 ]; then
    sudo rm -f "$bin_dir/agents-md"
  else
    rm -f "$bin_dir/agents-md"
  fi
fi

skills_dir="$HOME/dotfiles/code_agents/skills"
installer="$HOME/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py"

if [ -x "$installer" ]; then
  mkdir -p "$skills_dir"

  rm -rf "$skills_dir/webapp-testing"
  python3 "$installer" \
    --repo anthropics/skills \
    --path skills/webapp-testing \
    --dest "$skills_dir"

  rm -rf "$skills_dir/frontend-design"
  python3 "$installer" \
    --repo anthropics/skills \
    --path skills/frontend-design \
    --dest "$skills_dir"

  rm -rf "$skills_dir/tapestry"
  python3 "$installer" \
    --repo michalparkola/tapestry-skills-for-claude-code \
    --path tapestry \
    --dest "$skills_dir"

  rm -rf "$skills_dir/content-research-writer"
  python3 "$installer" \
    --url https://github.com/ComposioHQ/awesome-claude-skills/tree/master/content-research-writer \
    --dest "$skills_dir"
else
  echo "Skill installer not found: $installer" >&2
fi
