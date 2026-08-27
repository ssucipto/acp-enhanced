---
id: task-323
milestone: M87
title: "GATE: local encrypted archive of reports + feedback"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
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

- [x] Ciphertext exists under `${HOME}/acp-enhanced-private/` (`.gpg` or `.age`)
- [x] Restore dry-run listed both trees
- [x] `git status` does not show the archive as staged
- [x] Passphrase is not in any tracked file
- [x] Plaintext tar is gone from `/tmp`

## User-Observable Acceptance

Operator can decrypt into `/tmp/acp-restore-test` without GitHub.

## Expected Output

### Files Created / Modified
- Local encrypted archive (untracked, off-repo)
- This task file (restore notes)

### Notes
Do not `git add -f` the archive. Git object parachute is 334; 330 takes a second local mirror before rewrite.

Restore 2026-08-27:
- Tool: `gpg` (age missing). `--symmetric --cipher-algo AES256` with `--batch --pinentry-mode loopback`.
- Ciphertext: `$HOME/acp-enhanced-private/acp-reports-feedback-20260827T203242.tar.gz.gpg` (648K)
- Passphrase file: `$HOME/acp-enhanced-private/.gpg-passphrase` (chmod 600, **not in git**)
- `git ls-files` before 328: reports **171**, feedback **37**
- Restore `/tmp/acp-restore-test`: both trees present (`find` reports 180 including dirs, feedback 38)
- Plaintext tar removed from `/tmp`

