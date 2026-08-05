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

# The imported packs below are reference libraries. If they enter Codex's flat
# auto-discovery directory, their broad descriptions compete with Knowledge,
# content-quality-director, imagegen, Presentations, and other local owners.
cold_only=(
  "openakita-content-writer"
  "claude-world-notebooklm"
  "khazix-skills"
  "ian-xiaohei-illustrations"
  "guizang-social-card-skill"
  "baoyu-skills"
  "guizang-ppt-skill"
  "html-anything"
)

for skill_name in "${cold_only[@]}"; do
  if [[ -e "${HOME}/.codex/skills/${skill_name}" ]]; then
    printf 'conflict: cold pack is auto-discovered by Codex: %s\n' "${skill_name}" >&2
    missing=1
  fi
done

local_routes=(
  "${HOME}/.codex/skills/chinese-content-toolkit/SKILL.md"
  "${HOME}/.codex/skills/knowledge/SKILL.md"
  "${HOME}/.codex/skills/knowledge/references/content/visual-production-methods.md"
  "${HOME}/.codex/skills/knowledge/references/research/horizontal-vertical-analysis.md"
  "${HOME}/.codex/skills/content-quality-director/SKILL.md"
  "${HOME}/.codex/skills/content-quality-director/references/article-production-methods.md"
)

for full_path in "${local_routes[@]}"; do
  if [[ ! -r "${full_path}" ]]; then
    printf 'missing adopted local route: %s\n' "${full_path}" >&2
    missing=1
  fi
done

router_skill="${HOME}/.codex/skills/chinese-content-toolkit/SKILL.md"
if [[ -r "${router_skill}" ]] && ! grep -Fq 'Do not trigger merely because' "${router_skill}"; then
  printf 'conflict: chinese-content-toolkit description is not narrowed\n' >&2
  missing=1
fi

if [[ "${missing}" -ne 0 ]]; then
  exit 1
fi

printf 'validated %d upstream sources, %d cold-pack boundaries, and %d adopted local routes\n' \
  "${#paths[@]}" "${#cold_only[@]}" "${#local_routes[@]}"
