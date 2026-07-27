---
id: task-296
milestone: M83
title: "M83 closure — doc reconcile, review-002 amendment, ship v6.29.0"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: null
completed: null
phase: 6
depends_on: [task-280, task-281, task-282, task-283, task-284, task-285, task-286, task-287, task-288, task-289, task-290, task-291, task-292, task-293, task-294, task-295]
audit_findings: [F-102-04, F-102-06]
files_affected:
  - agent/commands/acp.review.md
  - agent/reports/review-002-local-thorough-campaign.md
  - agent/memory/audit-carryovers.md
  - agent/progress.yaml
  - CHANGELOG.md
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - agent/core/identity.yml
  - package.yaml
  - README.md
---

## Objective

Reconcile the documentation with what actually shipped, amend the M82 review report, settle all 18 carryovers, and release v6.29.0.

## Context

**F-102-04 (MEDIUM):** `acp.review.md:41,56` claims 56 rules "cannot be scripted". After Phase 3 the real split is roughly 38 deterministic / 26 semantic, and YM-03 + ACP-02 were always automated in `acp-validate.ts`.

**F-102-06 (LOW):** rule ownership between `/acp-validate` and `/acp-review` is undocumented, causing the double-count above. Task-294 resolves the A08 half; this task documents the rest.

**review-002 amendment:** its Phase 1 row records "1 HIGH — false positive" as if the scan were complete. It was produced by an ≈8%-recall scanner over half the intended scope (F-102-01). The report must be **annotated, not rewritten** — the campaign happened and its other findings stand.

## Steps

1. Update `acp.review.md`: corrected Phase 1/Phase 2 counts, the measured precision/recall table from task-284, and a rule-ownership section covering `/acp-validate` vs `/acp-review` vs `/acp-integrity`.
2. Amend `review-002-local-thorough-campaign.md` with a dated note: Phase 1 was run with a scanner later measured at ≈8% recall over half the intended scope; point to audit-102/103 and this milestone.
3. Re-run the full local review with the fixed scanner; record the new result as review-003.
4. Settle all 18 carryovers (F-102-01…08, F-103-01…10) to `status: fixed` with `fix_applied_date` and `verified_in_audit` — **each requires a regression fixture** (binding shortcut #4).
5. Confirm F-101-02/03/05/06 remain `pending` under M81 — they are CodeRabbit-fixture-blocked and out of scope.
6. Version bump to **6.29.0** across the full file set: `identity.yml`, `progress.yaml`, `package.yaml`, `AGENTS.md`/`CLAUDE.md`/`copilot-instructions.md` (hash-identical), `README.md` badge, `CHANGELOG.md`.
7. Run `npx tsx scripts/acp-validate.ts --memory` and the full E2E suite; both must be clean.
8. Update `agent/wiki/domain.yml` for new scripts and E2E suites.

## Verification

- [ ] No claim in `acp.review.md` is unsupported by a measurement
- [ ] review-002 annotated, not rewritten; review-003 published
- [ ] All 18 M83 carryovers `fixed`, each with a regression fixture
- [ ] F-101-* still `pending` under M81
- [ ] Version consistent across all 8+ version-bearing files
- [ ] Instruction files SHA-256 identical
- [ ] `acp-validate --memory` clean; full E2E green
- [ ] Milestone doc status and progress.yaml agree (cross-layer check)

## User-Observable Acceptance

v6.29.0 ships a `/acp-review` whose documented capability matches measured behaviour, with every audit-102/103 finding closed and verified.
