#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
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

install_shim "code-agents-config" "$script_dir/code-agents-config"
install_shim "code-agents-config-console" "$script_dir/code-agents-config-console"

if [ -e "$bin_dir/agents-md" ]; then
  if [ "$needs_sudo" -eq 1 ]; then
    sudo rm -f "$bin_dir/agents-md"
  else
    rm -f "$bin_dir/agents-md"
  fi
fi
