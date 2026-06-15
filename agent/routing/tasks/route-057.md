---
id: route-057
title: R9 Phase 3+4 — Proceed Spawning + Validation
task_type: typescript-tooling
milestone: M44
complexity: high
executor: deepseek-v4-pro
context_required: [agent/commands/acp.proceed.md, scripts/acp-validate.ts]
design_reference: [Parallel Task Support](../design/local.parallel-task-support.md)
files_affected: [agent/commands/acp.proceed.md, scripts/acp-validate.ts]
tokens_est: 8000
created: 2026-06-03
completed: 2026-06-03
depends_on: [route-056]
---

# R9 Phases 3+4: Proceed Spawning + Validation

Add parallel sub-agent spawning to `/acp-proceed` autonomous mode. Add dependency validation.

## Acceptance Criteria

- [ ] `/acp-proceed --complete` detects `task_type: parallel` and spawns sub-agents
- [ ] Independent sub-tasks (`depends_on: []`) spawn concurrently
- [ ] Dependent sub-tasks wait for their dependencies
- [ ] Orchestrator aggregates sub-task outputs + verifies deliverables
- [ ] `acp-validate.ts` detects circular dependencies in sub_task DAG
- [ ] Validation rejects `depends_on` references to non-existent sub-tasks
