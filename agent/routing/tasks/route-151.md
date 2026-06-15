---
id: route-151
title: "M57-002: AGENTS.md Step 4.5 — scheduled review due check"
task_type: documentation-sync
milestone: M57
complexity: low
executor: copilot
context_required: [milestones/milestone-57-recurring-tasks-scheduler.md, AGENTS.md, .github/copilot-instructions.md]
files_affected: [AGENTS.md, .github/copilot-instructions.md]
tokens_est: 2000
created: 2026-06-08
completed: 2026-06-08
---

# Route 151: Session-Start Overdue Check

## Objective

Add Step 4.5 to AGENTS.md Context Loading Protocol that surfaces overdue scheduled reviews at session start.

## Expected Output

### Files Modified
- `AGENTS.md` — insert Step 4.5 between Step 4 and Step 5
- `.github/copilot-instructions.md` — sync same change

## Step 4.5 Specification

Insert after Step 4 (Load Working Memory):

```markdown
### Step 4.5 — Scheduled Review Due Check (conditional)

Read agent/progress.yaml → recurring_tasks.
If any task has status: overdue OR next_due <= today:
  Output before starting any other task:
  ⏰ [ACP] Scheduled review(s) overdue:
     [task_id]: [command] — last run [date], due [date]
  Recommend running before unrelated work.
  Developer may defer: note in session entry as deferred with reason.

If all tasks are current:
  (Silent — do not output to avoid noise at every session start.)
```

## Design Decisions

- **Silent on success**: Avoids noise at every session start — only surfaces when action needed
- **Deferral allowed**: Developer can skip; the scheduler tracks cadence, doesn't enforce
- **Before any task work**: Output must appear before the confirm banner so agent sees it

## Verification

- [ ] AGENTS.md has "Step 4.5" section between Step 4 and Step 5
- [ ] `.github/copilot-instructions.md` has matching Step 4.5
- [ ] Step 4.5 references `progress.yaml → recurring_tasks`
- [ ] Overdue output format includes ⏰ emoji, task_id, command, last_run, next_due
- [ ] "If all tasks are current" clause specifies silent behavior

## User-Observable Acceptance

- At session start, overdue reviews are surfaced before any task work begins
- When all reviews are current, no extra output appears (silent)
