---
id: route-190
title: acp.handoff.md v2 — dual mode executor + cross-repo
task_type: command-doc-update
milestone: M67
complexity: medium
executor: copilot
context_required:
  - proposals/acp-enhanced-cross-agent-handoff-v1.md
  - reports/audit-077-cross-agent-handoff-feedback-007.md
  - commands/acp.handoff.md
files_affected:
  - agent/commands/acp.handoff.md
  - .github/prompts/acp-handoff.prompt.md
  - .opencode/commands/acp-handoff.md
  - .cursor/commands/acp-handoff.md
  - agent/core/routing.yml
  - e2e/acp.handoff.test.sh
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Rewrite `/acp-handoff` to v2.0.0 with `--mode executor|cross-repo` and `--to <executor>`. Executor mode uses proposal §4 template (ADR locks, task sequence, guardrails, git pin). Cross-repo mode preserves v1.0.0 behaviour.

## Acceptance criteria

- [ ] `--mode cross-repo` (default) unchanged from v1 problem-only spec
- [ ] `--mode executor` requires disk output with all §4 sections
- [ ] Outgoing ritual enforces `/acp-commit` before save
- [ ] `routing.yml` adds `acp-receive` to handoff suggestions
- [ ] E2E structural tests for both modes

## Addresses

audit-077 H1, H3, H5, H7; feedback-007 §4
