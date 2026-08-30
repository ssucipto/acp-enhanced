# Design: Public name and ledger privacy (M95 / ADR-30 / ADR-31)

<!-- @acp.meta.design
topic: privacy, ADR-30, ADR-31, names, progress.yaml, replace-text
description: Public remotes must not contain field-feedback project names including history; progress.yaml is status-only
status: active
updated: 2026-08-30
decisions: D1..D12
@acp.meta.end -->

**Version**: 1.1.0  
**Date**: 2026-08-30  
**Pre-impl**: audit-141 (READY waves 0–2; 398 D11 blocked)  
**Source**: audit-139, audit-140  
**ADR**: ADR-30 (names including history), ADR-31 (progress.yaml split)  
**Does not reopen**: ADR-27, ADR-28, ADR-29  
**Target release**: v6.40.0 after fresh-clone proof  

---

## Problem

Path-class privacy (ADR-27/28/29) is closed. Public remotes still contain **field-feedback project names** in KEEP files and git history, plus a ~10k-line dogfood `progress.yaml`. M94 deferred both. That deferral is forbidden here.

## Solution — Milestone M95

```
M95 Public name privacy + progress split
├── Wave 0 — Encoded inventory + ADR-31 scaffolding     388–389
├── Wave 1 — HEAD redact (docs, ledgers, split, fixtures) 390–394
├── Wave 2 — Leftover audit + backup GATE                 395–396
├── Wave 3 — replace-text rewrite + new D11 + proof       397–399
└── Wave 4 — Stamps + v6.40.0 PR                          400–402
```

## Decisions

| ID | Decision |
|----|----------|
| D1 | Deny-list tokens are **encoded** in tracked tests/scripts. Plaintext names live only in gitignored local cookbook / replace-text expressions. |
| D2 | HEAD redact includes CHANGELOG, sessions, carryovers, ADR prose, lessons — not README-only. |
| D3 | `progress.local.yaml` is gitignored; it is a **full snapshot copy** of `progress.yaml` (operator notes). Tracked `progress.yaml` keeps schema-required status; mapping `notes:` are empty scalars and the top-level `notes:` list is `[]`. Tests must not `touch`/`rm` the overlay path. |
| D4 | History rewrite uses `--replace-text` on a **throwaway** clone (`git clone --no-local`). Never the daily worktree. |
| D5 | Force-push phrase is **only**: `force-push adr-30 names replace-text develop mainline tags: yes`. `/acp-proceed --yes` is not consent. Do not reuse the ADR-29 phrase. |
| D6 | Do not invent `v6.39.1` as a substitute for tag rewrite. Existing tag **names** retarget new SHAs. |
| D7 | Stamp F-135-07 / F-139-* / F-140-* **only** after stranger-clone proof (task-399). |
| D8 | Empty deny-list match after rewrite is **success** (M94 empty PURGE-list CI lesson). |
| D9 | `git rm` of any newly ignored file uses `--cached` only. |
| D10 | Private-pack includes `progress.local.yaml`. Restore tests must not unpack onto the live clone. |
| D11 | Path-class PURGE globs are **closed** — this milestone does not add design/local paths. |
| D12 | QUICKSTART/PRD worked examples become generic (no Expo-as-the-only-stack, no chore-list screen name). |
| D13 | Name-scan **tests** use temp fixtures. `--repo` is not a CI job until HEAD is clean (task-394). Do not fail the default test suite on a dirty HEAD. |
| D14 | `acp.private-pack.sh` packs `agent/progress.local.yaml` via extra **files** list (dirs-only tar misses it). |
| D15 | Task-397 refuses to run unless `${HOME}/acp-enhanced-private/M95_LAST_STAMP.txt` exists (backup GATE). |
| D16 | Version bump **once** at task-401 (`v6.40.0` + annotated tag). Per-task identity bumps reopen the tag-validator trap. |

## Anti-shortcuts

- Do not skip Wave 2 leftover audit (audit-138 class).
- Do not skip backup GATE before task-397.
- Do not commit the replace-text expressions file.
- Do not stamp complete when `gh pr create` failed.
- Do not treat HEAD `git grep` as history proof.
- Do not filter-repo with directory `--invert-paths`.
- Do not add name-scan to `.github/workflows/ci.yaml` before task-394.
- Do not start 397 without `M95_LAST_STAMP.txt`.

## KEEP vs local

| Path | Remote |
|------|--------|
| This file (`acp-public-name-privacy.md`) | **KEEP** |
| `agent/design/local.m95-name-history-privacy.md` | **local** (operator cookbook + plaintext token list) |
| `agent/progress.local.yaml` | **local** |
| Replace-text expressions | **local** (never commit) |
