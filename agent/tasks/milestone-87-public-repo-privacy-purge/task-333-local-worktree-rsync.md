---
id: task-333
milestone: M87
title: "GATE FIRST: local worktree rsync (including untracked reports)"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 0
depends_on: []
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-120-01', 'F-120-03']
files_affected: []
---

<!-- @acp.meta.task
topic: m87, backup, rsync, worktree, gate
description: Copy the entire working tree including untracked audit reports to HOME before any other M87 task.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D3
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Create a restore-tested **rsync copy of this clone** (files + `.git` + untracked `agent/reports/`) **outside** the repo. This is the **first** `/acp-proceed` target. Nothing else in M87 starts until the dry-run passes.

## Context

GitHub and `git clone --mirror git@github.com:...` do **not** contain untracked `audit-118`/`audit-119` or unpushed `develop`. audit-120 F-120-03. Use design **CB-0a** exactly.

## Steps

1. `command -v rsync` — if missing, install (macOS: rsync is `/usr/bin/rsync`) and stop if still missing.
2. Confirm destination is **not** inside the clone: `BACKUP_DIR="${HOME}/acp-enhanced-private"` and `pwd` is not under that path.
3. Execute **CB-0a** (writes `LAST_STAMP.txt`).
4. Execute CB-0a restore dry-run (`test -d`, `git rev-parse HEAD` match).
5. Record `DEST` path and HEAD SHA in this task’s notes (no secrets).
6. **GATE**: 334 may run after this (needs `LAST_STAMP.txt`). Do not start 322.

## Verification

- [x] `LAST_STAMP.txt` exists
- [x] Copy HEAD equals live HEAD
- [x] Untracked audit-119 exists in the copy
- [x] Copy is not under the project path
- [x] `git status` does not stage anything in `${HOME}/acp-enhanced-private`

## Restore notes (2026-08-27)

- STAMP: `20260827T202952`
- DEST: `$HOME/acp-enhanced-private/worktree-20260827T202952`
- HEAD: `4e734925cfa1045c07f84d25e7d75220534ae3d8`
- Also copied audit-120.

### Notes

Operator can `ls` a second directory under `$HOME/acp-enhanced-private/worktree-*` that contains the same reports as this machine, including files git does not track.

## Expected Output

### Files Created / Modified
- Local rsync dest (untracked, off-repo)
- This task file (notes)

### Notes
Do not rsync the backup **back** onto the live clone. 334 is next.
