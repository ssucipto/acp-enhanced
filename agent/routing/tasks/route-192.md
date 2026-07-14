---
id: route-192
title: Extend acp.resume.md — optional handoff path
task_type: command-doc-update
milestone: M67
complexity: low
executor: copilot
context_required:
  - commands/acp.resume.md
  - commands/acp.receive.md
files_affected:
  - agent/commands/acp.resume.md
  - .github/prompts/acp-resume.prompt.md
  - .opencode/commands/acp-resume.md
  - .cursor/commands/acp-resume.md
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Add optional handoff path argument to `/acp-resume`. When provided (e.g. `/acp-resume @agent/reports/handoff-*.md`), run receive protocol steps before standard init+proceed chain.

## Acceptance criteria

- [ ] Documented path / `@` attach pattern
- [ ] Receive checklist runs before resume banner
- [ ] No handoff arg → unchanged v1 behaviour

## Depends on

route-191

## Addresses

audit-077 U1, H2
