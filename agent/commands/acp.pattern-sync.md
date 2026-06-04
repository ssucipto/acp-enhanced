# Command: pattern-sync

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-pattern-sync` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-pattern-sync` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-04  
**Last Updated**: 2026-06-04  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Manual repair tool — sync pattern documents from registry. Same engine as `/acp-commit` step 3b, callable without a full commit.  
**Category**: Memory  
**Frequency**: Repair only (primary workflow is commit-integrated sync)  

---

## Arguments

| Flag | Description |
|------|-------------|
| `--dry-run` | Show what would be created/updated without writing any files |
| `--all` | Sync ALL registry entries (default: only new/changed since last sync) |
| `--name <pattern-name>` | Sync a specific pattern by name |

---

## What This Command Does

This is a **manual repair tool** — not the primary workflow. The primary sync trigger is `/acp-commit` (steps 3b, 6b), which auto-syncs pattern documents on every commit.

Use `/acp-pattern-sync` when:
- Patterns accumulated in `agent/memory/patterns.md` before v6.9 (pre-auto-sync era)
- Documents drifted from registry due to manual edits
- You want to preview what would change before running `/acp-commit`

---

## Prerequisites

- [ ] `agent/memory/patterns.md` exists
- [ ] `agent/patterns/` directory exists

---

## Steps

### 0. Display Command Header

```
⚡ /acp-pattern-sync
  Manual repair — sync pattern documents from registry

  Usage:
    /acp-pattern-sync               Sync new/changed patterns only
    /acp-pattern-sync --dry-run     Preview without writing
    /acp-pattern-sync --all         Sync ALL registry entries
    /acp-pattern-sync --name <name> Sync specific pattern

  Related:
    /acp-session-sync   Sync session documents
    /acp-commit         Primary workflow (auto-syncs on commit)
    /acp-validate       Check for YAML issues before syncing
```

### 1. Read Registry

Read `agent/memory/patterns.md` and parse all YAML entries.

### 2. Determine Sync Scope

- Default: Sync only entries that are new or changed since last sync
- `--all`: Sync every entry in the registry
- `--name <name>`: Sync only the entry with matching `name:` field

### 3. Sync Pattern Documents

> **Atomicity (v6.9.1+)**: Write to `.tmp.{name}.md` first, then atomically rename
> to `{name}.md`. Prevents partial writes from leaving corrupted documents.

For each pattern in scope:

1. **Determine filename**: `agent/patterns/{name}.md` where `{name}` is the `name:` field
2. **Check existing**: If file exists with identical content → skip
3. **Write/update**: Generate markdown document from registry entry:

```markdown
# Pattern: {name}

**Date**: {date}
**Task Type**: {task_type or "N/A"}
**Code Ref**: {code_ref or "N/A"}

## Description
{description}

## Template
{template or "N/A"}
```

4. **Respect namespace**: `local.{name}.md` for project patterns, `{ns}.{name}.md` for packages

### 4. Report

```
Patterns synced: N created, M updated, K skipped
```

Or with `--dry-run`:
```
[DRY RUN] Would create: N, Would update: M, Would skip: K
```

---

## Verification

- [ ] Missing pattern documents are created
- [ ] Changed pattern documents are updated
- [ ] Unchanged documents are skipped (idempotent)
- [ ] `--dry-run` shows planned changes without writing
- [ ] Namespace conventions respected

---

## Examples

### Sync all patterns (first run after v6.9 upgrade)

**Invocation**: `/acp-pattern-sync --all`  

**Result**: 36 pattern documents created from registry, 0 updated, 0 skipped.

### Preview before sync

**Invocation**: `/acp-pattern-sync --dry-run`  

**Result**: Shows what would be created/updated without modifying files.
