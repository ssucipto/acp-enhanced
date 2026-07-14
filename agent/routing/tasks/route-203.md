---
id: route-203
title: Doc reconciliation — version-update paths, README, CHANGELOG, route-079
task_type: docs-update
milestone: M68
complexity: low
executor: copilot
context_required:
  - commands/acp.version-update.md
  - reports/audit-080-version-update-overwrite-safety.md
files_affected:
  - agent/commands/acp.version-update.md
  - README.md
  - CHANGELOG.md
  - agent/routing/tasks/route-079.md
  - CONTRIBUTING.md
tokens_est: 2500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Fix `domain.yml` path in command doc (`agent/wiki/` not `agent/core/`). Add consumer safety section to README/CONTRIBUTING. Note v6.9.0 doc-only gap in CHANGELOG v6.24.0. Re-close route-079 when script passes E2E.

## Acceptance criteria

- [ ] Command doc matches implemented flags and paths
- [ ] README warns: pre-v6.24.0 updates require git commit first
- [ ] FIFOZ consumer path documented
- [ ] route-079 `completed:` stamped only after route-199 E2E green

## Addresses

audit-080 F-080-08, F-080-12
