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
  console.log(`Usage:
  agents-md                      # open TUI
  agents-md enable [name...]     # enable fragments
  agents-md disable [name...]    # disable fragments
  agents-md status [name...]     # show status`);
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

function orderedEnabledList(available, enabledSet) {
  return available.filter((name) => enabledSet.has(name));
}

async function runTui(available, enabledSet) {
  const choices = available.map((name) => ({
    title: name,
    value: name,
    selected: enabledSet.has(name),
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

function commandEnableDisable(command, available, enabledSet, targets) {
  const names = targets.length > 0 ? targets : available;
  names.forEach(requireFragment);

  if (command === 'enable') {
    names.forEach((name) => enabledSet.add(name));
  } else {
    names.forEach((name) => enabledSet.delete(name));
  }

  const ordered = orderedEnabledList(available, enabledSet);
  writeEnabledList(ordered);
  buildAgents(ordered);
}

function commandStatus(available, enabledSet, targets) {
  const names = targets.length > 0 ? targets : available;
  names.forEach(requireFragment);

  names.forEach((name) => {
    const status = enabledSet.has(name) ? 'enabled' : 'disabled';
    console.log(`${name}: ${status}`);
  });
}

async function main() {
  const available = listFragmentNames();
  if (available.length === 0) {
    console.error(`No fragments found in ${fragmentsDir}`);
    process.exit(1);
  }

  const enabledSet = new Set(readEnabledList());
  const args = process.argv.slice(2);

  if (args.length === 0) {
    await runTui(available, enabledSet);
    return;
  }

  const command = args[0];
  const targets = args.slice(1);

  if (command === 'enable' || command === 'disable') {
    commandEnableDisable(command, available, enabledSet, targets);
    return;
  }

  if (command === 'status') {
    commandStatus(available, enabledSet, targets);
    return;
  }

  if (command === '-h' || command === '--help' || command === 'help') {
    usage();
    process.exit(0);
  }

  console.error(`Unknown command: ${command}`);
  usage();
  process.exit(1);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
