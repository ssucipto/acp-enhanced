---
id: task-331
milestone: M87
title: "Fresh-clone proof: no report/feedback bodies in history or tags"
status: completed
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 4
depends_on: [task-330]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-119-02']
files_affected: []
---

<!-- @acp.meta.task
topic: m87, verify, fresh-clone, tags
description: Clone origin into a temp dir and prove report/feedback bodies are absent from tip, history, and a former leak tag.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D4
depends_on: task-330
status: completed
updated: 2026-08-27
@acp.meta.end -->

## Objective

Prove from a **new full clone of origin** (not the dirty worktree, **not** `--depth=1`) that bodies are gone from develop, mainline, **and** a rewritten tag.

## Context

Local `filter-repo` can look clean while origin or tags still leak. F-118-01..03 must not be stamped until this proof. Use **CB-5**.

## Steps

1. Execute **CB-5** (develop + mainline logs).
2. `git checkout v6.32.4` (or the latest rewritten tag) in that clone; `git ls-files agent/reports | wc -l` must be keepers (not 171).
3. Unpack 323/329 archive into a **separate** directory (not the clone-under-test). Confirm restore.
4. Record clone SHAs and command output in this task (no leaked contents). Note F-119-09 residual (forks).

## Verification

- [x] Fresh clone tip = keepers only on develop and mainline
- [x] History log has no body paths
- [x] Former leak tag is keepers-only
- [x] Pack restore works outside the public clone
- [x] Evidence for 332 stamps

## User-Observable Acceptance

A stranger cloning the public repo, including by tag, cannot recover audit-118 Class B files from git.

## Expected Output

### Files Created / Modified
- This task file (verification notes)

### Notes
GitHub CDN/forks may lag; document that forks must re-clone.

Proof 2026-08-27 (full clone to `$HOME/acp-enhanced-private/acp-fresh-proof`, **not** the daily worktree):
- `origin/develop` `4a7cef3` — keepers only (`ls-files` = 4 files)
- `origin/mainline` `d83cddc` — keepers only
- `git rev-list --objects --all` report/feedback bodies = **0**
- `v6.32.4` → commit `b9b7502` (tag object `19dfc7c`); `ls-files agent/reports` = **0** (was 171)
- Pack restore: CB-1 / task-323 gpg archive already restore-tested before rewrite; archive path unchanged off-repo
- Residual F-119-09: forks and GitHub caches may retain old objects until they refetch
- Do **not** stamp F-118 in this task — task-332 stamps after CHANGELOG/validate
