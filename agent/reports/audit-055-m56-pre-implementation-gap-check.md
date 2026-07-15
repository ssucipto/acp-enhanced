# Audit Report: M56 — Pre-Implementation Gap & Consistency Check

**Audit**: #055  
**Date**: 2026-06-07  
**Subject**: M56 /acp-integrity v1.0 plan — inconsistencies, missing milestones, rule count drift  
**Prior audits**: audit-053 (feedback-007 suitability), audit-054 (second-round consolidated)  

## Summary

M56 is a well-structured plan with strong architecture (LLM/Script Boundary Rule, build-order enforcement). All 8 route files exist. However, 5 findings were identified:

1. **Rule count drift**: Claims "44 rules" but actual v1.0 scope is 55 rules — off by 11
2. **M57 + M58 milestones missing**: Deferred items have no tracking — risk of being forgotten
3. **Unbacked deterministic rules**: 4 pattern-matchable rules lack script backing
4. **Skill file token target**: 500 tokens is aspirational but may be tight; should document fallback
5. **Script coverage audit gap**: IG-04, IG-18–IG-20 are deterministic but not script-assigned

## Files Analyzed

| File | Relevance |
|------|-----------|
| `agent/milestones/milestone-56-acp-integrity-command.md` | Primary plan document |
| `agent/routing/tasks/route-142.md` through `route-149.md` | 8 route task files |
| `agent/progress.yaml` | M56 entry verification |
| `agent/feedback/feedback-007-acp-integrity-command-upstream-v2.md` | Original proposal |
| `agent/feedback/audit-054-second-round-acp-integrity-consolidated.md` | Second-round audit |

## Key Findings

### GAP-055-01 (MEDIUM) — Rule Count Drift: 55 ≠ 44

The milestone header and multiple sections claim "44 rules" for v1.0. Actual category-by-category count:

| Category | Rules | Count |
|----------|-------|-------|
| Cat 1 — Network Anomalies | IG-01–IG-06 | 6 |
| Cat 2 — Exfiltration | IG-07–IG-13 | 7 |
| Cat 3 — Obfuscation | IG-14–IG-20 | 7 |
| Cat 4 — Persistence | IG-21–IG-26 | 6 |
| Cat 5 — Dependencies | IG-27–IG-32 | 6 |
| Cat 6 — Git Provenance | IG-33–IG-37 | 5 |
| Cat 7 — ACP Self-Integrity | IG-38–IG-44 | 7 |
| Cat 9 — Prompt Injection (partial) | IG-51, IG-52, IG-55, IG-63 | 4 |
| Cat 11 — GitHub Actions | IG-64–IG-70 | 7 |
| **v1.0 Total** | | **55** |
| **Claimed in milestone** | | **44** |
| **Delta** | | **+11** |

**Root cause**: The "44 rules" number appears to be a rough estimate from audit-054 that was carried forward without recount. The milestone's own rule tables add up to 55.

**Fix**: Update all "44 rules" references to "55 rules" throughout the milestone document. Also update route-146 (wiki file: "all 44 rules" → "all 55 rules") and route-147 (command doc: same).

---

### GAP-055-02 (HIGH) — Missing M57 + M58 Milestones

The M56 plan explicitly defers 6 items to M57 and M58:

| Deferred Item | Target | Status |
|--------------|--------|--------|
| Recurring tasks scheduler | M57 | ❌ No milestone exists |
| Pre-commit hook framework | M57 | ❌ No milestone exists |
| CI/CD pipeline enforcement | M57 | ❌ No milestone exists |
| Taint flow analysis (IG-45–IG-50) | M58 | ❌ No milestone exists |
| Semantic injection detection (IG-53, IG-54, IG-56, IG-57) | M58 | ❌ No milestone exists |
| Memory poisoning detection (IG-58–IG-62) | M58 | ❌ No milestone exists |

**Impact**: Without M57 and M58 milestone documents, these deferred items have no tracking, no task breakdown, no estimated hours, and no entry in `progress.yaml`. They will be forgotten after M56 ships. This is the same pattern that caused the original feedback-007 to be "v1.0 with everything" — deferring without creating tracking is effectively cancelling.

**Fix**: Create M57 and M58 milestone stubs in `agent/milestones/` with:
- Goal, deferred items list, dependency on M56 completion
- `Status: planned`, priority, estimated weeks
- Entry in `progress.yaml`
- At minimum: what was deferred, why, what needs to happen before it can start

These do not need full route breakdowns now — but they need to exist so `/acp-status` and `/acp-proceed` can surface them.

---

### GAP-055-03 (MEDIUM) — Unbacked Deterministic Rules

The LLM/Script Boundary Rule states: "No deterministic task may be handled by LLM reasoning alone." However, 4 rules in v1.0 are deterministic but lack script backing:

