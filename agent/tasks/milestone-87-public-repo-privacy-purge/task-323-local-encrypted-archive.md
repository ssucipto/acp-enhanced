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
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03']
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

Create a restore-tested encrypted archive of current `agent/reports/` and `agent/feedback/` **before** any destructive git. This is a **hard GATE** for 328 and 330.

## Context

History rewrite and `git rm` destroy the only copy on GitHub. The operator must be able to restore on this machine and on a second directory. The archive must **never** be committed or pushed.

## Steps

1. Inventory tracked + untracked files under `agent/reports/` and `agent/feedback/` (counts only in git notes).
2. Write an archive **outside the repo** (or under a gitignored path that is also listed in `.gitignore` if inside the tree — prefer `$HOME` backup dir, not the clone).
3. Encrypt with `age` or gpg. Record algorithm + archive filename **without** putting the passphrase in git.
4. Restore dry-run into a throwaway directory. Confirm file counts and that a sample audit and the design-spec filename exist.
5. Document restore steps in this task’s notes (commands, not secrets).
6. **GATE**: 328 and 330 must not start until this checkbox is true.

## Verification

- [ ] Encrypted archive exists off-remote
- [ ] Restore dry-run matched inventory counts
- [ ] Archive is not in `git status` as a staged file
- [ ] Passphrase is not in any tracked file

## User-Observable Acceptance

Operator can restore reports/feedback into an empty folder from the archive without GitHub.

## Expected Output

### Files Created / Modified
- Local archive (untracked, off-repo preferred)
- This task file (restore notes)

### Notes
Do not use `git add -f` on the archive. Do not force-push in this task.
