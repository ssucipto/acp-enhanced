---
id: task-268
milestone: M80
title: "M80 closure — full suite, ship v6.28.2, close carryovers"
status: completed
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-24
started: null
completed: null
route: route-257
audit_findings: [F-M78-01]
depends_on: [task-265, task-266]
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Close M80 honestly: confirm the full E2E suite failure count dropped (assertion-level), ship v6.28.2, and settle the F-M78-01 carryover per its real outcome. (F-086-02 already fixed — developer-confirmed 2026-07-24.)

## Steps

1. Run the full suite `bash run-e2e-tests.sh --skip-network`; record file-level pass/fail. Also confirm assertion-level: no test was greened by weakening an assertion (spot-check touched tests).
2. Confirm failure count strictly decreased vs the M79 baseline (7 F-M78-01 failures) with ZERO new failures (audit-099 lesson: compare assertion-level, not only file-level).
3. `npx tsx scripts/acp-validate.ts` (exit 0), `npx vitest run` (green).
4. Bump version 6.28.1 → 6.28.2 across all 9 stamped files + `agent/progress.yaml project.version`; CHANGELOG entry; regenerate integrity manifest; git tag v6.28.2.
5. **Carryover settlement**: F-M78-01 → `fixed` if all 7 resolved; else `fixed` for resolved subset with a documented remainder (list the irreducible items + rationale), do NOT overstate. (F-086-02 already fixed — developer-confirmed 2026-07-24.)
6. Set M80 `completed`; update `current_milestone`, `recent_work`, `next_steps`.

## Verification

- [ ] Full-suite failures < 7; no new failures (assertion-level confirmed)
- [ ] `acp-validate` exit 0 (incl. progress.yaml version check); vitest green
- [ ] v6.28.2 stamped across 9 files + progress.yaml; git tag v6.28.2
- [ ] F-M78-01 settled truthfully (fixed or fixed-with-remainder)
- [ ] M80 milestone completed; carryovers schema valid

## User-Observable Acceptance

v6.28.2 ships with a materially cleaner E2E suite; the carryover ledger reflects exactly what was proven, with any remaining debt named and justified rather than hidden.
