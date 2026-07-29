# Audit Report: Mainline Readiness Verification

**Audit**: #111
**Date**: 2026-07-28
**Subject**: Is everything resolved and safe to PR/merge `develop` → `mainline`?
**Mode**: standard (readiness gate — verdict determines whether the merge proceeds)

## Summary

**"All issues resolved" is not accurate — 3 carryovers remain open.** None of them are regressions from the two commits awaiting merge, and none block it.

The merge is nonetheless a **strict improvement to mainline**: `windows-latest` goes from failing to passing for the first time, while every other job is unchanged. Recommendation is therefore to merge, with the open items tracked rather than blocking.

This audit also retracted one of its own predecessor's findings.

## Correction to audit-110

| Finding | Status |
|---|---|
| **A-110-06** — "`acp.review-scan.sh` sources `acp.coderabbit.sh` but calls nothing from it" | **RETRACTED — false positive** |

`acp.review-scan.sh` sources exactly three files (`acp.integrity-output.sh:16`, `acp.gitleaks.sh:18`, `acp.dupehound.sh:20`). The audit-110 claim came from `grep -l acp.coderabbit.sh` matching **line 485**, which is a *case pattern* inside `is_sh_allowlisted()`'s SH-01 exclusion list — not a `source` statement.

Consequence: **A-110-04's risk is lower than stated.** `coderabbit_active()` (21.5s) is not reachable from the scanner at all; only `e2e/coderabbit-optionality.test.sh` and future callers hit it. The finding remains valid — 21.5s is real — but it is not a scanner landmine.

This is the **third** substring-vs-structure error in three audits (sessions.md `- date:` split; `status:pending` matched in prose; now a case pattern read as an import). Logged to `lessons.md` with the structural-pattern rule.

## Open Carryovers

| ID | Severity | Blocks merge? | Rationale |
|----|----------|---------------|-----------|
| A-110-04 | HIGH | **No** | `coderabbit_active()` 21.5s — unreachable from the scanner (see retraction). Latent for future callers. |
| A-110-05 | MEDIUM | **No** | Preference layer ~2.2s/lookup; `yaml_parse` 1.37s on 106 lines. Pre-existing, predates this branch. |
| A-110-07 | MEDIUM | **No** | `preferences-validate` 159s vs a 180s limit. Causes the macOS red — but it is caused by A-110-05, not by these commits. |

## Merge Impact — CI Comparison

| Job | mainline (867d44b) | develop (1894041) | Change |
|-----|--------------------|-------------------|--------|
| CI Checks | success | success | — |
| e2e ubuntu-latest | success | success | — |
| e2e windows-latest | **failure** | **success** | **fixed** |
| e2e macos-latest | failure | failure | unchanged |

Merging **cannot make mainline worse**: one job improves, none regress. The macOS failure is a single suite (`acp.preferences-validate.test.sh`, TIMEOUT) that already fails on mainline.

## Local Verification

| Gate | Result |
|------|--------|
| review-scan / review / integrity / package-update / validate / recurring-tasks | 0 failures each |
| corpus `--ci` | 47 cases, 0 FP, 0 FN, 100%/100% |
| vitest | 72/72 |
| `acp-validate` · manifest verify | exit 0 · exit 0 |

One transient `integrity` failure appeared in a single sweep and did **not** reproduce across 5 subsequent runs, including two that replayed the exact sweep ordering (manifest regenerate → suite). Recorded as transient, not a regression.

## Verdict

**READY TO MERGE — with 3 tracked carryovers, not "all issues resolved".**

The distinction matters: the branch is safe and strictly improves mainline, but the preference-layer work (A-110-05) is real, is what keeps macOS red, and should be the next milestone rather than being quietly forgotten once this merges.

## Recommendations

1. Merge — the improvement is unambiguous and the risk is nil.
2. Make **A-110-05** the next piece of work; it closes A-110-07 (macOS) and A-110-04 (21.5s) at the root.
3. Do **not** raise the 180s timeout to make macOS green. audit-110 already demonstrated that masks the defect.
4. Add a wall-clock assertion to the corpus gate — correctness gates could not see an 18× slowdown.

---

**Findings**: 1 (a retraction of a prior finding) · **Carryovers**: 3 open, 0 blocking
**Verdict**: Merge approved.
