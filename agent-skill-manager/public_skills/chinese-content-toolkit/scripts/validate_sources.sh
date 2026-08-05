#!/usr/bin/env bash
set -euo pipefail

library_root="${HOME}/.local/share/agent-skill-manager/skills"
paths=(
  "humanizer-zh/SKILL.md"
  "dbskill/skills/dbs/SKILL.md"
  "openakita-content-writer/skills/content-research-writer/SKILL.md"
  "claude-world-notebooklm/SKILL.md"
  "khazix-skills/khazix-writer/SKILL.md"
  "ian-xiaohei-illustrations/ian-xiaohei-illustrations/SKILL.md"
  "guizang-social-card-skill/SKILL.md"
  "baoyu-skills/skills/baoyu-article-illustrator/SKILL.md"
  "guizang-ppt-skill/SKILL.md"
  "html-anything/SKILL.md"
)

missing=0
for relative_path in "${paths[@]}"; do
  full_path="${library_root}/${relative_path}"
  if [[ ! -r "${full_path}" ]]; then
    printf 'missing: %s\n' "${full_path}" >&2
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  exit 1
fi

printf 'validated %d Chinese content skill sources\n' "${#paths[@]}"
