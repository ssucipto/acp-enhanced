---
id: task-323
milestone: M87
title: "GATE: local encrypted archive of reports + feedback"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 0
depends_on: [task-333, task-334]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-119-01', 'F-120-04']
files_affected: []
---

<!-- @acp.meta.task
topic: m87, backup, archive, gpg, gate
description: Encrypted local archive of reports and feedback with a restore dry-run before any git rm or filter-repo.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D3
depends_on: task-333, task-334
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Create a restore-tested encrypted archive of `agent/reports/` and `agent/feedback/` **after** 333+334. **Hard GATE** for 322, 324, 328, and 330.

## Context

333 copied the worktree; 334 copied git objects. This encrypts report/feedback **content** for off-machine transport. **CB-1**: use `gpg --symmetric` when `age` is missing (this Mac has gpg only). Do not start 322 until restore dry-run passes.

## Steps

1. Confirm 333 and 334 restore tests passed.
2. `command -v age || command -v gpg` — if neither, **stop** and install one.
3. Execute **CB-1** (trap removes plaintext tar). Record output path.
4. Execute CB-1 restore dry-run (`test -d` both trees; compare counts to `git ls-files`).
5. **GATE** for 322.

## Verification

- [ ] Ciphertext exists under `${HOME}/acp-enhanced-private/` (`.gpg` or `.age`)
- [ ] Restore dry-run listed both trees
- [ ] `git status` does not show the archive as staged
- [ ] Passphrase is not in any tracked file
- [ ] Plaintext tar is gone from `/tmp`

## User-Observable Acceptance

Operator can decrypt into `/tmp/acp-restore-test` without GitHub.

## Expected Output

### Files Created / Modified
- Local encrypted archive (untracked, off-repo)
- This task file (restore notes)

### Notes
Do not `git add -f` the archive. Git object parachute is 334; 330 takes a second local mirror before rewrite.
