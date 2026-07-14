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
completed: 2026-07-15
override_reason:
---

## Objective

Milestone exit: CHANGELOG v6.24.0, version bump, audit-080 + audit-081 carryovers → fixed, M68 gates checked.

## Acceptance criteria

- [ ] Tag v6.24.0 (only after route-204 validate guard passes)
- [ ] All M68 verification gates ✅
- [ ] audit-080 F-080-01..12 → fixed, `verified_in_audit: 081`
- [ ] audit-081 P-081-01..03 → fixed, `verified_in_audit: 081`
- [ ] progress.yaml M68 → completed
- [ ] route-079 `completed:` stamped (if not done in route-203)

## Addresses

audit-080, audit-081 release; FIFOZ unblock; SC-080-02 closure
