---
id: route-175
title: Add memory-layer entity schemas + enforce all schemas in acp-validate.ts
task_type: yaml-schema
milestone: M62
complexity: high
executor: copilot
context_required:
  - skills/schemas.md
  - skills/typescript.md
files_affected:
  - agent/schemas/milestone.schema.yaml
  - agent/schemas/session.schema.yaml
  - agent/schemas/lessons.schema.yaml
  - agent/schemas/decisions.schema.yaml
  - agent/schemas/clarification.schema.yaml
  - agent/schemas/feedback.schema.yaml
  - agent/schemas/audit-carryovers.schema.yaml
  - scripts/acp-validate.ts
tokens_est: 12000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Add schemas for the unvalidated memory-layer entities and wire `acp-validate.ts` to enforce all schemas (including the 5 existing ones it currently ignores).

## Context

Only 5 schemas exist (progress, package, task, projects, driver) and none are enforced by the validator (audit-066 MED-066-007). The memory layer (sessions, lessons, decisions, carryovers) is entirely unvalidated, allowing malformed YAML that breaks dispatch parsing.

## Steps

1. Author schemas (follow `agent/schemas/progress.schema.yaml` style) for: milestone, session, lessons, decisions, clarification, feedback, audit-carryovers.
2. Derive each schema's required fields from the documented formats in AGENTS.md / command docs (e.g., session entry: date, executor, tasks, done, deferred, key_fact).
3. Extend `acp-validate.ts` with a schema-enforcement pass: load each schema, validate the corresponding file(s), report errors with file:line.
4. Add a `--memory` or default mode hook consistent with `/acp-validate` Step 2b.
5. Wire into CI (extends route-161/172 CI work).
6. Prove enforcement with a deliberately malformed memory entry.

## Expected Output

### Files Created
- 7 new `agent/schemas/*.schema.yaml`

### Files Modified
- `scripts/acp-validate.ts` — schema enforcement pass; `.github/workflows/ci.yaml`

## Verification (double-verify)

- [ ] **Automated**: a malformed sessions.md / carryovers entry FAILS validation in CI
- [ ] **Manual**: valid current files pass; each new schema lints
- [ ] Existing 5 schemas now enforced (not just present)

## User-Observable Acceptance

- `/acp-validate` reports memory-layer schema results
- Breaking a memory entry's structure turns CI red

## Addresses

audit-066 MED-066-007 (consolidated register M11)
