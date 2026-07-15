---
id: route-216
title: "Commit sync atomicity"
task_type: milestone-delivery
milestone: M70
complexity: medium
executor: copilot
context_required:
  - agent/design/m70-tech-debt-gate-hardening.md
  - agent/milestones/milestone-70-tech-debt-gate-hardening.md
files_affected:
  - agent/scripts/acp.atomic-write.sh
  - agent/commands/acp.pattern-sync.md
  - agent/commands/acp.session-sync.md
  - agent/commands/acp.commit.md
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

M70 route: Commit sync atomicity. Addresses GAP-041-08.

## Tasks

task-227

## Acceptance Criteria

- [ ] Carryover(s) GAP-041-08 stamped fixed
- [ ] /acp-validate 0 errors
- [ ] E2E suites green for touched areas

