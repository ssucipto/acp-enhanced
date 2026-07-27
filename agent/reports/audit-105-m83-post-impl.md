# Audit Report: M83 Deterministic Review Engine — Post-Implementation

**Audit**: #105  
**Date**: 2026-07-28  
**Subject**: M83 implementations — gaps, inconsistencies, carryovers, shortcuts, industry alignment  
**Follow-up to**: audit-102 (scope), audit-103 (precision), audit-104 (pre-impl), review-003 (closure)  
**Executor**: cursor  

---

## Summary

M83 delivered the deterministic review engine as planned: **42 built-in Phase 1 rules**, optional **SH-03** / **gitleaks** / **dupehound** helpers (ADR-23), a **30-case labelled corpus** with **100% recall/precision** on fixtures, **55/55 executing E2E** checks, and closure at **v6.29.0**. The binding sequencing discipline from audit-103 was honored — lexing (282) and measurement (284) preceded Tier C expansion (286–289).

This audit finds **no ship-blocking regressions** in M83 scope. The milestone is **substantially complete** and materially better than the pre-M83 baseline (≈8% recall, 0% precision per audit-103). Remaining issues are **documentation drift**, **one partial task-295 shortcut** (per-rule thresholds), **M81 carryovers** (unchanged), and **architectural limits** inherent to regex+char-lexer scanning.

Remediation applied in this audit:
- Corrected stale prose in `agent/commands/acp.review.md` (corpus counts, rule ownership, removed obsolete "11 rules" block).
- Closed **F-104-05** (SC-15 rationale already corrected in task-286).
- Wired `acp.review-measure.sh --ci` into `.github/workflows/ci.yaml`.
- Opened **F-105-01** (per-rule thresholds) and **F-105-02** (lexer architecture limit).

---

## Verification Snapshot

| Check | Result |
|-------|--------|
| `bash agent/scripts/acp.review-measure.sh --ci` | **PASS** — 30 cases, 47 TP rows, 100% recall/precision |
| `bash e2e/acp.review-scan.test.sh` | **PASS** — 55/55 |
| `bash e2e/acp.review.test.sh` | Not re-run this session; passed at M83 closure (67/67) |
| Live scan `scripts/` (sample) | 16 findings in ~65s — 7 HIGH, 5 MEDIUM, 4 LOW (real signal, not corpus) |
| Policy map vs scanner rule IDs | **42/42** Phase 1 rows match implemented emitters |
| M83 carryovers F-102..F-104 | **All fixed** except F-104-05 → fixed this audit |

---

## Key Findings

| ID | Severity | Finding | Location | Status |
|----|----------|---------|----------|--------|
| F-105-01 | MEDIUM | Per-rule enable/severity overrides promised in task-295 / F-103-09 not implemented — only baseline + inline suppression shipped | `acp.integrity-output.sh` | **pending** → M84 |
| F-105-02 | LOW | Char-walker lexer, not AST/tree-sitter — caps semantic rule quality vs industry SAST | `acp.review-scan-ts.py` | **pending** → backlog |
| — | MEDIUM | `acp.review.md` had contradictory counts (42 vs "11 rules"; 18 vs 30 corpus cases; 8-rule ownership table) | `acp.review.md:60–83` | **fixed** this audit |
| — | LOW | `acp.review-measure.sh --ci` was not in CI despite being the published quality gate | `.github/workflows/ci.yaml` | **fixed** this audit |
| F-104-05 | LOW | SC-15 verification rationale referenced wrong reason | `task-286-tierc-security-batch.md` | **fixed** (verified) |
| F-101-02..06 | HIGH/MED | M81 CodeRabbit fixture gate tasks — not M83 scope | M81 tasks | **pending** (unchanged) |

---

## M83 Carryover Closure

| Range | Count | Status |
|-------|-------|--------|
| F-102-01..08 (audit-102 scope/E2E) | 8 | fixed |
| F-103-01..10 (audit-103 precision/standards) | 10 | fixed* |
| F-104-01..07 (audit-104 pre-impl) | 7 | fixed |

\* **F-103-09 partial**: baseline + inline suppression verified; per-rule thresholds deferred to **F-105-01**. Closure was acceptable for M83 exit but overstated "all three FP controls."

---

## Shortcuts Taken (and whether acceptable)

| Shortcut | Verdict | Notes |
|----------|---------|-------|
| Python char-walker instead of tree-sitter/TS compiler API | **Acceptable for v1** | Sufficient for comment/string FP elimination; document limit (F-105-02) |
| Hand-rolled regex rules vs full SAST engine | **Acceptable** | Scoped to deterministic subset; optional tools cover secrets/dupes |
| `dupehound-sample.json` is hand-crafted, not from live `dupehound` binary | **Acceptable** | E2E uses fake dupehound stub; live binary path not verified on maintainer machine |
| `gitleaks` / `dupehound` never required in CI | **Acceptable** | ADR-23 three-gate pattern; graceful degradation tested |
| 100% corpus metrics presented without production disclaimer | **Risk** | Metrics are **fixture-bound**; live `scripts/` scan shows real HIGH findings — credibility OK if labelled "corpus-backed" |
| task-295 marked complete without per-rule thresholds | **Not acceptable** | Re-opened as F-105-01 |
| review-measure not in CI until this audit | **Not acceptable** | Fixed in ci.yaml |

---

## Industry Standards & Best Practices

### Aligned

