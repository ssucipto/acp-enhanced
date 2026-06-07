# ACP Enhanced — Agent Context Protocol

> **Canonical protocol source** — synced to CLAUDE.md on commit via pre-commit hook.
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

**Mode selection** (read `agent/core/routing.yml → context_modes`):

- **Light mode** (default for daily dev): Load identity.yml + progress.yaml + last 3 sessions (~200 tokens). Use this for bug fixes, CRUD, UI components, audits, and routine tasks.
- **Full mode** (triggered by `/acp-init`, architecture sessions, new workspace): Load all 6 steps (~800 tokens). Use this for design documents, schema changes, ADRs, and first sessions.

### Light Mode (default — most sessions)

1. Read `agent/core/identity.yml` — project identity and stack
2. Read `agent/progress.yaml` — current milestone, recent work, next steps
3. Read last 3 entries from `agent/memory/sessions.md` — session history + deferred items
4. Output the confirm banner (MUST be the first output before any task work), populating variables
   from the actual loaded data:
   - `{executor}` = from `agent/core/routing.yml → session.executor`
   - `{date}` = from last entry in sessions.md
   - `{mode}` = `light`

```
[ACP] light | executor: [executor] | last session: [date] | est. ~200 tokens
```

5. **Set current mode**: Update `agent/core/routing.yml → context_modes.current` to `light`.

5. **Mode recommendation**: After outputting the banner, check the task_type against
   `agent/core/routing.yml → context_modes.light.recommend_full_for`. If the task matches
   one of those types (architecture-design, data-schema, adr-write, milestone-create,
   upstream-parity-check), append:
   ```
   💡 This task may benefit from full context. Run /acp-init to switch.
   ```

> **Mode switching**: To switch from light to full, run `/acp-init`. Light mode is the
> default for all new sessions — no action needed to stay in light mode.

> **Checking your mode**: Run `/acp-status` — the mode banner is shown at session start.
> You can also check `agent/core/routing.yml → context_modes.current`.

### Full Mode (`/acp-init` or auto-triggered)

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

### Step 3 — Skills are Now @-Mention Invoked (v6.8.2, R6)

Skill files are no longer auto-loaded by task_type. Instead, they are invoked explicitly:

- User types `@{skill-name}` in chat (e.g., `@{testing}`, `@{commands}`)
- Agent reads the corresponding `agent/skills/{skill-name}.md`
- Agent applies conventions from the skill file to the current task
- Brief acknowledgement: `[@testing] Loaded testing conventions.`

> See `agent/routing/taxonomy.yml → skills_catalog` for the full list of 7 @-mentions.
> The auto-load mechanism (Step 3 in pre-v6.8.2) is deprecated. Skill files
> remain available for direct reading when needed.

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

### Step 5 — Load Reference (section only, if needed)
Only if the task requires it:
- ACP architecture decisions → load specific ADR from `agent/memory/decisions.md` by ID
- Domain/command taxonomy → load relevant section of `agent/wiki/domain.yml`
- Package/script integration patterns → load relevant section of `agent/wiki/architecture.md`

**Never load an entire wiki file. Load one section at a time.**

### Step 6 — Confirm and Proceed
Before starting the task, output one line, populating variables from loaded data:
- `{executor}` = from `agent/core/routing.yml → session.executor`
- `{count}` = number of files loaded in steps 1–5
- `{mode}` = `full`

`[ACP] full | executor: [executor] | est. ~800 tokens | files: [N] | mode: full`

Then update `agent/core/routing.yml → context_modes.current` to `full`.

Then check the task_type against `agent/core/routing.yml → context_modes.full.recommend_light_for`.
If the task matches a light-sufficient type (bug-fix, command-doc-update, docs-update,
changelog-update, progress-update, audit-run, memory-write), append:
```
💡 Light mode would be sufficient for this task type. Next session will default to light.
```

> **Mode switching**: Full mode is triggered by `/acp-init`, first sessions, or architecture
> tasks. To return to light mode, simply start a new session — light is the default. No
> explicit command is needed to switch back.

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

## Post-Command Discoverability (added v6.8.2, audit-024)

> **Why this exists**: 43 of 48 commands were never invoked in 14 sessions of production
> use. Users don't know what's available. This section ensures the agent surfaces relevant
> commands contextually — similar to how VS Code's command palette shows "Related" commands
> and npm shows "Did you know?" tips after install.

### Rule: Suggest Related Commands After Every Command

After completing ANY command execution (reading and executing a command doc), display
2–3 related commands from `agent/core/routing.yml → command_suggestions`. Each suggestion
MUST include:

1. The command name (in `/acp-command` format)
2. A one-line description of **when** to use it (not what it does)

Format:
```
📋 Related: /acp-xxx (when to use it) · /acp-yyy (when to use it) · /acp-zzz (when to use it)
```

If the invoked command is not in `command_suggestions`, use your best judgment to suggest
2–3 logically related commands based on what was just completed.

### Rule: Surface Underused Commands Proactively

When a session involves repetitive work (same task type 3+ times), suggest a command
that could automate or improve that workflow:

```
💡 Tip: /acp-xxx can [benefit]. You've done this 3 times manually this session.
```

### Rule: "Getting Started" Check

If this is the user's first session with ACP Enhanced, or they haven't used it in >7 days,
suggest:
```
👋 New to ACP Enhanced? Try /acp-status to see your project state, then /acp-proceed to start working.
```

---

## Context Budget Hard Limits

> **Why does this budget exist?**
> The 2,800-token budget is a **discipline practice, not a technical limit**.
> Modern LLMs (Claude 3.5+, GPT-4o, Gemini 1.5) have 100K–200K token context windows —
> this budget is not required to prevent context overflow.
>
> The budget exists because:
> - **Reproducibility** — deterministic loading means every session starts identically
> - **Speed and cost** — smaller prompts are faster and cheaper at API scale
> - **Focus** — less context forces the agent to load only what is decision-relevant
> - **Credibility** — ACP preaches discipline; the protocol must model what it teaches
>
> If a task genuinely requires more context, exceed the budget deliberately and note it.
> The budget is a default, not a ceiling.

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
3b. **Auto-populate lessons from key_fact** (added v6.8.2, audit-022 R2):
   If this session's `key_fact` contains a reusable lesson, auto-append to
   `agent/memory/lessons.md`:
   ```yaml
   - date: [today]
     scope: [inferred from task_type, e.g. backend-python, frontend-react-native, testing]
     task_type: [from session]
     lesson: [key_fact text]
     priority: [high if contains CRITICAL/SECURITY/BROKEN/CRASH/CORRUPTION/never/must/always/IDOR, else normal]
     source: session-key-fact
   ```
   Before writing, check for duplicates by reading the last 10 entries in lessons.md.
   If any existing lesson covers the same topic (same technology, same problem category,
   same root cause), skip it — do not write a near-duplicate lesson.
   Only write if the lesson is materially new.
3c. **Auto-update observability** (added v6.8.2, audit-022 R8):
   Read `agent/routing/ledger.md` and aggregate the latest session's data into
   `agent/progress.yaml → observability`:
   - `this_week`: sessions count, total tokens, total cost, top executor
   - `by_executor`: per-model breakdown (tasks, tokens, cost, error rate)
   - `weekly_trend`: append this week's totals to the trend array
   If ledger is empty or unavailable, leave observability fields unchanged.
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
