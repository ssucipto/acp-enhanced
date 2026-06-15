---
id: route-176
title: Resolve 5 audit-062 carryovers (recurring-task & hooks hardening)
task_type: bash-script-fix
milestone: M62
complexity: medium
executor: copilot
context_required:
  - core/constraints.yml
  - progress.yaml
files_affected:
  - agent/core/constraints.yml
  - agent/progress.yaml
  - agent/commands/acp.validate.md
  - .git/hooks/pre-commit
tokens_est: 7000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Resolve the 5 long-standing audit-062 carryovers around recurring tasks and pre-commit hooks (M57 deep-dive findings), and mark them fixed in `audit-carryovers.md`.

## Context

5 pending carryovers from audit-062 (all medium): hooks block format divergence, unverified milestone checklist items, no automated next_due, missing reference git-hook, no findings-to-task feedback loop.

## Steps

1. **F-062-01** — Restore the 2 dropped hooks to the constraints.yml hooks block: `pre_commit_integrity_phase1` and `ci_npm_ignore_scripts` (verify against the M57 milestone plan).
2. **F-062-02** — Verify the 3 milestone checklist items: disabled-task exclusion, frequency/trigger XOR rule, executor cross-validation; document results.
3. **F-062-03** — Add automated `next_due` calculation for recurring_tasks (compute from `last_run` + frequency) so dates don't drift manually; implement in the recurring-task handling (script or command step).
4. **F-062-04** — Provide a reference `pre-commit` git-hook implementation for the `pre-commit-rule-audit` trigger.
5. **F-062-05** — Add `last_findings_count` field to recurring_tasks entries (findings-to-task feedback loop).
6. Mark F-062-01..05 `status: fixed`, set `fix_applied_date` + `verified_in_audit` in `audit-carryovers.md`.

## Expected Output

### Files Modified
- `agent/core/constraints.yml`, `agent/progress.yaml`, `agent/commands/acp.validate.md`, reference hook
- `agent/memory/audit-carryovers.md` — 5 carryovers closed

## Verification (double-verify)

- [ ] **Automated**: next_due recomputation produces correct dates from a known last_run+frequency
- [ ] **Manual**: hooks block matches M57 plan; reference hook runs; carryovers marked fixed
- [ ] `/acp-validate` clean

## User-Observable Acceptance

- `agent/memory/audit-carryovers.md` shows F-062-01..05 as `status: fixed`
- Recurring task next_due updates automatically

## Addresses

audit-062 F-062-01..05 (consolidated register carryovers)
