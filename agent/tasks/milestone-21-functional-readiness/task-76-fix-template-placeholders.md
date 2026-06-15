---
id: task-76
title: Fix 8 unfilled template placeholders in pretend-context lines
milestone: M21
task_type: command-doc-update
complexity: medium
executor: Persona A (Copilot)
files_affected:
  - agent/commands/acp.package-create.md
  - agent/commands/acp.package-install.md
  - agent/commands/acp.proceed.md
  - agent/commands/acp.plan.md
  - agent/commands/acp.project-create.md
  - agent/commands/acp.report.md
  - agent/commands/acp.resume.md
  - agent/commands/acp.task-create.md
  - agent/commands/git.commit.md
created: 2026-05-01
completed: 2026-05-01
---

<!-- @acp.meta.task
topic: problem
description: Fix 8 unfilled template placeholders in pretend-context lines
milestone: M21
status: draft
updated: 2026-05-01
@acp.meta.end -->


## Problem

The command template (`command.template.md`) contains a pretend-context line:
```
> Pretend this command was entered with this additional context: "Execute directive `@{namespace}-{command-name} NOW. ...
```

This placeholder `@{namespace}-{command-name}` was never replaced in 8 command files.
The `command.template.md` file itself is correct — it IS a template and SHOULD have the placeholder.

When an LLM reads `@acp.plan`, it encounters this in the pretend-context:
```
Execute directive `@{namespace}-{command-name} NOW.
```
Instead of:
```
Execute directive `@acp.plan NOW.
```
This weakens the directive reinforcement and may confuse the LLM about what command it is running.

## Replacements Required

| File | Replace placeholder with |
|------|--------------------------|
| `acp.package-create.md` | `@acp.package-create` |
| `acp.package-install.md` | `@acp.package-install` |
| `acp.proceed.md` | `@acp.proceed` |
| `acp.plan.md` | `@acp.plan` |
| `acp.project-create.md` | `@acp.project-create` |
| `acp.report.md` | `@acp.report` |
| `acp.resume.md` | `@acp.resume` |
| `acp.task-create.md` | `@acp.task-create` |
| `git.commit.md` | `@git.commit` |

## Acceptance Criteria

- [ ] No file in `agent/commands/` (except `command.template.md`) contains `@{namespace}-{command-name}` in a pretend-context line
- [ ] Each pretend-context line correctly states the actual command name
- [ ] `command.template.md` is NOT changed (it is the template source)
