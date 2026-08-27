---
id: task-331
milestone: M87
title: "Fresh-clone proof: no report/feedback bodies in history"
status: planned
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 4
depends_on: [task-330]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03']
files_affected: []
---

<!-- @acp.meta.task
topic: m87, verify, fresh-clone, history
description: Clone origin into a temp dir and prove report/feedback bodies are absent from tip and history.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D4
depends_on: task-330
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Prove from a **new clone of origin** (not the dirty worktree) that report and feedback bodies are gone from the tip and from `git log --all --full-history`.

## Context

Local `filter-repo` can look clean while origin still has old objects. F-118-01..03 must not be stamped until this proof. Also restore the 323/329 pack into a second directory and confirm `/acp-audit` can write ignored files.

## Steps

1. `git clone` origin into a temp directory (both default branch and `mainline` if different).
2. `git ls-files agent/reports agent/feedback` — keepers only.
3. `git log --all --full-history -- agent/reports/ agent/feedback/` — no historical body paths (or only keepers).
4. `git grep` in the clone for vendor billing UUID **pattern** without writing the UUID into AE files; expect no matches.
5. Unpack private pack into a **separate** directory (not the clone-under-test). Confirm restore.
6. Record clone SHAs and command output paths in this task (no leaked contents).

## Verification

- [ ] Fresh clone tip = keepers only
- [ ] History has no report/feedback bodies
- [ ] Pack restore works outside the public clone
- [ ] Evidence attached for 332 stamps

## User-Observable Acceptance

A stranger cloning the public repo cannot recover audit-118 Class B files from git.

## Expected Output

### Files Created / Modified
- This task file (verification notes)
- Local evidence (gitignored)

### Notes
GitHub CDN/forks may lag; document that forks must re-clone.
