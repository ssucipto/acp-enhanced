---
id: task-321
milestone: M86
title: "v6.31.0 closure — CHANGELOG, versions, carryover stamps"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: null
completed:
phase: 4
depends_on: [task-318, task-319, task-320]
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
status: draft
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
4. Stamp F-114-02…09 fixed with fix_applied_date and verified evidence pointers — **do not stamp without evidence**.
5. Leave F2-09 and M81 fixture items untouched.
6. Run validate + key E2E suites; record run ids/paths.
7. Do not push; do not retarget current_milestone unless maintainer directs (default: keep M81 as current_milestone with note M86 complete).

## Verification

- [ ] All version pins 6.31.0 consistent per acp-validate
- [ ] CHANGELOG has 6.31.0 section
- [ ] F-114-02…09 fixed with evidence
- [ ] Milestone doc Progress 17/17
- [ ] current_milestone policy documented in notes

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
