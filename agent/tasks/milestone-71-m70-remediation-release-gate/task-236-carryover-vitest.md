---
id: task-236
milestone: M71
title: "validateCarryoverFreshness vitest fixture"
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-225
audit_findings: [F-086-04]
depends_on: [task-233]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Harden F-086-04 with behavioral vitest — stale pending carryover triggers warning.

## Steps

1. Add `scripts/fixtures/carryovers-stale.yaml` test fixture
2. Vitest: `validateCarryoverFreshness()` warns on fixture pending entry with matching fix_target file
3. Document 30-day re-verify workflow in `acp.validate.md`

## Verification

- [ ] vitest includes carryover freshness test
- [ ] F-086-04 verified_in_audit: audit-090

## User-Observable Acceptance

`cd scripts && npm test` includes passing carryover freshness behavioral test.
