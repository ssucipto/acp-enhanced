# Audit Report: Windows E2E Timeout — Root Cause and Preference-Layer Gaps

**Audit**: #110
**Date**: 2026-07-28
**Subject**: Why `acp.review.test.sh` timed out on windows-latest, and what else the investigation exposed
**Mode**: standard

## Summary

`acp.review.test.sh` had been timing out on `windows-latest` since before this release, and kept timing out even after the per-test budget was raised to 600s. That resistance was the clue: 600s for a 72-assertion suite is not slowness, it is something structurally wrong.

It was not a hang, and not really a Windows problem. **Every scanner invocation spent ~3 seconds asking whether two optional analyzers were enabled — analyzers that were not installed.** `gitleaks_active()` and `dupehound_active()` each resolved a preference (a ~1.5s pure-bash YAML walk) *before* checking tool availability with `command -v`. Windows merely amplified a cost that every platform was paying.

Fixing the ordering took a single-file scan from **2.95s to 0.16s (18×)** and `acp.review.test.sh` from **66s to 3s (22×)**. The Windows-specific timeout added earlier in this release was then reverted — it was treating the symptom.

## Root Cause

```bash
gitleaks_active() {
  local pref
  pref="$(_gitleaks_pref)"          # ~1.5s pure-bash YAML walk
  [[ "$pref" == "false" ]] && return 1
  gitleaks_available                # `command -v` — microseconds
}
```

When the tool is absent the result is "inactive" for **every** preference value, so the expensive call cannot change the answer. Checking availability first is provably equivalent.

Verified across all six states, before and after:

| gitleaks | pref=auto | pref=true | pref=false |
|---|---|---|---|
| absent | inactive | inactive | inactive |
| present | ACTIVE | ACTIVE | inactive |

Identical results for `dupehound`. Semantics unchanged.

### Measurements

| Measurement | Before | After |
|---|---|---|
| Single-file scan (`x.ts`) | 2.95s (user 1.17 / **sys 1.78**) | **0.16s** |
| `acp.review.test.sh` | 66s | **3s** |
| `acp.review-scan.test.sh` | 22s | **12s** |
| `get_preference` calls per scan | 2 (~1.5s each) | 0 when tools absent |

The high **sys** time was the tell — the cost was process/filesystem churn inside the preference walk, not computation.

## Findings

| ID | Severity | Finding | Status |
|----|----------|---------|--------|
| A-110-01 | **HIGH** | `gitleaks_active()` / `dupehound_active()` resolved a ~1.5s preference before the microsecond availability check, costing ~3s on *every* scanner invocation on *every* platform | **Fixed** — availability short-circuits first |
| A-110-02 | MEDIUM | `_gitleaks_pref` / `_dupehound_pref` re-resolved the preference on every call, so `*_active` + `*_hint_if_missing` paid it twice | **Fixed** — memoised per process |
| A-110-03 | MEDIUM | Windows-only 600s timeout masked the real defect and would have hidden future regressions | **Fixed** — reverted to a uniform 180s now that the cause is gone |
| A-110-04 | **HIGH** | `coderabbit_active()` costs **21.5s** — `_coderabbit_enabled` 13.8s + `coderabbit_available` 5.5s, neither memoised. Not currently on the scan path, but a latent landmine for any caller | **Open — carryover** |
| A-110-05 | MEDIUM | `get_preference` (strict) is ~2.5× slower than `get_preference_or` (13.8s vs 5.5s in the same resolution). The preference layer itself is the deeper root cause; both figures are unreasonable for reading one key | **Open — carryover** |
| A-110-06 | LOW | `acp.review-scan.sh` sources `acp.coderabbit.sh` but calls no `coderabbit_*` function — an unused import that pulls a 21s-capable helper into the scanner's surface | **Open — carryover** |

## Why This Went Unnoticed

The corpus gate measures **recall and precision, not time**. A scanner 18× slower than necessary scores 100%/100%. The only signal was a per-test timeout on the slowest platform, which reads as "Windows is flaky" rather than "the scanner is slow everywhere" — and the natural response (raise the timeout) removes the signal entirely. That is exactly what happened earlier in this release before this audit.

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/scripts/acp.gitleaks.sh:26` | `_gitleaks_pref` — now memoised |
| `agent/scripts/acp.gitleaks.sh:36` | `gitleaks_active` — availability checked first |
| `agent/scripts/acp.dupehound.sh:16` | `_dupehound_pref` — now memoised |
| `agent/scripts/acp.dupehound.sh:44` | `dupehound_active` — availability checked first |
| `run-e2e-tests.sh:79` | Uniform 180s timeout restored |
| `agent/scripts/acp.coderabbit.sh:34,47,62` | A-110-04 — unmemoised, 21.5s combined |

## Verification

| Gate | Result |
|------|--------|
| review-scan / review / integrity / package-update / validate / recurring-tasks | 66/66 · 71/71 · 77/77 · 13/13 · 17/17 · 16/16 |
| coderabbit-optionality | 13/13 |
| corpus `--ci` | 47 cases, 0 FP, 0 FN, 100%/100% |
| `acp-validate` · vitest · manifest verify | exit 0 · 72/72 · exit 0 |
| Behavioural equivalence | 6/6 preference × availability states identical for both helpers |

## Recommendations

1. **Close A-110-04/05** — memoise the CodeRabbit helpers and profile `get_preference` itself. A 13.8s single-key read is the real defect; the analyzer helpers were just the first place it surfaced.
2. **Drop the unused `acp.coderabbit.sh` source** from `acp.review-scan.sh` (A-110-06).
3. **Add a performance assertion to the corpus gate** — e.g. fail if a single-file scan exceeds ~1s. Correctness gates cannot see an 18× regression, and a timeout on one platform is too weak a signal.
4. **Treat "raise the timeout" as requiring a root-cause note.** The 600s bump was reasonable-looking and wrong; it would have permanently hidden this.

---

**Findings**: 6 (2 HIGH, 3 MEDIUM, 1 LOW) — 3 fixed, 3 carried over
**Verdict**: The Windows timeout was a symptom of a ~3s constant cost on every scanner invocation across all platforms. Root cause fixed; the preference layer beneath it still warrants work.
