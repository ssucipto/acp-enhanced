---
id: task-261
milestone: M79
title: "M78 version regression fix + carryover ledger closure + doc reconcile"
status: completed
priority: 5
complexity: low
estimated_hours: 1.5
created: 2026-07-23
started: 2026-07-23
completed: 2026-07-23
route: route-250
audit_findings: [F-099-01, F-099-03, F-099-04, F-099-06]
depends_on: []
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Fix the four M78 closure-integrity findings that are metadata/doc corrections: the version regression, the unclosed carryovers, the stale milestone reference, and the task-259 pointer mismatch.

## Context

audit-099: the v6.28.0 bump missed `agent/progress.yaml:6 version:`, caught by cross-file E2E checks but not acp-validate.ts. And F-098-01..07 + F-097-01 were implemented in M78 but never marked fixed (carryover-integrity failure, audit-094 lesson).

## Steps

1. **F-099-01** — In `agent/progress.yaml`: set `project.version` (line 6) `6.27.2 → 6.28.0`; update the description (line 11) `v6.27.2; M73 complete` → `v6.28.0; M78 complete`. Do NOT touch historical `recent_work` entries dated 2026-07-17 (those correctly cite 6.27.2).
2. **F-099-03** — In `agent/memory/audit-carryovers.md`, set `status: fixed`, `fix_applied_date: 2026-07-23`, `verified_in_audit: audit-099` on F-097-01 and F-098-01, F-098-02, F-098-03, F-098-04, F-098-05, F-098-06, F-098-07 — after re-confirming each is actually implemented (spot-check the shipped artifact).
3. **F-099-04** — In `agent/milestones/milestone-78-*.md`: Build Order table row for task-256 `acp.common.sh` → `acp.coderabbit.sh`; Depends-on line reference likewise.
4. **F-099-06** — In `task-259-*.md`, change verification line "AGENTS.md pointer added…" → "README.md pointer added (AGENTS.md byte budget favors the lean pointer)".
5. Re-run `tests/acp.e2e-workflow.test.sh` and `tests/acp.security.test.sh`; confirm the version-mismatch assertions now pass (assertion-level, not just file count).

## Verification

- [ ] `grep "^  version:" agent/progress.yaml` → `6.28.0`
- [ ] `tests/acp.e2e-workflow.test.sh` version cross-file assertion passes; `tests/acp.security.test.sh` version-match assertion passes
- [ ] F-098-01..07 + F-097-01 all `status: fixed` + `verified_in_audit: audit-099`; carryovers schema valid
- [ ] milestone-78 Build Order + Depends-on say `acp.coderabbit.sh`
- [ ] task-259 verification line references README pointer
- [ ] Historical recent_work 6.27.2 entries untouched

## User-Observable Acceptance

`agent/progress.yaml` reports v6.28.0 consistently with identity.yml; the carryover ledger honestly shows M78's findings as fixed; the cross-file version E2E checks no longer flag a mismatch.
