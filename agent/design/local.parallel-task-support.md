# Parallel Task Support

<!-- @acp.meta.design
topic: parallel, task, support
description: Parallel Task Support
status: active
updated: 2026-06-15
@acp.meta.end -->

**Design**: DR-002  
**Created**: 2026-06-03  
**Last Updated**: 2026-06-15  
**Namespace**: local  
**Source**: audit-022 R9, ChoreHive feedback, Anthropic 6 Agent Workflows (Dec 2024)  

---

## Problem

ACP Enhanced maps to 4 of Anthropic's 6 agent workflows. The two gaps are:

| Missing Workflow | Description | Example |
|---|---|---|
| **Parallelization** | Multiple independent sub-tasks run concurrently | "Add tests for endpoints A, B, and C" |
| **Orchestrator-workers** | Orchestrator decomposes a task, dispatches to workers | Large refactors spanning multiple domains |

Without these, tasks that are naturally parallel must be executed sequentially, wasting time and tokens on independent work that could run concurrently.

## Solution

Add `task_type: parallel` to the taxonomy with a `sub_tasks` schema. The `/acp-proceed` command (autonomous mode) detects parallel tasks and spawns sub-agents.

### How It Works

```
/acp-proceed --complete M44
  ↓
Agent reads task: route-051 (task_type: parallel)
  ↓
Agent decomposes into sub-tasks:
  - route-051a: Tests for /api/chores    → deepseek-v4-flash
  - route-051b: Tests for /api/members   → deepseek-v4-flash
  - route-051c: Tests for /api/households → deepseek-v4-flash
  ↓
Agent spawns 3 sub-agents concurrently
  ↓
All 3 complete → agent aggregates results → marks task done
```

### Sub-Task Schema

```yaml
# route-NNN.md frontmatter
---
id: route-051
title: Add endpoint tests
task_type: parallel
executor: deepseek-v4-pro     # Orchestrator
sub_tasks:
  - id: route-051a
    title: Tests for /api/chores
    executor: deepseek-v4-flash
    depends_on: []
  - id: route-051b
    title: Tests for /api/members
    executor: deepseek-v4-flash
    depends_on: []
  - id: route-051c
    title: Tests for /api/households
    executor: deepseek-v4-flash
    depends_on: [route-051a]   # Must wait for chores tests (shared fixture)
---
```

### Orchestrator-Workers Pattern

For large refactors, the orchestrator model applies:

```
Orchestrator (deepseek-v4-pro)
  ↓ Decomposes
  ├─ Worker A: Refactor auth module     (deepseek-v4-pro)
  ├─ Worker B: Refactor data layer      (deepseek-v4-pro)
  └─ Worker C: Update integration tests (deepseek-v4-flash)
  ↓ Aggregates
Orchestrator reviews all outputs, resolves conflicts, marks task done
```

## Architecture Changes

### 1. taxonomy.yml — Add parallel Task Type

```yaml
task_types:
  parallel:
    executor: deepseek-v4-pro     # Orchestrator — decomposes + aggregates
    complexity: high
    context_required: [agent/routing/taxonomy.yml]
    tokens_est: 12000
    skill: crosscut
    sub_task_default_executor: deepseek-v4-flash

  orchestrator-workers:
    executor: deepseek-v4-pro     # Orchestrator
    complexity: high
    context_required: [agent/routing/taxonomy.yml]
    tokens_est: 20000
    skill: crosscut
```

### 2. `/acp-proceed` — Parallel Spawning (Autonomous Mode)

Add to autonomous task loop (Step A4):

```
A4. For each task:
    a. If task_type is parallel:
       - Read sub_tasks from route file
       - For each independent sub_task (depends_on: []):
         → Spawn sub-agent with sub_task context
       - Wait for dependent sub_tasks (respects depends_on order)
       - Aggregate all sub-task outputs
       - Verify all deliverables
       - Mark parent task complete
    b. Otherwise: standard sequential execution
```

### 3. Dependency Resolution

Sub-tasks form a DAG:
- `depends_on: []` — can run immediately (parallel)
- `depends_on: [route-051a]` — waits for 051a to complete
- Circular dependencies → validation error

## Implementation Plan

| Phase | Task | Files | Complexity |
|:-----:|------|-------|:---:|
| 1 | Add `parallel` + `orchestrator-workers` to taxonomy.yml | `agent/routing/taxonomy.yml` | Low |
| 2 | Define sub-task schema | `agent/schemas/task.schema.yaml` (new) | Medium |
| 3 | Add parallel spawning to `/acp-proceed` autonomous mode | `agent/commands/acp.proceed.md` | High |
| 4 | Add dependency resolution validation | `scripts/acp-validate.ts` | Medium |
| 5 | Update AGENT.md + README.md | `AGENT.md`, `README.md` | Low |

## Trade-offs

| Pro | Con |
|-----|-----|
| Completes ACP against Anthropic's 6 workflows | Sub-agents increase total token usage (parallel = more concurrent tokens) |
| Independent tasks finish faster (wall-clock) | Dependency resolution adds complexity |
| Orchestrator pattern enables large-scale refactors | Sub-agent coordination is hard to get right |
| Matches industry direction (LangChain Deep Agents) | Not needed for solo developers with simple tasks |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| DAG-based dependency model | Simpler than full workflow engine; sufficient for most cases |
| Sub-tasks in route file frontmatter | Same location as task definition; no new file |
| `depends_on: []` = parallel-ready | Explicit opt-in to parallelism; default is sequential |
| Orchestrator uses pro model | Decomposition + aggregation is reasoning-heavy |
| Workers default to flash | Independent implementation is execution-heavy, not reasoning |

## Acceptance Criteria

- [ ] `task_type: parallel` in taxonomy.yml with sub_task_default_executor
- [ ] Sub-task schema with id, title, executor, depends_on
- [ ] `/acp-proceed --complete` spawns sub-agents for parallel tasks
- [ ] Dependency resolution respects `depends_on` ordering
- [ ] Orchestrator aggregates sub-task outputs + verifies deliverables
- [ ] Circular dependency detection in acp-validate.ts
- [ ] AGENT.md documents parallel + orchestrator workflows
