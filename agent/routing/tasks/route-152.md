---
id: route-152
title: "M57-003: constraints.yml hooks + progress.schema.yaml"
task_type: yaml-schema
milestone: M57
complexity: low
executor: copilot
context_required: [milestones/milestone-57-recurring-tasks-scheduler.md, route-150]
files_affected: [agent/core/constraints.yml, agent/schemas/progress.schema.yaml]
tokens_est: 2000
created: 2026-06-08
completed: 2026-06-08
---

# Route 152: Hooks Configuration + Schema Validation

## Objective

Add `hooks:` block to `constraints.yml` for pre-commit integrity scans, and update `progress.schema.yaml` to validate the new `recurring_tasks:` block.

## Expected Output

### Files Modified
- `agent/core/constraints.yml` — add `hooks:` block
- `agent/schemas/progress.schema.yaml` — add `recurring_tasks` validation rules

## constraints.yml — hooks Block

```yaml
hooks:
  pre_commit_rule_file_audit: true      # /acp-integrity --fast --ci on commit
  pre_commit_integrity_phase1: false    # Opt-in full Phase 1 scan
  ci_npm_ignore_scripts: true           # Enforce --ignore-scripts in CI
```

## progress.schema.yaml — recurring_tasks Validation

Add schema rules for:
- `recurring_tasks` must be a list
- Each entry requires: `id`, `command`, `frequency`, `executor`, `last_run`, `next_due`, `status`, `description`
- `frequency` must be one of: `weekly`, `monthly`, `quarterly`, `on-commit`
- `status` must be one of: `current`, `overdue`, `disabled`
- `last_run` and `next_due` must be ISO date format (YYYY-MM-DD) or null
- `command` must start with `/acp-`

## Verification

- [ ] `constraints.yml` parses as valid YAML
- [ ] `hooks:` block has 3 entries with correct defaults
- [ ] `progress.schema.yaml` validates recurring_tasks required fields
- [ ] Schema validates frequency enum values
- [ ] Schema validates status enum values
- [ ] `acp-validate` picks up new schema rules

## User-Observable Acceptance

- `constraints.yml` shows pre-commit hook configuration
- `acp-validate` catches malformed recurring_tasks entries
