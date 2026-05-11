---
id: route-036
title: M42 — Fix acp-dispatch.ts updateRoutingYml() execution order + SIGINT handler (BUG-003)
task_type: typescript-feature
milestone: M42
complexity: medium
executor: copilot
context_required:
  - scripts/acp-dispatch.ts
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
  - agent/memory/audit-carryovers.md
files_affected:
  - scripts/acp-dispatch.ts
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Fix the dispatch ordering bug in `scripts/acp-dispatch.ts`: `updateRoutingYml()` is currently called at line ~208 BEFORE the API stream begins. If the API call fails (network error, invalid key, or SIGINT), `routing.yml` is permanently mutated to show an executor/model that did no work. Add a SIGINT handler that flushes a partial ledger row and exits cleanly without mutating `routing.yml`.

## Context

From audit-015 BUG-003:
> `updateRoutingYml(executor, modelConfig.model)` is called at line 208 in `scripts/acp-dispatch.ts`, before the API stream. If API fails or SIGINT received, `routing.yml` permanently shows the intended executor/model with no work done. Also: SIGINT during streaming loses the ledger row — tokens billed but not recorded.

The correct call order is:
1. `streamToConsole()` — run the API call and stream output
2. `appendLedger()` — record tokens/cost AFTER stream completes
3. `updateRoutingYml()` — record the executor/model AFTER ledger confirms the run

## Acceptance Criteria

### Fix execution order
- [ ] `updateRoutingYml(executor, modelConfig.model)` is called AFTER `appendLedger()`, not before it
- [ ] Verify the call appears at approximately line 270+ (after the stream and ledger write)
- [ ] Normal (successful) dispatch flow: routing.yml and ledger both updated correctly

### Add SIGINT handler
- [ ] SIGINT handler registered before the API call begins (using `process.on('SIGINT', ...)`)
- [ ] On SIGINT:
  - Print: `\n[dispatch] Interrupted — flushing partial ledger row`
  - Write a partial ledger row via `appendLedger()` with `tokens: 0, cost: 0, note: "interrupted by SIGINT"`
  - Do NOT call `updateRoutingYml()` — routing.yml stays at its previous state
  - Exit with code 130 (`process.exit(130)`)
- [ ] SIGINT handler is removed after the API call completes (avoid double-handling)
- [ ] Handler does not interfere with normal successful dispatch

### Regression check
- [ ] Read surrounding lines to ensure no other early mutation of routing.yml exists
- [ ] Verify `appendLedger()` and `updateRoutingYml()` are not called in error/catch paths that would double-execute them

## Implementation Notes

Use `process.on('SIGINT', handler)` and `process.off('SIGINT', handler)` (or `once`) for clean registration/deregistration. The partial ledger row format should follow the same schema as `appendLedger()` — just with zeroed token/cost values and a note field.

Read the current file carefully before editing — the exact line numbers may differ from audit-015 estimates.
