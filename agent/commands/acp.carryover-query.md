# Command: carryover-query

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-carryover-query` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-carryover-query` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-04  
**Last Updated**: 2026-06-04  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Search and filter audit carryovers from `agent/memory/audit-carryovers.md`  
**Category**: Maintenance  
**Frequency**: As Needed  

---

## Arguments

| Flag | Description |
|------|-------------|
| `--pending` | Show only carryovers with `status: pending` or `status: in-progress` |
| `--severity <level>` | Filter by severity: critical, high, medium, low |
| `--audit <N>` | Filter by audit ID (e.g., `--audit 41`) |
| `--keyword <term>` | Search finding descriptions for matching text |
| (none) | Show summary counts by status |

---

## What This Command Does

Search the `agent/memory/audit-carryovers.md` file for carryover entries. The file can
grow to 5000+ lines in production use (FIFOZ), making manual inspection impractical.
This command provides structured querying by status, severity, audit, or keyword.

---

## Steps

### 0. Display Command Header

```
⚡ /acp-carryover-query
  Search audit carryovers by status, severity, audit, or keyword

  Usage:
    /acp-carryover-query                  Show summary counts
    /acp-carryover-query --pending        Show only pending/in-progress
    /acp-carryover-query --severity high  Filter by severity
    /acp-carryover-query --audit 41       Filter by audit ID
    /acp-carryover-query --keyword test   Search descriptions

  Related:
    /acp-audit    Creates audit reports and carryover entries
    /acp-status   Project health check
```

### 1. Read Carryovers File

Read `agent/memory/audit-carryovers.md` and parse YAML carryover entries.

### 2. Apply Filters

Apply any combination of `--pending`, `--severity`, `--audit`, `--keyword` filters.

### 3. Display Results

**Default (no filters)** — summary:
```
Carryovers: 4 pending, 28 fixed, 0 in-progress
```

**With filters** — table:
```
Pending carryovers (--pending):

  GAP-041-07 (medium): No E2E test route in M47
    File: [no specific file]
    Fix: Create route for E2E tests covering commit auto-sync
    Escalated: M48 routes 085-086

  GAP-041-08 (medium): Atomicity not addressed in sync design
    File: agent/commands/acp.commit.md
    Fix: Consider temp-file+atomic-rename approach
    Escalated: M48 route-087
```

## Verification

- [ ] `--pending` shows only pending/in-progress carryovers
- [ ] `--severity high` filters correctly
- [ ] `--audit 41` shows audit-041 carryovers only
- [ ] `--keyword test` finds E2E test-related carryovers
- [ ] No filters shows summary counts

---

## Examples

### Show pending only

**Invocation**: `/acp-carryover-query --pending`  

**Result**: Lists 4 pending carryovers from audit-041.

### Find high-severity items

**Invocation**: `/acp-carryover-query --severity high`  

**Result**: Shows only HIGH-severity carryovers across all audits.

---

## Related Commands

- [`/acp-audit`](acp.audit.md) — Creates audit reports and carryover entries
- [`/acp-review`](acp.review.md) — Creates review carryovers via `--carryover` flag
- [`/acp-repair-tools`](acp.repair-tools.md) — Auto-resolve carryover findings
- [`/acp-status`](acp.status.md) — Project health check including carryover counts
