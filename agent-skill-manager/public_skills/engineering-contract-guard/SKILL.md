---
name: engineering-contract-guard
description: Lightweight contract preflight for software engineering changes. Use when modifying or designing APIs, DTOs, request/response schemas, OpenAPI/Swagger docs, gateway routes, SDK/client contracts, storage/query isolation fields, or cross-service interface boundaries. This skill checks compatibility and current facts before coding; it is not a full implementation workflow.
---

# Engineering Contract Guard

## Purpose

Use this skill to prevent contract drift before changing an interface.

It is a narrow preflight. It does not own the overall development flow, planning flow, or review flow. If repo instructions, organization skills, or explicit user instructions apply, follow them first; then use this skill only to lock down the interface contract.

## Contract Preflight

Before editing code, produce a short check:

```text
Engineering contract check:
- Current contract:
- Existing callers/docs/tests:
- Requested change type:
- Compatibility decision:
- Naming decision:
- Isolation fields:
- Documentation and route impact:
- Verification plan:
- Conclusion: PROCEED / ADD_NEW_ENDPOINT / NEEDS_CONTEXT / BLOCKED
```

Keep it compact. For small changes, one line per item is enough.

## Required Checks

### 1. Current Contract

Inspect the existing implementation before proposing a new shape.

Check the real route, handler, DTO, service method, generated docs, tests, and known callers. Prefer repository facts over user shorthand. If the current API uses `query`, do not rename it to `q` just because the user describes the input as "q" unless they explicitly request a breaking rename.

### 2. Existing Callers, Docs, And Tests

Search for current users before changing a contract:

- route registrations
- request and response structs or schemas
- OpenAPI / Swagger annotations and generated files
- gateway or proxy route config
- frontend/client/SDK calls
- handler/service tests
- markdown API docs

If callers cannot be found, say what was searched. Do not treat "no caller found yet" as proof that breaking changes are safe.

### 3. Requested Change Type

Classify the change:

- `additive`: new optional request field, new optional response field, new endpoint, new route config
- `compatible behavior`: existing request still succeeds and returns the old shape
- `breaking`: renamed field, removed field, type change, required-field tightening, response shape change, changed success semantics
- `unknown`: not enough evidence

Breaking changes require explicit user approval or a new endpoint/version.

### 4. Compatibility Decision

Default to preserving existing behavior.

Do not change an existing endpoint's response from an object to a list, from one envelope shape to another, or from top-1 to top-k if existing callers expect the old shape. Prefer a new endpoint or version when the product needs a new response shape.

Adding optional response fields is usually safe. Adding required request fields is usually breaking.

### 5. Naming Decision

Inherit local naming conventions:

- Keep existing request field names unless a rename is explicitly required.
- Match the repo's JSON casing, tags, path style, and error envelope.
- Do not introduce synonyms for the same concept across API, service, docs, and tests.
- If user wording conflicts with current API naming, treat user wording as product shorthand until confirmed.

### 6. Isolation Fields

Identify data-boundary fields and trace them to the real query or storage call.

Common examples:

- `tenant_id`
- `space_id`
- `bid`
- `org_id`
- `user_id`
- `account_id`
- `project_id`

For search and list APIs, explicitly verify whether the isolation field is required, where it is validated, and whether it reaches the database, ES query, vector search, cache key, or downstream client call.

If an isolation field exists in the old API, do not remove it from the new API unless explicitly approved.

### 7. Documentation And Route Impact

For API changes, decide whether these must change:

- Swagger / OpenAPI annotations and generated output
- markdown interface docs
- gateway / proxy config
- client SDK or frontend types
- examples and fixtures

If the repo has generated docs, regenerate them or explain why not.

### 8. Verification Plan

Before coding, name the smallest useful verification:

- contract/unit tests for DTO mapping and compatibility
- handler tests for route reachability
- service tests for isolation fields and query params
- generated Swagger/OpenAPI validation
- gateway JSON validation
- caller compile/typecheck if clients are in scope

Before declaring done, report the evidence. "Looks right" is not evidence.

## Conclusions

- `PROCEED`: contract is understood, compatible path is clear, and verification is defined.
- `ADD_NEW_ENDPOINT`: old contract must remain intact and requested shape is materially different.
- `NEEDS_CONTEXT`: missing current contract, caller, isolation, or compatibility evidence.
- `BLOCKED`: safe implementation is impossible without user/product decision.

## Coordination

- In rcrai repositories, organization rules still own gateway, Swagger, DB, deployment, and feature-flow expectations. Use this skill as a contract preflight inside that workflow.
- Use `iteration-drift-guard` for long-running boundary drift, migration, or repeated bug-fix loops. Use this skill for API/interface compatibility.
- Use gstack or Superpowers only when explicitly invoked or when their larger workflow is appropriate. This skill should remain small and local to the contract decision.
