---
id: route-056
title: R9 Phase 1+2 — Taxonomy + Sub-Task Schema
task_type: yaml-schema
milestone: M44
complexity: medium
executor: deepseek-v4-pro
context_required: [agent/routing/taxonomy.yml]
design_reference: [Parallel Task Support](../design/local.parallel-task-support.md)
files_affected: [agent/routing/taxonomy.yml, agent/schemas/task.schema.yaml]
tokens_est: 3000
created: 2026-06-03
completed: 2026-06-03
depends_on: []
---

# R9 Phases 1+2: Taxonomy + Sub-Task Schema

Add `parallel` and `orchestrator-workers` task types. Define sub-task schema.

## Acceptance Criteria

- [ ] `task_type: parallel` in taxonomy.yml with sub_task_default_executor
- [ ] `task_type: orchestrator-workers` in taxonomy.yml
- [ ] Sub-task schema: id, title, executor, depends_on fields
- [ ] Schema validates DAG (no circular dependencies)
- [ ] Route template updated to include sub_tasks field
