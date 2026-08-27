# Milestone 87: Public-repo privacy purge

<!-- @acp.meta.milestone
topic: privacy, reports, feedback, git-filter-repo, public-repo, ADR-27
description: Remove reports/feedback/audit bodies from public remotes including history; local backups first then pack
status: planned
updated: 2026-08-27
tasks: task-322..task-334
@acp.meta.end -->

**Planned version**: v6.33.0  
**Status**: in_progress  
**Progress**: 10/13 tasks — **HALT** at task-330 force-push gate  
**Estimated effort**: ~34h (13 tasks)  
**Source**: audit-118; audit-119; audit-120 backup-first  
**Design**: [local.public-repo-privacy-purge.md](../design/local.public-repo-privacy-purge.md)  
**ADR**: ADR-27  
**Closes**: F-118-01..06 (F-118-07 via redaction; F-118-08 keep email)

---

## Why this milestone exists

Public remotes must not host `agent/reports/` or `agent/feedback/` bodies, including git history. Local backups must exist **before any other work**.

## Goal

A stranger cloning origin (including tags) cannot read audit/feedback bodies. The operator can restore this machine from `$HOME/acp-enhanced-private/` without GitHub.

## Phases

| Phase | Tasks | Outcome |
|-------|-------|---------|
| **0 — Local backups GATE** | **333 → 334 → 323** | Worktree rsync, local git mirror, encrypted content; all restore-tested |
| **1 — Policy** | 322 | Citation map; **blocked on 323** |
| **2 — Make ignore legal** | 324–326 | Validator, commands/E2E, install/pattern |
| **3 — Tip** | 327–328 | Leftovers redacted; `git rm --cached` |
| **4 — History + prove** | 329–332 | Pack script; second local mirror + filter-repo; clone+tag proof; stamps |

## Task index

| ID | Name | Est | Depends |
|----|------|-----|---------|
| **333** | Local worktree rsync (untracked too) | 2h | — **START HERE** |
| **334** | Local git mirror + bundle from `$(pwd)` | 2h | 333 |
| **323** | Encrypted reports+feedback (gpg if no age) | 3h | 333, 334 |
| 322 | Citation map | 2h | 323, 333, 334 |
| 324 | Gitignore + reverse D9 validator (**one commit**) | 3h | 322, 323 |
| 325 | Commands/E2E/wiki | 3h | 324 |
| 326 | Pattern + project-create + install.sh | 2h | 324 |
| 327 | Redact leftovers | 3h | 322, 323 |
| 328 | `git rm --cached` bodies | 2h | 323, 324, 325, 327 |
| 329 | `acp.private-pack.sh` | 3h | 323, 324 |
| 330 | filter-repo; `force-push develop mainline tags: yes` | 4h | 323, 328, 334 |
| 331 | Fresh-clone + tag proof | 2h | 330 |
| 332 | Closure v6.33.0 | 3h | 325, 326, 329, 331 |

## Anti-shortcuts

- First `/acp-proceed` is **333**, not 322.
- Never mirror **only** from GitHub.
- Never `git rm` without `--cached`. Never `git add -f` report bodies.
- Force-push only after exact phrase including **tags**.
- Do not commit audit-118/119/120.
- F-R006-* out of scope.
- Cookbook **CB-0a, CB-0b, CB-1…CB-6**.

## Success criteria

- [x] Three local backups restore (worktree, git mirror, encrypted content)
- [ ] Origin tip + rewritten tags = keepers only
- [ ] `/acp-audit` writes a local ignored file
- [ ] Validate green with ignored reports
- [ ] F-118-01..06 stamped only after 331
