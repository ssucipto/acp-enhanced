---
id: task-320
milestone: M86
title: "Consumer upgrade dry-run + FIFOZ notification"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 4
depends_on: [task-314, task-319]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-01', 'F-114-04']
files_affected:
  - agent/reports/m86-fifoz-upgrade-note.md
---

<!-- @acp.meta.task
topic: m86, fifoz, consumer, upgrade, fifoz, note
description: Prove a fork can upgrade without silent loss, and tell FIFOZ which port-guide claims were false vs shipped.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D3, D4
depends_on: task-314, task-319
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Prove a fork can upgrade without silent loss, and tell FIFOZ which port-guide claims were false vs shipped.

## Context

User asked how to ensure updates improve FIFOZ without losing functions. This task is the answer artifact.

## Steps

1. Document a dry-run procedure: clone/worktree, run version-update against M86 artifacts, run upgrade-guard, run /acp-ci --static.
2. Execute as much as feasible in this repo (guard self-test already in 315); record results.
3. Write `agent/reports/m86-fifoz-upgrade-note.md` including:
   - Correction: six "unreported" commands already identical upstream
   - What v6.31.0 adds (/acp-ci, /acp-pr, upgrade-guard, FG contracts, review-scan merge)
   - Which FIFOZ upstream-delta sentinels become supersede_when candidates
   - Checklist link
4. Do not claim M81 fixture work.

## Verification

- [x] Upgrade note corrects false positive
- [x] Lists supersede candidates
- [x] Links fork checklist
- [x] Dry-run results recorded

## User-Observable Acceptance

FIFOZ can read `m86-fifoz-upgrade-note.md` and know what they gain vs what they should delete from local_only.

## Expected Output

### Files Created / Modified
- `agent/reports/m86-fifoz-upgrade-note.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
