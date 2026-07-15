---
id: task-235
milestone: M71
title: "Route files_affected hygiene + review benchmark fixtures"
status: completed
priority: 4
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-224
audit_findings: [F-089-07, F-089-08]
depends_on: [task-231]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Populate `files_affected` on M70 routes 208–219 and M71 routes 220–228; add persistent review fixtures.

## Steps

1. Populate `files_affected` on route-208..219 from actual M70 deliverables
2. Populate route-220..228 for M71 tasks
3. Create `agent/benchmarks/fixtures/review/` with pass/fail fixtures per Phase 1 rule
4. Reference fixtures from `e2e/acp.review.test.sh` (optional migrate from mktemp)

## Verification

- [ ] No M70/M71 route has empty `files_affected: []`
- [ ] Fixtures dir exists with ≥4 files
- [ ] F-089-07, F-089-08 carryovers fixed

## User-Observable Acceptance

Pre-impl audit `files_affected` check passes for M70/M71 routes.
