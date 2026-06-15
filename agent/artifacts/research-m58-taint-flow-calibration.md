# M58 Taint-Flow Detection Accuracy Calibration

<!-- @acp.meta.artifact
topic: taint-flow, SAST, code-integrity, IG-45, IG-46, IG-47, IG-48, IG-49, IG-50, confidence-ceiling
last_verified: 2026-06-15
confidence: high
status: active
updated: 2026-06-15
@acp.meta.end -->

**Type**: research  
**Created**: 2026-06-15  
**Category**: Security / Code Integrity  
**Sources**: OWASP Top 10:2025, ACP integrity-rules.md, M56 audit literature citations

---

## Executive Summary

Taint-flow rules IG-45–50 require cross-file data-flow reasoning that pure bash cannot reliably perform at `confidence: HIGH`. Literature and M56 planning cite **11–40% false-negative rates** for LLM semantic security analysis and **60–89% attack success** against agent memory/context (AUR). This calibration recommends:

1. **Ship IG-45–50 in M58 with `confidence: MEDIUM` ceiling** — never CRITICAL auto-fail in `--ci` mode.
2. **Use heuristic scripts for obvious sinks** (exec, eval, raw SQL concat) — script hits get `confidence: HIGH` only when pattern is unambiguous.
3. **Use LLM for cross-function flow** — capped at `confidence: MEDIUM`.
4. **Ground truth**: 12 fixtures in `agent/benchmarks/fixtures/taint-flow/` (route-158 E2E).

**Go/no-go**: Proceed to route-157 script implementation. Do NOT claim SAST-grade coverage.

---

## Research Context

**Why this research was conducted:**

M56 deferred Category 8 pending production calibration data. Route-155 establishes measurable targets before un-deferring rules.

**Initial questions:**

- What TPR/TNR is realistic per rule with script+LLM hybrid?
- Which rules can be partially script-backed?
- What confidence ceiling prevents false CI failures on the clean ACP codebase?

**Scope:**

- In scope: IG-45–50, fixture design, detection method assignment
- Out of scope: IG-53–62 (routes 156–157), full benchmark suite execution

---

## Key Findings

1. **LLM taint analysis is unreliable at HIGH confidence**
   - **Source**: ACP M56 planning (`agent/wiki/integrity-rules.md`, 2026-06-07)
   - **Confidence**: High (9/10)
   - **Details**: Documented 11–40% FNR for semantic security; aligns with industry LLM-SAST skepticism.

2. **Obvious sinks are script-detectable**
   - **Source**: M56 LLM/Script Boundary Rule (`agent/skills/code-integrity.md`)
   - **Confidence**: High (9/10)
   - **Details**: `child_process.exec` with template literal + request param, raw SQL string concat — grep/AST-lite sufficient for HIGH on single-file obvious cases.

3. **Cross-file and sanitization reasoning needs MEDIUM ceiling**
   - **Source**: OWASP Injection prevention guidance (2025)
   - **Confidence**: Medium (7/10)
   - **Details**: Validator wrappers, ORM parameterization, and allowlist redirects defeat naive taint tracking.

---

## Calibration Matrix

| Rule | Source → Sink | Script heuristic | LLM required | TPR target | TNR target | Max confidence |
|------|---------------|------------------|--------------|------------|------------|----------------|
| IG-45 | User input → SQL | Concat in query string | Cross-file param flow | ≥85% fixtures | ≥90% safe | MEDIUM (HIGH if obvious concat) |
| IG-46 | User input → shell | exec/spawn with interpolation | Indirect command build | ≥90% fixtures | ≥95% safe | MEDIUM (HIGH if direct exec) |
| IG-47 | User input → file path | path.join(req.param, ...) | Canonicalization checks | ≥80% fixtures | ≥85% safe | MEDIUM |
| IG-48 | User input → redirect | res.redirect(req.query.url) | Allowlist validation | ≥85% fixtures | ≥90% safe | MEDIUM |
| IG-49 | Env var → network | fetch(process.env.URL) | Schema validation absent | ≥75% fixtures | ≥90% safe | MEDIUM |
| IG-50 | Library output → security | trust external flag without verify | Context-dependent | ≥70% fixtures | ≥85% safe | LOW–MEDIUM |

