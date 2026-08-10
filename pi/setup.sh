#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_AGENT_DIR="${PI_AGENT_DIR:-$HOME/.pi/agent}"

npm install -g --ignore-scripts @earendil-works/pi-coding-agent

mkdir -p "$PI_AGENT_DIR"

node - "$SCRIPT_DIR/settings.json" "$PI_AGENT_DIR/settings.json" <<'NODE'
const fs = require("node:fs");

const [sourcePath, targetPath] = process.argv.slice(2);
const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));
const target = fs.existsSync(targetPath)
  ? JSON.parse(fs.readFileSync(targetPath, "utf8"))
  : {};

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

fs.writeFileSync(targetPath, `${JSON.stringify(merge(target, source), null, 2)}\n`);
NODE
