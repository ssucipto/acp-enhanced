---
id: route-128
title: "Wiki: Cursor integration guide from cursor-acp-enhanced.md feedback reference"
task_type: wiki-update
milestone: M53
complexity: low
executor: copilot
context_required:
  - agent/feedback/cursor-acp-enhanced.md
  - agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md
  - agent/wiki/
files_affected:
  - agent/wiki/cursor-integration.md
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 128: Cursor Integration Wiki Guide

## Objective

Create `agent/wiki/cursor-integration.md` from the `cursor-acp-enhanced.md` feedback reference, documenting how Cursor users invoke ACP commands and how slash commands stay in sync.

## Context

Per feedback-001 §3.4: "Add a short Cursor integration section... How slash commands are generated, when to re-run sync, troubleshooting."

## Changes

### Create `agent/wiki/cursor-integration.md`

Content adapted from `agent/feedback/cursor-acp-enhanced.md`:

```markdown
# ACP Enhanced — Cursor Integration

## Invocation

| Method | Example | Status |
|--------|---------|--------|
| Slash command | `/acp-init` | ✅ Preferred (auto-generated during install) |
| @-mention alias | `@acp-init` | ✅ Works (legacy fallback) |
| File reference | `@agent/commands/acp.init.md` | ✅ Works (direct source) |

## How Slash Commands Are Generated

`agent/scripts/acp.cursor-commands-sync.sh` reads every `agent/commands/acp.*.md`
and `git.*.md` and writes matching `.cursor/commands/<slash-name>.md` wrappers.

Naming rule: dots → hyphens (`acp.design-spec` → `/acp-design-spec`).

## When to Re-Sync

- After `acp.install.sh` or `acp.version-update.sh` (auto)
- After adding a new command under `agent/commands/`
- After changing a command **Purpose** line

```bash
./agent/scripts/acp.cursor-commands-sync.sh
```

## Troubleshooting

- **`/` menu stale**: Reload Cursor window (Cmd+Shift+P → "Developer: Reload Window")
- **Commands missing after update**: Re-run sync script manually
- **Wrapper content outdated**: Sync script regenerates from canonical sources
```

### Create `.cursor/rules/acp-slash-commands.mdc` (G-048-05)

Per feedback-001 §3.3, this always-on Cursor rule ensures agents execute (not just read)
command files when invoked via `@acp-*` or `@agent/commands/` aliases:

```markdown
---
alwaysApply: true
---
# ACP Enhanced — Slash Command Protocol

When a user invokes any of these equivalent forms, you MUST execute the full
command specification from `agent/commands/`:

- `/acp-*` — **preferred** (native Cursor slash command from `.cursor/commands/`)
- `@acp-*` — legacy alias (when slash picker unavailable)
- `@agent/commands/acp.*.md` — direct source reference

All three forms are execution aliases — they are NOT read-only file references.
Load and run every step from the canonical `agent/commands/acp.*.md` source.

**Naming**: `/acp-init` = `agent/commands/acp.init.md` (dots → hyphens in slash form).
```

## Verification

- [ ] `agent/wiki/cursor-integration.md` exists
- [ ] `.cursor/rules/acp-slash-commands.mdc` exists with `alwaysApply: true`
- [ ] Covers invocation methods (slash, @-mention, file reference)
- [ ] Documents naming rule (dots → hyphens)
- [ ] Documents when to re-sync
- [ ] Includes troubleshooting section
- [ ] `.cursor/rules/` rule defines execution aliases (not read-only refs)
