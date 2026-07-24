---
id: task-275
milestone: M82
title: "Sync branches + run overdue ACP weeklies"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-24
started: null
completed: null
depends_on: []
files_affected:
  - agent/progress.yaml
  - agent/reports/
  - agent/memory/audit-carryovers.md
---

## Objective

Bring local `develop` in sync with `origin/mainline` (CI-green tip), then run the overdue ACP weeklies so the thorough campaign starts from a clean governance baseline.

## Steps

1. `git fetch origin`; fast-forward or merge `origin/mainline` into `develop` (no force). Confirm CI was green on that tip.
2. Run `/acp-review --report --carryover` (or equivalent documented invocation); save report under `agent/reports/`.
3. Run `/acp-integrity --self --report --carryover`.
4. Update `recurring_tasks` for `weekly-code-review` and `weekly-integrity-scan`: `last_run`, `next_due`, `last_findings_count`, keep `status` accurate.
5. Note finding counts in task notes / session for task-278 dedupe.

## Verification

- [ ] `develop` contains `origin/mainline` tip (or is intentionally ahead only with M82 plan commits)
- [ ] Review + integrity reports exist for this campaign date
- [ ] Recurring task due dates are in the future (or explicitly deferred with reason)

## User-Observable Acceptance

Weeklies are no longer overdue; local branch matches the green mainline baseline before CodeRabbit chunks run.
