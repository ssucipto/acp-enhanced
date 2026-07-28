# Audit Report: Today's Work — Gap Analysis, Review, and Carryover Closure

**Audit**: #108
**Date**: 2026-07-28
**Subject**: All work performed today (F-107 remediation + audit-107), audited for gaps, inconsistencies and missing implementation; `/acp-review` run over the changed set; all findings and all open carryovers fixed
**Mode**: standard + `/acp-review` Phase 1

## Summary

This audit checked today's own output rather than the codebase at large: the F-107 CodeRabbit remediation and the audit-107 self-audit. It ran the deterministic review scanner over every file changed today, closed all three open carryovers, and hunted for shortcuts.

**Nine findings.** The most consequential was not in today's diff at all: implementing the G-107-02 duplicate-key validator immediately exposed **four real, pre-existing memory corruptions** — including a lesson that had been silently shadowed since June and a carryover whose `fix_applied_date: null` was overriding a real date while `status: fixed`. The audit also caught one false positive in my own new validator before it could cause harm, and one review finding I introduced.

All nine are fixed. All three carryovers are closed and stamped.

## `/acp-review` — Phase 1 over today's changed files

Scanned 9 modified shell scripts + 2 modified E2E suites with `--include-tests`.

| Result | Count | Assessment |
|--------|-------|------------|
| Findings with my changes | 9 | — |
| Findings at HEAD (same files) | 8 | baseline |
| **Introduced by today's work** | **1** | R-01 below |

| ID | Sev | Finding | Verdict |
|----|-----|---------|---------|
| R-01 | MEDIUM | `SH-03 SC2046` — unquoted `$([[ ... ]] && echo 0 \|\| echo 1)` in my B34 test | **Introduced today — fixed** (use `"$B34_RC"`) |
| R-02 | HIGH ×2 | `SH-01` missing `set -euo pipefail` on both E2E suites | **Not a defect.** 48 of 62 e2e files omit it deliberately — assertion harnesses must not abort on first non-zero exit. Tests are excluded from scans by default; only `--include-tests` surfaces this |
| R-03 | MEDIUM ×6 | `SH-03 SC2046` in `acp.integrity.test.sh` | Pre-existing, untouched by today's work |

## Audit Findings

| ID | Severity | Finding | Status |
|----|----------|---------|--------|
| A-108-01 | **HIGH** | `lessons.md` entry #12: two lessons merged — the audit-070 "false assurance" lesson was silently shadowed by a version-bump lesson that had lost its `- date:` header | **Fixed** — split into two entries |
| A-108-02 | **HIGH** | `audit-carryovers.md` #69 (audit-69 F-069-09): duplicate `fix_applied_date` where `null` shadowed the real `2026-06-15` while `status: fixed` — self-contradictory record | **Fixed** — merged, real date kept |
| A-108-03 | MEDIUM | `audit-carryovers.md` #40 and #63: duplicate `verified_in_audit` keys; only the later value was ever read | **Fixed** — merged, both audits recorded |
| A-108-04 | MEDIUM | My own new duplicate-key validator produced a **false positive** on `sessions.md` — splitting on `- date:` folded the legitimate `- type: weekly-summary` compaction blocks into the preceding entry | **Fixed** before it could block CI — split on any top-level list item |
| A-108-05 | MEDIUM | `acp.review.md` documented `--write-baseline` as writing "the current findings", which after F-107-03 is no longer accurate | **Fixed** — documented exactly what is and is not captured |
| A-108-06 | LOW | `acp.review-scan.sh` silently skips YM-01/YM-02 when `scripts/node_modules` is absent, understating corpus recall (95.7% vs 100%) with no signal | **Fixed** — warns once to stderr |
| A-108-07 | LOW | Old `_sed_i` experimental-flag call inserted **nothing** on a real manifest shape — failure masked by `2>/dev/null \|\| true` | **Fixed** as part of G-107-08 |

## Carryover Closure

| ID | Severity | Resolution | Verified |
|----|----------|-----------|----------|
| G-107-02 | HIGH | `findDuplicateEntryKeys()` + `validateMemoryDuplicateKeys()` in `acp-validate.ts`, wired into exit status; covers sessions/lessons/patterns/carryovers | Reproduced the exact audit-107 corruption → detector fires, exit 1; clean tree → 324 entries, exit 0. **4 unit tests added (72/72 vitest)** |
| G-107-07 | MEDIUM | `!tests/fixtures/**/package-lock.json` negation in `.gitignore`; 3 stub fixtures tracked | Materialised the index as a standalone tree (`git write-tree` + `git archive`) and ran the corpus there: **SC-15 100%/100% on a simulated fresh clone** |
| G-107-08 | LOW | `_insert_experimental_flag()` — awk-based, replacing `\n`-in-sed-replacement | Idempotent across repeat runs (old sed produced a duplicate key or nothing); `index()` match removes regex-metacharacter exposure; package-update E2E 13/13 |

## Verification Evidence

| Gate | Result |
|------|--------|
| `e2e/acp.review-scan.test.sh` | 66/66 |
| `e2e/acp.review.test.sh` | 71/71 |
| `e2e/acp.integrity.test.sh` | 77/77 |
| `e2e/acp.package-update.test.sh` | 13/13 |
| `e2e/acp.integrity-v2.test.sh` | 52/55 — 3 pre-existing (missing PyYAML), identical at HEAD |
| `scripts && npm test` (vitest) | 72/72 (4 new) |
| `acp.review-measure.sh --ci` | 47 cases, 0 FP, 0 FN, 100%/100% |
| Fresh-clone corpus simulation | 100%/100% with node_modules; SC-15 case fixed |
| `acp-validate.ts` | exit 0 — includes new duplicate-key gate |
| `acp.manifest-hash.sh --verify` | exit 0 |
| Platform | bash 3.2.57 (oldest supported target) |

## Key Decisions

- **A duplicate key is always an error, never last-wins.** The validator now fails rather than warns. Two separate incidents (191-key `progress.yaml`, and the four found today) show silent shadowing is the failure mode that actually loses data.
- **Split memory entries on any list marker, not a known first key.** Keying off `- date:` was what made my first implementation wrong; `sessions.md` legitimately holds two different entry shapes.
- **awk over python3 in `acp.package-update.sh`** — that script already uses awk 12× and python3 zero times; matching the local idiom over introducing a dependency.
- **Silent degradation is a defect.** Both A-108-06 and A-108-07 were failures masked by suppressed output. A check that cannot run must say so.

## Recommendations

1. Audit remaining `2>/dev/null || true` suppressions in `agent/scripts/` — A-108-07 was a silently broken code path hidden by exactly this idiom, and it survived unnoticed for months.
2. Consider extending the duplicate-key gate to `progress.yaml`, the original incident's file.
3. The 6 pre-existing `SC2046` findings in `acp.integrity.test.sh` remain unaddressed (out of today's scope).

---

**Findings**: 9 (3 HIGH, 4 MEDIUM, 2 LOW) — **all 9 fixed**
**Carryovers**: 3 open at start → **0 open at close**
**Verdict**: Today's work is verified correct. Four pre-existing memory corruptions were found and repaired as a side effect of closing G-107-02.
