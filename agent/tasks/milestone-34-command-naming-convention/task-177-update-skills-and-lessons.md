---
id: task-177
milestone: M34
title: Update skills/commands.md and lessons.md with naming convention link
status: completed
priority: 3
complexity: trivial
estimated_hours: 0.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: update, skillscommandsmd, and, lessonsmd, with, naming, convention, link
description: Update skills/commands.md and lessons.md with naming convention link
milestone: M34
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add a link to `agent/patterns/local.command-naming-convention.md` at the top of `agent/skills/commands.md`, and update the high-priority `@acp-foo` lessons.md entry to reference the pattern doc.

## Context

After creating the naming convention pattern doc (task-176), it should be wired into the two places agents consult most during command work:
1. `agent/skills/commands.md` — loaded whenever task_type is "command-doc-writing"
2. `agent/memory/lessons.md` — the high-priority entry about `@acp-foo` is already there

## Implementation

### Change 1: agent/skills/commands.md

Find the opening section (first 10–15 lines) of `agent/skills/commands.md`. Add after the first header or intro paragraph:

```markdown
> **Naming convention**: Before writing any command references, read  
> `agent/patterns/local.command-naming-convention.md` for the canonical  
> naming table, invocation format, and upstream porting rules.
```

### Change 2: agent/memory/lessons.md

Find the existing high-priority lesson about `@acp-foo` vs `@acp.foo` (search for `@acp-foo` or `dash after @`). The entry likely reads:

```yaml
- date: ...
  task_type: command-doc-writing
  mistake: Used @acp-foo (dash after @) instead of /acp-foo
  correction: Invocations use /acp-NAME (slash+hyphen). @acp.NAME is only the filename dot notation.
  priority: high
```

Update the `correction:` field to append:
```
  correction: Invocations use /acp-NAME (slash+hyphen). @acp.NAME is only the filename dot notation.
    See agent/patterns/local.command-naming-convention.md for the full reference.
```

## Expected Output

### Files Updated
- `agent/skills/commands.md`
- `agent/memory/lessons.md`

## Verification
- [ ] `agent/skills/commands.md` has a link to `local.command-naming-convention.md` near the top
- [ ] `agent/memory/lessons.md` high-priority `@acp-foo` entry references the pattern doc
- [ ] No other content in either file is changed

## User-Observable Acceptance
When an agent loads `agent/skills/commands.md` for a command-writing task, it immediately sees a reference to the naming convention pattern. The lesson entry provides the link as part of the correction text.
