---
id: route-150
title: "M57-001: progress.yaml + progress.template.yaml — recurring_tasks schema"
task_type: yaml-schema
milestone: M57
complexity: low
executor: copilot
context_required: [milestones/milestone-57-recurring-tasks-scheduler.md]
files_affected: [agent/progress.yaml, agent/progress.template.yaml]
tokens_est: 2000
created: 2026-06-08
completed: 2026-06-08
---

# Route 150: Recurring Tasks Schema

## Objective

Add `recurring_tasks:` block to `progress.yaml` and `progress.template.yaml` with 5 default periodic review tasks.

## Expected Output

### Files Modified
- `agent/progress.yaml` — add `recurring_tasks:` block (5 default tasks)
- `agent/progress.template.yaml` — add `recurring_tasks:` section with placeholder

## Schema Specification

Each task entry requires:
- `id`: kebab-case unique identifier
- `command`: Full ACP command with flags
- `frequency`: `weekly` | `monthly` | `quarterly` | `on-commit`
- `executor`: Valid executor from taxonomy
- `last_run`: ISO date or null
- `next_due`: ISO date or null (null for `on-commit`)
- `status`: `current` | `overdue` | `disabled`
- `description`: One-line description

## 5 Default Tasks

1. `weekly-code-review` — `/acp-review --report --carryover` (weekly, copilot)
2. `weekly-integrity-scan` — `/acp-integrity --self --report --carryover` (weekly, copilot)
3. `pre-commit-rule-audit` — `/acp-integrity --fast --ci` (on-commit, deepseek-v4-pro)
4. `monthly-dependency-audit` — `/acp-integrity --rules dependencies` (monthly, deepseek-v4-pro)
5. `quarterly-deep-scan` — `/acp-integrity --rules taint-flow,memory --report` (quarterly, claude-sonnet)

## Verification

- [ ] `progress.yaml` parses as valid YAML after addition
- [ ] All 5 tasks have required fields (id, command, frequency, executor, last_run, next_due, status, description)
- [ ] `frequency` values are valid enum members
- [ ] `status` values are valid enum members
- [ ] `progress.template.yaml` has `recurring_tasks:` placeholder section

## User-Observable Acceptance

- `progress.yaml` contains a `recurring_tasks:` block with 5 scheduled reviews
- Template file guides new projects to configure their own review cadence
