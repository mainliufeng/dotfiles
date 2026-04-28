---
name: iteration-drift-guard
description: General engineering iteration drift guard. Use this skill whenever coding, reviewing, or planning changes in a long-running codebase, especially after repo migration/splitting, repeated bug fixes, prototype-to-production transitions, integration-test patches, AI-generated code iterations, or when a request says the project may have "gone off track", "跑偏", "越改越乱", "codex一直在写", "fix after fix", "migration", "refactor", "local integration", or "make this process safer". It forces a short boundary, invariant, entrypoint, ownership, and test-loop check before implementation so patches do not accumulate into architectural drift.
---

# Iteration Drift Guard

## Purpose

Use this skill to keep software work from drifting during long AI-assisted iterations.

It is not a full design process. It is a compact guardrail to run before code changes, reviews, or debugging when the project has signs of drift:

- A feature has moved across repos, modules, or deployment units.
- Several fixes keep touching the same concept.
- Local integration code starts becoming production behavior.
- Prompts, mocks, fallback paths, or UI compatibility patches are carrying business rules.
- Data identifiers, ownership boundaries, or external dependencies are being guessed.
- The code now passes a demo but the formal entrypoint, persistence, tests, or docs do not match.

## Core Rule

Before implementing, write a short drift check. If the check exposes an unresolved boundary or invariant problem, fix the plan first instead of adding another patch.

Keep the check concise. One screen is enough for small work.

```text
Drift check:
- Scope boundary:
- Formal entrypoint:
- Core invariants:
- Data ownership:
- Dependency ownership:
- Runtime vs fallback:
- Test loop:
- Decision: PROCEED / NEEDS_DESIGN / NEEDS_CONTEXT / OUT_OF_SCOPE
```

If the user is speaking Chinese, output the Chinese version:

```text
漂移检查:
- 范围边界:
- 正式入口:
- 核心不变量:
- 数据归属:
- 依赖归属:
- 正式路径 vs fallback:
- 测试闭环:
- 结论: PROCEED / NEEDS_DESIGN / NEEDS_CONTEXT / OUT_OF_SCOPE
```

## How To Check

### 1. Scope Boundary

State exactly where the change belongs.

Ask:

- Is this production code, test support, local integration, migration glue, or documentation?
- Is this the correct repo/module/service for the responsibility?
- Is the change expanding the module's ownership just because it is convenient?
- If this came from a migrated repo, what responsibilities were intentionally left behind?

If the change belongs elsewhere, say so directly. Do not re-create another system's responsibility locally unless the user explicitly chooses that tradeoff.

### 2. Formal Entrypoint

Name the real entrypoint that makes the capability production-visible.

Examples:

- HTTP route mounted in the real server startup path.
- CLI command wired into the real binary.
- Kafka/queue/topic consumer connected on startup.
- Cron/scheduler/worker registered in the runtime.
- Webhook/callback route with auth and routing.
- UI workflow connected to the real API.

Do not count these as formal entrypoints by themselves:

- A helper function.
- A service method with no caller.
- A mock consumer.
- A local-only script.
- A debug UI button.
- An integration-test-only path.

### 3. Core Invariants

List the rules that must always hold, then decide where each is enforced.

Prefer service/database/state-machine enforcement for invariants. Prompts, comments, docs, frontend checks, and tests are useful, but they are not primary enforcement.

Common invariant categories:

- Identity: which ID means what.
- State machine: which transitions are legal.
- Idempotency: what makes repeated calls safe.
- Ordering: what can run concurrently and what must be serialized.
- Authorization/tenant scope: what data boundary must never be crossed.
- Evidence: what must be recorded before a status can change.

If an invariant is currently enforced only by a prompt, model instruction, UI condition, or "latest record wins" guess, treat that as a risk.

### 4. Data Ownership

For every important field or object, say who owns the truth.

Use concrete names:

- Which table, store, external API, file, or memory cache owns the value?
- Is this field canonical, derived, denormalized, or just display data?
- Can one value fan out to many owners, or must it be unique?
- What is the lookup key, and is it stable?

Never use one field to mean two things. If the code needs a customer ID, thread ID, account ID, task ID, session ID, binding ID, or external ID, name the distinction explicitly.

### 5. Dependency Ownership

Assign each external call to the correct dependency.

Ask:

- Which client owns this API call?
- Is this a real production dependency or a local/test substitute?
- Are config keys separate for separate dependencies?
- Does the fallback path accidentally override the production path?
- Are DTOs stored under the dependency that actually owns them?

Do not let local integration endpoints blur dependency boundaries.

### 6. Runtime vs Fallback

Separate the production path from compatibility and test paths.

For each fallback, record:

- Why it exists.
- How it is enabled.
- Whether it is off by default in production.
- Which tests prove the real path still works.

Fallbacks are useful during migration, but they should not silently become the architecture.

### 7. Test Loop

Match tests to the risk.

At minimum, consider:

- Unit tests for invariants, state transitions, ID mapping, parsing, and error returns.
- Integration tests through real process wiring when the risk is entrypoint or dependency wiring.
- Regression tests for the exact bug and at least one adjacent counterexample.
- Contract/API tests when DTOs or external calls change.
- Migration tests when data shape or ownership changes.

If the bug came from repeated patching, add a test around the model, not only around the latest symptom.

## Drift Signals

Pause and re-check when you see any of these:

- Many commits or patches say `fix` around the same nouns.
- Code chooses "latest", "first", "default", or "fallback" without a written business rule.
- A mock, local server, in-memory adapter, or demo endpoint becomes a runtime default.
- A service takes parameters it should be able to derive only from trusted context.
- The same concept appears under different names in API, DB, UI, and docs.
- A function is added but not wired into the actual startup path.
- The UI compensates for an API mismatch instead of clarifying the contract.
- The implementation updates code but not docs/tests that define the workflow.
- A prompt is asked to guarantee behavior that the backend can enforce.

## Implementation Guidance

- Prefer tightening the existing model over adding a parallel special case.
- Keep temporary compatibility code explicitly named and gated.
- When fixing a bug, identify whether the root cause is in a missing invariant, unclear ownership, bad entrypoint wiring, or inadequate test coverage.
- If a small fix touches many unrelated layers, stop and write the missing model first.
- If the right fix requires a different repo, say so before editing.
- If the user explicitly wants a quick demo patch, label it as such and avoid presenting it as production-ready.

## Review Guidance

When reviewing code, lead with drift risks before style comments:

- Boundary expansion.
- Unwired or fallback-only entrypoints.
- Ambiguous identifiers.
- Invariants enforced only by prompt/UI/test.
- Dependency ownership confusion.
- Missing regression test for the model.

## Output Discipline

For small tasks, the drift check can be 6-8 lines. For larger tasks, include a short plan after the check.

Do not turn every task into heavyweight process. The value is in forcing the right boundary and invariant questions before another patch lands.
