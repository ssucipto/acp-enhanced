# ACP Enhanced — Agent Context Protocol

> v6.25.0 — Context Loading Protocol (light + full modes)
>
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
- CI/CD workflows (`.github/workflows/ci.yaml`, `.github/workflows/e2e-tests.yaml`)

**Git workflow**: `develop` → `mainline` (gitflow-lite). All work happens on `develop`
or feature branches. PRs merge `develop` → `mainline`. CI runs on every push and PR.
See `agent/core/identity.yml → git_workflow` for branch safety rules.

---

## Context Loading Protocol

**Run this protocol at the START of every session, before any task.**

### Step 1 — Load Core (always, every session)
Read these files in order. They are small and always relevant:
1. `agent/core/identity.yml` — project identity and stack
2. `agent/core/constraints.yml` — hard rules and context budget
3. `agent/core/routing.yml` — which executor you are this session

### Step 1b — Git Branch Safety Check (conditional)
Only run this step if `agent/core/identity.yml` contains a `git_workflow:` block.

Run: `git branch --show-current`  
Compare to `identity.yml → git_workflow.default_working_branch`.

- **Matches default_working_branch** → proceed normally
- **Is the production_branch (e.g. `main`)** → output warning and stop:
  ```
  ⚠️ [ACP] You are on `main` (production branch).
  All work should target the default working branch. Switch with:
    git checkout [default_working_branch]
  Do not commit until you are on the correct branch.
  ```
  Output the warning and stop. Do not continue any task steps. The developer
  must switch branches and re-invoke the session.
- **Is `feature/*`, `fix/*`, or other** → note it in session, proceed normally
- **`git_workflow` not defined in identity.yml** → skip this step entirely

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
2. **Gap check**: Compare the most recent session's `date:` against today. If the most
   recent entry has `deferred:` items, surface them now — they are your current backlog.
   If recent git commits exist that post-date the last `sessions.md` entry by more than
   a day, note the potential knowledge gap in your session-start response.
3. Read `agent/memory/lessons.md` — filter to entries where
   `trigger` matches current task_type OR `priority: high`
   Load maximum 5 lesson entries.
4. Check `agent/memory/audit-carryovers.md` (if it exists):
   - If the file does not exist → skip silently
   - If the file exists, read the `carryovers:` list. If any entries have `status: pending`:
     Output before starting any work:
     ```
     ⚠️ [ACP] Open audit carryovers: [N] pending items require attention.
     [finding_id]: [one-line finding description]
     Review before starting to avoid re-discovering fixed or stale items.
     ```
   - If all entries are `status: fixed` → skip silently

### Step 4.5 — Scheduled Review Due Check (conditional)

Read `agent/progress.yaml` → `recurring_tasks`.
If any task has `status: overdue` OR `next_due` <= today:
  Output before starting any other task:
  ```
  ⏰ [ACP] Scheduled review(s) overdue:
     [task_id]: [command] — last run [date], due [date]
  ```
  Recommend running before unrelated work.
  Developer may defer: note in session entry as deferred with reason.

If all tasks are current:
  (Silent — do not output to avoid noise at every session start.)

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

## Mid-Session Commit Triggers (Proactive — do NOT wait for /acp-commit)

> **Why this section exists**: Context window overflow is silent — it terminates sessions
> without warning and without a final turn. Any knowledge not written to disk at the moment
> of discovery is permanently lost. The `/acp-commit` command is for **finalising** a session
> that already has most of its entries written, not for capturing everything at the end.
>
> **Write at the moment of discovery. Compact later.**

The agent MUST proactively write memory entries WITHOUT waiting for the developer to run
`/acp-commit` whenever ANY of these events occur:

| Trigger | Action |
|---------|--------|
| A milestone phase completes (task group or audit done) | Write `sessions.md` entry immediately |
| An audit report is created (`audit-N.md` committed) | Capture key findings in `lessons.md` |
| An architectural decision is made | Create ADR in `decisions.md` immediately |
| A new reusable pattern is discovered | Append to `patterns.md` immediately |
| A correction is given by the developer | Append to `lessons.md` immediately (Correction Protocol) |
| Context window is approaching capacity (summarisation imminent) | Write session entry NOW, before overflow |
| A `git commit` is made touching more than 5 files | Treat as phase boundary — write session entry |

**The rule**: ACP memory writes happen at the **moment of discovery**, not at session end.
`sessions.md` entries are written **incrementally per phase**, not as one end-of-session dump.

---

## Context Budget Hard Limits

> The 2,800-token budget is a **discipline practice, not a technical limit** — reproducibility, focus, and cost at scale. Exceed deliberately when needed; note it.

Enforce these limits. If exceeded, drop lower-tier content first:
- Layer 1 (core): max 500 tokens
- Layer 2 (skills): max 1,000 tokens
- Layer 3 (memory + wiki): max 3,500 tokens
- Total session context: max 5,000 tokens (before task content)

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

2. Auto-stamp `completed:` on routing task files listed in the session `tasks:` field (skip if already set; never overwrite).
3. Check: did this session produce a reusable pattern? If yes, append to `agent/memory/patterns.md`
4. Check: did you make an architectural decision? If yes, prompt: "An architectural decision was made: [decision]. Create ADR? (y/n)"
5. Count entries in sessions.md. If > 15, auto-compact oldest 10 entries into a weekly summary block
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
