---
id: task-210
milestone: M68
title: Release v6.24.0 + audit-080 closure (route-205)
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-205
---

## Objective

Ship M68; close audit-080 carryovers; unblock FIFOZ.

## Steps

1. CHANGELOG v6.24.0 — safe install/update policy summary
2. Bump identity.yml → 6.24.0; triple-sync AGENTS/CLAUDE/copilot
3. Mark M68 milestone gates ✅; progress.yaml M68 completed
4. audit-carryovers F-080-01..11 → fixed, verified_in_audit 081
5. Git tag v6.24.0

## Verification

- [ ] All M68 gates checked
- [ ] `npx tsx scripts/acp-validate.ts` — 0 errors
- [ ] E2E preserve suites green

## User-Observable Acceptance

FIFOZ can run `/acp-version-update` on v6.24.0 without losing identity.yml.