| Practice | ACP implementation |
|----------|-------------------|
| OWASP Top 10:2025 citation | Explicit coverage table with deliberate non-coverage (A06 → Phase 2, A08 → `/acp-integrity`) |
| Measure before expand | Corpus + `acp.review-measure.sh` with 90% CI floor |
| FP management (partial) | Baseline file, inline `acp-review-ignore` with required reason, suppression summary |
| Optional tool pattern | gitleaks, dupehound, shellcheck — no hard deps, no binary downloads |
| Executing E2E over doc asserts | `e2e/acp.review-scan.test.sh` (55 cases) |
| Supply chain signal | SC-14 via `npm audit` in scanner; separate CI `npm audit` job |
| Cross-command ownership | `/acp-validate`, `/acp-integrity`, `/acp-review` boundaries documented |

### Gaps vs mature scanners (gitleaks, Semgrep, CodeQL)

| Capability | Industry norm | ACP M83 |
|------------|---------------|---------|
| AST / semantic analysis | Standard for TS/JS | Regex + char-lexer only |
| Per-rule tuning | enable/disable, severity override | **Missing** (F-105-01) |
| Production-scale corpus | Thousands of real-world samples | 30 curated fixtures |
| SARIF / IDE integration | Common | Custom text/JSON only |
| Differential scan default | PR-scoped | Full-path scan; dupehound has `--diff` |
| Secret detection without optional tool | Dedicated engine | Prefix table + entropy fallback; weaker than gitleaks alone |

---

## What We Are Doing Well

1. **Sequencing discipline** — audit-103 binding rule enforced: lexing → measurement → expansion. Avoided multiplying FP rate on a broken foundation.
2. **Honest phase split** — 42 + 1 optional + 2 validate-owned + 19 semantic; no "64/64 automated" claim.
3. **Regression harness** — executing scanner E2E caught multi-path, `--self`, `.mjs`, flag-order bugs that doc-only tests missed (F-102-08 lesson applied).
4. **Reproducible metrics** — `expected.yaml` + measure script; now CI-gated.
5. **Optional-tool architecture** — ADR-23 Variant B is clean, testable, and matches industry "progressive enhancement."
6. **Carryover hygiene** — 25 M83-related findings tracked and closed with verification pointers.
7. **Real-world signal** — scanning `scripts/` surfaces plausible HIGH issues (EH-09, TS-08, SH-01, TS-01), suggesting rules fire on non-fixture code.

---

## Limitations

1. **Fixture-bound quality claims** — 100% recall/precision applies to **30 labelled cases**, not the full repo or arbitrary codebases.
2. **No per-rule policy file** — teams must baseline or inline-ignore; cannot downgrade noisy rules via config (F-105-01).
3. **Lexer ceiling** — template/comment handling is good; type-aware or flow-sensitive rules remain out of reach without AST (F-105-02).
4. **Performance** — single-directory `scripts/` scan ~65s; full `--self` on the repo is slow for interactive use.
5. **Optional tools unproven in CI** — gitleaks/dupehound paths tested via stubs; live binary integration not exercised in GitHub Actions.
6. **M81 still blocked** — CodeRabbit fixture gate (F-101-02..06) remains; policy map references `acp.findings-import.sh` not yet shipped.
7. **CH-05 / dupehound maturity** — v0.1.2 tool; wrapper is correct but ecosystem risk remains per audit-102.

---

## Files Analyzed

| File | Relevance |
|------|-----------|
| `agent/scripts/acp.review-scan.sh` | 42-rule orchestration, SC-14/15, SH-03, optional tools |
| `agent/scripts/acp.review-scan-ts.py` | Lexing + majority of rule emitters |
| `agent/scripts/acp.review-measure.sh` | Corpus recall/precision gate |
| `agent/scripts/acp.integrity-output.sh` | Baseline + inline suppression |
| `agent/scripts/acp.gitleaks.sh`, `acp.dupehound.sh` | ADR-23 helpers |
| `agent/commands/acp.review.md` | Phase counts, OWASP table, FP docs |
| `agent/wiki/coderabbit-policy-map-lite.md` | 42-rule ownership map |
| `tests/fixtures/review-corpus/expected.yaml` | 30-case corpus |
| `e2e/acp.review-scan.test.sh` | Executing behavioral suite |
| `agent/memory/audit-carryovers.md` | M83 + M81 carryover state |
| `.github/workflows/ci.yaml` | CI gates |

---

## Git History (M83 implementation arc)

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-27 | `6d3a7c0` | Phase 1: scope fixes, E2E harness, lexing foundation (280–282) |
| 2026-07-27 | `7c97f72` | Pattern recall, corpus measurement, shellcheck SH-03 (283–285) |
| 2026-07-27 | `32761cc` | ADR-23 local analyzers |
| 2026-07-27 | `8b34d62` | Tier C rules, optional analyzers, FP controls (286–295 bulk) |

---

## Recommendations

1. **M84 or hotfix**: Implement `review.rule_overrides` preferences (**F-105-01**) — highest-value remaining FP control.
2. **M81**: Resolve F-101-02..06 before CodeRabbit integration ships; do not invent fixture.
3. **Adoption playbook**: Document "baseline → tighten" workflow for legacy repos; run full `--self` once and publish finding counts in wiki.
4. **Corpus growth**: Add production-derived false-positive samples when teams adopt; keep 90% floor.
5. **Optional**: Live dupehound/gitleaks smoke job in CI (non-blocking) when binaries available on ubuntu-latest.

---

## Verdict

**M83: SHIP-QUALITY with documented limitations.** The implementation closes the audit-102/103/104 findings it targeted, adheres to industry patterns for phased SAST rollout (measure → gate → expand → optional tools → FP controls), and fails only on the partial task-295 delivery (per-rule thresholds). Documentation drift and missing CI measure gate are remediated in this audit.

**Next milestone focus**: M81 (CodeRabbit layer) + F-105-01 (per-rule overrides).
