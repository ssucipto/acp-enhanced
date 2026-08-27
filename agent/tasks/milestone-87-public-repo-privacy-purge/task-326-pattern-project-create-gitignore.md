---
id: task-326
milestone: M87
title: "Pattern, project-create, and install gitignores"
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 2
depends_on: [task-324]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-05']
files_affected:
  - agent/patterns/local.tracked-untracked-directories.md
  - agent/commands/acp.project-create.md
  - scripts/acp-bootstrap.sh
---

<!-- @acp.meta.task
topic: m87, pattern, project-create, gitignore-heredoc
description: Align tracked-untracked pattern and new-project gitignore templates with ADR-27 (reports/feedback local).
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2, D5
depends_on: task-324
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

New installs and agents following the pattern must gitignore `agent/reports/` and `agent/feedback/` (keepers excepted), matching ADR-27 — not D9 tracking.

## Context

F-118-05: the pattern already said those dirs were gitignored while AE tracked them. After 324, the pattern is right again; project-create and bootstrap heredocs must not re-introduce D9 “track evidence” comments.

## Steps

1. Update `agent/patterns/local.tracked-untracked-directories.md`: reports/feedback = local like drafts; cite ADR-27; D9 tracking does not apply to this public protocol repo.
2. Update `acp.project-create.md` gitignore comments and any heredoc.
3. Update bootstrap / install scripts that emit `agent/.gitignore`.
4. Attribution policy one-liner (F-118-06): consumer **names** may appear in CHANGELOG/README if consented; consumer **internals** never go in git. Point to ADR-27.
5. Do not copy field-report bodies into the pattern.

## Verification

- [ ] Pattern matches validator + gitignore
- [ ] New-project gitignore ignores reports/feedback
- [ ] No “D9 — reports are tracked” comments left in install templates

## User-Observable Acceptance

A project created from AE templates does not commit audit reports by default.

## Expected Output

### Files Created / Modified
- `agent/patterns/local.tracked-untracked-directories.md`
- `agent/commands/acp.project-create.md`
- Bootstrap/install gitignore emitters

### Notes
F-118-06 is policy text, not a dump of feedback files.
