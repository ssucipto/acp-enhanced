---
id: route-195
title: E2E handoff/receive fixtures + behavioral tests
task_type: testing
milestone: M67
complexity: medium
executor: copilot
context_required:
  - design/cross-agent-handoff-protocol.md
  - benchmarks/fixtures/handoff/
files_affected:
  - e2e/acp.handoff.test.sh
  - e2e/acp.receive.test.sh
  - agent/benchmarks/fixtures/handoff/executor-m51-anonymized.md
  - agent/benchmarks/fixtures/handoff/drift-wrong-sha.md
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Behavioral E2E for handoff v2 and receive — anonymized M51 exemplar fixture, git drift fixture. Addresses F-070-03 class (no grep-only E2E).

## Acceptance criteria

- [ ] ≥10 assertions per suite
- [ ] Drift fixture produces DRIFT warning when receive steps run
- [ ] Fixtures under agent/benchmarks/fixtures/handoff/

## Depends on

route-191

## Addresses

audit-245 S3; audit-077 quality gate; task-200
