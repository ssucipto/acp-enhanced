---
id: route-159
title: Fix updateRoutingYml() full-overwrite — surgical session-block update + regression test
task_type: typescript-feature
milestone: M59
complexity: medium
executor: copilot
context_required:
  - wiki/architecture.md#dispatch-script-flow
  - memory/lessons.md
files_affected:
  - scripts/acp-dispatch.ts
  - scripts/acp-dispatch.test.ts
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Fix the data-loss bug where `updateRoutingYml()` overwrites the entire `agent/core/routing.yml` with a 4-line `session:` stub, destroying `context_modes` and `command_suggestions`. Replace with a surgical update of ONLY the `session:` block, preserving the rest of the file. Add a regression test that fails on the current behaviour.

## Context

`scripts/acp-dispatch.ts:191-195` does `writeFileSync(routing.yml, "session:\n...")` — a full replace. `core/routing.yml` is git-tracked framework data containing the light/full mode system (line 24) and command discoverability config (line 83). Every Persona B/C dispatch silently deletes that config and would commit the loss. Found in audit-066 (HIGH-066-001).

## Steps

1. Read `scripts/acp-dispatch.ts` `updateRoutingYml()` and the current `core/routing.yml` structure.
2. Rewrite `updateRoutingYml()` to update only the `session:` block:
   - Parse routing.yml, replace the `session:` mapping in place (preserve `context_modes`, `command_suggestions`, comments where feasible), OR use a targeted regex that swaps only the `session:` block up to the next top-level key.
   - Prefer round-tripping via `js-yaml` load→mutate→dump only if it preserves the rest; otherwise targeted block replace to keep comments.
3. Add `scripts/acp-dispatch.test.ts` (vitest or node:test) asserting:
   - After `updateRoutingYml('x','y')`, `context_modes` and `command_suggestions` still present.
   - `session.executor` is updated.
4. Wire the test into `scripts/package.json` `test` script (used by route-172/M61 for the broader suite).

## Expected Output

### Files Modified
- `scripts/acp-dispatch.ts` — surgical `updateRoutingYml()`

### Files Created
- `scripts/acp-dispatch.test.ts` — regression test

## Verification (double-verify)

- [ ] **Automated**: new test FAILS against the old implementation, PASSES after fix
- [ ] **Manual**: run a dry dispatch (or call the function directly), then `grep context_modes agent/core/routing.yml` returns matches
- [ ] No comments/sections other than `session:` are lost
- [ ] `npx tsc --noEmit` clean

## User-Observable Acceptance

- After a dispatch, `agent/core/routing.yml` still contains `context_modes:` and `command_suggestions:`
- `npm test` (in scripts/) shows the routing.yml non-destructiveness test passing

## Addresses

audit-066 HIGH-066-001 (consolidated register H1)
