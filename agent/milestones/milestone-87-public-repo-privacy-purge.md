# Milestone 87: Public-repo privacy purge

<!-- @acp.meta.milestone
topic: privacy, reports, feedback, git-filter-repo, public-repo, ADR-27
description: Remove reports/feedback/audit bodies from public remotes including history; local archive + pack
status: planned
updated: 2026-08-27
tasks: task-322..task-332
@acp.meta.end -->

**Planned version**: v6.33.0  
**Status**: planned  
**Progress**: 0/11 tasks  
**Estimated effort**: ~30h (11 tasks, 5 phases)  
**Source**: audit-118; maintainer: reports **and** audit/feedback folders leave the remote  
**Design**: [local.public-repo-privacy-purge.md](../design/local.public-repo-privacy-purge.md)  
**ADR**: ADR-27 (supersedes M72 D9 tracking for this public repo)  
**Closes**: F-118-01, F-118-02, F-118-03, F-118-04, F-118-05, F-118-06 (F-118-07 via path redaction; F-118-08 keep email)

---

## Why this milestone exists

audit-118 found secrets-adjacent and consumer-internal files on **both** `develop` and `mainline`. The maintainer decided the public repo must not host `agent/reports/` or `agent/feedback/` **bodies**, including git history. D9 “track evidence” is the wrong default for a public clone.

## Goal

A fresh clone of `origin/mainline` has no audit/review/feedback/inbox content and no `$HOME` or vendor-account blobs in history. Operators keep a local encrypted archive and can move machines without using GitHub as the sync channel.

## Phases

| Phase | Tasks | Outcome |
|-------|-------|---------|
| **0 — Policy** | 322 | ADR-27 + design locked; no rewrite yet |
| **1 — Backup** | 323 | Encrypted archive exists; restore dry-run passed (**GATE**) |
| **2 — Make ignore legal** | 324–326 | Validator, commands/E2E, install/pattern match D2 |
| **3 — Tip + remaining tracked leaks** | 327–328 | `$HOME`/internals gone from remaining files; tree purged |
| **4 — History + prove** | 329–332 | Pack script; filter-repo + **confirmed** force-push; clone proof; stamps |

## Task index

| ID | Name | Est | Depends |
|----|------|-----|---------|
| 322 | Lock design + citation map | 2h | — |
| 323 | Local encrypted archive + restore test | 3h | 322 |
| 324 | Gitignore + reverse D9 validator (**one commit**) | 3h | 322 |
| 325 | Commands/E2E/wiki: reports are local | 3h | 324 |
| 326 | Pattern + project-create + **install.sh** gitignore | 2h | 324 |
| 327 | Redact leftovers in remaining tracked files | 3h | 322 |
| 328 | `git rm --cached` bodies; keep keepers | 2h | 323, 324, **325**, 327 |
| 329 | `acp.private-pack.sh` + docs | 3h | 323, 324 |
| 330 | `git filter-repo`; confirm `force-push develop mainline tags: yes` | 4h | 323, 328 |
| 331 | Fresh-clone + **tag** proof | 2h | 330 |
| 332 | Closure: validate, stamp F-118/F-119, CHANGELOG v6.33.0 | 3h | 325, 326, 329, 331 |

## Anti-shortcuts

- F-118-01..03 stay **pending** until task-331 clone **and tag** proof.
- No force-push without the exact phrase `force-push develop mainline tags: yes`.
- Never `git rm` reports/feedback without `--cached`.
- Never `git add -f` report bodies. Do not add `audit-118` / `audit-119` to origin.
- Review-006 F-R006-01..03 stay on the **code** backlog (not this milestone).
- Canonical commands: design cookbook **CB-1…CB-6** — do not improvise flags.

## Success criteria

- [ ] `git ls-files agent/reports agent/feedback` on origin tip is only keepers
- [ ] `git log --all --full-history -- agent/reports/` on a **fresh clone** shows no historical bodies
- [ ] Rewritten **tags** (e.g. v6.32.4) are keepers-only
- [ ] `/acp-audit` still creates a local file that `git status` ignores
- [ ] `acp-validate.ts` is green with ignored reports
- [ ] Private pack restores reports on a second directory
- [ ] F-118-01..06 marked fixed only after 331
