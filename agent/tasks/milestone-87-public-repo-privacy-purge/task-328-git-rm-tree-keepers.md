---
id: task-328
milestone: M87
title: "git rm report/feedback bodies; keep .gitkeep + README"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 3
depends_on: [task-323, task-324, task-327]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03']
files_affected:
  - agent/reports/
  - agent/feedback/
---

<!-- @acp.meta.task
topic: m87, git-rm, keepers
description: Remove tracked report and feedback bodies from the tree; keep .gitkeep and a short README each.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1
depends_on: task-323, task-324, task-327
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Remove all tracked bodies under `agent/reports/` and `agent/feedback/` from the **current tree**. Leave `.gitkeep` and a ≤10-line README stating files are local (ADR-27).

## Context

**Blocked on 323 restore proof.** This commit does **not** unpublish history. Do not mark F-118-01..03 fixed. Do not force-push.

## Steps

1. Confirm 323 archive restore dry-run passed.
2. `git ls-files agent/reports agent/feedback` — save the list locally (untracked) as a deletion manifest.
3. `git rm` all listed files except keepers. Add `README.md` if missing (no inventory of old audits).
4. Confirm working copy still has local copies if they were only untracked; tracked copies are gone from the index.
5. Commit with a message that does **not** name leaked identifiers.
6. Do not run `filter-repo` here.

## Verification

- [ ] `git ls-files agent/reports agent/feedback` is only keepers
- [ ] 323 archive still restores full inventory
- [ ] F-118-01..03 still `pending`
- [ ] No `git add` of remaining local report bodies

## User-Observable Acceptance

GitHub **tip** (after push of this commit, before rewrite) no longer shows audit/feedback bodies. History still does — that is expected until 330.

## Expected Output

### Files Created / Modified
- `agent/reports/.gitkeep`, `agent/reports/README.md`
- `agent/feedback/.gitkeep`, `agent/feedback/README.md`
- Index: bodies removed

### Notes
Push of this commit is optional and **not** the security control.
