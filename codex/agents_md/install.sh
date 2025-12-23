#!/usr/bin/env bash
set -euo pipefail

bin_dir="/usr/local/bin"
mkdir -p "$bin_dir"

cat <<'SHIM' > "${bin_dir}/agents-md"
#!/usr/bin/env bash
set -euo pipefail

node "${HOME}/dotfiles/codex/agents_md/agents-md.js" "$@"
SHIM

chmod +x "${bin_dir}/agents-md"
