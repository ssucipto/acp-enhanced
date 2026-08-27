---
id: task-328
milestone: M87
title: "git rm --cached report/feedback bodies; keep .gitkeep + README"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 3
depends_on: [task-323, task-324, task-325, task-327]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-119-01', 'F-119-04']
files_affected:
  - agent/reports/
  - agent/feedback/
---

<!-- @acp.meta.task
topic: m87, git-rm-cached, keepers
description: Remove tracked report and feedback bodies from the index only; keep working tree and keepers.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1
depends_on: task-323, task-324, task-325, task-327
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Remove tracked bodies from the **index** using **CB-3**. Leave files on disk (ignored). Leave `.gitkeep` + ≤10-line README.

## Context

**Blocked on 323 restore proof.** `git rm -r` (no `--cached`) is a **critical** foot-gun (F-119-01). This commit does **not** unpublish history. Depends on **325** so CI/docs are not still requiring tracked bodies when the tree is emptied.

## Steps

1. Confirm 323 CB-1 restore dry-run passed. Confirm 324 gitignore is on HEAD.
2. Execute **CB-3** exactly. If you type `git rm` without `--cached`, **stop** and restore from the `.age` archive before continuing.
3. `git ls-files agent/reports agent/feedback` must be only keepers.
4. `test -f` at least one previously tracked report still on disk (ignored).
5. Commit message must not name leaked identifiers.
6. Do not run `filter-repo`. Do not stamp F-118-01..03.

## Verification

- [x] `git ls-files agent/reports agent/feedback` = keepers only
- [x] Working tree still has report files (`ls agent/reports | wc -l` > 2)
- [x] F-118-01..03 still `pending`
- [x] No `git add -f` of audit bodies

## User-Observable Acceptance

GitHub **tip** after this commit (before rewrite) no longer shows audit/feedback bodies. History still does.

## Expected Output

### Files Created / Modified
- Keepers under `agent/reports/` and `agent/feedback/`
- Index: bodies removed

### Notes
CB-4 will strip keepers from history too; 330 re-adds them. Push of this commit is not the security control.
