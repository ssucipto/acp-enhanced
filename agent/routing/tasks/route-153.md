---
id: route-153
title: "M57-004: acp.validate.md — recurring_tasks validation step"
task_type: command-doc-update
milestone: M57
complexity: low
executor: copilot
context_required: [milestones/milestone-57-recurring-tasks-scheduler.md, routes 150-152, agent/commands/acp.validate.md]
files_affected: [agent/commands/acp.validate.md]
tokens_est: 2000
created: 2026-06-08
completed: 2026-06-08
---

# Route 153: Validate Integration — Recurring Tasks Schema Check

## Objective

Add a validation step to `acp.validate.md` that checks `progress.yaml → recurring_tasks` for schema correctness, stale dates, and valid command references.

## Expected Output

### Files Modified
- `agent/commands/acp.validate.md` — add Step for recurring_tasks validation

## Validation Rules

1. **Schema check**: Every recurring_tasks entry has required fields (id, command, frequency, executor, last_run, next_due, status, description)
2. **Enum check**: `frequency` ∈ {weekly, monthly, quarterly, on-commit}; `status` ∈ {current, overdue, disabled}
3. **Date check**: `last_run` and `next_due` are ISO dates or null
4. **Command check**: `command` starts with `/acp-` and references an existing command doc
5. **Staleness check** (warning): `last_run` > 90 days ago for weekly tasks, > 180 days for monthly
6. **Overdue check** (warning): `next_due` < today and `status` is not `disabled`

## Output Format

```
📋 Recurring Tasks Validation:
  ✅ weekly-code-review: current (next due: 2026-06-15)
  ⚠️ weekly-integrity-scan: overdue — last run 2026-06-01, due 2026-06-08
  ✅ pre-commit-rule-audit: on-commit (active)
  ✅ monthly-dependency-audit: current (next due: 2026-07-01)
  ℹ️ quarterly-deep-scan: current (next due: 2026-07-01, deferred to M58)

  Summary: 5 tasks, 4 current, 1 overdue, 0 disabled
```

## Verification

- [ ] `acp.validate.md` has new Step for recurring_tasks validation
- [ ] Schema checks cover all 8 required fields
- [ ] Enum validation for frequency and status
- [ ] Staleness warnings for old last_run dates
- [ ] Overdue warnings for past next_due with non-disabled status
- [ ] Command reference validation (exists in agent/commands/)

## User-Observable Acceptance

- `/acp-validate` reports recurring task status
- Overdue tasks flagged with ⚠️
- Disabled tasks excluded from overdue checks
