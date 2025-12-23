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

tmp_shim="$(mktemp)"
cat <<'SHIM' > "$tmp_shim"
#!/usr/bin/env bash
set -euo pipefail

node "${HOME}/dotfiles/codex/agents_md/agents-md.js" "$@"
SHIM

if [ "$needs_sudo" -eq 1 ]; then
  sudo install -m 755 "$tmp_shim" "${bin_dir}/agents-md"
else
  install -m 755 "$tmp_shim" "${bin_dir}/agents-md"
fi
rm -f "$tmp_shim"

if [ ! -d "${HOME}/dotfiles/codex/agents_md/node_modules" ]; then
  (cd "${HOME}/dotfiles/codex/agents_md" && npm install)
fi
