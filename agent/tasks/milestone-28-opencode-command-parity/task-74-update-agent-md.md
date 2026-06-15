---
id: task-74
title: Update AGENT.md invocation table for opencode
task_type: docs
milestone: M28
complexity: low
executor: copilot
context_required:
  - agent/core/identity.yml
  - agent/skills/crosscut.md
files_affected:
  - AGENT.md
tokens_est: 300
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed: 2026-05-04
override_reason:
---

<!-- @acp.meta.task
topic: task, update, agentmd, invocation, table, for, opencode
description: Update AGENT.md invocation table for opencode
milestone: M28
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Task: Update AGENT.md invocation table for opencode

Replace the two-row invocation table (`/acp-*` and `@acp.*`) with a three-row table that accurately describes all supported invocation styles:
1. GitHub Copilot via `/acp-*` slash commands
2. opencode via `/acp-*` slash commands (via `.opencode/commands/`)
3. Manual delegation for all other agents

Remove the `@acp.*` row — this was broken syntax in opencode (@ = file reference, not command) and misleading for other agents.

## Acceptance Criteria

- [x] Table has 3 rows: Copilot, opencode, manual
- [x] `@acp.*` notation removed from AGENT.md (was broken in opencode)
- [x] Explanation paragraph updated to mention `.opencode/commands/` and commit status

## Implementation Notes

Updated the "Command Invocation Styles" section at line ~980. Replaced the old paragraph explaining `@acp.*` with accurate text covering both slash command directories.
