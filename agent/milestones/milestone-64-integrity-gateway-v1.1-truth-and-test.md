# Milestone 64: Integrity Gateway v1.1 — Truth & Test

**Shipped version**: 6.19.0  
**Status**: completed  
**Completed**: 2026-06-15  
**Priority**: HIGH (blocks further M58 v2.0 semantic work)
**Estimated effort**: ~18h (6 routes)
**Source**: audit-070 (M55–M58 gateway deep dive) — findings F-070-01..16
**Depends on**: none (operates on shipped M56 `/acp-integrity` v1.0 code)
**Blocks**: M58 v2.0 semantic analysis (do not build taint/memory analysis on an untested, partially-implemented v1)

---

## 1. Goal

Make `/acp-integrity` **honest and tested**. Audit-070 found the integrity gateway advertises 55 script-backed rules but ~18 are actually implemented, one scanner (`acp.entropy-scan.sh`) crashes on every positive finding, the unicode scanner is too slow to use as a gate, and the E2E suite never exercises detection logic — so all of this passes CI green. For a startup depending on this as a security gate on AI-generated code, the cardinal risk is **false assurance**: the tool prints `✓` while most of its CRITICAL rules never run.

This milestone closes that gap on two axes:
- **Truth**: documented coverage == executed coverage (implement the high-value missing rules; honestly relabel anything still unenforced).
- **Test**: every script-backed rule has a true-positive and true-negative fixture that runs the real script in CI, plus a real clean-codebase false-positive baseline.

The quality gateway (`/acp-review`, M55) was confirmed production-grade in audit-070 and is **out of scope** here except as the reference design for output format.

---

## 2. Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-179 | Fix the two broken scanners: entropy `set -e` crash + unicode single-pass performance | F-070-01, F-070-04 | 3h | completed |
| route-180 | Implement missing deterministic detections (exfil IG-07–13, persistence IG-21–26, IG-04/05, shadow-deps IG-29, real typosquat IG-27, IG-32) | F-070-02, F-070-08 | 5h | completed |
| route-181 | Truth pass: reconcile coverage tables (cmd/wiki/skill/headers) to actual; relabel unenforced rules; fix token budget | F-070-02 (doc), F-070-07, F-070-16 | 2h | completed |
| route-182 | Uniform output contract `[SEVERITY] file:line ruleID — msg` (+ `--json`) and severity-aware `--ci` across all 6 scripts | F-070-05, F-070-06, F-070-13 | 3h | completed |
| route-183 | Robustness: YAML via parser, git-date staleness, IG-37 explicit-skip, manifest dir-enumeration + write-to-file, sha fallback | F-070-09, F-070-10, F-070-11, F-070-12, F-070-15 | 3h | completed |
| route-184 | **Keystone**: per-rule true+/true- fixture matrix + real clean-codebase false-positive baseline + fix E2E `\d` count | F-070-03, F-070-14 | 2h | completed |

**Recommended execution order**: 179 → 182 → 180 → 183 → 181 → 184. Rationale: fix crashes first (179); lock the output contract (182) so newly-implemented rules (180, 183) emit the right format from the start; do the truth/relabel pass (181) once real coverage is known; finish with the test harness (184) that proves all of the above.

---

## 3. Industry-Standard Alignment (the bar each route must meet)

| Standard | Requirement | Enforced by |
|----------|-------------|-------------|
| NIST SSDF PW.7 / RV.1 | Verification must actually run and be tested | route-184 fixture matrix |
| Truth-in-advertising (security tooling) | Documented coverage == real coverage | route-181 |
| SAST CI norms | Low false-positive rate; severity-gated CI | route-182 (`--ci` filters CRITICAL/HIGH), route-184 baseline |
| Reproducibility | Deterministic across environments (no mtime, no single-tool deps) | route-183 |
| Output contract | Machine-parseable, uniform finding format | route-182 |

---

## 4. Milestone-Level Exit Criteria (double-verify gate)

Each route satisfies BOTH:
1. **Automated proof**: a test/CI check that FAILS before the fix and PASSES after (regression-first).
2. **Manual proof**: documented before/after command output in the route's User-Observable Acceptance.

Milestone exit:
- `acp.entropy-scan.sh` on a known high-entropy fixture prints the finding and exits with the documented code (no `exit 3` crash).
- `acp.unicode-scan.sh` scans the whole repo in < 5s (single-pass).
- Every script-backed IG rule has ≥1 true-positive fixture (scanner flags it) AND ≥1 true-negative fixture (scanner stays silent), all wired into `e2e/acp.integrity.test.sh` running the real scripts.
- Real false-positive baseline (`assert_finding_count CRITICAL 0` / `HIGH 0` over the clean ACP codebase) present and green — as M56 §8 originally mandated.
- `agent/wiki/integrity-rules.md`, `agent/commands/acp.integrity.md`, `agent/skills/code-integrity.md`, and every script header report the SAME, ACCURATE coverage. No rule is listed as enforced unless a fixture proves it runs.
- All six scripts emit the uniform `[SEVERITY] file:line ruleID — message` format; `--ci` exits 1 only on CRITICAL/HIGH.
- `CHANGELOG.md` entry for v6.19.0.
- Carryovers F-070-01..16 marked `fixed` with `verified_in_audit` set.

---

## 5. Out of Scope (deliberately deferred)

- M58 v2.0 semantic rules (taint/memory/semantic-injection) — handled in M58/M65; this milestone only hardens v1.
- New rule categories beyond the existing IG-01..70 catalogue.
- `/acp-review` changes (confirmed healthy in audit-070).

---

## 6. References

- `agent/reports/audit-070-m55-m58-gateway-deep-dive.md` (findings + code pointers)
- `agent/scripts/acp.{unicode-scan,entropy-scan,network-whitelist-validate,manifest-hash,git-provenance,dependency-diff}.sh`
- `agent/skills/code-integrity.md`, `agent/commands/acp.integrity.md`, `agent/wiki/integrity-rules.md`
- `agent/skills/scripts.md` (set -euo pipefail; never parse YAML with grep), `agent/scripts/acp.yaml-parser.sh`
- `agent/milestones/milestone-56-acp-integrity-command.md` §8 (mandated false-positive baseline)
- `e2e/acp.review.test.sh` (reference for behavioral test style)

*Milestone 64 | ACP Enhanced v6.19.0 | audit-070 | 2026-06-15*
