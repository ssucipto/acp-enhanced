---
id: route-206
title: M63 — E2E tier 2/3 coverage + command↔test parity guard
task_type: testing
milestone: M63
complexity: medium
executor: copilot
context_required:
  - agent/schemas/command-e2e-coverage.yaml
  - scripts/acp-validate.ts
files_affected:
  - agent/schemas/command-e2e-coverage.yaml
  - scripts/acp-validate.ts
  - scripts/acp-validate.test.ts
  - e2e/acp.tier2-workflow.test.sh
  - e2e/acp.tier3-memory-knowledge.test.sh
  - e2e/acp.command-coverage-parity.test.sh
tokens_est: 12000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Close M63: 0 untested commands via coverage registry + CI validate guard + tier 2/3 behavioral E2E suites.

## Acceptance criteria

- [x] `agent/schemas/command-e2e-coverage.yaml` — all 70 `acp.*` commands mapped
- [x] `validateCommandE2eCoverage()` in acp-validate.ts — fails on unmapped command
- [x] `e2e/acp.tier2-workflow.test.sh` — tier 2 package/project/version/prefs
- [x] `e2e/acp.tier3-memory-knowledge.test.sh` — tier 3 memory/knowledge workflow
- [x] `e2e/acp.command-coverage-parity.test.sh` — registry completeness
- [x] Vitest: validateInstallUpdateSafety regression; full parity via `e2e/acp.command-coverage-parity.test.sh`
