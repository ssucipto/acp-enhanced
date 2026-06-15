---
id: route-188
title: M57/M58 hygiene — promote F-062-03 to M59, gate quarterly-deep-scan, pipefail acp.meta-scan.sh, track wiki v2.0 surface
task_type: progress-update
milestone: M65
complexity: low
executor: copilot
context_required:
  - reports/audit-068-m57-m58-implementation-gap-analysis.md
files_affected:
  - agent/milestones/milestone-59-critical-fix-ci-integrity.md
  - agent/progress.yaml
  - agent/scripts/acp.meta-scan.sh
  - agent/routing/tasks/route-173.md
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Clean up four small but real M57/M58 hygiene issues: a HIGH correctness gap living in a shipped feature, a scheduled task that calls an unbuilt capability, a script missing `-o pipefail`, and a doc-surface tracking note.

## Context

audit-068/069: F-068-03/F-069-05 (HIGH) — F-062-03 (no automated `next_due` → manual date drift) is a HIGH gap in the SHIPPED recurring-task scheduler but is queued late in route-176/M62; it should be promoted to the M59 critical track. F-068-10 (LOW) — the `quarterly-deep-scan` recurring task invokes unbuilt M58 capability (`--rules taint-flow,memory`) and is scheduled (next_due 2026-09-08) for a feature not yet implemented. F-068-12 (LOW) — `agent/scripts/acp.meta-scan.sh` uses `set -eu` + ERR trap but not `-o pipefail` and is not in route-173's 17-file list. F-068-07 (MED) — wiki/command still show only v1.0 surface; ensure route-156 owns updating the v2.0 surface when rules land.

## Steps

1. **Promote F-062-03** (F-068-03/F-069-05): add a route to M59 (or annotate route-176) that implements automated `next_due` calculation (`acp.task-complete.sh` helper or `--complete` flag setting `last_run=today`, `next_due=today+frequency`). Update `milestone-59` Build Order + carryover `escalated_to` for F-062-03 to point at the M59 route. Keep F-062-01/02/04/05 in route-176/M62.
2. **Gate quarterly-deep-scan** (F-068-10): in `progress.yaml → recurring_tasks`, set the `quarterly-deep-scan` entry to `status: blocked` (or add `blocked_by: M58`) with a note that it activates when v2.0 ships; remove/comment the premature `next_due` or annotate it clearly.
3. **pipefail acp.meta-scan.sh** (F-068-12): either add `agent/scripts/acp.meta-scan.sh` to route-173's file list (preferred — single batch) OR upgrade its header to `set -euo pipefail` here. Update route-173 `files_affected` if adding.
4. **Wiki v2.0 surface** (F-068-07): confirm route-156 (M58) explicitly owns updating `integrity-rules.md` + `acp.integrity.md` header counts when v2.0 rules land; add a one-line acceptance criterion to route-156 if missing.

## Expected Output

### Files Modified
- `milestone-59-*.md` + `progress.yaml` — F-062-03 promoted; quarterly-deep-scan gated
- `agent/scripts/acp.meta-scan.sh` or `route-173.md` — pipefail coverage
- `route-156.md` (M58) — wiki v2.0 surface acceptance (if missing)
- `agent/memory/audit-carryovers.md` — `escalated_to` updated for F-062-03

## Verification (double-verify)

- [ ] **Manual**: F-062-03 appears in M59 Build Order; carryover escalated_to updated
- [ ] **Manual**: `quarterly-deep-scan` no longer shows an imminent `next_due` for an unbuilt feature (blocked/annotated)
- [ ] **Manual**: `grep -L 'set -euo pipefail' agent/scripts/acp.meta-scan.sh` returns nothing
- [ ] route-156 acceptance mentions updating wiki/command v2.0 counts

## User-Observable Acceptance

- The shipped scheduler's date-drift gap is on the critical track; no scheduled task points at an unbuilt feature; all scripts are pipefail-clean.

## Addresses

audit-068 F-068-03 (HIGH), F-068-10 (LOW), F-068-12 (LOW), F-068-07 (MED); audit-069 F-069-05 (HIGH)
