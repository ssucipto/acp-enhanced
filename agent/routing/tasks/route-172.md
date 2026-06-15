---
id: route-172
title: Unit tests for TS tooling (dispatch + validate) via vitest
task_type: typescript-feature
milestone: M61
complexity: medium
executor: copilot
context_required:
  - skills/typescript.md
  - wiki/architecture.md#dispatch-script-flow
files_affected:
  - scripts/package.json
  - scripts/acp-dispatch.test.ts
  - scripts/acp-validate.test.ts
  - scripts/vitest.config.ts
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Establish a unit-test harness for the TypeScript tooling and cover the dispatch and validate logic — currently the only Turing-complete code in the repo with zero tests.

## Context

`scripts/*.test.ts` = 0 files; `acp-dispatch.ts` and `acp-validate.ts` are untested (audit-066 MED-066-003). route-159 introduces the first dispatch test; this route builds it out into a full suite and wires it into CI.

## Steps

1. Add a test runner to `scripts/package.json` (vitest recommended; add `"test": "vitest run"`), plus minimal config.
2. `acp-dispatch.test.ts` — cover:
   - `buildContext` enforces the 6,500-token budget (prunes wiki on overflow).
   - `getFilteredLessons` filters by task_type, skips archived, caps at 5.
   - `getLastNSessions` returns last N entries.
   - `updateRoutingYml` is non-destructive (merge/extend route-159's test here).
   - `getSkillFile` maps task types correctly.
3. `acp-validate.test.ts` — cover:
   - placeholder detection on lines 3-4.
   - frontmatter-field detection (Namespace/Version/Status/Scripts).
4. Refactor pure functions for testability if needed (export them).
5. Add a CI step to run `npm test` in `scripts/` (extends route-161 CI work).

## Expected Output

### Files Created
- `scripts/acp-dispatch.test.ts`, `scripts/acp-validate.test.ts`, `scripts/vitest.config.ts`

### Files Modified
- `scripts/package.json` — test script + devDeps; `.github/workflows/ci.yaml` — npm test step

## Verification (double-verify)

- [ ] **Automated**: `npm test` green; CI runs it; coverage includes budget + non-destructive routing.yml
- [ ] **Manual**: introducing a budget-busting input makes the budget test fail
- [ ] `npx tsc --noEmit` clean

## User-Observable Acceptance

- `cd scripts && npm test` runs the TS unit suite green
- CI shows a TS unit-test job

## Addresses

audit-066 MED-066-003 (consolidated register M10)
