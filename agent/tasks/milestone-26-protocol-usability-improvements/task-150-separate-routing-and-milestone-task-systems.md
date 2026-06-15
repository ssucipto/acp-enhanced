---
id: task-150
title: Separate routing task system from milestone task system — rename and document
milestone: M26
task_type: refactor
complexity: low
executor: Persona A (Copilot)
files_affected:
  - agent/routing/tasks/*.md                  # rename task-NNN.md → route-NNN.md (12 files)
  - agent/routing/tasks/task-template.md      # rename to route-template.md
  - agent/scripts/acp.install.sh              # update routing/tasks/task- references
  - agent/scripts/acp.version-update.sh       # update routing/tasks/task- references
  - .github/copilot-instructions.md           # update /acp-route task file format description
  - agent/commands/acp.route.md               # update file creation path/name format
  - AGENT.md                                  # add "Two Task Systems" explanation note
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: separate, routing, task, system, from, milestone, task, system, rename, and, document
description: Separate routing task system from milestone task system — rename and document
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Resolve the naming collision between `agent/routing/tasks/task-NNN.md` (routing dispatch
decisions) and `agent/tasks/milestone-XX-*/task-NNN-title.md` (milestone work tasks). Both
use "task" in their names but serve completely different purposes and are tracked in
different systems.

**Decision**: Rename routing task files from `task-NNN.md` → `route-NNN.md`, making the
distinction visible at a glance without changing directory structure or merging locations.

## Background

### System A — Routing Tasks (`agent/routing/tasks/`)

- **Created by**: `/acp-route` command
- **Purpose**: Routing/dispatch decisions — which executor handles this work, token estimates, cost tracking
- **Tracked in**: NOT in `progress.yaml`. Standalone routing artifacts.
- **Count**: 12 files (task-001..012)
- **Extra fields**: `tokens_est`, `tokens_actual`, `cost_est_usd`, `cost_actual_usd`, `precedes`, `executor`, `context_required`
- **IDs**: Zero-padded 3-digit (task-001, task-012)

### System B — Milestone Tasks (`agent/tasks/milestone-XX-*/`)

- **Created by**: `/acp-task-create` or manually
- **Purpose**: Work task descriptions — what to build, acceptance criteria, dependencies
- **Tracked in**: `progress.yaml` (ground truth)
- **Count**: 154 files across 19 milestone directories
- **IDs**: No zero-padding (task-1, task-145)

### Root Cause of Confusion

Both use `task-NNN.md` naming. A new contributor or agent scanning the repo sees two
"task-NNN" directories and cannot tell which is authoritative. The `/acp-route`
documentation description and the milestone task template look similar.

### Why NOT merge into one location

The routing system has distinct fields (`tokens_est`, `cost_est_usd`, `executor`) that
don't belong on milestone task files. Merging would inflate all milestone task templates
with dispatch metadata irrelevant to the work description. Two locations is correct — the
naming is just confusing.

## Resolution Strategy

**Rename routing task files** to use a `route-` prefix instead of `task-`:

| Before | After |
| --- | --- |
| `agent/routing/tasks/task-001.md` | `agent/routing/tasks/route-001.md` |
| `agent/routing/tasks/task-002.md` | `agent/routing/tasks/route-002.md` |
| `agent/routing/tasks/task-012.md` | `agent/routing/tasks/route-012.md` |
| `agent/routing/tasks/task-template.md` | `agent/routing/tasks/route-template.md` |

This makes the distinction clear:
- `agent/routing/tasks/route-*.md` = routing dispatch records
- `agent/tasks/milestone-*/task-*.md` = milestone work tasks

## Steps

### 1. Rename the routing task files

```bash
cd agent/routing/tasks
for f in task-*.md; do
  mv "$f" "route-${f#task-}"
done
```

### 2. Update internal `precedes:` references inside routing task files

Some routing tasks reference each other via `precedes: task-002`. Update these to
`precedes: route-002` to match the new names.

```bash
cd agent/routing/tasks
sed -i '' 's/precedes: task-/precedes: route-/g' route-*.md
```

### 3. Update `agent/scripts/acp.install.sh`

Find all occurrences of `routing/tasks/task-` and replace with `routing/tasks/route-`.
Also update the `cp` command that copies the template file.

### 4. Update `agent/scripts/acp.version-update.sh`

Same pattern: replace `routing/tasks/task-` with `routing/tasks/route-` in all relevant
copy/migrate lines.

### 5. Update `.github/copilot-instructions.md`

The `/acp-route` section says:
> Create `agent/routing/tasks/task-[next-id].md` with full frontmatter

Change to:
> Create `agent/routing/tasks/route-[next-id].md` with full frontmatter

Also update the Task file format section: change `id: task-[NNN]` → `id: route-[NNN]`.

### 6. Update `agent/commands/acp.route.md`

Find the step that creates the routing task file and update the filename pattern from
`task-[next-id].md` to `route-[next-id].md`.

### 7. Update `AGENT.md`

Add a short note in the Tasks section (or a new "Task Systems" subsection):

```markdown
**Two task systems coexist:**
- `agent/tasks/milestone-XX-*/task-NNN-title.md` — Milestone work tasks (tracked in `progress.yaml`)
- `agent/routing/tasks/route-NNN.md` — Routing dispatch records (created by `/acp-route`, not in progress.yaml)
```

## Verification

- [ ] `ls agent/routing/tasks/route-*.md` lists all 12 renamed routing tasks
- [ ] No `task-*.md` files remain in `agent/routing/tasks/` (except git history)
- [ ] `grep -r "routing/tasks/task-" agent/scripts/` returns no results
- [ ] `grep -r "routing/tasks/task-" .github/` returns no results
- [ ] `/acp-route` command doc generates `route-NNN.md` filenames
- [ ] `AGENT.md` explains both task systems
- [ ] E2E tests pass (routing system is not directly tested by e2e suite)

## Scope Note

This task does NOT:
- Merge the two systems into one directory
- Change the milestone task file format
- Update `progress.yaml` (routing tasks are not tracked there)
- Rename the directory `agent/routing/tasks/` (it stays — the directory name is still accurate)

## Estimated Hours

2–3 hours
