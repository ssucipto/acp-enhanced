---
id: route-185
title: Reconcile status across layers — re-stamp milestones, fill route completed dates, register M59-M65 in progress.yaml
task_type: progress-update
milestone: M65
complexity: medium
executor: copilot
context_required:
  - reports/audit-069-m57-m58-post-sync-reaudit.md
files_affected:
  - agent/progress.yaml
  - agent/milestones/milestone-57-recurring-tasks-scheduler.md
  - agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md
  - agent/routing/tasks/route-150.md
  - agent/routing/tasks/route-151.md
  - agent/routing/tasks/route-152.md
  - agent/routing/tasks/route-153.md
  - agent/routing/tasks/route-154.md
  - agent/routing/tasks/route-155.md
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

Make every tracking layer agree. Re-stamp the M57/M58 milestone docs to their true status, fill `completed:` on the M57 routes (and route-155), register the on-disk milestones M59–M65 into `progress.yaml`, and fix the M54 dangling pointer.

## Context

audit-069: F-069-01 (HIGH) milestone-57/58 docs say "planned" while progress.yaml says completed/in-progress (merge restored pre-completion versions). F-069-02 (HIGH) route-155 deliverables exist and progress.yaml counts M58 1/4 but route-155.md `completed:` is empty; M57 routes similarly unstamped. F-069-09 (MED) progress.yaml M54 → `milestone-54-ci-cd-gitflow.md` does not exist; M54 is active/30% with `tasks_total: 0`. Separately, M59–M63 milestone docs + route-150..178 exist on disk but progress.yaml has NO M59–M63 entries and `current_milestone: M58` — the operational side of the desync.

## Steps

1. **Re-stamp milestones** (F-069-01): set `milestone-57-*.md` → `Status: completed` (+ Started/Target/Completed dates from git/progress.yaml); `milestone-58-*.md` → `Status: in_progress` with accurate % and "Started".
2. **Stamp routes** (F-069-02): set `completed:` on route-150..154 (M57, completed) and route-155 (M58 research) to their actual completion dates (from git log of the deliverables). Leave route-156..158 unstamped (not started). Reconcile `progress.yaml` M57/M58 `tasks_completed` with the stamps.
3. **Verify milestone registration**: M59–M65 are already registered in `progress.yaml` (M59–M63 from prior planning; M64/M65 added 2026-06-15). Confirm all seven entries have correct `file:` pointers, `tasks_total`, and `status: planned`; repair any that are missing/incorrect. Do NOT mark any complete.
4. **current_milestone**: `progress.yaml` still reads `current_milestone: M58`. Set it to the active implementation track per user intent (recommend M59 — the critical-fix track — since M59 is the gating prerequisite). Document the choice in `notes`.
5. **Fix M54** (F-069-09): EITHER create `milestone-54-ci-cd-gitflow.md` from git history of the CI/CD gitflow work, OR remove the M54 entry/pointer if folded elsewhere; fix `tasks_total` vs `status` inconsistency.
6. Update `next_steps` to reflect M59→M65 ordering.

## Expected Output

### Files Modified
- `agent/progress.yaml` — M59–M65 registered, M54 fixed, M57/M58 counts reconciled, current_milestone + next_steps updated
- `milestone-57/58.md` — status re-stamped
- `route-150..155.md` — `completed:` stamped

## Verification (double-verify)

- [x] **Automated**: route-186's new `/acp-validate` check passes (no status disagreements, no dangling pointers) — run after route-186 lands; until then, manual
- [x] **Manual**: `grep -E "M(59|60|61|62|63|64|65):" agent/progress.yaml` returns all seven
- [x] **Manual**: no `file:` in progress.yaml points to a non-existent file (`for f in $(grep -oE 'agent/milestones/[^ ]+\.md' agent/progress.yaml); do test -f $f || echo MISSING $f; done`)
- [x] milestone-57 status == completed, milestone-58 status == completed (M58 shipped v6.20.2 during M65 execution), matching progress.yaml

## User-Observable Acceptance

- A reader gets ONE consistent status for every milestone/route across docs, progress.yaml, and git.

## Addresses

audit-069 F-069-01 (HIGH), F-069-02 (HIGH), F-069-09 (MED)
