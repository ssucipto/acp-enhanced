---
id: route-044
title: M43 — Add copilot executor note to ledger.md (R2)
task_type: documentation-sync
milestone: M43
complexity: low
executor: deepseek-v4-flash
context_required:
  - memory/sessions.md
files_affected:
  - agent/routing/ledger.md
tokens_est: 1500
tokens_actual:
cost_est_usd: 0.00
cost_actual_usd:
created: 2026-05-12
completed: 2026-05-12
override_reason:
---

## Task Description

Add a clarifying comment to the `agent/routing/ledger.md` header explaining why rows with `executor: copilot` always have blank `tokens_in`, `tokens_out`, and `cost_usd` values.

**Background**: Cost report analysis showed all 8 ledger rows have blank token/cost data. Investigation revealed that 5 of 8 task types use `executor: copilot` — these tasks run inside VS Code Copilot which has no mechanism to write back to `ledger.md`. The ledger rows are created as stubs but never populated. Without a note explaining this, future `/acp-cost-report` runs will flag these rows as broken or missing data, wasting investigation time.

**Source**: audit-017 recommendation R2 (`agent/reports/audit-017-taxonomy-improvement-suggestions.md`)

## Implementation

Add to the comment header block in `agent/routing/ledger.md` (after the existing format line):

```
# Note: Rows with executor 'copilot' will always have blank tokens_in/tokens_out/cost_usd.
# Copilot tasks run inside VS Code and have no write-back mechanism to this ledger.
# Only tasks dispatched via acp-dispatch.ts (deepseek-v4-flash, deepseek-v4-pro, claude-sonnet)
# can populate actual token and cost data.
```

## Acceptance Criteria

- [ ] Comment note added to `ledger.md` header (within the existing `#` comment block, before the table)
- [ ] Note mentions `executor: copilot` as the cause of blank rows
- [ ] Note mentions `acp-dispatch.ts` as the only path that populates actuals
- [ ] No table rows modified — header comment only
