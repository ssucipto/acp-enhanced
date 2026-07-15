---
id: route-230
title: "M72 validator hardening — root anchor, zero-fail, hash, pkg, 5-surface parity"
task_type: typescript-feature
milestone: M72
complexity: high
executor: copilot
files_affected:
  - scripts/acp-validate.ts
  - scripts/acp-validate.test.ts
  - agent/commands/acp.validate.md
tokens_est: 8000
created: 2026-07-15
completed: 2026-07-15
---

## Objective

Enforcement half of F-091-01..05: ROOT-anchored paths, zero-found=fail, SHA-256 instruction sync, package.yaml version check, 5-surface parity + dot-stray detection, ≥6 vitests.

## Tasks

task-241