| Rule | Description | Deterministic? | Script Assigned? |
|------|-------------|---------------|------------------|
| IG-04 | `eval()` of network-fetched content | ✅ Pattern match (`eval(` + `fetch`) | ❌ None |
| IG-18 | Hex/base64 decoded at runtime without comment | ✅ Pattern match (hex/base64 regex) | ❌ None |
| IG-19 | Minified blocks in human-authored source | ⚠️ Mixed — line length ratio heuristic | ❌ None |
| IG-20 | AI-directive language in comments | ✅ Grep for known phrases | ❌ None |

**Options**:
- **Option A**: Add these to existing scripts (IG-18 → `acp.entropy-scan.sh`, IG-20 → `acp.unicode-scan.sh` since it already does text scanning)
- **Option B**: Document them as "LLM-reasoned with `confidence: MEDIUM`" — accept the boundary rule exception with explicit justification
- **Option C**: Create a 7th script `acp.pattern-scan.sh` covering IG-04, IG-18, IG-19, IG-20

**Recommendation**: Option A for IG-18 and IG-20 (low effort, existing script scope expansion). Option B for IG-04 and IG-19 (genuinely mixed deterministic/semantic). Document the classification in the rule tables.

---

### GAP-055-04 (LOW) — Skill File Token Target Ambiguity

Route-146 says "≤500 tokens." Audit-054 says "≤500 tokens." But `agent/core/constraints.yml` Layer 2 budget allows up to 1,000 tokens for skill files. The 500-token target is aspirational and may be difficult to achieve with the required content (boundary rule paragraph + 6-script table + output spec + confidence rules).

**Fix**: Document the target as "≤500 tokens ideal, ≤800 tokens acceptable (within Layer 2 budget of 1,000)." If the skill file lands at 600–800 tokens, that's within constraints and should not block release.

---

### GAP-055-05 (LOW) — No E2E Test for Individual Scripts Before Integration

The build order says "scripts first, E2E tested independently." But there's no route for per-script unit tests. Route-149's E2E test runs after the command doc exists — meaning script bugs would only be caught at the final integration step.

**Fix**: Add a verification step to routes 143–145: "Each script must have a standalone smoke test in the route's verification section before proceeding to route-146." This doesn't require a separate E2E file — just ensures each route author runs `bash -n` + fixture test before marking the route complete.

---

## Inconsistencies

### INC-055-01 (LOW) — IG-61 Referenced But Deferred

The script-to-rule mapping in the milestone (§3) assigns IG-61 to `acp.unicode-scan.sh`. But IG-61 is in Category 10 (Memory Integrity) — which is deferred to M58. IG-61 is the rule "Any memory file containing hidden Unicode characters." The Unicode scanner can detect this, but the memory scanning context (Category 10) is not in v1.0.

**Resolution**: Keep IG-61 in the script mapping (it's a Unicode scan — the script works regardless). But clarify: "IG-61: Unicode detection in memory files is available in v1.0 via `acp.unicode-scan.sh` but the full memory integrity semantic analysis (IG-58–IG-62 context) is deferred to M58."

### INC-055-02 (LOW) — Route-145 Depends on Route-142 but Route-143/144 Don't

Route-145 (git-provenance.sh) correctly depends on route-142 (identity.yml team_members). But route-144 (network-whitelist-validate.sh) also needs route-142 (network_whitelist.yml) — yet route-144 lists no dependency.

**Fix**: Add `route-142` as dependency for route-144 in the milestone task table.

---

## What's NOT a Gap (Verified Correct)

| Item | Verification |
|------|-------------|
| 8 route files exist (142–149) | ✅ All present |
| Build order is correct | ✅ Scripts → wiki → skill → command doc → integration → E2E |
| LLM/Script Boundary Rule formalized | ✅ In milestone §3, route-146, route-147 |
| Remediation Playbook | ✅ In milestone §6, route-147 |
| False-positive baseline in E2E | ✅ In milestone §8, route-149 |
| Standards References with version pinning | ✅ In milestone §2.1, route-147 |
| `acp-rule-file-audit` alias (not separate command) | ✅ Route-148 — 3-line wrappers only |
| Open questions resolved | ✅ All 4 OQs answered in milestone §11 |
| Executor mapping (copilot = Composer 2.5) | ✅ Correct — ACP taxonomy uses `copilot` key |
| SLSA provenance paradox documented | ✅ In milestone Cat 5 warning, route-146 wiki |

---

## Recommendations

### Fix Before M56 Implementation

1. **Fix rule count**: Update "44 rules" to "55 rules" in milestone header, route-146, route-147
2. **Create M57 + M58 stubs**: Minimum viable milestone files — goal, deferred items, dependency on M56
3. **Resolve unbacked rules**: Assign IG-18/IG-20 to existing scripts; document IG-04/IG-19 as LLM-reasoned
4. **Fix route-144 dependency**: Add route-142 as dependency
5. **Clarify IG-61 status**: It's in v1.0 for Unicode scanning, but Category 10 context is deferred
6. **Clarify skill token target**: "≤500 ideal, ≤800 acceptable"

### After Fixes

M56 will be **READY for implementation** with zero blockers.

---

*Audit-055 | ACP Enhanced v6.11.0 | 2026-06-07*
