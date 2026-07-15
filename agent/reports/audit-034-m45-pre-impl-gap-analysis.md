# Audit Report: M45 Pre-Implementation Gap Analysis

**Audit**: #034  
**Date**: 2026-06-03  
**Mode**: --pre-impl  
**Subject**: M45 test package — gaps, inconsistencies, and improvements for industry-standard test coverage

## Summary

Eight routes (060–067) were planned for M45 but contain **structural overlap, missing categories, and insufficient real-world workflow testing**. Found 5 critical gaps and 3 medium gaps. Routes 060–062 are empty parent wrappers that overlap with their child routes — they should be removed or collapsed. The test plan lacks smoke tests, end-to-end workflow tests, performance verification, and cross-feature integration coverage that industry-standard frameworks require.

## Gap Analysis

### 🔴 GAP-028: Parent routes 060/061/062 overlap with children

| Route | Says | Route | Says | Problem |
|-------|------|-------|------|---------|
| 060 | "Create 5 test files" | 063–065 | "Create light-mode, @-mention, bootstraps" | **Duplicate scope** — 060 says create tests, 063–065 say the same. Route-060 has no independent deliverables. |
| 061 | "CI hardening" | 067 | "CI hardening + runner" | **Overlap** — both target runner and CI. |
| 062 | "Security + accountability" | 066 | "Security + accountability" | **Identical scope** — 062's entire description is duplicated by 066. |

**Fix**: Remove routes 060–062 (they add no value). Route-067 absorbs the CI work. Route-063–066 do all actual implementation.

### 🔴 GAP-029: No smoke test

Every quality framework has a "does the smoke rise" smoke test. M45 has zero coverage of: "given a fresh install, does the core system respond correctly?" A smoke test catches environment issues, missing files, and dependency failures in <5 seconds.

**Test cases needed**: agent/ directory exists, core files are readable, routing.yml is valid YAML, identity.yml is present.

### 🔴 GAP-030: No end-to-end workflow test

The test plan tests individual features in isolation but never tests the **real-world development workflow**:

```
/acp-init → /acp-audit → /acp-plan → /acp-proceed → /acp-commit → /git-commit
```

This is the primary ACP workflow. A 6-step integration test would catch cross-feature regressions that isolated tests miss — e.g., does /acp-commit still stamp route files after the R1 routing.yml changes?

### 🔴 GAP-031: No performance test

"Light mode loads ~200 tokens" is a documented promise. The test plan has structural checks (routing.yml sections exist) but **zero verification** that the actual token budget is accurate. A performance test should:

1. Count characters in identity.yml (~60 tokens)
2. Count characters in progress.yaml (first 30 lines, ~100 tokens)
3. Count characters in last 3 sessions.md entries (~40 tokens)
4. Assert total ≤ 300 tokens

Similarly for full mode (~800 tokens).

### 🟡 GAP-032: No cross-feature integration tests

Features tested in isolation may break when combined:

| Combination | Risk |
|-------------|------|
| Light mode + skills @-mention | Full mode Step 3 replaced — does light mode correctly NOT load skills? |
| Bootstrap --team-size + manifest overrides | Does manifest override CLI flags? |
| Observability + commit protocol | Does auto-populate require ledger.md to exist? |

### 🟡 GAP-033: No upgrade path test

ACP Enhanced supports version-update.sh for upgrades. If someone upgrades from v6.8.1 to v6.8.2:
- Does routing.yml get the new context_modes section?
- Do existing route-001 through route-045 files remain valid?
- Does sessions.md survive overwrite?
- Does progress.yaml observability section auto-initialize?

### 🟢 GAP-034: No test suite self-test

`run-e2e-tests.sh` discovery — does it actually find all tests in tests/ and e2e/? A self-test would:
1. Count discovered files vs expected count
2. Verify each test file returns correct exit codes
3. Verify --filter and --skip-network work

## Proposed Fixes

| Gap | Fix | Route |
|-----|-----|:-----:|
| GAP-028 | Remove routes 060–062 (empty parents) | — |
| GAP-029 | Add smoke test route | **route-068** |
| GAP-030 | Add end-to-end workflow test route | **route-069** |
| GAP-031 | Add token budget performance test route | **route-070** |
| GAP-032 | Merge into end-to-end workflow (route-069) | 069 |
| GAP-033 | Add upgrade compatibility assertion to smoke test | 068 |
| GAP-034 | Add --list verification step to route-067 | 067 |

## Updated Route Map

| Route | File(s) | Checks | Replaces |
|-------|---------|:------:|:--------:|
| **063** | `tests/acp.light-mode.test.sh` | 10 | (was 063) |
| **064** | `tests/acp.at-mention.test.sh` + `acp.parallel.test.sh` | 9 | (was 064) |
| **065** | `tests/acp.bootstrap-flags.test.sh` + `acp.observability.test.sh` | 10 | (was 065) |
| **066** | `tests/acp.security.test.sh` + `acp.accountability.test.sh` | 9 | (was 066) |
| **067** | `run-e2e-tests.sh` + CI + `tests/common.sh` | 5 | 060+061+067 merged |
| **068** (new) | `tests/acp.smoke.test.sh` | 6 | GAP-029 + GAP-033 |
| **069** (new) | `tests/acp.e2e-workflow.test.sh` | 6 | GAP-030 + GAP-032 |
| **070** (new) | `tests/acp.performance.test.sh` | 4 | GAP-031 |

### Execution Order

```
Phase 1 — 063 + 064 + 065 (independent parallel)
Phase 2 — 068 (smoke) + 066 (security)
Phase 3 — 069 (workflow — depends on 063-065)
Phase 4 — 070 (performance) + 067 (infra)
```

## Industry Standard Comparison

| Standard | Industry Expectation | M45 Before | M45 After |
|----------|---------------------|:----------:|:---------:|
| Smoke test | <5s sanity check | ❌ Missing | ✅ Route 068 |
| E2E workflow | Full user journey | ❌ Missing | ✅ Route 069 |
| Performance | Real metric verification | ❌ Missing | ✅ Route 070 |
| Security | OWASP Top 10 for CLI | ❌ Missing | ✅ Route 066 |
| Cross-platform | macOS + Linux CI | 🟡 Partial | ✅ Route 067 |
| Regression | Old bugs stay fixed | 🟡 Existing 38 tests | ✅ + new |
| Documentation | Docs match code | 🟡 Partial | ✅ Route 066 |
| Test isolation | Clean fixtures per test | ✅ existing suite | ✅ Preserved |

## Verdict

**BLOCKED** until routes 060–062 are removed and routes 068–070 are added. The test plan was directionally correct but missed critical categories: smoke, workflow, and performance tests. Without these, the test suite would give false confidence — all structural checks pass while the core workflow breaks.
