---
id: route-207
title: M63 audit-083 remediation — tier3 loop, vitest, tracking closure
task_type: testing
milestone: M63
complexity: medium
executor: copilot
context_required:
  - agent/reports/audit-083-m63-implementation-gaps.md
  - e2e/acp.tier3-memory-knowledge.test.sh
  - scripts/acp-validate.ts
files_affected:
  - e2e/acp.tier3-memory-knowledge.test.sh
  - e2e/acp.tier2-workflow.test.sh
  - scripts/acp-validate.ts
  - scripts/acp-validate.test.ts
  - scripts/fixtures/command-e2e-coverage-gap.yaml
  - agent/milestones/milestone-63-test-coverage-tier2-3.md
  - agent/tasks/milestone-63-test-coverage-tier2-3/task-*.md
  - agent/memory/audit-carryovers.md
  - CHANGELOG.md
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Close all audit-083 findings (F-083-01..06, SC-M63-01..05) after M63 v6.25.0 ship. Ship v6.25.1 patch.

## Acceptance criteria

- [x] Tier3 E2E dynamic loop — 58 commands, meta-assertion
- [x] Vitest `validateCommandE2eCoverage` — 3 cases + fixture
- [x] Case-insensitive Agent Directive in tier2/tier3
- [x] Milestone + task tracking reconciled
- [x] audit-083 report + carryovers closed
- [x] CHANGELOG v6.25.1

## Tasks

| Task | Finding | Status |
|------|---------|--------|
| task-212 | F-083-01 SC-M63-01 | completed |
| task-213 | F-083-04 SC-M63-04 | completed |
| task-214 | F-083-06 SC-M63-05 | completed |
| task-215 | F-083-02 SC-M63-02 | completed |
| task-216 | F-083-03 SC-M63-03 | completed |
| task-217 | audit-083 release | completed |
| task-218 | preventive meta-assertion | completed |
