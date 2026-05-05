# Command: route

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-route` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-route` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Classify a task, select the cheapest capable executor, and create a route file in `agent/routing/tasks/`  
**Category**: Routing  
**Frequency**: Before every new task  

---

## Arguments

**CLI-Style Arguments**:
- `<task description>` (positional) — Natural language description of the task to route

**Natural Language Arguments**:
- `/acp-route "Add retry logic to the auth service"` — Route a specific task
- `/acp-route "Fix bug in YAML parser"` — Route a bug fix
- `/acp-route "Write E2E test for project-list command"` — Route a test writing task

---

## What This Command Does

Routes a task to the cheapest capable AI executor by reading the taxonomy and routing rules, classifying the task, and creating a route file with cost estimates.

**Use this when**:
- Starting any new task before calling `acp-dispatch.ts`
- Planning a session and want to know which model to use
- Assigning work to different executors across a batch of tasks

---

## Prerequisites

- [ ] `agent/routing/taxonomy.yml` exists
- [ ] `agent/routing/rules.md` exists
- [ ] `agent/routing/tasks/` directory exists

---

## Steps

### 1. Read Taxonomy and Rules

- Read `agent/routing/taxonomy.yml` — full list of `task_type` entries with their `executor`, `context_required`, and `tokens_est`
- Read `agent/routing/rules.md` — priority order and tie-breaker logic

### 2. Classify Task

- Match the task description to the closest `task_type` in taxonomy
- If uncertain between two types, choose the one with the higher-risk executor (per rules.md ambiguity section)
- Determine: `executor`, `complexity` (low/medium/high), `context_required`, `tokens_est`

### 3. Create Route File

- Get the next available route ID from the highest existing ID in `agent/routing/tasks/`
- Create `agent/routing/tasks/route-[ID].md` with complete YAML frontmatter:

```yaml
---
id: route-[NNN]
title: [task title]
task_type: [from taxonomy]
milestone: [current milestone or none]
complexity: [low/medium/high]
executor: [from taxonomy]
context_required: [list from taxonomy]
files_affected: []
tokens_est: [from taxonomy]
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: [today]
completed:
override_reason:
---

[Task description and acceptance criteria]
```

### 4. Update Ledger

- Append a pending row to `agent/routing/ledger.md`:

```
| [date] | route-[ID] | [title] | [executor] | [tokens_est] | — | — | pending |
```

### 5. Output

```
Route created: route-[ID] | executor: [executor] | est. [N] tokens | est. $[cost]
File: agent/routing/tasks/route-[ID].md
```

---

## Verification

- [ ] Route file created at `agent/routing/tasks/route-[ID].md`
- [ ] YAML frontmatter complete — no blank required fields
- [ ] Executor matches taxonomy default (or `override_reason` provided)
- [ ] Ledger row appended with `pending` status

---

**Namespace**: acp  
**Command**: route  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  
