---
id: task-211
milestone: M63
title: "Phase 1: E2E tier 2/3 coverage + command↔test parity guard (route-206)"
status: completed
priority: 5
complexity: medium
estimated_hours: 12
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-206
audit_findings: []
depends_on: []
---

## Objective

Ship M63 Phase 1 (v6.25.0): 0 untested `acp.*` commands via registry + CI validate guard + tier 2/parity E2E.

## Steps

1. Create `agent/schemas/command-e2e-coverage.yaml` — map all 70 commands
2. Add `validateCommandE2eCoverage()` to `acp-validate.ts`
3. Add `e2e/acp.tier2-workflow.test.sh` — tier 2 package/project/version/prefs
4. Add `e2e/acp.tier3-memory-knowledge.test.sh` — initial tier 3 subset (superseded by task-212)
5. Add `e2e/acp.command-coverage-parity.test.sh` — registry completeness
6. Release v6.25.0 + tag

## Verification

- [x] Registry maps 70 commands
- [x] `npx tsx scripts/acp-validate.ts` — 0 errors, 0 untested
- [x] Tier2 + parity E2E green
- [x] Git tag v6.25.0

## User-Observable Acceptance

CI fails if a new `acp.*.md` command is added without an E2E registry entry.

## Notes

Post-ship audit-083 found tier3 static subset shortcut — remediated in route-207 (tasks 212–218).
