---
id: route-204
title: acp-validate — guard against blind cp in install/update scripts
task_type: typescript-tooling
milestone: M68
complexity: low
executor: copilot
context_required:
  - scripts/acp-validate.ts
files_affected:
  - scripts/acp-validate.ts
  - tests/acp-validate.test.ts
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Add validate check: `acp.version-update.sh` and `acp.install.sh` must not contain blind `cp ... agent/core/*.yml`, blind `find ... *.*.md -exec cp`, or `cat > agent/manifest.yaml` without tier helper call.

## Acceptance criteria

- [x] Validator fails if destructive glob patterns reintroduced (core, commands, manifest)
- [x] Vitest coverage for new check
- [x] `npx tsx scripts/acp-validate.ts` — 0 errors
- [x] **Required before v6.24.0 tag** (SC-080-03) — shipped v6.24.0, verified @ audit-082

## Addresses

audit-080 regression prevention; SC-080-03; blocks SC-080-01 recurrence
