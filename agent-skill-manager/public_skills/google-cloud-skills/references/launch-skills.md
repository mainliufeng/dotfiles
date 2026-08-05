# Google Cloud launch skills catalog

Google announced these thirteen skills on 2026-04-22. The upstream repository is
actively developed, so the paths below point to the current equivalents rather
than a copied snapshot.

Upstream root:

`~/.local/share/agent-skill-manager/skills/google-cloud-official-skills`

## Product skills

| Skill | Load when | Current path under upstream root |
| --- | --- | --- |
| `alloydb-basics` | The target is AlloyDB for PostgreSQL, including clusters, instances, backups, IAM database authentication, or connectivity. Do not use for generic PostgreSQL or Cloud SQL. | `skills/cloud/alloydb-basics/SKILL.md` |
| `bigquery-basics` | The task manages BigQuery datasets, tables, jobs, ingestion, or SQL analysis. | `skills/cloud/bigquery-basics/SKILL.md` |
| `cloud-run-basics` | The task deploys or diagnoses Cloud Run services, jobs, or worker pools. | `skills/cloud/cloud-run-basics/SKILL.md` |
| `cloud-sql-basics` | The target is Cloud SQL, including instances, databases, backups, connections, or IAM. | `skills/cloud/cloud-sql-basics/SKILL.md` |
| `firebase-basics` | A mobile or web project explicitly uses Firebase products or services. | `skills/cloud/firebase-basics/SKILL.md` |
| `gemini-api` | The task uses Gemini through Vertex AI / Google Cloud Agent Platform and the Google Gen AI SDK. | `skills/cloud/gemini-api/SKILL.md` |
| `gke-basics` | The task uses Google Kubernetes Engine, especially Autopilot versus Standard, Workload Identity, resources, or cluster credentials. | `skills/cloud/gke-basics/SKILL.md` |

## Recipe skills

| Skill | Load when | Current path under upstream root |
| --- | --- | --- |
| `google-cloud-networking-observability` | The task analyzes Google Cloud networking logs, metrics, connectivity, firewalls, NAT, threats, or VPC flow logs. | `skills/cloud/google-cloud-networking-observability/SKILL.md` |
| `google-cloud-recipe-auth` | The task designs or diagnoses human, workload, service-to-service, ADC, OAuth, API-key, or Workload Identity authentication and authorization. | `skills/cloud/google-cloud-recipe-auth/SKILL.md` |
| `google-cloud-recipe-onboarding` | The user explicitly wants to set up or onboard a Google Cloud project, identity, billing, or first workload. | `skills/cloud/google-cloud-recipe-onboarding/SKILL.md` |

## Well-Architected Framework skills

| Skill | Load when | Current path under upstream root |
| --- | --- | --- |
| `google-cloud-waf-cost-optimization` | A Google Cloud workload needs a cost review, constraints, or optimization recommendations. | `skills/cloud/google-cloud-waf-cost-optimization/SKILL.md` |
| `google-cloud-waf-reliability` | A Google Cloud architecture needs SLI/SLO, redundancy, recovery, observability, graceful degradation, or postmortem guidance. | `skills/cloud/google-cloud-waf-reliability/SKILL.md` |
| `google-cloud-waf-security` | A Google Cloud workload needs IAM, zero-trust, network, data, supply-chain, AI-security, privacy, or compliance review. | `skills/cloud/google-cloud-waf-security/SKILL.md` |

## Selection notes

- Prefer a single product skill for implementation or diagnosis.
- Authentication and networking observability are cross-cutting recipes, not
  generic replacements for the product skill.
- The three Well-Architected skills are review lenses. Load them for an explicit
  review or production-readiness decision, not for every small edit.
- Onboarding can create projects and link billing. Keep it advisory/read-only
  unless the user's request clearly authorizes those external changes.
