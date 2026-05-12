---
id: route-043
title: M43 — Add shell-scripting to taxonomy.yml (GAP-001)
task_type: yaml-schema
milestone: M43
complexity: low
executor: deepseek-v4-flash
context_required:
  - routing/taxonomy.yml
  - routing/tasks/route-005.md
  - routing/tasks/route-011.md
  - memory/audit-carryovers.md
files_affected:
  - agent/routing/taxonomy.yml
tokens_est: 2000
tokens_actual:
cost_est_usd: 0.00
cost_actual_usd:
created: 2026-05-12
completed: 2026-05-12
override_reason:
---

## Task Description

Add a `shell-scripting` entry to `agent/routing/taxonomy.yml` to prevent silent fallback to `claude-sonnet` for routes that use this task type.

**Background**: `route-005` and `route-011` both have `task_type: shell-scripting` but this type is not registered in `taxonomy.yml`. When `acp-dispatch.ts` encounters an unknown task type, it falls back to `config.yml → default_model` which is `claude-sonnet` — the most expensive model (10–20× more expensive than the correct `deepseek-v4-flash`).

**Source**: audit-017 finding GAP-001 (`agent/reports/audit-017-taxonomy-improvement-suggestions.md`)

## Implementation

Add to `agent/routing/taxonomy.yml` under the `# ── BASH SCRIPTS ──` section (after `bash-script-refactor`):

```yaml
  shell-scripting:
    executor: deepseek-v4-flash
    complexity: low
    context_required: [memory/sessions.md]
    tokens_est: 4000
    skill: scripts
    description: >
      Legacy alias for bash-script-fix. Used in early routes (route-005, route-011).
      New routes should use bash-script-fix, bash-script-create, or bash-script-refactor.
```

Also update `last_updated:` on line 4 of taxonomy.yml to `2026-05-12`.

## Acceptance Criteria

- [ ] `shell-scripting` entry exists in `taxonomy.yml` under the bash-scripts section
- [ ] `executor: deepseek-v4-flash` — matches bash-script-fix (appropriate for this type)
- [ ] `description:` field notes it as a legacy alias and directs new routes to the canonical types
- [ ] `last_updated: 2026-05-12` updated in taxonomy.yml header
- [ ] `grep "shell-scripting" agent/routing/taxonomy.yml` returns the new entry
- [ ] Carryover GAP-001 in `agent/memory/audit-carryovers.md` set to `status: fixed, fix_applied_date: 2026-05-12`
