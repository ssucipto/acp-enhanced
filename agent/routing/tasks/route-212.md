---
id: route-212
title: "Carryover freshness validator"
task_type: milestone-delivery
milestone: M70
complexity: medium
executor: copilot
context_required:
  - agent/design/m70-tech-debt-gate-hardening.md
  - agent/milestones/milestone-70-tech-debt-gate-hardening.md
files_affected:
  - scripts/acp-validate.ts
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

M70 route: Carryover freshness validator. Addresses F-086-04.

## Tasks

task-223

## Acceptance Criteria

- [ ] Carryover(s) F-086-04 stamped fixed
- [ ] /acp-validate 0 errors
- [ ] E2E suites green for touched areas

