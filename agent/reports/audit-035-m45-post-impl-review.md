# Audit Report: M45 Comprehensive Test Package — Post-Implementation Review

**Audit**: #035  
**Date**: 2026-06-03  
**Subject**: Post-implementation audit of M45 test package — gaps, bugs, and improvements found after the initial implementation

## Summary

M45 was implemented with 8 routes (063–070) and 9 test files totaling 60 assertions. A post-implementation audit revealed **1 critical bug**, **1 documentation gap**, and **3 medium/low improvements**. The critical bug caused the performance test's light-mode token budget check to **always silently pass** regardless of actual token count. The milestone document still showed `Status: planned` despite completion. All gaps have been fixed in this session.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `tests/acp.performance.test.sh` | Test | 🔴 Undefined variable bug in light mode total |
| `agent/milestones/milestone-45-comprehensive-test-package.md` | Doc | 🔴 Status still "planned" |
| `tests/acp.at-mention.test.sh` | Test | 🟢 Missing duplicate mention detection |
| `agent/routing/taxonomy.yml` | Config | 🟢 Referenced by @-mention test |
| `agent/progress.yaml` | Config | Cross-reference for version sync |
| `run-e2e-tests.sh` | Script | Test discovery verification |
| `tests/common.sh` | Test infra | Assertion helper quality check |

## Key Findings

| Finding | Location | Severity | Status |
|---------|----------|----------|--------|
| BUG-001: `id_chars`/`prog_chars` undefined in performance test | `tests/acp.performance.test.sh:42` | 🔴 Critical | ✅ Fixed |
| DOC-001: Milestone doc says `Status: planned` | `agent/milestones/milestone-45-*.md:6` | 🔴 High | ✅ Fixed |
| GAP-001: Full mode perf test missing sessions+wiki | `tests/acp.performance.test.sh` | 🟡 Medium | ✅ Fixed |
| GAP-002: @-mention catalog no duplicate check | `tests/acp.at-mention.test.sh` | 🟢 Low | ✅ Fixed |
| GAP-003: M45 milestone doc no actuals section | `agent/milestones/milestone-45-*.md` | 🟢 Low | ✅ Fixed |

## BUG-001: Undefined Variables in Performance Test

**File**: `tests/acp.performance.test.sh:42`  
**Code**: `total_chars=$((id_chars + prog_chars))`  
**Root Cause**: The variables `id_chars` and `prog_chars` were never defined. The `check_token_est` function used local variables that were not captured.

**Impact**:
- `total_chars` always evaluated to `0`
- `total_est` always evaluated to `0`
- The assertion `0 ≤ 800` was **always true**, making the light-mode budget check useless
- This test could have regressed silently for months

**Fix**: Added global variables `ID_CHARS` and `PROG_CHARS` that are set by `check_token_est` via a case statement matching on file path. This makes the light-mode total test actually verify the combined budget.

## DOC-001: Stale Milestone Status

**File**: `agent/milestones/milestone-45-comprehensive-test-package.md:6`  
**Issue**: `**Status**: planned` despite M45 being 100% complete  
**Impact**: Any agent reading the milestone doc would see "planned" and either re-do the work or skip it assuming it wasn't ready  
**Fix**: Changed to `**Status**: completed` and added an "Actual Results" section with final metrics

## Performance Test Scope Improvement

**Before**: Full mode test checked only `core (identity.yml) + taxonomy (first 30 lines) + skill (crosscut.md)` = ~1203 tokens  
**After**: Also includes `sessions.md (first 20 lines) + wiki (first 20 lines)` = ~1864 tokens — more representative of actual full mode load

## @-mention Duplicate Detection

**Added**: New assertion in `tests/acp.at-mention.test.sh` that verifies all `@{mention}` values in the `skills_catalog:` section are unique. Scoped to the catalog section only to avoid false positives from task types that reference the same skill.

## Recommendations

1. **All audit-035 findings are fixed** — no remaining action items from this audit
2. **Recommend adding a `--list` flag to `run-e2e-tests.sh`** so tests can self-verify discovery count (M46 candidate)
3. **Add version-update.sh test** to ensure the bootstrap syntax fix doesn't regress (M46 candidate)
