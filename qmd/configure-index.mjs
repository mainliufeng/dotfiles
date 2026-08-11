#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const [configPath, embedModel] = process.argv.slice(2);
if (!configPath || !embedModel) {
  console.error("Usage: configure-index.mjs <index.yml> <embed-model>");
  process.exit(1);
}

if (!fs.existsSync(configPath)) {
  console.error(`QMD config not found: ${configPath}`);
  process.exit(1);
}

let config = fs.readFileSync(configPath, "utf8");
const embedLine = `  embed: ${embedModel}`;

if (/^models:\s*$/m.test(config)) {
  if (/^  embed:.*$/m.test(config)) config = config.replace(/^  embed:.*$/m, embedLine);
  else config = config.replace(/^models:\s*$/m, `models:\n${embedLine}`);
} else {
  config = `${config.trimEnd()}\nmodels:\n${embedLine}\n`;
}

fs.mkdirSync(path.dirname(configPath), { recursive: true });
fs.writeFileSync(configPath, config, "utf8");
console.log(`[qmd] embedding model: ${embedModel}`);
