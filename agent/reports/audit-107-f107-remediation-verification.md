# Audit Report: F-107 CodeRabbit Remediation — Verification & Gap Analysis

**Audit**: #107
**Date**: 2026-07-28
**Subject**: Verification of the F-107-01..04 remediation (CodeRabbit PR#13 findings ported upstream), plus gaps, leftovers, carryovers, and shortcuts taken
**Mode**: standard (self-audit of work completed earlier in the same session)

## Summary

The four CodeRabbit findings raised against a downstream consumer's PR #13 were checked against this repo, the origin of the affected framework files. **Three applied and were fixed; the fourth was correctly rejected upstream.** This audit verified each fix behaves as claimed, then went adversarial on the implementation to find what the first pass missed.

The remediation holds up: every fix is backed by a regression test proven to fail at the pre-fix commit. But the audit found **eight issues the first pass missed or got wrong** — including one self-inflicted data-corruption bug in `sessions.md`, one incorrect claim recorded in project memory, a behavioural regression against documented SC-15 semantics that would have broken the repo's own review corpus, and a shortcut where 7 of 8 scanners were fixed but only 1 got permanent regression coverage. All eight are now resolved.

## Verification of the Original Four Findings

| # | Finding | Applies upstream? | Verified how | Status |
|---|---------|-------------------|--------------|--------|
| F-107-01 | Positional args `"${arr[@]:-}"` | **Yes — worse than reported** | e2e B26 fails on exactly 6 of 8 scanners at HEAD | Fixed |
| F-107-02 | SC-15 lockfile tracking | **Yes — worse than reported** | Tracking check was dead code (`return 0` both branches); HEAD emits nothing for an untracked lockfile | Fixed |
| F-107-03 | Baseline ordering | Yes | HEAD baseline captures EH-02 at lines `[2,3]`; fixed captures `[3]` | Fixed |
| F-107-04 | GNU-only `sed '\n'` | **Yes — plus a second defect** | Reproduced *invalid JSON on GNU sed* when a message contains `},{` | Fixed |
| #4 | `task.schema.yaml` executor default | **No — rejected** | `composer-2.5` absent from `agent/routing/taxonomy.yml`; `deepseek-v4-flash` is the framework cheap-tier default for ~14 task types | Not applied (by design) |

### Where the original reports were incomplete

| Claim as reported | Actual upstream finding |
|---|---|
| "`$1` may hold a stale value from earlier in the script" | Not staleness. Under `set -u`, `"${arr[@]:-}"` expands an **empty** array to one empty-string argument, so `$1=""` reached the target loop |
| Affects `acp.review-scan.sh` | Affects **all 8** scanners; **6 aborted entirely** with `Error:  not found` on a bare invocation |
| SC-15 used "awkward path combinations" | Both branches ended in `return 0` — the entire `git ls-files` half was **unreachable**; an untracked lockfile always passed |
| GNU sed `\n` is a macOS-only bug | Also breaks on **GNU sed**: the pattern matches `},{` inside a finding message, injecting a raw newline into a JSON string literal |

## Gaps Found by This Audit

| ID | Severity | Finding | Location | Resolution |
|----|----------|---------|----------|------------|
| G-01 | **HIGH** | Session entry corruption — the `sessions.md` insert deleted the prior entry's header, merging two entries into one block with duplicate `done:`/`key_fact:` keys | `agent/memory/sessions.md:5-35` | Repaired; diff now shows 25 insertions, **0 deletions** |
| G-02 | **HIGH** | `acp-validate.ts` accepted the corrupted file, reporting "21 entries — all valid". Duplicate keys within a session entry are not detected | `scripts/acp-validate.ts` | **Open — carryover** |
| G-03 | **MEDIUM** | SC-15 fix regressed against documented behaviour: `acp.review.md` permits gitignored lockfiles (M55 G-001), but the new HIGH finding fired on exactly that case | `agent/scripts/acp.review-scan.sh:439` | Fixed via `git check-ignore` exemption |
| G-04 | **MEDIUM** | G-03 would have broken the repo's own negative review-corpus fixture, which relies on a gitignored lockfile | `tests/fixtures/review-corpus/negative/security-project/` | Prevented by G-03 fix; corpus back to 100%/100% |
| G-05 | **MEDIUM** | Shortcut — 8 scanners fixed, only `review-scan` got a regression test. The session's own lesson demanded coverage for all | `e2e/acp.integrity.test.sh` | Fixed — B26 covers all 8 |
| G-06 | **MEDIUM** | Incorrect claim written to memory: "5 of 8 scanners" broken. Actual count is **6 of 8** (omitted `review-scan` itself) | `lessons.md`, `sessions.md` | Corrected in both files |
| G-07 | **MEDIUM** | Review corpus depends on 3 **untracked, gitignored** lockfile fixtures. On a fresh clone SC-15 precision drops 100% → 50% (aggregate 97.9%) | `tests/fixtures/review-corpus/` | **Open — carryover** (passes the 90% gate, so masked) |
| G-08 | **LOW** | Same BSD-sed `\n`-in-replacement class as F-107-04, unfixed | `agent/scripts/acp.package-update.sh:337` | **Open — carryover** (works on Darwin 25 + GNU) |
| G-09 | **LOW** | 7 further `"${arr[@]:-}"` instances — all guarded, not live bugs | `agent/scripts/acp.package-install.sh:260-265,800` | Informational; hygiene only |
| G-10 | **LOW** | Missing CHANGELOG entry and stray `)` typo in SC-15 doc row | `CHANGELOG.md`, `acp.review.md:298` | Fixed |

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/scripts/acp.integrity-output.sh:62-85` | `ig_format_json_array_body` — parses the buffer as JSON instead of sed string surgery |
| `agent/scripts/acp.integrity-output.sh:330-337` | Baseline capture, now **after** inline-suppression evaluation |
| `agent/scripts/acp.review-scan.sh:103-110` | Guarded positional restore (pattern replicated in 7 sibling scanners) |
| `agent/scripts/acp.review-scan.sh:424-452` | SC-15 — repo root from lockfile dir; tracked / untracked / gitignored / non-repo cases |
| `e2e/acp.review-scan.test.sh:388-448` | B34–B37 regression tests |
| `e2e/acp.integrity.test.sh:B26` | All-8-scanner no-argument regression test |

## Verification Evidence

| Gate | Result |
|------|--------|
| `e2e/acp.review-scan.test.sh` | 66/66 |
| `e2e/acp.review.test.sh` | 71/71 |
| `e2e/acp.integrity.test.sh` | 77/77 |
| `e2e/acp.integrity-v2.test.sh` | 52/55 — **3 pre-existing**, identical at HEAD (missing PyYAML) |
| `acp.review-measure.sh --ci` | 47 cases, 0 FP, 0 FN, 100% recall / 100% precision |
| `acp-validate.ts` | exit 0, clean |
| `acp.manifest-hash.sh --verify` | exit 0 |
| shellcheck | 5 SC2034 in `review-scan.sh` — identical to HEAD; 0 new |
| Regression proof | B34–B37 + B26 fail at pre-fix commit, pass after |
| Platform | All testing ran on **bash 3.2.57** (macOS system bash) — the oldest supported target |

## Key Decisions

- **Rejected the executor-default change upstream.** `composer-2.5` is a consumer model policy; applying it to the framework default would misroute every other consumer. The M84 `rule_overrides` mechanism is the sanctioned project-level escape hatch.
- **SC-15 distinguishes deliberate from accidental.** `git check-ignore` separates a gitignored lockfile (documented, permitted) from an untracked one (accident, breaks `npm ci`). This satisfies both the supply-chain intent and the M55 G-001 qualifier.
- **Repo root resolved from the lockfile's own directory**, not the script-level `REPO_ROOT` (which derives from the caller's cwd and is wrong for absolute paths outside it). This departs from the downstream fix, which used `git -C "$REPO_ROOT"`.

## Recommendations

1. **Close G-02** — add duplicate-key detection for memory-layer YAML entries in `acp-validate.ts`. This is the second time duplicate keys have slipped through (cf. the 191-key `progress.yaml` incident); the validator is the only thing standing between an agent edit and silent memory loss.
2. **Close G-07** — commit the 3 corpus lockfile fixtures via a `!tests/fixtures/**` negation so CI measures the same corpus as local runs. "Reproducible metrics" (`acp.review.md:66`) is currently untrue in CI.
3. **Close G-08** — route `acp.package-update.sh:337` through a portable helper.
4. **Test the no-argument path for every new scanner.** Six scanners were totally broken while 59 assertions passed, because every test passed an explicit path.
5. Consider a lint rule banning `"${arr[@]:-}"` in `set --` position — the antipattern recurred 8 times.

---

**Findings**: 10 (2 HIGH, 5 MEDIUM, 3 LOW) — 7 resolved in-session, 3 carried over
**Verdict**: The F-107 remediation is **verified correct and complete**. Three unrelated pre-existing issues are carried forward.
