---
id: route-081
title: "Schema alignment — commit output vs visualizer expectations"
task_type: command-doc-update
milestone: M47
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/commands/acp.validate.md
files_affected:
  - agent/commands/acp.commit.md
  - agent/commands/acp.validate.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 081: Schema Alignment

## Objective

Align the schema field names between `/acp-commit` output and what the ACP Visualizer
expects, eliminating the `tasks:` vs `tasks_completed:` drift that causes the visualizer
to show "0 tasks" per session.

## Context

FIFOZ feedback-001 (F-09) identified that `/acp-commit` step 2 writes `tasks:` in the
session entry schema, but the visualizer's `SessionEntry` type expects `tasks_completed:`.
Even after YAML fixes, the Sessions timeline shows "0 tasks" because of this mismatch.

**Additional finding (audit-041)**: `acp.commit.md` has internal field inconsistency —
Step 2 uses `tasks:` (line 83) while Step 6 compaction uses `tasks_completed:` (line 120).
Both must be aligned. Also, `acp.validate.md` Step 11.6 validates against `tasks:` key
(line 409) — must be updated simultaneously with the commit schema change.

## Changes

### acp.commit.md — Session Entry Schema (Steps 2 AND 6)

Update BOTH schemas to consistently use `tasks_completed:`:

**Step 2 (session entry)** — Before:
```yaml
- date: [today]
  executor: [executor used this session]
  tasks: [list of route IDs completed]
```

**Step 2 — After**:
```yaml
- date: [today]
  executor: [executor used this session]
  tasks_completed: [list of route IDs completed]
```

**Step 6 (weekly-summary compaction)** — uses `tasks_completed:` already. Update the
step description text to consistently reference `tasks_completed:` (not `tasks:`).

### acp.validate.md — Step 11.6 (Sessions Structure Check)

Update the validator to check for `tasks_completed:` instead of `tasks:`:
- Line 409: change required key from `tasks` to `tasks_completed`
- The date format validation (`YYYY-MM-DD`) and other required keys (`date`, `executor`, `done`) remain unchanged

> **Backward compatibility note**: Existing entries with `tasks:` should still be
> readable. The visualizer should also accept `tasks:` as a fallback (visualizer-side fix
> tracked separately). The canonical field going forward is `tasks_completed:`.

## Verification

- [ ] acp.commit.md step 2 schema uses `tasks_completed:`
- [ ] Existing sessions.md entries are not broken by the change (visualizer handles both)
- [ ] New sessions write `tasks_completed:` consistently

## Dependencies

- Visualizer repo: accept both `tasks:` and `tasks_completed:` (separate issue)
