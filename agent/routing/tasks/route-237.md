---
id: route-237
title: "Carryover integrity restore + verified_in_audit guard"
task_type: data-integrity
milestone: M73
complexity: medium
executor: copilot
files_affected:
  - agent/memory/audit-carryovers.md
  - scripts/acp-validate.test.ts
tokens_est: 3000
created: 2026-07-15
completed:
---

## Objective

Restore 19 corrupted carryover audit stamps and add prevention guard (F-094-01).

## Tasks

task-248
