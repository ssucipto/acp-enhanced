---
id: task-315
milestone: M86
title: "E2E upgrade-guard + fork upgrade documentation"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 2
depends_on: [task-314]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-04']
files_affected:
  - e2e/acp.upgrade-guard.test.sh
  - docs/acp-fork-upgrade-checklist.md
---

<!-- @acp.meta.task
topic: m86, fifoz, e2e, upgrade, guard, docs
description: Automated tests for the guard and a consumer checklist FIFOZ can follow when upgrading.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D3
depends_on: task-314
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Automated tests for the guard and a consumer checklist FIFOZ can follow when upgrading.

## Context

FIFOZ fear is regression on upgrade. Docs must say: run guard → review collisions → prefer upstream when superseded → run /acp-ci --static → E2E.

## Steps

1. E2E: create temp delta with sentinel, pass; remove; fail; restore.
2. Write `docs/acp-fork-upgrade-checklist.md` (portable; no FIFOZ secrets).
3. Link from AGENT.md or README in task-319/321 — at least create the doc here.
4. Mention ADR-25 policy.

## Verification

- [x] e2e passes
- [x] Checklist includes prefer-upstream-when-superseded
- [x] Checklist includes /acp-ci after upgrade

## User-Observable Acceptance

A fork maintainer can open `docs/acp-fork-upgrade-checklist.md` and follow numbered steps after `/acp-version-update`.

## Expected Output

### Files Created / Modified
- `e2e/acp.upgrade-guard.test.sh`
- `docs/acp-fork-upgrade-checklist.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
