# Command: session-sync

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-session-sync` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-session-sync` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-04  
**Last Updated**: 2026-06-04  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Manual repair tool — sync session documents from registry. Same engine as `/acp-commit` step 2b, callable without a full commit.  
**Category**: Memory  
**Frequency**: Repair only (primary workflow is commit-integrated sync)  

---

## Arguments

| Flag | Description |
|------|-------------|
| `--dry-run` | Show what would be created/updated without writing any files |
| `--all` | Sync ALL registry entries (default: only new/changed since last sync) |
| `--date <YYYY-MM-DD>` | Sync a specific session by date |

---

## What This Command Does

This is a **manual repair tool** — not the primary workflow. The primary sync trigger is `/acp-commit` (steps 2b, 6b), which auto-syncs session documents on every commit.

Use `/acp-session-sync` when:
- Sessions accumulated in `agent/memory/sessions.md` before v6.9 (pre-auto-sync era)
- Documents drifted from registry due to manual edits
- You want to preview what would change before running `/acp-commit`

---

## Prerequisites

- [ ] `agent/memory/sessions.md` exists
- [ ] `agent/sessions/` directory exists (will be created if missing)

---

## Steps

### 0. Display Command Header

```
⚡ /acp-session-sync
  Manual repair — sync session documents from registry

  Usage:
    /acp-session-sync                Sync new/changed sessions only
    /acp-session-sync --dry-run      Preview without writing
    /acp-session-sync --all          Sync ALL registry entries
    /acp-session-sync --date <date>  Sync specific session

  Related:
    /acp-pattern-sync   Sync pattern documents
    /acp-commit         Primary workflow (auto-syncs on commit)
```

### 1. Read Registry

Read `agent/memory/sessions.md` and parse all YAML entries. Skip `type: weekly-summary` blocks.

### 2. Determine Sync Scope

- Default: Sync only entries that are new or changed since last sync
- `--all`: Sync every entry in the registry
- `--date <YYYY-MM-DD>`: Sync only the session with matching date

### 3. Sync Session Documents

> **Atomicity (v6.9.1+)**: Write to `.tmp.{date}-{slug}.md` first, then atomically
> rename to `{date}-{slug}.md`. Prevents partial writes.

For each session in scope:

1. **Determine filename**: `agent/sessions/{date}-{slug}.md` where:
   - `{date}` = the entry's `date:` field
   - `{slug}` = kebab-case of first `done:` item (truncated to ~50 chars), or executor name if empty
2. **Create directory** if `agent/sessions/` does not exist
3. **Check existing**: If file exists with identical content → skip
4. **Write/update**: Generate markdown document from registry entry:

```markdown
# Session: {date}

**Executor**: {executor}
**Branch**: {branch or "N/A"}
**Tasks**: {tasks_completed list}

## Completed
{one done: item per line as a bullet list}

## Deferred
{one deferred item per line, or "None"}

## Key Fact
{key_fact or "None"}
```

### 4. Report

```
Sessions synced: N created, M skipped
```

Or with `--dry-run`:
```
[DRY RUN] Would create: N, Would skip: M
```

---

## Verification

- [ ] Missing session documents are created
- [ ] Existing unchanged documents are skipped (idempotent)
- [ ] `--dry-run` shows planned changes without writing
- [ ] `agent/sessions/` directory created if missing
- [ ] Weekly-summary blocks in registry are skipped

---

## Examples

### Sync all sessions (first run after v6.9 upgrade)

**Invocation**: `/acp-session-sync --all`  

**Result**: 14 session documents created from registry, 0 skipped.

### Preview before sync

**Invocation**: `/acp-session-sync --dry-run`  

**Result**: Shows what would be created without modifying files.
