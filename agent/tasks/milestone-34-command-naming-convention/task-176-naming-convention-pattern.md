---
id: task-176
milestone: M34
title: Create command-naming-convention pattern document
status: completed
priority: 3
complexity: low
estimated_hours: 1.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Create `agent/patterns/local.command-naming-convention.md` as the single canonical reference for the ACP Enhanced command naming system: dot notation filenames, hyphen invocation, triple-file architecture, and upstream porting rules.

## Context

The naming duality (`/acp-` vs `@acp.`) has caused repeated mistakes (logged in lessons.md as high-priority). The convention spans 3 file types, 2 naming formats, and has a specific porting rule for upstream content. A dedicated pattern doc gives agents and contributors a compact reference that can be linked from AGENT.md, skills/commands.md, and lessons.md.

## Implementation

Create `agent/patterns/local.command-naming-convention.md`:

```markdown
---
id: local.command-naming-convention
version: 1.0.0
category: convention
---

# ACP Command Naming Convention

<!-- @acp.meta.task
topic: acp, command, naming, convention
description: Create command-naming-convention pattern document
milestone: M34
status: completed
updated: 2026-05-05
@acp.meta.end -->



## Intent
Establish a consistent, unambiguous naming system for all ACP commands across command
directive files, IDE prompt integrations, and runtime invocations.

## The Triple-File Architecture

Every ACP command requires exactly 3 files. All must exist together:

| # | Surface | Path | Name format | Example |
|---|---|---|---|---|
| 1 | Command directive | `agent/commands/acp.NAME.md` | `acp.NAME.md` | `acp.plan.md` |
| 2 | VS Code prompt | `.github/prompts/acp-NAME.prompt.md` | `acp-NAME.prompt.md` | `acp-plan.prompt.md` |
| 3 | opencode command | `.opencode/commands/acp-NAME.md` | `acp-NAME.md` | `acp-plan.md` |

**Rule**: File #1 uses **dot** separators. Files #2 and #3 use **hyphen** separators.

## Invocation

| Context | Format | Example |
|---|---|---|
| User types in VS Code | `/acp-NAME` | `/acp-plan` |
| User types in opencode | `/acp-NAME` | `/acp-plan` |
| Agent references in body text | `/acp-NAME` | "run `/acp-plan`" |
| Filename reference | `acp.NAME.md` | "see `acp.plan.md`" |

## Critical Anti-Patterns

```
❌ @acp-plan      # dash after @ — NEVER valid
❌ @acp plan      # space — NEVER valid
❌ acp-plan.md    # wrong separator for command directive filename
❌ /acp.plan      # dot in invocation — wrong
✅ /acp-plan      # correct invocation
✅ acp.plan.md    # correct directive filename
```

## Upstream Porting Rule

Upstream ACP uses `@acp.<name>` as the invocation syntax. When porting content:
```
Replace: @acp.foo-bar → /acp-foo-bar (everywhere in text, steps, examples)
Replace: @acp.foo     → /acp-foo
Never:   @acp-foo     # hyphen is never used after @
```

## Creating New Commands

Use `/acp-command-create` — it scaffolds all 3 files with correct names and template content.

## Related
- ADR-4 (command naming convention decision)
- ADR-6 (triple-file architecture decision)
- `agent/skills/commands.md`
- `agent/commands/acp.command-create.md`
```

Keep the total file ≤70 lines.

## Expected Output

### Files Created
- `agent/patterns/local.command-naming-convention.md`

## Verification
- [ ] File has valid YAML frontmatter
- [ ] File has naming table (3 rows for triple-file)
- [ ] File has invocation table
- [ ] File has anti-patterns section with ❌/✅ examples
- [ ] File has upstream porting rule
- [ ] File is ≤70 lines

## User-Observable Acceptance
An agent that reads this pattern doc before writing command references will use `/acp-plan` (not `@acp-plan` or `@acp.plan`) for invocations and will correctly translate upstream `@acp.foo` → `/acp-foo`.
