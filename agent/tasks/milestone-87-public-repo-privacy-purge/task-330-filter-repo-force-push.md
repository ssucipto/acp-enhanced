---
id: task-330
milestone: M87
title: "filter-repo SOP + operator-confirmed force-push (branches + tags)"
status: planned
priority: 5
complexity: high
estimated_hours: 4
created: 2026-08-27
started: null
completed: null
phase: 4
depends_on: [task-323, task-328, task-334]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-119-02', 'F-119-09', 'F-119-10']
files_affected:
  - agent/reports/
  - agent/feedback/
---

<!-- @acp.meta.task
topic: m87, git-filter-repo, force-push, tags, history
description: Rewrite all refs including tags; force-push develop, mainline, and tags only after exact operator phrase.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D4
depends_on: task-323, task-328, task-334
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Remove `agent/reports/` and `agent/feedback/` **blobs from git history** on `develop`, `mainline`, **and tags**, then force-push only when the operator types exactly `force-push develop mainline tags: yes`.

## Context

`v6.32.4` still has 171 report files. `develop` is ahead of `origin/mainline` (M87 plan). `git filter-repo` **deletes `origin`**. `--invert-paths` also drops keepers from HEAD (F-119-10) — re-add via CB-3 keepers after rewrite. Forks and Actions caches are **residual** (F-119-09); say so in the commit/session notes.

## Steps

1. Confirm 323 CB-1 still restores. Take a **second** local mirror with **CB-4** (`git clone --mirror "$(pwd)"` — **not** GitHub).
2. Follow **CB-4** throwaway clone from that local mirror + `git filter-repo --invert-paths --path agent/reports/ --path agent/feedback/` (no extra paths).
3. `git remote add origin` as in CB-4. Re-add keepers; commit `chore: restore reports/feedback keepers after filter-repo`.
4. On the throwaway clone: `git log --all --full-history --oneline -- agent/reports/` must not list body files.
5. **STOP.** Print residual-risk sentence: forks and GitHub caches may retain objects until they refetch. Ask for the exact phrase. Do **not** treat `/acp-proceed` as consent.
6. If phrase matches: `git push --force origin develop`, `git push --force origin mainline`, `git push --force origin --tags`. **Not** `--force-with-lease`.
7. If no: leave local rewrite unpushed; task stays in_progress. Do not stamp F-118-*.

## Verification

- [ ] Mirror backup exists off-GitHub
- [ ] Throwaway clone history has no report/feedback bodies
- [ ] Keepers exist on rewritten tip
- [ ] Confirmation phrase recorded in session notes (not a secret)
- [ ] Origin branches **and** tags updated, **or** awaiting confirm

## User-Observable Acceptance

`git checkout v6.32.4` on a new clone after tag push does **not** restore 171 reports.

## Expected Output

### Files Created / Modified
- Rewritten git history; remotes only after confirm

### Notes
Never run filter-repo in the daily worktree. Never put credentials in the SOP.
