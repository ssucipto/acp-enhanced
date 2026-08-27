---
id: task-332
milestone: M87
title: "Closure: validate, stamp F-118, CHANGELOG v6.33.0"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 4
depends_on: [task-325, task-326, task-329, task-331]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-118-04', 'F-118-05', 'F-118-06']
files_affected:
  - CHANGELOG.md
  - agent/core/identity.yml
  - agent/progress.yaml
  - agent/memory/audit-carryovers.md
---

<!-- @acp.meta.task
topic: m87, closure, v6330, carryover-stamp
description: Ship v6.33.0 and stamp F-118 findings only after fresh-clone history proof.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1, D6
depends_on: task-325, task-326, task-329, task-331
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Release v6.33.0 with consistent version surfaces, stamp F-118-01..06 **fixed** only with 331 evidence, and leave F-R006-* pending.

## Context

Cross-cut anti-pattern: never bump only one version file. Never stamp carryovers without evidence. F-118-07 is covered by 327 path redaction; F-118-08 email stays (do not “fix” it).

## Steps

1. **GATE**: 331 checkboxes all true. If 330 is awaiting force-push confirm, this task is blocked.
2. Bump 6.33.0: `identity.yml`, `progress.yaml` `project.version`, AGENTS.md, CLAUDE.md, `.github/copilot-instructions.md`, package.yaml / package.json as validate requires.
3. CHANGELOG: Removed reports/feedback from public remotes; Added private-pack; Changed D9/validator. Do not paste internals.
4. Stamp F-118-01..06 `fixed` with `verified_in_audit` pointing at 331 clone proof (not at local git rm).
5. Milestone 87 progress 11/11; progress.yaml M87 completed. `current_milestone`: do not silently retarget unless maintainer directs (M81 is already complete — set to M87 only if starting implementation was already done; at closure, set current to M87 completed or leave a note). Prefer: M87 `status: completed`; ask before changing current_milestone away from whatever implementation used.
6. Run validate + affected E2E. Register private-pack on all required surfaces.
7. Do not stamp F-R006-01..03.

## Verification

- [ ] All version pins 6.33.0
- [ ] CHANGELOG has 6.33.0
- [ ] F-118-01..06 fixed with 331 evidence
- [ ] F-118-08 still keep / not treated as a leak
- [ ] F-R006-* still pending
- [ ] Milestone 11/11

## User-Observable Acceptance

CHANGELOG `[6.33.0]` explains public remotes no longer host reports; carryover ledger matches clone proof.

## Expected Output

### Files Created / Modified
- Version files + CHANGELOG
- `agent/memory/audit-carryovers.md`
- `agent/progress.yaml`
- AGENT.md / README / package.yaml if 329 added a script

### Notes
Do not add audit-118.md to origin.
