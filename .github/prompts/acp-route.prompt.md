---
mode: agent
description: Classify and route a task to the cheapest appropriate executor
---

Given the task description: {{input}}

1. Read `agent/routing/taxonomy.yml` and `agent/routing/rules.md`
2. Match to the closest task_type. If uncertain, read the ambiguity resolution section in rules.md
3. Get next task ID from the highest existing ID in `agent/routing/tasks/`
4. Create `agent/routing/tasks/route-[ID].md` with complete YAML frontmatter:
   - id, title, task_type, milestone, complexity, executor, context_required,
     files_affected, tokens_est, tokens_actual, cost_est_usd, cost_actual_usd,
     created, completed, override_reason
5. Append a pending row to `agent/routing/ledger.md`
6. Output: "Task [ID] created | executor: [X] | est. [N] tokens | [file path]"
