---
id: route-051
title: R9 — Parallelization + Orchestrator-Workers Support
task_type: architecture-design
milestone: M44
complexity: high
executor: deepseek-v4-pro
context_required: [agent/routing/taxonomy.yml, agent/schemas/*.yaml]
design_reference: [Parallel Task Support](../design/local.parallel-task-support.md)
files_affected: [agent/routing/taxonomy.yml, agent/schemas/task.schema.yaml, agent/commands/acp.proceed.md, scripts/acp-validate.ts, AGENT.md]
tokens_est: 8000
created: 2026-06-03
completed:
delegated_to: [route-056, route-057, route-058]
---

# R9: Parallelization Support

**Source**: audit-022, ChoreHive feedback R9 (P2)

## Problem

ACP Enhanced maps to 4 of 6 Anthropic agent workflows. The two gaps are:
- **Parallelization**: Multiple sub-tasks run concurrently in separate agent instances
- **Orchestrator-workers**: Orchestrator decomposes task, dispatches to worker agents

## Solution

Add `task_type: parallel` with sub-tasks:
```yaml
task:
  id: M44-T01
  title: Add endpoint tests
  task_type: parallel
  sub_tasks:
    - id: M44-T01a
      title: Tests for /api/chores
      executor: deepseek-v4-flash
    - id: M44-T01b
      title: Tests for /api/members
      executor: deepseek-v4-flash
```

## Acceptance Criteria

- [ ] `task_type: parallel` added to taxonomy.yml
- [ ] Sub-task schema defined with independent executors
- [ ] `/acp-proceed` can spawn parallel sub-tasks
- [ ] Orchestrator-worker pattern supported for large refactors
- [ ] Completes ACP Enhanced against Anthropic's 6 workflows
