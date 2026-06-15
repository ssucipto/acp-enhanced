---
id: task-146
title: Standardize task status format — deprecate `**Status**:` in favour of YAML `completed:`
milestone: M26
task_type: command-doc-update
complexity: medium
executor: Persona A (Copilot)
files_affected:
  - agent/commands/acp.task-create.md
  - agent/tasks/task-1-{title}.template.md (or equivalent task template)
  - agent/commands/acp.proceed.md (status display step)
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: standardize, task, status, format, deprecate, status, in, favour, of, yaml, completed
description: Standardize task status format — deprecate `**Status**:` in favour of YAML `completed:`
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Eliminate the two-tier task status format confusion identified in audit-002. The old format uses `**Status**: Not Started / In Progress / Completed` as a markdown body field. The new format uses `completed: <date>` in YAML frontmatter. Both exist in `agent/tasks/` simultaneously. Standardize on the YAML `completed:` field as the sole status indicator going forward.

## Context

- **Old format** (M1–M10 era): markdown body field `**Status**: Not Started` — updated manually, never reliably
- **New format** (M20+ era): YAML frontmatter `completed: <date>` — more machine-parseable, used by routing tasks
- **Ground truth**: `agent/progress.yaml` — this does NOT change; it remains authoritative
- **Scope**: Only update the *template* and the *task-create command*. Do NOT bulk-update 112 existing stale task files — the audit determined that effort outweighs the benefit.
- **task-create**: `agent/commands/acp.task-create.md` generates new task files; it must produce the YAML frontmatter format

## Steps

1. **Read `agent/commands/acp.task-create.md`** — find the task file template block it uses
2. **Find the task template file** — likely `agent/tasks/task-1-{title}.template.md` or similar
3. **Update the template** to:
   - Remove `**Status**: Not Started` from the markdown body (if present)
   - Add `completed:` (blank) to the YAML frontmatter block (after `created:`)
   - Add a comment: `# Set by /acp-commit automatically — do not edit manually`
4. **Update `agent/commands/acp.task-create.md`**:
   - Ensure the generated task frontmatter includes `completed:` field
   - Ensure the generated task body does NOT include a `**Status**:` markdown line
5. **Update `agent/commands/acp.proceed.md`** (if it displays task status):
   - Ensure status display reads `completed:` YAML field, not `**Status**:` markdown
   - If both are checked, keep backward compat but prefer YAML field
6. **Add a deprecation note** to `AGENT.md` in the Tasks section (one line): "`**Status**:` fields in task bodies are deprecated — use YAML `completed:` frontmatter"

## Verification

- [ ] Task template file produces YAML frontmatter with `completed:` field
- [ ] Task template file does NOT produce `**Status**: Not Started` in body
- [ ] `acp.task-create.md` step that generates task frontmatter includes `completed:` field
- [ ] `acp.proceed.md` reads `completed:` field when determining task completion status
- [ ] `AGENT.md` Tasks section mentions `completed:` as the current format
- [ ] Existing task files are NOT mass-updated (backward compat preserved)

## Dependencies

- task-145 (auto-stamp) — complements this task; both should be in same commit if possible

## Estimated Hours

3–4 hours
