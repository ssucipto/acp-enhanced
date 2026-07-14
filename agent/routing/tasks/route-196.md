---
id: route-196
title: Handoff ecosystem parity — package, domain, index, routing audit
task_type: crosscut
milestone: M67
complexity: medium
executor: copilot
context_required:
  - design/cross-agent-handoff-protocol.md
  - wiki/domain.yml
  - package.yaml
files_affected:
  - package.yaml
  - agent/wiki/domain.yml
  - agent/index/acp.core.yaml
  - agent/core/routing.yml
  - README.md
  - CONTRIBUTING.md
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Register acp.receive as 70th framework command with full parity. Audit routing.yml — no references to unshipped commands. Document proposals/feedback intake.

## Acceptance criteria

- [ ] acp.receive in package.yaml
- [ ] domain.yml command count = 70
- [ ] index entries for handoff/receive/resume
- [ ] 70×3 wrapper parity passes
- [ ] routing.yml validated against shipped command set

## Depends on

route-191

## Addresses

audit-077 U2, SC-01, SC-07; carryover HIGH-067-001 (receive entry)
