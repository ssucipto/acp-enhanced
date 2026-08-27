---
id: task-332
milestone: M87
title: "Closure: validate, stamp F-118, CHANGELOG v6.33.0"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 4
depends_on: [task-325, task-326, task-329, task-331]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-118-04', 'F-118-05', 'F-118-06']
files_affected:
  - CHANGELOG.md
  - agent/core/identity.yml
  - agent/progress.yaml
  - agent/memory/audit-carryovers.md
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - package.yaml
---

<!-- @acp.meta.task
topic: m87, closure, v6330, carryover-stamp
description: Ship v6.33.0 and stamp F-118 findings only after fresh-clone history and tag proof.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1, D6
depends_on: task-325, task-326, task-329, task-331
status: completed
updated: 2026-08-27
@acp.meta.end -->

## Objective

Release v6.33.0 with consistent version surfaces, stamp F-118-01..06 **fixed** only with 331 evidence (including tag check), stamp F-119-01..11 when the cited tasks are done, leave F-R006-* pending.

## Context

Never bump only one version file. Never stamp without evidence. F-118-08 email stays. Do not `git add` audit-118/119 reports.

## Steps

1. **GATE**: 331 checkboxes all true. If 330 awaits the confirmation phrase, this task is blocked.
2. Bump **6.33.0**: `identity.yml`, `progress.yaml` `project.version`, AGENTS.md, CLAUDE.md, copilot-instructions.md, package.yaml / package.json as validate requires.
3. CHANGELOG: Removed report/feedback bodies from public remotes **including history and tags**; Added private-pack; Changed D9/validator. Do not paste internals.
4. Stamp F-118-01..06 and F-119-* `fixed` with `verified_in_audit: "119"` **and** pointer to 331 notes. F-R006-* stay pending.
5. Milestone 87 progress 11/11; M87 `status: completed`. Do not silently change `current_milestone` without maintainer direction.
6. Register private-pack on required surfaces if 329 deferred AGENT.md. Run validate + affected E2E.
7. Five-surface parity if a new command wrapper was added.

## Verification

- [x] All version pins 6.33.0
- [x] CHANGELOG has 6.33.0
- [x] F-118-01..06 fixed with 331 evidence
- [x] F-118-08 still keep
- [x] F-R006-* still pending
- [x] Milestone 13/13
- [x] `git status` does not stage `agent/reports/audit-*.md`

## User-Observable Acceptance

CHANGELOG `[6.33.0]` explains public remotes no longer host reports; carryover ledger matches clone+tag proof.

## Expected Output

### Files Created / Modified
- Version files + CHANGELOG + carryovers + progress.yaml

### Notes
Do not add audit-118.md or audit-119.md to origin.
