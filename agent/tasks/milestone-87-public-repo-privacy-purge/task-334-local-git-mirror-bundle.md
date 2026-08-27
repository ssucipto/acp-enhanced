---
id: task-334
milestone: M87
title: "GATE FIRST: local git mirror + bundle (from this clone)"
status: completed
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 0
depends_on: [task-333]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-120-02', 'F-120-07']
files_affected: []
---

<!-- @acp.meta.task
topic: m87, backup, git-mirror, bundle, gate
description: Mirror and bundle all local refs from this clone (not GitHub) and restore-clone to prove HEAD matches.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D3
depends_on: task-333
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Snapshot **all local git refs and objects** with `git clone --mirror "$(pwd)"` plus a `git bundle`. Restore-clone must match live `HEAD`. This is the git-history parachute if `filter-repo` or a bad `git rm` goes wrong.

## Context

**Wrong:** `git clone --mirror git@github.com:ssucipto/acp-enhanced.git` — that is `origin/mainline`, not this `develop` tip, and has no untracked files (those are 333). **Right: CB-0b.** Depends on 333 so `LAST_STAMP.txt` exists and the worktree copy is already done.

## Steps

1. Confirm 333 restore dry-run passed. Read `LAST_STAMP.txt`.
2. Execute **CB-0b** exactly (`git clone --mirror "$(pwd)"`, then bundle, then `git clone` the mirror to `/tmp/acp-from-mirror`).
3. Confirm restore HEAD equals live HEAD. Confirm `develop` exists in the mirror.
4. Record mirror path in notes. Do not push the mirror.
5. **GATE** for 323.

## Verification

- [x] Mirror dir exists under `${HOME}/acp-enhanced-private/`
- [x] Bundle file exists
- [x] `/tmp/acp-from-mirror` HEAD == live HEAD
- [x] Mirror was created from `$(pwd)`, not GitHub

## User-Observable Acceptance

`git clone` of the local `.git` mirror produces the same commit as this checkout, including unpushed M87 plan commits.

## Expected Output

### Files Created / Modified
- Local `*.git` mirror + `*.bundle` (off-repo)
- This task file (notes)

### Notes
Task-330 takes a **second** local mirror immediately before filter-repo (history will have moved after 328).

Restore 2026-08-27:
- STAMP: `20260827T202952`
- Mirror: `$HOME/acp-enhanced-private/acp-enhanced-20260827T202952.git`
- Bundle: `$HOME/acp-enhanced-private/acp-enhanced-20260827T202952.bundle` (5.3M)
- Source: `git clone --mirror "$(pwd)"` (this clone, not GitHub)
- develop in mirror: `1488312d551d81e7faa7013ff2bd4cb025b9ae2b`
- LIVE HEAD == restore `/tmp/acp-from-mirror` HEAD (match)

