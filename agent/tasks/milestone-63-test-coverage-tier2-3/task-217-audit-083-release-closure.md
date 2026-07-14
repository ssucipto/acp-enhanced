---
id: task-217
milestone: M63
title: "audit-083 release closure — report, carryovers, v6.25.1"
status: completed
priority: 4
complexity: low
estimated_hours: 1
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-207
audit_findings: [F-083-01..06]
depends_on: [task-212, task-213, task-214, task-215, task-216]
---

## Objective

Formalize audit-083 closure: report, carryover stamps, version bump v6.25.1.

## Steps

1. Write `agent/reports/audit-083-m63-implementation-gaps.md`
2. Append F-083-01..04, F-083-06 to `audit-carryovers.md` as `fixed` @ 083
3. CHANGELOG v6.25.1 entry
4. Bump identity.yml, AGENTS.md, CLAUDE.md → 6.25.1
5. Git tag `v6.25.1` (after commit)

## Verification

- [x] audit-083 report exists with verdict ALL GAPS CLOSED
- [x] Carryovers stamped `verified_in_audit: 083`
- [x] `npx tsx scripts/acp-validate.ts` — 0 errors
- [x] Git tag `v6.25.1` on release commit `a84b00a`

## User-Observable Acceptance

Consumers on v6.25.1 have defensible tier 2/3 behavioral coverage, not registry-only credit.
