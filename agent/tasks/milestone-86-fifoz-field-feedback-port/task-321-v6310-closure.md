---
id: task-321
milestone: M86
title: "v6.31.0 closure — CHANGELOG, versions, carryover stamps"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 4
depends_on: task-316, task-317, task-318, task-319, task-320
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-02', 'F-114-03', 'F-114-04', 'F-114-05', 'F-114-06', 'F-114-07', 'F-114-08', 'F-114-09']
files_affected:
  - CHANGELOG.md
  - agent/core/identity.yml
  - agent/progress.yaml
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - agent/memory/audit-carryovers.md
---

<!-- @acp.meta.task
topic: m86, fifoz, v6310, closure
description: Ship v6.31.0 with full version file set and stamp F-114 carryovers only with evidence.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D1, D2, D3
depends_on: task-318, task-319, task-320
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Ship v6.31.0 with full version file set and stamp F-114 carryovers only with evidence.

## Context

crosscut anti-pattern: never update only one version surface. M85 required multi-platform proof for flake carryovers; for M86, stamp only when verification from prior tasks exists.

## Steps

1. Bump version to 6.31.0 across identity, progress project.version, AGENTS/CLAUDE/copilot parity, package fields as required by validate.
2. CHANGELOG Keep-a-Changelog entry: Added /acp-ci, /acp-pr, upgrade-guard; Fixed false-green classes; Changed review-scan merge.
3. Update milestone-86 progress 17/17; progress.yaml M86 completed.
4. Stamp carryovers **F-114-02, 03, 04, 05, 06, 07, 08, 09, 11** fixed only with evidence pointers — **never stamp without evidence**. F-114-01/10 are informational (no code stamp required).
5. Leave F2-09 and M81 fixture items untouched.
6. Refresh `agent/upstream-delta.yml` collisions if 319/321 touched more upstream files; re-run upgrade-guard.
7. Run validate + key E2E suites; record run ids/paths.
8. Do not push; do not retarget `current_milestone` unless maintainer directs (default: keep M81; note M86 complete in progress notes).
9. **GATE**: all of 305–320 must be `completed` in progress.yaml before this task completes.

## Verification

- [x] All version pins 6.31.0 consistent per acp-validate
- [x] CHANGELOG has 6.31.0 section
- [x] F-114-02,03,04,05,06,07,08,09,11 fixed with evidence (or explicitly deferred with reason)
- [x] Milestone doc Progress 17/17
- [x] current_milestone policy documented in notes
- [x] upgrade-guard passes on final delta file
- [x] tasks 305–320 all completed in progress.yaml

## User-Observable Acceptance

CHANGELOG shows ## [6.31.0]; `agent/core/identity.yml` version is 6.31.0; carryovers F-114-02…09 show status fixed.

## Expected Output

### Files Created / Modified
- `CHANGELOG.md`
- `agent/core/identity.yml`
- `agent/progress.yaml`
- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `agent/memory/audit-carryovers.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
