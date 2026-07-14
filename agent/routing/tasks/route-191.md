---
id: route-191
title: New acp.receive.md — incoming handoff protocol
task_type: command-doc-update
milestone: M67
complexity: medium
executor: copilot
context_required:
  - proposals/acp-enhanced-cross-agent-handoff-v1.md
  - wiki/cross-agent-handoff.md
files_affected:
  - agent/commands/acp.receive.md
  - .github/prompts/acp-receive.prompt.md
  - .opencode/commands/acp-receive.md
  - .cursor/commands/acp-receive.md
  - e2e/acp.receive.test.sh
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Create `/acp-receive` command: load handoff by path or `--latest`, warn on git SHA drift vs HEAD, warn on session date gap vs `sessions.md`, output assignment checklist (implement vs audit).

## Acceptance criteria

- [ ] Command doc + 3 wrappers synced
- [ ] Git drift warning when pinned SHA ≠ HEAD (non-blocking)
- [ ] Session gap warning when handoff date > last sessions.md entry
- [ ] E2E with fixture handoff + wrong SHA

## Depends on

route-190 (filename convention + frontmatter fields)

## Addresses

audit-077 H2, H4; feedback-007 §6
