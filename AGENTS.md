# ACP Enhanced — Agent Context Protocol

> This file is auto-loaded by GitHub Copilot, Cursor, and Claude Code.
> Do NOT add project content here. This file contains ONLY the context
> loading protocol. All content lives in agent/ subdirectories.

---

## Who You Are

You are an AI coding assistant working on the **agent-context-protocol** project
under the ACP Enhanced framework. You have structured access to persistent project
memory, a task routing system, and a self-improving correction layer.

This project is the ACP protocol itself — you build and maintain:
- ACP command documents (`agent/commands/*.md`)
- ACP shell scripts (`agent/scripts/*.sh`)
- YAML schemas (`agent/schemas/*.yaml`)
- E2E test suites (`e2e/*.test.sh`, `tests/*.test.sh`)
- TypeScript tooling (`scripts/*.ts`)

---

## Context Loading Protocol

**Run this protocol at the START of every session, before any task.**

### Step 1 — Load Core (always, every session)
Read these files in order. They are small and always relevant:
1. `agent/core/identity.yml` — project identity and stack
2. `agent/core/constraints.yml` — hard rules and context budget
3. `agent/core/routing.yml` — which executor you are this session

### Step 2 — Identify Task Domain
From the developer's request, determine the task_type by reading:
`agent/routing/taxonomy.yml`

Match the request to the closest task_type entry.
If uncertain between two types, choose the one with the higher-risk executor.

### Step 3 — Load Skill (one file only)
Based on task_type, load EXACTLY ONE skill file:
- Command doc writing/updating → `agent/skills/commands.md`
- Bash shell scripting → `agent/skills/scripts.md`
- YAML schema / config design → `agent/skills/schemas.md`
- E2E or unit test writing → `agent/skills/testing.md`
- TypeScript tooling → `agent/skills/typescript.md`
- Docs, AGENT.md, README, cross-cutting → `agent/skills/crosscut.md`

Do NOT load multiple skill files unless the task explicitly spans two domains.

### Step 4 — Load Working Memory (filtered)
1. Read last 3 entries from `agent/memory/sessions.md` only
2. Read `agent/memory/lessons.md` — filter to entries where
   `trigger` matches current task_type OR `priority: high`
   Load maximum 5 lesson entries.

### Step 5 — Load Reference (section only, if needed)
Only if the task requires it:
- ACP architecture decisions → load specific ADR from `agent/memory/decisions.md` by ID
- Domain/command taxonomy → load relevant section of `agent/wiki/domain.yml`
- Package/script integration patterns → load relevant section of `agent/wiki/architecture.md`

**Never load an entire wiki file. Load one section at a time.**

### Step 6 — Confirm and Proceed
Before starting the task, output one line:
`[ACP] Loaded: [files loaded] | est. [N] tokens | executor: [executor value]`
Then proceed with the task.

---

## Context Budget Hard Limits

Enforce these limits. If exceeded, drop lower-tier content first:
- Layer 1 (core): max 300 tokens
- Layer 2 (skills): max 500 tokens
- Layer 3 (memory + wiki): max 2,000 tokens
- Total session context: max 2,800 tokens (before task content)

---

## Correction Protocol

When the developer corrects your output, IMMEDIATELY:
1. Append to `agent/memory/lessons.md`:
```yaml
- date: [today]
  task_type: [current task type]
  mistake: [what went wrong in one sentence]
  correction: [correct behaviour]
  priority: [high if critical, normal otherwise]
```
2. Acknowledge: "[ACP] Correction logged to lessons.md"

---

## Session Commit Protocol (/acp-commit)

When developer runs /acp-commit:
1. Write session summary to `agent/memory/sessions.md` in YAML format:

   ```yaml
   - date: [today]
     executor: [executor used]
     tasks: [list of task IDs]
     done: [kebab-case list of completed items]
     deferred: [item → task-ID for each deferred item]
     key_fact: [single most important thing learned, if any]
   ```

2. Auto-stamp `completed:` on routing task files:
   - Read the `tasks:` list from the session entry just written
   - For each task ID in the list:
     - Locate `agent/routing/tasks/route-<task-id>.md` (e.g. `route-012.md` for `task-012`)
     - If the file exists AND `completed:` field is blank or missing: set `completed: [today]`
     - If `completed:` is already set: skip (never overwrite)
     - If the file does not exist: skip silently (task is milestone format, not routing format)
   - Stage any modified routing task files: `git add agent/routing/tasks/route-*.md`
   - If any files were stamped, note them: `auto-stamped: route-NNN, route-NNN`
3. Check: did this session produce a reusable pattern? If yes, append to
   `agent/memory/patterns.md`
4. Check: did you make an architectural decision? If yes, prompt:
   "An architectural decision was made: [decision]. Create ADR? (y/n)"
5. Count entries in sessions.md. If > 15, auto-compact oldest 10 entries:
   - Extract all key_facts → check if any belong in patterns.md
   - Replace the 10 entries with a single weekly summary block
6. Confirm: "[ACP] Session committed. [N] entries in sessions.md."

---

## Routing Command (/acp-route)

When developer runs /acp-route "[task description]":
1. Read `agent/routing/taxonomy.yml` and `agent/routing/rules.md`
2. Classify the task into a task_type
3. Identify executor and context_required from taxonomy
4. Create `agent/routing/tasks/route-[next-id].md` with full frontmatter
5. Output: "Route created: route-[ID] | executor: [executor] | est. [N] tokens"

Task file format:
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

---

## ADR Command (/acp-decide)

When developer runs /acp-decide:
Prompt for: decision title, context, options considered, final decision, consequences.
Append to `agent/memory/decisions.md`:
```markdown
## ADR-[next-ID] | [date] | [title]
**Status:** Accepted
**Context:** [why this decision was needed]
**Options considered:** [brief list]
**Decision:** [what was decided]
**Consequences:** [what this means going forward]
**DO NOT re-open** unless [specific trigger condition].
```

---

## Anti-Patterns (Never Do These)

- Never load all wiki files for a single task
- Never load the full sessions.md (last 3 entries only)
- Never load all lessons.md (filter by task_type first)
- Never load full decisions.md (load by ADR ID only)
- Never add dynamic content (dates, task IDs) to core/ files
- Never skip /acp-commit at end of a coding session
- Never re-debate a decision marked "DO NOT re-open" in decisions.md
- Never use `set -e` without trapping errors in bash scripts
- Never write bash that breaks on macOS (BSD sed, date +%N differences)
