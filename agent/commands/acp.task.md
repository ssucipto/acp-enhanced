# Command: task

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-task` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-task` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-11  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Create, read, list, and stamp routing task files in `agent/routing/tasks/`  
**Category**: Workflow  
**Frequency**: Daily  

---

## Arguments

**Subcommands**:
- `create <title>` — create a new route-NNN.md from the route template
- `list` — list all routes with their status (completed vs pending)
- `show <route-NNN>` — display a specific route file in full
- `stamp <route-NNN>` — mark a route as completed with today's date

**Note**: This command manages routing task *records*. To create a route from a natural language description, use `/acp-route` instead.

---

## What This Command Does

`/acp-task` is the task management layer for ACP routing. It enables listing, stamping, showing, and creating task records in `agent/routing/tasks/`.

- **`create`** is a lightweight wrapper: it creates a new route file from the route template and prompts for the required frontmatter fields.
- **`list`** gives a quick snapshot of all tasks: how many are pending, how many are done.
- **`show`** displays a route file for review before implementing.
- **`stamp`** marks a route as done after implementation is complete.

---

## Prerequisites

- [ ] ACP installed in current directory (`agent/` directory exists)
- [ ] `agent/routing/tasks/` directory exists

---

## Steps

### Step 0 — Display Header

```
📋 /acp-task
  Create, list, show, and stamp routing task files
```

### Step 1 — Parse Subcommand

Detect the subcommand from the first argument. If none provided, display usage:

```
Usage:
  /acp-task create <title>     Create a new route-NNN.md
  /acp-task list               List all routes with status
  /acp-task show <route-NNN>   Display a specific route
  /acp-task stamp <route-NNN>  Mark route completed today
```

### Step 2 — Execute Subcommand

#### 2a. `create <title>`

1. List existing route files in `agent/routing/tasks/route-*.md`
2. Find the highest existing route number (e.g. route-035 → 35)
3. New route number = highest + 1, zero-padded to 3 digits
4. Read `agent/routing/tasks/route-template.md` if it exists; otherwise use this minimal template:
   ```yaml
   ---
   id: route-{NNN}
   title: {title}
   task_type:
   milestone:
   complexity:
   executor:
   context_required: []
   files_affected: []
   tokens_est:
   tokens_actual:
   cost_est_usd:
   cost_actual_usd:
   created: {today}
   completed:
   override_reason:
   ---

   ## Task Description

   ## Acceptance Criteria

   - [ ]
   ```
5. Prompt for: `task_type`, `milestone`, `complexity`, `executor` (use taxonomy.yml to suggest values)
6. Create `agent/routing/tasks/route-{NNN}.md`
7. Confirm: `✓ Created: agent/routing/tasks/route-{NNN}.md`

#### 2b. `list`

1. List all `agent/routing/tasks/route-*.md` files
2. For each file, extract: `id`, `title`, `complexity`, `completed` from YAML frontmatter
3. Display table:
   ```
   ID          Status     Complexity  Title
   ─────────────────────────────────────────────────────────────────
   route-022   ✅ done    low         M41a — Fix sessions.md YAML
   route-023   ✅ done    low         M41a — Fix HTTP-Referer
   route-024   🔄 pending medium      M41a — Create acp.feedback.md
   route-025   🔄 pending medium      M41a — Create acp.task.md
   ...
   ```
4. Display summary: `{N} tasks total | {X} completed | {Y} pending`

#### 2c. `show <route-NNN>`

1. Read `agent/routing/tasks/{route-NNN}.md`
2. Display full file content (frontmatter + body)
3. Highlight: `status`, `executor`, `files_affected`, `acceptance criteria`

#### 2d. `stamp <route-NNN>`

1. Read `agent/routing/tasks/{route-NNN}.md`
2. If `completed:` is already set → confirm with user before overwriting
3. Set `completed: {today YYYY-MM-DD}` in the YAML frontmatter
4. Write file
5. Confirm: `✓ Stamped: route-{NNN} completed {today}`

### Step 3 — Confirm

Display confirmation of the action taken and any follow-up suggestions relevant to the subcommand.
