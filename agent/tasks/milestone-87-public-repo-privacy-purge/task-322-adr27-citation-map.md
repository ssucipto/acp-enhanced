---
id: task-322
milestone: M87
title: "Lock ADR-27 + citation map of tracked reports/feedback"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 0
depends_on: []
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04']
files_affected:
  - agent/memory/decisions.md
  - agent/design/local.public-repo-privacy-purge.md
  - agent/milestones/milestone-87-public-repo-privacy-purge.md
---

<!-- @acp.meta.task
topic: m87, adr-27, privacy, citation-map
description: Confirm ADR-27 and design have no leaked internals; inventory every command/E2E/wiki that assumes tracked reports.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1, D6
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Lock policy (ADR-27) and produce a citation map so later tasks do not miss a command, validator, or E2E that still requires tracked `agent/reports/` or `agent/feedback/` bodies.

## Context

Planning already wrote ADR-27 and the design. This task is the **implementation start**: verify those files contain no consumer internals or vendor IDs, then list every live reference that tasks 324–326 must change.

## Steps

1. Re-read ADR-27 and `local.public-repo-privacy-purge.md`. Confirm they do **not** paste consumer spec bodies, `$HOME` paths, or vendor account identifiers.
2. Grep the repo for `agent/reports`, `agent/feedback`, `validateProtocolDirAddability`, and D9 tracking language. Record hits in the task notes (paths only, no leaked file contents).
3. Split hits into: (a) writers that must stay local, (b) validators/E2E that must stop requiring tracked files, (c) install/pattern/docs, (d) remaining tracked files that still contain `$HOME` or consumer internals (feeds task-327).
4. Confirm review-006 (js-yaml / bootstrap / dispatch) is **not** on this map.
5. Do not `git add` any `agent/reports/` or `agent/feedback/` bodies.

## Verification

- [ ] ADR-27 present; D9 tracking superseded for this public repo
- [ ] Citation map lists commands, `scripts/acp-validate.ts`, E2E, wiki, pattern, project-create
- [ ] No new secrets in planning docs
- [ ] F-R006-* explicitly out of scope

## User-Observable Acceptance

A developer starting 324 can open this task’s notes and see every file that still assumes tracked reports.

## Expected Output

### Files Created / Modified
- This task file (notes with citation map)
- ADR-27 / design only if a leak or contradiction is found

### Notes
Do not reopen the Class A/B git split. Force-push is not this task.