**CI policy**: Only script-backed findings with unambiguous patterns may trigger `--ci` exit 1 at HIGH. All LLM taint findings report at MEDIUM or below.

---

## Detection Method Assignment (route-157 input)

| Rule | Script signals (deterministic) | LLM signals (semantic) |
|------|-------------------------------|------------------------|
| IG-45 | `` `SELECT ... ${` ``, `+ req.`, `.query(\`...${` | ORM usage, prepared statements, query builders |
| IG-46 | `exec(`, `spawn(`, `execSync(` with `${` or `+` | Command array vs shell, sanitization wrappers |
| IG-47 | `readFile(req.`, `path.join(req.`, `../` in param | `path.resolve` + allowlist, chroot patterns |
| IG-48 | `redirect(req.`, `location.href = req.` | Allowlist host check, relative-only redirects |
| IG-49 | `fetch(process.env`, `axios(process.env` | Zod/env schema validation present |
| IG-50 | External API boolean trusted in `if (` without re-check | Defense-in-depth patterns |

---

## Fixture Ground Truth

Manifest: `agent/benchmarks/fixtures/taint-flow/manifest.yaml`

| File | Rule | Expected |
|------|------|----------|
| ig-45-vulnerable.js | IG-45 | FINDING |
| ig-45-safe.js | IG-45 | CLEAN |
| ig-46-vulnerable.js | IG-46 | FINDING |
| ig-46-safe.js | IG-46 | CLEAN |
| ig-47-vulnerable.js | IG-47 | FINDING |
| ig-47-safe.js | IG-47 | CLEAN |
| ig-48-vulnerable.js | IG-48 | FINDING |
| ig-48-safe.js | IG-48 | CLEAN |
| ig-49-vulnerable.js | IG-49 | FINDING |
| ig-49-safe.js | IG-49 | CLEAN |
| ig-50-vulnerable.js | IG-50 | FINDING |
| ig-50-safe.js | IG-50 | CLEAN |

Route-158 will run `/acp-integrity --rules taint-flow` against this directory and assert matrix compliance.

---

## Recommendations

1. **Implement `acp.taint-scan.sh` (route-157)** (Priority: High, Confidence: 9/10) — canonical name per M65 route-187 resolution; shipped as `acp.taint-scan.sh` + `acp.taint-scan.py` in M58 Phase 2.
   - Rationale: Covers obvious sinks at zero token cost
   - Impact: HIGH-confidence findings for unambiguous patterns only

2. **Keep LLM taint pass optional `--semantic`** (Priority: High, Confidence: 8/10)
   - Rationale: Avoid mandatory expensive/low-accuracy pass in CI

3. **Never promote taint findings to CRITICAL in v2.0** (Priority: High, Confidence: 9/10)
   - Rationale: FNR too high for blocking gate; use advisory reporting

---

## Limitations & Gaps

- Fixtures are single-file; multi-file taint not covered until route-157 integration tests
- No live LLM benchmark run in route-155 — empirical TPR measured in route-158
- TypeScript/Python fixtures deferred to route-157 if JS heuristics insufficient

---

## Sources & References

1. **ACP Integrity Rules Catalogue v1.0**
   - Path: `agent/wiki/integrity-rules.md`
   - Date Accessed: 2026-06-15

2. **ACP Code Integrity Skill**
   - Path: `agent/skills/code-integrity.md`
   - Date Accessed: 2026-06-15

3. **OWASP Top 10:2025 — Injection**
   - URL: https://owasp.org/Top10/
   - Date Accessed: 2026-06-15
