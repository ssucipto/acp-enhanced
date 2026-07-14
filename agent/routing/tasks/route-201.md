---
id: route-201
title: acp-bootstrap.sh — create-if-absent for Tier B stubs
task_type: bug-fix
milestone: M68
complexity: low
executor: copilot
context_required:
  - design/safe-install-update-policy.md
  - scripts/acp-bootstrap.sh
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Change bootstrap Tier B file creation from `cat >` to `[ -f path ] || cat >` for constraints.yml, routing.yml, wiki stubs, taxonomy.yml, rules.md, config.yml.

## Acceptance criteria

- [ ] Re-run bootstrap on project with customized wiki/domain.yml does not overwrite
- [ ] Fresh install still creates all stubs when absent
- [ ] Post-install verification unchanged (exit 1 on incomplete)

## Addresses

audit-080 F-080-05
