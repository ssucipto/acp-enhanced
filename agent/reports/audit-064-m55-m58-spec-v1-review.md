# Audit Report: design-spec-m55-m58-command-ecosystem-v1.0 — Deep Audit

**Audit**: #064
**Date**: 2026-06-09
**Subject**: design-spec-m55-m58-command-ecosystem-v1.0.md — gaps, inconsistencies, and accuracy cross-check

---

## Summary

V1.0 is structurally well-organized with clear architecture diagrams and data flows. However, cross-referencing against the actual milestone docs, route files, and live codebase reveals **14 findings** — 3 CRITICAL numerical errors (rule counts don't match reality), 4 missing traceability layers, 4 missing metadata, and 3 categorization errors. The most impactful: the M55 rule count is off by 23 (54 claimed, 77 actual), and the M56 category subtotals don't sum to the claimed total.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/reports/design-spec-m55-m58-command-ecosystem-v1.0.md` | audit subject | Full spec under review |
| `agent/commands/acp.review.md` | source-of-truth | Actual rule count (77, not 54) |
| `agent/wiki/integrity-rules.md` | source-of-truth | Full 70-rule catalogue |
| `agent/milestones/milestone-55-acp-review-command.md` | source-of-truth | M55 plan — 11 routes, 6 gaps |
| `agent/milestones/milestone-56-acp-integrity-command.md` | source-of-truth | M56 plan — 8 routes, 55 rules |
| `agent/milestones/milestone-57-recurring-tasks-scheduler.md` | source-of-truth | M57 plan — 3 components |
| `agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md` | source-of-truth | M58 plan — 4 routes |
| `agent/routing/tasks/route-131.md` through `route-158.md` | source-of-truth | 28 route files |
| `agent/progress.yaml` | source-of-truth | M54 status, recurring_tasks actual data |
| `agent/reports/audit-062-m57-implementation-deep-dive.md` | source-of-truth | M57 known gaps |

## Key Findings

### Finding 1 — CRITICAL: §4.3 M55 rule count is 77, not 54

**Report says**: "54 Rules in 7 Categories"
**Actual**: `acp.review.md` contains 77 rules (grep -cE "^\| (EH|SC|TS|CS|PF|DP|SH|YM|AP|NC)-[0-9]+")

**Impact**: Undercounts the review ruleset by 23 rules (30% error). The milestone plan originally specified 54 rules, but the implemented command doc has 77. The spec inherited the plan number, not the actual delivered count.

**Fix**: Update to 77 rules. Recalculate category subtotals from actual acp.review.md.

### Finding 2 — CRITICAL: §4.3 category subtotals sum to 59, not 54 (or 77)

**Report says**: 10+10+10+8+6+5+10 = 54
**Actual math**: 10+10+10+8+6+5+10 = 59

**Impact**: Internal inconsistency. Even using the wrong total (54), the subtotals don't add up.

**Fix**: Recount actual category subtotals from acp.review.md.

### Finding 3 — CRITICAL: §5.3 M56 category subtotals sum to 51, not 55

**Report says**: "55 Rules in 11 Categories"
**Actual math**: 6+7+6+4+6+5+1+3+4+2+7 = 51

**Impact**: 4 rules unaccounted for (7% error). Categories 8-10 (prompt injection + memory) may have additional v1.0 rules beyond what the report lists.

**Fix**: Verify against integrity-rules.md for exact counts per category.

### Finding 4 — HIGH: Missing route-level traceability

**Report**: No listing of individual routes per milestone.
**Missing**: 
- M55: Routes 131-141 (11 routes) — not listed
- M56: Routes 142-149 (8 routes) — not listed, only build order diagram
- M57: Routes 150-154 (5 routes) — not listed
- M58: Routes 155-158 (4 routes) — not listed

**Impact**: Cannot trace a design decision to its implementing route. Without route IDs, audit findings can't reference specific implementation units.

**Fix**: Add route inventory tables per milestone.

### Finding 5 — HIGH: Missing audit trail

**Report**: No mention of the 6+ audits conducted across M55-M58.
**Missing**:
- audit-050 (M55 scope correction)
- audit-051 (M55 readiness — 13 findings)
- audit-052 (M55 post-implementation — 8 findings)
- audit-053 (M56 suitability analysis)
- audit-054 (M56 second-round consolidated)
- audit-055 (M56 pre-impl gap — 6 fixes)
- audit-056/057/058 (M56 post-impl — 13 bugs/gaps)
- audit-059/060/061 (M57 cross-milestone + pre/post)
- audit-062 (M57 deep dive vs industry standards)

**Impact**: Without audit references, a reader cannot verify that the design was independently reviewed or find detailed gap analyses.

### Finding 6 — HIGH: Missing feedback sources

**Report**: No mention of feedback-006 (source of M55), feedback-007 (source of M56/M57/M58).
**Missing**: These are the external stakeholders whose requirements drove the entire M55-M58 spine.

**Impact**: Violates ISO 42010 stakeholder viewpoint tracking. Without feedback traceability, a stakeholder cannot verify their requirements were met.

### Finding 7 — HIGH: M55 spec merge decision not documented

**Report**: §4.1 mentions "Route 133 (spec file) was merged into acp.review.md" but doesn't:
- Name the decision (ADR-CMD-SPEC is listed in §11 but not explained)
- Explain that this was an audit-052 decision
- List what was lost/gained by merging

**Impact**: This is one of the most important architectural decisions in M55 and deserves more than one sentence.

### Finding 8 — MEDIUM: §8.1 executor mapping oversimplified

**Report says**: /acp-integrity executor = "copilot (M55)" — but M56 uses deepseek-v4-pro for 6 deterministic scripts and copilot only for the skill file.
**Actual**: The integrity command has multiple executors depending on the rule category:
- Scripts: deepseek-v4-pro (deterministic)
- LLM pattern rules: copilot (interpretation)
- Deep scan (M58): claude-sonnet (semantic)

### Finding 9 — MEDIUM: Missing M54 dependency documentation

**Report**: §8.4 shows v6.10.1 (M54 CI/CD) in the version chain but doesn't explain that M54 is incomplete (30% progress, active status). M55-M58 all depend on the CI/CD pipeline for E2E execution.
**Missing**: M54's status as a dependency risk — if CI is broken, all E2E suites are unverifiable.

### Finding 10 — MEDIUM: Missing M57 carryover references

**Report**: §6 (M57) doesn't reference audit-062 findings (5 carryovers: F-062-01 through F-062-05). These are known gaps in the M57 implementation.
**Missing**: Should include a "known gaps" subsection for M57 referencing audit-062.

### Finding 11 — LOW: §5.4 component inventory incomplete

**Report**: Lists 7 M56 components.
**Actual**: The M56 milestone doc lists 20 deliverables including wrapper files, aliases, taxonomy updates, routing updates, and package.yaml entry.
**Missing**: Prompt wrappers, opencode wrappers, alias wrappers, taxonomy/routing/package entries.

### Finding 12 — LOW: §6.4 data flow uses idealized tiered rendering

**Report**: Shows 4 tiers (⏰ OVERDUE, ⚠️ DUE TODAY, 📅 UPCOMING, silent).
**Actual**: Step 4.5 only checks `status: overdue` and `next_due <= today`. The tiered rendering (DUE TODAY, UPCOMING) is planned for M59 (audit-062 F-062-07) but not yet implemented. The spec presents it as current.

### Finding 13 — LOW: Missing language detection scope note for M55

**Report**: §4.1 says "TypeScript/React/React Native/Expo/Node.js" as the audience.
**Actual**: The milestone doc's G-002 notes that Python, Go, Rust projects get zero relevant rules. The command doc has a "Language Scope" section documenting this as a known limitation.
**Missing**: This limitation should be noted in the spec for honest capability documentation.

### Finding 14 — LOW: §9 E2E assertion count incomplete

**Report**: "Core total (M55-M57) = 91"
**Actual**: 49 + 26 + 16 = 91. Correct mathematically, but the report doesn't note that these are the empirically verified counts (not planned/estimated). Should state "verified 2026-06-09".

## Code Pointers

| Location | Issue |
|----------|-------|
| `design-spec-...v1.0.md:104` | M55 rules claim 54, actual 77 |
| `design-spec-...v1.0.md:110` | Category math 10+10+10+8+6+5+10=59≠54 |
| `design-spec-...v1.0.md:218` | M56 category math 6+7+6+4+6+5+1+3+4+2+7=51≠55 |
| `design-spec-...v1.0.md:445` | Executor mapping "copilot (M55)" for integrity |
| `design-spec-...v1.0.md:48` | No route tables per milestone |
| `design-spec-...v1.0.md:48` | No audit trail references |
| `design-spec-...v1.0.md:27` | No feedback source references |
| `acp.review.md:78-250` | Actual 77 rules, not 54 |
| `integrity-rules.md:1-70` | 70 total rules, 55 v1.0 |

## Recommendations

### P0 — Fix before publishing v2.0

1. **Finding 1**: Count actual rules from acp.review.md (77) and update §4.3 header + category subtotals
2. **Finding 2**: Recalculate category subtotals to actual counts
3. **Finding 3**: Verify M56 category counts against integrity-rules.md

### P1 — Essential for completeness

4. **Finding 4**: Add route inventory tables per milestone
5. **Finding 5**: Add audit trail section
6. **Finding 6**: Add feedback sources section
7. **Finding 7**: Expand the command-doc-as-spec ADR

### P2 — Accuracy improvements

8. **Finding 8**: Fix executor mapping table
9. **Finding 9**: Document M54 dependency risk
10. **Finding 10**: Add M57 known gaps from audit-062
11. **Finding 11**: Complete M56 component inventory
12. **Finding 12**: Note tiered rendering as planned (M59), not current
13. **Finding 13**: Add language scope limitation note
14. **Finding 14**: Add verification date to assertion count

## Phase Summary

| Category | Findings | Highest Severity |
|----------|----------|-----------------|
| Numerical Errors | 3 (F1, F2, F3) | CRITICAL |
| Missing Traceability | 4 (F4, F5, F6, F7) | HIGH |
| Missing Metadata | 4 (F9, F10, F11, F14) | MEDIUM |
| Categorization | 3 (F8, F12, F13) | MEDIUM |
| **Total** | **14** | **CRITICAL** |

## Readiness Verdict

**UPDATE REQUIRED** — 3 CRITICAL numerical errors make v1.0 unreliable as an authoritative specification. The M55 rule count (77 actual vs 54 claimed) and the M56 category subtotal mismatch (51 vs 55) are factual errors that undermine the entire §4-§5 ruleset documentation. A v2.0 with verified counts, route traceability, and audit/feedback provenance is essential before this spec can be considered production-quality.

---

*Audit-064 | 2026-06-09 | Deep audit of design-spec-m55-m58-command-ecosystem-v1.0.md*
