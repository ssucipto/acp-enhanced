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
completed: 2026-07-15
override_reason:
---

## Objective

Fix `domain.yml` path in command doc (`agent/wiki/` not `agent/core/`). Remove contradictory overwrite/preserve lists (P-081-06). Add consumer safety section to README/CONTRIBUTING. Note v6.9.0 doc-only gap in CHANGELOG v6.24.0. Re-close route-079 when route-202 E2E passes.

## Acceptance criteria

- [x] Command doc matches implemented flags and paths
- [x] README warns: pre-v6.24.0 updates require git commit first
- [x] FIFOZ consumer path documented
- [x] route-079 `completed:` stamped only after route-202 E2E green (not route-199 alone — P-081-04)
- [x] Command doc has single authoritative tier table — no L38-47 contradiction (P-081-06, SC-080-05)

## Addresses

audit-080 F-080-08, F-080-12; P-081-04, P-081-06; SC-080-01, SC-080-02, SC-080-05
