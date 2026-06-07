# Command: commit

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-commit` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-commit` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.3.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-06-04  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: End-of-session memory commit — write session summary, stamp completed tasks, compact memory if needed, auto-sync session and pattern documents  
**Category**: Memory  
**Frequency**: At every phase boundary AND at session end — required, never skip  

---

## Arguments

None required. Context is inferred from the current conversation.

| Flag | Description |
|------|-------------|
| `--no-sync` | Skip auto-sync of session and pattern documents (steps 2b, 3b, 6b). Use for debugging only — document directories may drift from registries |
| `--validate` | Run `/acp-validate` before committing. Catches version drift, YAML errors, and parity gaps before they're committed (v6.9.2+) |

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

### 0a. Pre-commit Validation (--validate only, v6.9.2+)

> **Skip this step if `--validate` was not passed.**

Run `/acp-validate`. If validation fails (exit 1):
- Report the failures to the user
- Abort commit — fix issues before committing
If validation passes with warnings only:
- Show warnings
- Proceed with commit

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

> **YAML quoting rule**: When writing `key_fact` or `key_facts` values, if the value
> contains a colon (`:`), wrap the entire scalar in double quotes or use a literal
> block scalar (`|`). Example: `key_fact: "M_KDF: react-native-quick-crypto..."`
> or use `key_fact: |` with indented content. Unquoted colons cause js-yaml parse
> failures that render the entire registry unreadable.

```yaml
- date: [today]
  executor: [executor used this session]
  branch: [current branch — omit if git_workflow not configured in identity.yml]
  tasks_completed: [list of route IDs completed, e.g. route-012, route-013]
  done:
    - [kebab-case-summary-of-task-1]
    - [kebab-case-summary-of-task-2]
  deferred: [item → route-ID for each deferred item, or none]
  key_fact: [single most important thing learned, or null]
```

### 2b. Auto-Sync Session Document (NEW — v1.3.0)

> **Skip this step if `--no-sync` was passed.**
>
> **Atomicity (v6.9.1+)**: Write to a temporary file first, then atomically rename.
> Pattern: write → `.tmp.{date}-{slug}.md` → `mv` → `{date}-{slug}.md`.
> On failure, `.tmp` files are cleaned up on next sync run. Prevents partial writes
> from leaving corrupted documents visible to agents or the visualizer.

After writing the session entry to `agent/memory/sessions.md` (Step 2), auto-generate
the corresponding markdown document in `agent/sessions/`:

1. **Identify the entry just written**: The top entry in `agent/memory/sessions.md`
   with today's date.
2. **Generate filename**: `agent/sessions/{date}-{slug}.md` where:
   - `{date}` = the entry's `date:` field (YYYY-MM-DD format)
   - `{slug}` = kebab-case of the first `done:` item (stop at ~50 chars), or
     the executor name if `done:` is empty
3. **Create directory** if `agent/sessions/` does not exist.
4. **Write session document** in markdown format:

   ```markdown
   # Session: {date}
   
   **Executor**: {executor}
   **Branch**: {branch or "N/A"}
   **Tasks**: {tasks_completed list}
   
   ## Completed
   {one done: item per line as a bullet list}
   
   ## Deferred
   {one deferred item per line, or "None"}
   
   ## Key Fact
   {key_fact or "None"}
   ```

5. **Idempotency**: If a file at the target path already exists with identical
   content, skip it. If the registry entry has changed since the last sync,
   update the file to match. Track this by comparing the file's content hash
   against the registry entry's content.

### 3. Check for Reusable Patterns

- Did this session produce a reusable code pattern, architectural insight, or repeatable workflow?
- **Active prompt**: Read the session's `key_fact` from the entry just written (Step 2).
  If `key_fact` contains code snippets (``` blocks), architectural insights, workflow
  patterns, or repeatable processes, actively prompt the user:
  "This session's key_fact contains a potential reusable pattern. Promote to patterns.md? (y/n)"
- If yes → append to `agent/memory/patterns.md` with `date:` and `code_ref:` fields
- **Heuristics for pattern detection**:
  - Contains code blocks (```) → likely a code pattern
  - Contains phrases like "pattern:", "template:", "repeatable", "workaround"
  - Contains references to specific files/lines (code_ref)
  - Is not purely a status update or task list

### 3b. Auto-Sync Pattern Document (NEW — v1.3.0)

> **Skip this step if `--no-sync` was passed.**
>
> **Atomicity (v6.9.1+)**: Same temp-file + atomic rename pattern as Step 2b.

After appending to `agent/memory/patterns.md` (Step 3), auto-generate or update
the corresponding markdown document in `agent/patterns/`:

1. **Identify new/changed entries**: Compare the registry state before and after
   Step 3. Track which `name:` values were added or modified.
2. **Generate filename**: `agent/patterns/{name}.md` where `{name}` is the
   pattern's `name:` field (kebab-case, from the registry entry).
