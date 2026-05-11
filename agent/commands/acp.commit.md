# Command: commit

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-commit` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-commit` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.2.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: End-of-session memory commit — write session summary, stamp completed tasks, compact memory if needed  
**Category**: Memory  
**Frequency**: At every phase boundary AND at session end — required, never skip  

---

## Arguments

None. Context is inferred from the current conversation.

---

## What This Command Does

> **CRITICAL — Context Window Overflow Risk**: If a session ends due to context window
> overflow before `/acp-commit` is run, all session knowledge is permanently lost. Do
> not defer commits to the end of a long session. Write incrementally.

Persists the session's work into the ACP memory layer so future sessions start with accurate context. This is the single most important habit in ACP Enhanced — skipping it means the next session starts cold.

**Use this when**:
- Closing VS Code / opencode at end of a work session
- Handing off to another agent or executor
- Completing a milestone phase before switching focus
- **PROACTIVE (do not wait for /acp-commit command)**:
  - After any audit report is created
  - After a git commit touching >5 files
  - After any architectural decision is made
  - When a correction is given by the developer
  - Whenever the context window is approaching capacity

Each of these events triggers an **immediate partial commit** — you do not wait for the
developer to type `/acp-commit`.

---

## Prerequisites

- [ ] `agent/memory/sessions.md` exists
- [ ] `agent/memory/patterns.md` exists
- [ ] `agent/routing/tasks/` exists (for stamping completed routes)

---

## Steps

### 0. Pre-commit Branch Guard (conditional)
Only run if `agent/core/identity.yml` contains `git_workflow:`.

1. Run `git branch --show-current`
2. Read `git_workflow.production_branch` from `identity.yml` (e.g., `main`)
3. If current branch equals production_branch:  
   Output: `⚠️ [ACP] Refusing to commit on \`[production_branch]\` (production). Switch to \`[default_working_branch]\` first.`  
   STOP. Do not write sessions.md. Do not make a git commit.
4. If current branch equals default_working_branch or is `feature/*` / `fix/*` → proceed to Step 1

### 1. Identify Completed Tasks

Ask: "Which task IDs were completed this session?" if not obvious from context.

### 2. Write Session Entry

Prepend a YAML entry to `agent/memory/sessions.md`:

```yaml
- date: [today]
  executor: [executor used this session]
  branch: [current branch — omit if git_workflow not configured in identity.yml]
  tasks: [list of route IDs completed, e.g. route-012, route-013]
  done:
    - [kebab-case-summary-of-task-1]
    - [kebab-case-summary-of-task-2]
  deferred: [item → route-ID for each deferred item, or none]
  key_fact: [single most important thing learned, or null]
```

### 3. Check for Reusable Patterns

- Did this session produce a reusable code pattern, architectural insight, or repeatable workflow?
- If yes → append to `agent/memory/patterns.md` with `date:` and `code_ref:` fields

### 4. Check for Architectural Decisions

- Was an architectural decision made this session?
- If yes → prompt: "Create ADR for [decision]? (y/n)"
- If yes → run `/acp-decide` for that decision

### 5. Stamp Completed Route Files

- For each route ID in `tasks:` above:
  - Read `agent/routing/tasks/route-[NNN].md`
  - If `completed:` field is blank → set `completed: [today]`
  - If already set → skip (never overwrite)
  - If file does not exist → skip silently

### 6. Compact Sessions (if needed)

- Count entries in `agent/memory/sessions.md`
- If count > 15 → compact oldest 10 entries:
  1. Extract all `key_fact` values → check if any belong in `patterns.md` or `decisions.md`
  2. Replace the 10 entries with a single weekly summary block:
     ```yaml
     - type: weekly-summary
       week: [date range]
       key_facts: [extracted list]
       tasks_completed: [count]
     ```

### 7. Confirm

```
[ACP] Session committed | [N] entries in sessions.md | compacted: [y/n]
```

---

## Verification

- [ ] sessions.md has a new entry at top with today's date
- [ ] All route files from `tasks:` list are stamped with `completed:` date
- [ ] If sessions.md has > 15 entries, oldest 10 were compacted
- [ ] No session data was lost (key_facts preserved in patterns.md if applicable)

---

**Namespace**: acp  
**Command**: commit  
**Version**: 1.1.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-09  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  

---

## v1.2.0 Changelog (2026-05-11)

- Added Step 0 Pre-commit Branch Guard (conditional on `git_workflow:` in identity.yml)
- Added optional `branch:` field to sessions.md YAML entry schema
- Root cause: feedback-002 — git branch awareness. Prevents accidental commits to production branch.

## v1.1.0 Changelog (2026-05-09)

- Frequency changed from "end of session" to "phase boundary" (proactive)
- Added context-window overflow risk warning to "What This Command Does"
- Clarified that agent must commit immediately at phase events, not wait for `/acp-commit`
- Root cause: feedback-001 from TikrFlow project — 3 sessions of work lost to context overflow;
  retroactive reconstruction required a full additional session. Lesson: `acp-knowledge-gap`
  in lessons.md.
