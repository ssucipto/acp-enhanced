# Milestone 83: Deterministic Local Review Engine (`/acp-review` correctness, precision, and expansion)

<!-- @acp.meta.milestone
topic: acp-review, deterministic, phase1, precision, recall, lexing, shellcheck, dupehound, gitleaks, owasp, carryovers
description: Fix /acp-review scanner correctness and precision, measure it, then expand the deterministic ruleset and adopt optional local analyzers
 status: completed
updated: 2026-07-27
@acp.meta.end -->

**Planned version**: v6.29.0
**Status**: completed (17/17)
**Estimated effort**: ~45h (17 tasks, 6 phases)
**Source**: audit-102 (scope + expansion), audit-103 (precision + standards), maintainer discussion 2026-07-27
**Depends on**: nothing — explicitly **not** blocked by M81's ADR-22 CodeRabbit fixture gate
**Closes**: 18 carryovers — F-102-01…08, F-103-01…10

---

## Why this milestone exists

M82 established the operational fact: **CodeRabbit rate-limited after 2 of 4 CLI chunks** (F-M82-06), so the local deterministic layer is the primary review path, not a fallback.

audit-102 then found the scanner silently drops all but the last path argument, so the documented self-review recipe had only ever scanned half its intended scope. audit-103 went further and measured the eight shipped rules against seeded fixtures:

| Metric | Measured |
|--------|----------|
| Recall (13 seeded defects) | **1 detected — ≈8%** |
| Precision (clean fixture) | **0% — 2 findings, both on a comment and a string literal** |

Both industry failure modes are present at once: *"False positives above 30% destroy credibility"* and *"coverage gaps"*. The scanner has never had an executing test — `e2e/acp.review.test.sh` asserts documentation strings only, which is why every defect survived undetected since 2026-07-15.

## Binding sequencing rule

> **Phase 3 (rule expansion) MUST NOT start until Phases 1b and 1c are complete.**

audit-102 originally recommended adding ~30 rules immediately. audit-103 corrected this: adding rules onto an unlexed engine multiplies the false-positive rate roughly fourfold. **Fix the foundation, measure it, then expand.** This rule is the milestone's single most important constraint.

## Goal

Take `/acp-review` from *8 rules of unmeasured quality* to *a measured, lexed, expandable deterministic engine* with ~38 rules, industry-standard false-positive controls, and optional local analyzers for the two areas we should not hand-roll (duplicate detection, secrets).

---

## Phases

| Phase | Theme | Tasks | Gate |
|-------|-------|-------|------|
| **1** | Scanner correctness | 280, 281 | none — start here |
| **1b** | Precision foundation | 282, 283 | **blocks Phase 3** |
| **1c** | Measurement | 284 | **blocks Phase 3** |
| **2** | Free coverage (shellcheck) | 285 | independent |
| **3** | Ruleset expansion | 286, 287, 288, 289 | **gated on 1b + 1c** |
| **3b** | Secrets strategy | 290 | after 284 |
| **4** | dupehound / CH-05 | 291, 292, 293 | 291 gates 292/293 |
| **5** | Standards + FP controls | 294, 295 | independent |
| **6** | Closure | 296 | last |

---

## Deliverables

- Scanner that scans every path given, supports `--self`, and covers `.mjs`/`.cjs`
- Comment/string-aware matching; token-boundary tests replacing substring checks
- A fixture corpus with **published recall and precision numbers**, re-measured in CI
- `shellcheck` delegation for SH-03
- ~30 additional Tier C deterministic rules (8 → ~38)
- Secrets strategy that does not hand-roll regexes
- `acp.dupehound.sh` — three-gate optional helper, three-valued preference, assisted installer
- ADR-23 covering three decisions: local-analyzer carve-out, detection-as-consent variant, assisted-install boundary
- Corrected OWASP Top 10:2025 mappings + explicit A06/A07/A08 position
- Baseline mode, inline suppression, per-rule thresholds

## Explicit non-goals

- **No hand-rolled secret regex expansion** — delegate or reuse; 4 regexes will not approach gitleaks' ~200
- **No binary downloads by ACP** — assisted install delegates to brew/cargo only
- **No Rust toolchain installation** on the user's behalf
- **No rule-count claims without measured recall**
- **No CodeRabbit work** — M81 remains gated under ADR-22

---

## Shortcuts this milestone explicitly refuses

Carried from audit-103 Part 4, these are binding on implementation:

1. Do not add rules onto the unlexed foundation (Phase 3 gate above)
2. Do not hand-roll secret detection — delegate or reuse `entropy-scan.sh`
3. Do not publish rule counts without measured recall alongside
4. Do not mark a carryover fixed without a regression fixture proving it
5. Do not accept a doc-assertion-only test as coverage for a scanner rule

## Success criteria

- [x] Multi-path, `--self`, and `.mjs`/`.cjs` all verified by executing E2E
- [x] Recall ≥ 90% and precision ≥ 90% on the fixture corpus, published in `acp.review.md`
- [x] All 18 M83 carryovers `status: fixed` with a regression fixture each
- [x] Deterministic rule count ≥ 35, each with a corpus entry
- [x] `/acp-review` behaviour identical when dupehound and gitleaks are absent
- [x] ADR-23 accepted; `local.optional-external-tool.md` documents the variant
- [x] `npx tsx scripts/acp-validate.ts --memory` clean; full E2E suite green
- [x] review-002 amended to note the ~8%-recall / half-scope caveat
- [x] v6.29.0 shipped across the full version file set

---

## References

- [audit-102](../reports/audit-102-deterministic-review-engine.md) — scope bugs, Tier C inventory, dupehound assessment
- [audit-103](../reports/audit-103-review-precision-and-standards.md) — measured precision/recall, OWASP conformance, shortcuts
- [review-002](../reports/review-002-local-thorough-campaign.md) — M82 campaign; needs amendment (task-296)
- [local.optional-external-tool.md](../patterns/local.optional-external-tool.md) — 3-gate contract; amended by task-291
- ADR-19 / ADR-21 / ADR-22 — external-tool gates; ADR-23 carves out local analyzers
