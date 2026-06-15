---
id: task-145
title: Auto-stamp `completed:` on routing task files in /acp-commit
milestone: M26
task_type: command-doc-update
complexity: medium
executor: Persona A (Copilot)
files_affected:
  - agent/commands/git.commit.md
  - agent/routing/tasks/ (runtime — not a static file)
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: auto-stamp, completed, on, routing, task, files, in, acp-commit
description: Auto-stamp `completed:` on routing task files in /acp-commit
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Update the `/acp-commit` command (implemented via `agent/commands/git.commit.md`) to automatically set the `completed: <date>` field on routing task files for each task listed in the session's `tasks:` frontmatter block. This eliminates manual completion-stamping and prevents BUG-01 class omissions.

## Context

- **Root cause of BUG-01**: `task-011.md` was left with a blank `completed:` after the work was done and committed. The `/acp-commit` command asks the agent to "mark completed tasks" but provides no automated mechanism — it relies on the agent remembering to do it manually.
- **Routing task format**: `agent/routing/tasks/task-NNN.md` files have YAML frontmatter with a `completed:` field. When blank, it's treated as incomplete even if the work is done.
- **Session format**: `agent/memory/sessions.md` entries have a `tasks:` list of task IDs that were completed in the session.

## Steps

1. **Read `agent/commands/git.commit.md`** — find the current step that says "mark completed tasks" or equivalent
2. **Add a new step** (before the git commit step) with these sub-steps:
   a. Read the `tasks:` list from the session being committed (from the session YAML the agent is about to write)
   b. For each task ID in the list:
      - Locate `agent/routing/tasks/<task-id>.md`
      - If it exists AND `completed:` field is blank or missing: set `completed: <today's date in YYYY-MM-DD>`
      - If `completed:` is already set: skip (do not overwrite)
      - If the file does not exist: skip silently (task may be in `agent/tasks/` format, not routing format)
   c. Stage the modified routing task files with the session commit
3. **Add to the commit message convention**: include a note if routing task files were auto-stamped (e.g., `auto-stamped: task-011, task-012`)
4. **Verify** the step is in the correct position in the git.commit.md directive sequence

## Verification

- [ ] `agent/commands/git.commit.md` contains a "Auto-stamp task completion" step
- [ ] The step reads the `tasks:` list from the session being committed
- [ ] The step finds matching `agent/routing/tasks/<id>.md` files and sets `completed: <date>`
- [ ] The step skips tasks already stamped (no overwrite)
- [ ] The step skips task IDs with no routing task file (graceful fallback)
- [ ] Routing task files are staged as part of the session commit

## Dependencies

- None — this is a standalone command doc update

## Estimated Hours

2–3 hours
