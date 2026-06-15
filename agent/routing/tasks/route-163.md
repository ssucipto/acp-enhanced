---
id: route-163
title: OPENROUTER_API_KEY preflight check in dispatch
task_type: typescript-feature
milestone: M59
complexity: low
executor: copilot
context_required:
  - wiki/architecture.md#dispatch-script-flow
files_affected:
  - scripts/acp-dispatch.ts
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Add a clear preflight check for `OPENROUTER_API_KEY` so a missing env var fails fast with an actionable message instead of a cryptic OpenAI SDK error.

## Context

`scripts/acp-dispatch.ts:233` uses `process.env.OPENROUTER_API_KEY!` (non-null assertion). If unset, the SDK throws an opaque error deep in the call. Found in audit-066 (MED-066-002).

## Steps

1. In `dispatch()`, before constructing the `OpenAI` client (and after the `local-script` early return), check `process.env.OPENROUTER_API_KEY`.
2. If unset/empty: print `[ACP] OPENROUTER_API_KEY is not set. Export it or use Persona A (copilot). See scripts/QUICKSTART.md.` and `process.exit(1)`.
3. Remove the `!` non-null assertion now that presence is guaranteed.

## Expected Output

### Files Modified
- `scripts/acp-dispatch.ts` — preflight env check

## Verification (double-verify)

- [ ] **Automated**: unit test (or manual run) with unset key exits 1 with the clear message
- [ ] **Manual**: `OPENROUTER_API_KEY= npx ts-node scripts/acp-dispatch.ts <task>` prints the actionable message, not an SDK stack trace
- [ ] `npx tsc --noEmit` clean

## User-Observable Acceptance

- Running dispatch without the key prints a one-line actionable error and exits non-zero

## Addresses

audit-066 MED-066-002 (consolidated register M9)
