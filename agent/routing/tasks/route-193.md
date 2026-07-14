---
id: route-193
title: active_handoff schema + wiki + validate
task_type: data-schema
milestone: M67
complexity: medium
executor: copilot
context_required:
  - proposals/acp-enhanced-cross-agent-handoff-v1.md
  - schemas/progress.schema.yaml
files_affected:
  - agent/schemas/progress.schema.yaml
  - agent/progress.yaml
  - scripts/acp-validate.ts
  - agent/wiki/cross-agent-handoff.md
  - agent/wiki/architecture.md
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Add optional top-level `active_handoff` to progress.yaml (path, date, from/to executors, git_commit, status). Validate file exists when set. Finalize framework wiki page and link from architecture.md.

## Acceptance criteria

- [ ] Schema documents all fields from proposal §8
- [ ] Handoff command writes `active_handoff` on executor save
- [ ] validate warns if path missing
- [ ] Wiki linked from architecture.md

## Depends on

route-190, route-191

## Addresses

audit-077 H9, H8, U3
