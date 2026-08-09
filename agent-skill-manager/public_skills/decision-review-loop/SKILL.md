---
name: decision-review-loop
description: Record and revisit material decisions whose results arrive later. Use for product, architecture, growth, operations, rollout, pricing, channel, or automation-heartbeat decisions when an action needs an explicit hypothesis, expected change, review window, failure condition, and later evidence-based verdict; also use when the user asks to 复盘、回看、验证决策、记录假设、检查之前判断，or prevent repeated activity without learning. Do not use for immediate deterministic tasks or as an implementation-boundary guard.
---

# Decision Review Loop

Turn delayed-feedback work into explicit learning. Record what is believed before acting, then revisit the same decision when its evidence window matures.

Keep this separate from implementation preflight. Use `iteration-drift-guard` to decide whether an engineering change is structurally safe; use this skill to learn whether the underlying decision was correct.

## Store Decisions in the Existing Source of Truth

Write into the project's current roadmap, experiment table, decision ledger, automation memory, or equivalent durable file. Do not create a parallel global ledger when a project already owns one.

Preserve project-specific metrics and terminology. This skill supplies the lifecycle contract, not the business schema.

## Record a Decision Before Acting

Create an entry only for a material choice whose outcome is delayed or uncertain. Do not journal routine commands, obvious fixes, or facts with immediate deterministic verification.

Record:

```text
decision_id:
decided_at:
scope:
evidence:
decision:
reason:
expected_change:
primary_signal:
guardrail_signal:
review_at_or_window:
failure_condition:
risk_or_dependency:
status: pending
```

Rules:

- Describe evidence as observed facts with dates or measurement windows.
- State one decision, not a bundle of unrelated actions.
- Make `expected_change` falsifiable.
- Prefer one primary outcome signal; use guardrails to catch regressions.
- Set a real review date or bounded window. “Later” is invalid.
- Define failure before results arrive.
- Do not count shipping, commits, pages, posts, or checks as outcomes unless the decision explicitly concerns delivery throughput.

## Review Mature Decisions Before Adding New Ones

At the start of a recurring product or architecture loop, inspect pending decisions whose review date has arrived. Review them before creating another similar decision.

Append a review without rewriting the original belief:

```text
reviewed_at:
actual_evidence:
verdict: confirmed | falsified | inconclusive
learning:
next_action: continue | adjust | stop | gather_evidence
follow_up_decision_id: optional
```

Use the same metric definition and comparable window whenever possible. If instrumentation, traffic, sample size, seasonality, or an external dependency prevents a fair test, choose `inconclusive`; do not force success or failure.

If the decision changes, create a new linked decision rather than silently editing the old one. Preserve the historical chain so later reviewers can distinguish what was known then from what is known now.

## Avoid False Learning

- Separate an executed action from its user or system outcome.
- Separate “no observed change” from “the hypothesis is false” when exposure was insufficient.
- Do not move the goalposts after seeing results.
- Do not use vanity metrics to replace the predeclared primary signal.
- Do not turn every heartbeat into another experiment while earlier experiments are still awaiting review.
- Do not let a compelling anecdote override stronger aggregate or causal evidence without recording the conflict.

## Compact Output

For a new decision, report the decision, expected change, review window, and failure condition. For a review, report the actual evidence, verdict, learning, and next action.

Keep the user-facing summary short; keep the durable ledger complete.
