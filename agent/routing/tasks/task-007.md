---
id: task-007
title: Fix display_available_commands — list all 50 commands
task_type: bash-script-fix
milestone: M26-audit
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/scripts/acp.common.sh
  - agent/commands/*.md
files_affected:
  - agent/scripts/acp.common.sh
tokens_est: 3500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed:
override_reason:
---

## Task: Fix display_available_commands — list all 50 commands

## Problem

`display_available_commands()` in `agent/scripts/acp.common.sh` only echoes 16 `/acp-*`
commands. The repo now has 50 `acp.*` command files. 34 commands are invisible to users
and AI agents at install/update time.

Missing commands (confirmed via audit):
acp-artifact-glossary, acp-artifact-reference, acp-artifact-research, acp-audit,
acp-clarification-address, acp-clarification-capture, acp-clarification-create,
acp-command-create, acp-design-create, acp-design-reference, acp-handoff, acp-index,
acp-package-publish, acp-package-validate, acp-pattern-create, acp-plan,
acp-preferences-create, acp-preferences-get, acp-preferences-set, acp-preferences-show,
acp-preferences-validate, acp-project-create, acp-project-info, acp-project-list,
acp-project-remove, acp-project-set, acp-project-update, acp-projects-restore,
acp-projects-sync, acp-resume, acp-sessions, acp-spec, acp-task-create

## Acceptance Criteria

- [ ] `display_available_commands()` lists all 50 `acp-*` commands grouped by category
- [ ] Output matches the actual command files in `agent/commands/acp.*.md`
- [ ] Existing commands in the list remain in their current positions
- [ ] Categories: Workflow, Package, Project, Preferences, Artifact, Clarification,
      Design, Version, Utility
