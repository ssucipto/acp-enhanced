---
id: route-027
title: M41a — Create acp.dispatch.md command doc (BUG-003d)
task_type: command-doc-write
milestone: M41
complexity: medium
executor: deepseek-v4-pro
context_required:
  - wiki/domain.yml#commands
  - memory/patterns.md
  - wiki/architecture.md#dispatch-script-flow
  - scripts/QUICKSTART.md
  - scripts/acp-dispatch.ts
files_affected:
  - agent/commands/acp.dispatch.md
  - .github/prompts/acp-dispatch.prompt.md
  - .opencode/commands/acp-dispatch.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Create `agent/commands/acp.dispatch.md` — the missing command doc for Persona B/C dispatch workflow. Without this, Persona B/C users have no IDE-side command to invoke the routing engine and must reverse-engineer the `cd scripts && npx ts-node` incantation. Closes BUG-003d from audit-014.

All three companion files must be created atomically.

## Acceptance Criteria

- [ ] `agent/commands/acp.dispatch.md` created with standard ACP command directive header
- [ ] Version 1.0.0, Created 2026-05-11, Status: Active
- [ ] **Purpose**: Invoke the ACP dispatch engine (Persona B/C) to run a routing task with a configured LLM executor
- [ ] **Arguments**:
  - `<route-NNN>` — dispatch a specific routing task
  - `--dry-run` — preview prompt assembly without sending to LLM
  - `--model <model-id>` — override executor model for this run
- [ ] **Prerequisites**: Node.js installed, `cd scripts && npm install` run once
- [ ] **Steps**:
  - Step 0: Display header (includes Persona guide: A=Copilot only, B=DeepSeek/OpenRouter, C=mixed)
  - Step 1: Parse arguments; verify route file exists
  - Step 2: Pre-flight checks (identity.yml present, routing.yml present, API key in env)
  - Step 3: Run `cd scripts && npx ts-node acp-dispatch.ts ../agent/routing/tasks/route-NNN.md`
  - Step 4: Read ledger output; display token usage and cost
  - Step 5: Confirm completion; remind to run /acp-commit if session context was updated
- [ ] **Persona guide table** included explaining when to use Persona A vs B vs C
- [ ] `.github/prompts/acp-dispatch.prompt.md` created
- [ ] `.opencode/commands/acp-dispatch.md` created
- [ ] All 3 files created atomically

## Implementation Notes

Read `scripts/QUICKSTART.md` Step 5 and `wiki/architecture.md` dispatch section carefully — this command doc must precisely document the actual CLI invocation and environment requirements for the dispatch script. Do not invent flags that don't exist in `acp-dispatch.ts`.
