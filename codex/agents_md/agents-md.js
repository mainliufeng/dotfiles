#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');
const prompts = require('prompts');

const codexDir = path.join(os.homedir(), '.codex');
const fragmentsDir = __dirname;
const enabledFile = path.join(codexDir, 'agents_md.enabled');
const outputFile = path.join(codexDir, 'AGENTS.md');

function usage() {
  console.log(`Usage: agents-md [--defaults <name...>] [--build] [--list]`);
}

function ensureCodexDir() {
  fs.mkdirSync(codexDir, { recursive: true });
}

function listFragmentNames() {
  const entries = fs.readdirSync(fragmentsDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => entry.name.replace(/\.md$/, ''))
    .filter((name) => name !== 'README')
    .sort();
}

function requireFragment(name) {
  const fragmentPath = path.join(fragmentsDir, `${name}.md`);
  if (!fs.existsSync(fragmentPath)) {
    console.error(`Missing fragment: ${fragmentPath}`);
    process.exit(1);
  }
}

function readEnabledList() {
  if (!fs.existsSync(enabledFile)) {
    return [];
  }
  return fs
    .readFileSync(enabledFile, 'utf8')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);
}

function writeEnabledList(names) {
  ensureCodexDir();
  const content = names.join('\n');
  fs.writeFileSync(enabledFile, `${content}\n`, 'utf8');
}

function buildAgents(names) {
  ensureCodexDir();
  const tmpPath = path.join(codexDir, `AGENTS.md.${process.pid}.tmp`);

  let output = '';
  names.forEach((name, index) => {
    requireFragment(name);
    const fragmentPath = path.join(fragmentsDir, `${name}.md`);
    const fragment = fs.readFileSync(fragmentPath, 'utf8');
    if (index > 0) {
      output += '\n';
    }
    output += fragment.replace(/\s+$/, '');
    output += '\n';
  });

  fs.writeFileSync(tmpPath, output, 'utf8');
  fs.renameSync(tmpPath, outputFile);
}

function parseArgs(argv) {
  const args = [...argv];
  const result = { defaults: null, build: false, list: false };

  while (args.length > 0) {
    const arg = args.shift();
    if (arg === '--defaults') {
      const names = [];
      while (args.length > 0 && !args[0].startsWith('--')) {
        names.push(args.shift());
      }
      result.defaults = names;
      continue;
    }
    if (arg === '--build') {
      result.build = true;
      continue;
    }
    if (arg === '--list') {
      result.list = true;
      continue;
    }
    if (arg === '-h' || arg === '--help') {
      result.help = true;
      continue;
    }
    console.error(`Unknown argument: ${arg}`);
    result.help = true;
    break;
  }

  return result;
}

async function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    usage();
    process.exit(0);
  }

  if (options.list) {
    readEnabledList().forEach((name) => console.log(name));
    return;
  }

  if (options.defaults) {
    const defaults = options.defaults;
    defaults.forEach(requireFragment);
    const enabled = readEnabledList();
    if (enabled.length === 0) {
      writeEnabledList(defaults);
    }
    buildAgents(readEnabledList());
    return;
  }

  if (options.build) {
    buildAgents(readEnabledList());
    return;
  }

  const available = listFragmentNames();
  const enabled = new Set(readEnabledList());
  const choices = available.map((name) => ({
    title: name,
    value: name,
    selected: enabled.has(name),
  }));

  const response = await prompts({
    type: 'multiselect',
    name: 'selected',
    message: 'Select AGENTS.md fragments',
    choices,
    hint: '- space to select, enter to confirm',
  });

  if (!response.selected) {
    process.exit(1);
  }

  writeEnabledList(response.selected);
  buildAgents(response.selected);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
