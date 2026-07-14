---
id: task-200
milestone: M67
title: E2E fixtures + behavioral handoff/receive tests (route-195)
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed: 2026-07-15
route: route-195
---

## Objective

Create `e2e/acp.handoff.test.sh` and `e2e/acp.receive.test.sh` with **behavioral** fixtures — not grep-only structural tests.

## Context

Closes audit pattern from F-070-03 (E2E that doesn't exercise logic). Uses M51 exemplar structure anonymized.

## Steps

1. Create `agent/benchmarks/fixtures/handoff/executor-m51-anonymized.md` — valid executor handoff with known git pin
2. Create `agent/benchmarks/fixtures/handoff/drift-wrong-sha.md` — pin ≠ HEAD for receive test
3. `e2e/acp.handoff.test.sh`: assert all §4 headers present in fixture; mode flags documented
4. `e2e/acp.receive.test.sh`: run receive steps against drift fixture; assert DRIFT in output
5. Resume integration smoke: handoff path documented in resume command
6. Wire into `run-e2e-tests.sh` if not auto-discovered

## Verification

- [ ] ≥10 assertions per suite
- [ ] Drift fixture triggers warning (behavioral)
- [ ] No hardcoded absolute paths
- [ ] Fixtures committed under benchmarks/

## Depends on

task-196
