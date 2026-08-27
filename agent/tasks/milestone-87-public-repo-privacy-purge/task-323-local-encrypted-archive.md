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
phase: 1
depends_on: [task-322]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03', 'F-119-01']
files_affected:
  - agent/.gitignore
---

<!-- @acp.meta.task
topic: m87, backup, archive, age, gate
description: Encrypted local archive of reports and feedback with a restore dry-run before any git rm or filter-repo.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D3
depends_on: task-322
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Create a restore-tested encrypted archive of `agent/reports/` and `agent/feedback/` **before** any destructive git. **Hard GATE** for 328 and 330.

## Context

`git rm` without `--cached` and `filter-repo` destroy GitHub’s copy. The archive must never be committed. Use design **CB-1** exactly — do not change flags.

## Steps

1. Record inventory (numbers only):

```bash
git ls-files agent/reports | wc -l
git ls-files agent/feedback | wc -l
```

2. Execute **CB-1** archive from repo root (`age -p` passphrase is **not** written to any file in the repo).
3. Execute **CB-1** restore dry-run. Confirm `test -d` both dirs; compare `find | wc -l` to step 1 (untracked local reports may increase the restore count).
4. Paste command transcripts (redact passphrase) into this task’s notes.
5. **GATE**: 328 and 330 must not start until restore dry-run passed.

## Verification

- [ ] Ciphertext exists under `${HOME}/acp-enhanced-private/` (or equivalent **outside** the clone)
- [ ] Restore dry-run listed both trees
- [ ] `git status` does not show the `.age` file as staged
- [ ] Passphrase is not in any tracked file

## User-Observable Acceptance

Operator can restore reports/feedback into `/tmp/acp-restore-test` without GitHub.

## Expected Output

### Files Created / Modified
- Local `.age` archive (untracked, off-repo)
- This task file (restore notes)

### Notes
Do not `git add -f` the archive. Full **git mirror** backup is CB-4 / task-330, not this task.
