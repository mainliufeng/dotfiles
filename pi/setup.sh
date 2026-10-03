#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_AGENT_DIR="${PI_AGENT_DIR:-$HOME/.pi/agent}"

npm install -g --ignore-scripts @earendil-works/pi-coding-agent

mkdir -p "$PI_AGENT_DIR"

node - \
  "$SCRIPT_DIR/settings.json" "$PI_AGENT_DIR/settings.json" \
  "$SCRIPT_DIR/models.json" "$PI_AGENT_DIR/models.json" <<'NODE'
const fs = require("node:fs");

function merge(targetValue, sourceValue) {
  if (
    targetValue &&
    sourceValue &&
    typeof targetValue === "object" &&
    typeof sourceValue === "object" &&
    !Array.isArray(targetValue) &&
    !Array.isArray(sourceValue)
  ) {
    const result = { ...targetValue };
    for (const [key, value] of Object.entries(sourceValue)) {
      result[key] = merge(result[key], value);
    }
    return result;
  }
  return sourceValue;
}

const paths = process.argv.slice(2);
for (let index = 0; index < paths.length; index += 2) {
  const sourcePath = paths[index];
  const targetPath = paths[index + 1];
  const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));
  const target = fs.existsSync(targetPath)
    ? JSON.parse(fs.readFileSync(targetPath, "utf8"))
    : {};

  const merged = merge(target, source);
  if (sourcePath.endsWith("/models.json")) {
    // Magpie owns the gateway model catalog and key. Remove obsolete direct
    // routes, but preserve its machine-specific wiring during setup.
    merged.providers = target.providers?.magpie
      ? { magpie: target.providers.magpie }
      : {};
  }
  fs.writeFileSync(targetPath, `${JSON.stringify(merged, null, 2)}\n`);
}
NODE

chmod 600 "$PI_AGENT_DIR/models.json"

mkdir -p "$PI_AGENT_DIR/extensions"
ln -sfn "$SCRIPT_DIR/extensions/magpie-only.ts" "$PI_AGENT_DIR/extensions/magpie-only.ts"

# Skills use the private, harness-specific source list.
private_installer="${DOTFILES_PRIVATE_HOME:-$HOME/dotfiles-private}/pi/install-skills.py"
if [[ -f "$private_installer" ]]; then
  python3 "$private_installer"
fi
