---
id: route-205
title: Release v6.24.0 + audit-080 carryover closure
task_type: release
milestone: M68
complexity: low
executor: copilot
context_required:
  - milestones/milestone-68-safe-install-update-policy.md
  - memory/audit-carryovers.md
files_affected:
  - CHANGELOG.md
  - agent/core/identity.yml
  - agent/progress.yaml
  - agent/memory/audit-carryovers.md
tokens_est: 2000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Milestone exit: CHANGELOG v6.24.0, version bump, audit-080 F-080-* carryovers → fixed, M68 gates checked.

## Acceptance criteria

- [ ] Tag v6.24.0
- [ ] All M68 verification gates ✅
- [ ] audit-080 carryovers closed with `verified_in_audit: 081` or `080`
- [ ] progress.yaml M68 → completed

## Addresses

audit-080 release; FIFOZ unblock
