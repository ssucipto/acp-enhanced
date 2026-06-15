---
id: local.command-naming-convention
version: 1.0.0
category: convention
---

# ACP Command Naming Convention

<!-- @acp.meta.pattern
topic: acp, command, naming, convention
description: ACP Command Naming Convention
applies_to: testing, quality
status: active
updated: 2026-06-15
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
