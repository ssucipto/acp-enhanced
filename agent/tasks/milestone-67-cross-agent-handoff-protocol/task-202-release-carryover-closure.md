---
id: task-202
milestone: M67
title: Release v6.23.0 + carryover closure (route-197)
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-197
---

## Objective

Milestone exit: CHANGELOG, version bump, close audit-077 carryovers, verify feedback-007 acceptance criteria.

## Steps

1. CHANGELOG v6.23.0 entry — M67 summary, breaking: none (cross-repo default preserved)
2. Bump `agent/core/identity.yml` version
3. Update `audit-carryovers.md`: H1–H10, U1–U3 → `status: fixed`, `verified_in_audit: 078` (or next)
4. Check feedback-007 §6 checklist; note FIFOZ consumer update path
5. Run full validate + e2e handoff suites
6. Stamp routes 190–197 `completed:` in routing task files
7. M67 milestone doc → completed; progress.yaml M67 status

## Verification

- [ ] CHANGELOG at top (chronological)
- [ ] All audit-077 carryovers fixed or verified
- [ ] feedback-007 §6 all boxes pass
- [ ] `npx tsx scripts/acp-validate.ts` exit 0

## Depends on

task-195 through task-201 (194 optional for v6.23.0 if timeboxed — document deferral)