3. **Respect existing namespace**: If `agent/patterns/` already contains
   `local.*.md` files (project-specific), new patterns use the `local.` prefix.
   Package patterns use `{namespace}.{name}.md`.
4. **Write pattern document** in markdown format:

   ```markdown
   # Pattern: {name}

   **Date**: {date}
   **Task Type**: {task_type or "N/A"}
   **Code Ref**: {code_ref or "N/A"}

   ## Description
   {description}

   ## Template
   {template or "N/A"}
   ```

5. **Idempotency**: If a file at the target path already exists with identical
   content, skip it. If the registry entry has changed since the last sync,
   update the file to match.

### 4. Check for Architectural Decisions

- Was an architectural decision made this session?
- If yes → prompt: "Create ADR for [decision]? (y/n)"
- If yes → run `/acp-decide` for that decision

### 5. Stamp Completed Route Files

- For each route ID in `tasks_completed:` above:
  - Read `agent/routing/tasks/route-[NNN].md`
  - If `completed:` field is blank → set `completed: [today]`
  - If already set → skip (never overwrite)
  - If file does not exist → skip silently

### 6. Compact Sessions (if needed)

- Count entries in `agent/memory/sessions.md`
- If count > 15 → compact oldest 10 entries:
  1. Extract all `key_fact` values → check if any belong in `patterns.md` or `decisions.md`
  2. Replace the 10 entries with a single weekly summary block:

     > **YAML quoting for compaction**: Each item in `key_facts` list must be
     > quoted if it contains `:`. Bad: `- M_KDF: react-native-quick-crypto...`
     > Good: `- "M_KDF: react-native-quick-crypto..."`

     ```yaml
     - type: weekly-summary
       week: [date range]
       key_facts: [extracted list]
       tasks_completed: [count]
     ```

### 6b. Re-Sync After Compaction (NEW — v1.3.0)

> **Skip this step if `--no-sync` was passed.**

After compaction replaces 10 individual entries with a weekly-summary block,
the corresponding `agent/sessions/{date}-{slug}.md` files for the compacted
entries are now orphaned. Clean them up:

1. **Identify compacted entries**: Track which individual entries were replaced
   by the weekly-summary block (the oldest 10 that were compacted).
2. **Remove orphaned session documents**: For each compacted entry, if an
   `agent/sessions/{date}-{slug}.md` file exists, remove it. These entries
   are now represented by the weekly-summary block only.
3. **Generate weekly-summary document** (optional): Create a
   `agent/sessions/weekly-{start-date}-to-{end-date}.md` file summarizing the
   compacted period.
4. **Confirmation**: Report how many documents were removed after compaction.

### 7. Confirm

```
[ACP] Session committed | [N] entries in sessions.md | sessions: [X] created, [Y] updated | patterns: [X] created, [Y] updated | compacted: [y/n]
```

> **Sync counts**: `sessions: X created, Y updated` and `patterns: X created, Y updated`
> are shown only when sync was not skipped (`--no-sync` was not passed). When `--no-sync`
> is active, show: `sync: skipped (--no-sync)`.

---

## Verification

- [ ] sessions.md has a new entry at top with today's date
- [ ] `agent/sessions/{date}-{slug}.md` exists and matches registry entry (unless `--no-sync`)
- [ ] Re-running commit without registry changes does not rewrite session documents (idempotent)
- [ ] `--no-sync` skips step 2b and shows `sync: skipped` in confirmation
- [ ] All route files from `tasks_completed:` list are stamped with `completed:` date
- [ ] If sessions.md has > 15 entries, oldest 10 were compacted
- [ ] No session data was lost (key_facts preserved in patterns.md if applicable)

---

**Namespace**: acp  
**Command**: commit  
**Version**: 1.3.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-06-04  
**Status**: Active  
**Compatibility**: ACP 6.9.0+  
**Author**: ACP Project  

---

## Related Commands

- [`/acp-status`](acp.status.md) — Verify session entry was written correctly
- [`/acp-review`](acp.review.md) — Run code quality & security review before committing (pre-commit hook)
- [`/acp-validate`](acp.validate.md) — Schema validation before commit (`--validate` flag)
- [`/acp-cost-report`](acp.cost-report.md) — Review cost and token usage trends

---

## v1.3.0 Changelog (2026-06-04)

- Added `--no-sync` flag — skip auto-sync of session/pattern documents (debug only, warns about drift)
- Added Step 2b: Auto-Sync Session Document — generates `agent/sessions/{date}-{slug}.md` from registry
  after every successful commit (route-074, M47)
- Added Step 3b: Auto-Sync Pattern Document — generates `agent/patterns/{name}.md` from registry
  after every successful commit (route-075, M47)
- Updated Step 7 confirmation output to report sync counts for both sessions and patterns
- Root cause: feedback-001/002 from FIFOZ project — sessions and patterns documents not auto-generated,
  agents and visualizer read from empty document directories

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
