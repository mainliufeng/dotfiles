---
name: google-cloud-skills
description: Route explicit Google Cloud work to the relevant skill from Google's official launch set: AlloyDB, BigQuery, Cloud Run, Cloud SQL, Firebase, Gemini API on Agent Platform, GKE, networking observability, authentication, onboarding, cost optimization, reliability, and security.
---

# Google Cloud Skills Router

Use this router only when the target is explicitly Google Cloud or one of the
products named in the description. Do not activate it for generic PostgreSQL,
Kubernetes, SQL, web hosting, or model API work that does not use Google Cloud.

The upstream repository is kept as a manual cold-library pack. This router keeps
all thirteen launch skills available without placing thirteen specialized skill
descriptions into every runtime's automatic discovery surface.

## Routing workflow

1. Read [references/launch-skills.md](references/launch-skills.md) and select the
   smallest skill or skill combination that matches the task.
2. Resolve the upstream root at
   `~/.local/share/agent-skill-manager/skills/google-cloud-official-skills`.
3. Read the selected upstream `SKILL.md` completely before taking task actions.
   Read only the supplementary upstream references that the selected skill
   routes to for the current task.
4. Inspect the live repository, Google Cloud configuration, and current official
   documentation when correctness depends on project state, product behavior,
   model names, preview status, pricing, IAM roles, or CLI flags.
5. Apply the safety boundary below before proposing or executing commands.

If the cold-library root or a selected `SKILL.md` is missing, run the managed
sync rather than installing the upstream repository ad hoc:

```bash
~/dotfiles/agent-skill-manager/bin/skill-manager sync --only google-cloud-official-skills
```

## Safety boundary

- Start with read-only discovery of the active account, project, region, enabled
  APIs, IAM bindings, and relevant resources. Never guess these identifiers.
- Treat project creation, billing-account linkage, API enablement, IAM changes,
  deployments, public ingress, and resource deletion as external mutations.
  Execute them only when the user's task authorizes that exact scope.
- Never run placeholder commands unchanged. Replace and validate every project,
  region, account, service, cluster, database, network, and image value first.
- Do not treat upstream `--quiet` examples as approval to skip impact review.
- Prefer least-privilege roles, short-lived credentials, private connectivity,
  encrypted secrets, and reversible rollout paths.
- Never print, persist, or commit access tokens, service-account keys, database
  passwords, billing identifiers, or other credentials.
- Do not automatically install additional Firebase or third-party skills merely
  because an upstream skill recommends them. Route installation through
  `agent-skill-manager` and review the source first.
- For Gemini API work, distinguish Google AI Studio from Vertex AI / Agent
  Platform. This launch skill is for the Google Cloud enterprise path; verify
  current model names and APIs against official Google documentation.
- For advice-only requests, do not mutate Google Cloud state.

## Combining skills

Use one product skill as the primary procedure. Add a recipe or Well-Architected
skill only when it materially changes the result. Common combinations:

- Cloud Run + Cloud SQL + Authentication for a service-to-database deployment.
- GKE + Authentication + Security for workload identity and cluster access.
- BigQuery + Networking Observability for telemetry analysis.
- Any production workload + Reliability + Cost Optimization + Security for an
  architecture review.

Do not let this router override repo-specific workflows. When work is inside an
rcrAI repository, `rcrai` remains the organization-level router and this skill
supplies only Google Cloud product guidance.

## Verification

After changing infrastructure or deployment state, verify the requested outcome
through both the relevant control-plane status and an application-level check.
For advice or design work, cite the selected upstream skill and any current
official documentation used to validate drift-prone claims.
