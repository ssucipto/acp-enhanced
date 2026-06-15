---
id: route-084
title: "Command onboarding — /acp-init shows top commands for current phase"
task_type: command-doc-update
milestone: M47
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.init.md
  - agent/core/routing.yml (command_suggestions)
files_affected:
  - agent/commands/acp.init.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 084: Command Onboarding

## Objective

Enhance `/acp-init` to show a "commands for your current phase" section that surfaces
the top 5 most relevant commands based on the project's current milestone and status.

## Context

FIFOZ feedback-002 (F-05) noted: "61 commands installed, ~8 used — no guided onboarding."
While v6.8.2 added `command_suggestions` for post-command discoverability (related commands
after each invocation), there is no initial guidance showing what commands are available
for the current project phase.

## Changes

### acp.init.md — Add "Commands for Your Phase" Section

After the existing init steps, add:

```
### N. Commands for Your Phase

Based on your project state ({current_milestone}, {status}), these commands are most relevant:

| Command | Why now |
|---------|---------|
| /acp-audit | Run pre-impl audit before starting new work |
| /acp-plan | Plan upcoming milestone tasks |
| /acp-proceed | Start implementing next task |
| /acp-update | Sync progress.yaml after completing work |
| /acp-commit | Save session memory (patterns, lessons) |

💡 61 commands available. Run /acp-help to see all, or /acp-status for project health.
```

### Phase Detection Logic

The agent should select commands based on:
- **New project** (no milestones completed): `/acp-plan`, `/acp-design-create`, `/acp-task-create`, `/acp-audit`, `/acp-init`
- **Active milestone** (in_progress): `/acp-proceed`, `/acp-update`, `/acp-commit`, `/acp-audit`, `/acp-validate`
- **Post-milestone** (just completed): `/acp-commit`, `/acp-audit`, `/acp-plan`, `/acp-update`, `/acp-sync`
- **Maintenance** (no active milestone): `/acp-validate`, `/acp-audit`, `/acp-sync`, `/acp-memory-sync`, `/acp-status`

## Verification

- [ ] `/acp-init` shows 5 recommended commands based on project phase
- [ ] Commands are contextual (not the same 5 for every project)
- [ ] Phase detection works for new/active/completed/maintenance states
- [ ] Message includes total command count and how to see all

## Dependencies

None.
