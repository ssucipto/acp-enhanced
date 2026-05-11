---
id: route-025
title: M41a — Create acp.task.md command doc (BUG-003b)
task_type: command-doc-write
milestone: M41
complexity: medium
executor: deepseek-v4-pro
context_required:
  - wiki/domain.yml#commands
  - memory/patterns.md
  - agent/routing/tasks/route-template.md
  - agent/routing/taxonomy.yml
files_affected:
  - agent/commands/acp.task.md
  - .github/prompts/acp-task.prompt.md
  - .opencode/commands/acp-task.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Create `agent/commands/acp.task.md` — the missing command doc for routing task management. Daily ACP workflow uses routing tasks constantly (`/acp-route`) but there is no command doc for creating, reading, listing, or updating task files. Closes BUG-003b from audit-014.

All three companion files must be created atomically.

## Acceptance Criteria

- [ ] `agent/commands/acp.task.md` created with standard ACP command directive header
- [ ] Version 1.0.0, Created 2026-05-11, Status: Active
- [ ] **Purpose**: Create, read, list, and update routing task files in `agent/routing/tasks/`
- [ ] **Arguments**:
  - `create <title>` — create a new route-NNN.md from template
  - `list` — list all routes with status (completed vs pending)
  - `show <route-NNN>` — display a specific route
  - `stamp <route-NNN>` — mark route as completed with today's date
- [ ] **Steps**:
  - Step 0: Display header
  - Step 1: Parse subcommand (create|list|show|stamp)
  - Step 2 (create): Find next route number; fill template from taxonomy; create file
  - Step 2 (list): Read all route-*.md files; display table of id/title/status/complexity
  - Step 2 (show): Read and display specific route file
  - Step 2 (stamp): Set `completed: {today}` in the route frontmatter
  - Step 3: Confirm action taken
- [ ] `.github/prompts/acp-task.prompt.md` created
- [ ] `.opencode/commands/acp-task.md` created
- [ ] All 3 files created atomically

## Implementation Notes

This command is distinct from `/acp-route` (which creates routes from natural language descriptions). `/acp-task` is the management layer: it enables listing, stamping, and showing existing task records. The `create` subcommand is a lightweight wrapper around the route-template.
