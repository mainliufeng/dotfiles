#!/usr/bin/env bash
set -euo pipefail

upstream_root="${HOME}/.local/share/agent-skill-manager/skills/google-cloud-official-skills"
skills=(
  alloydb-basics
  bigquery-basics
  cloud-run-basics
  cloud-sql-basics
  firebase-basics
  gemini-api
  gke-basics
  google-cloud-networking-observability
  google-cloud-recipe-auth
  google-cloud-recipe-onboarding
  google-cloud-waf-cost-optimization
  google-cloud-waf-reliability
  google-cloud-waf-security
)

missing=0
for skill in "${skills[@]}"; do
  path="${upstream_root}/skills/cloud/${skill}/SKILL.md"
  if [[ ! -r "${path}" ]]; then
    printf 'missing: %s\n' "${path}" >&2
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  exit 1
fi

printf 'validated %d Google Cloud launch skills\n' "${#skills[@]}"
