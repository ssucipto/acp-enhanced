---
id: route-194
title: Handoff lifecycle polish — LATEST, superseded, ancestry
task_type: command-doc-update
milestone: M67
complexity: low
executor: copilot
context_required:
  - proposals/acp-enhanced-cross-agent-handoff-v1.md
files_affected:
  - agent/commands/acp.handoff.md
  - agent/commands/acp.receive.md
  - scripts/acp-validate.ts
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

P2 polish: copy latest handoff to `HANDOFF-LATEST.md`, support `status: superseded` in frontmatter, optional validate rule that pinned SHA is ancestor of HEAD.

## Acceptance criteria

- [ ] New handoff marks prior `active_handoff` superseded
- [ ] `HANDOFF-LATEST.md` updated on save
- [ ] validate `--strict` optional ancestry check

## Depends on

route-193

## Addresses

audit-077 H5, H10; proposal §10 P2
