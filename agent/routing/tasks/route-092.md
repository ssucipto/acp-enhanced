---
id: route-092
title: "Carryover query — CLI search for audit-carryovers.md"
task_type: command-doc-write
milestone: M48
complexity: low
executor: copilot
context_required:
  - agent/memory/audit-carryovers.md
  - agent/commands/acp.audit.md
files_affected:
  - agent/commands/acp.carryover-query.md (new)
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 092: Carryover Query

## Objective

Create a `/acp-carryover-query` command to search the 5000+ line
`agent/memory/audit-carryovers.md` file, making it queryable by status,
severity, audit ID, or keyword.

## Context

FIFOZ feedback-002 (B-066-08) noted that `audit-carryovers.md` at 5000+ lines
is unqueryable — agents and developers can't easily find pending items or
check if a finding was already addressed. A search command solves this.

## Command: /acp-carryover-query

### Arguments
- `--pending` — Show only pending carryovers
- `--severity <level>` — Filter by severity (critical/high/medium/low)
- `--audit <N>` — Filter by audit ID
- `--keyword <term>` — Search finding descriptions

### Steps
1. Read `agent/memory/audit-carryovers.md`
2. Parse YAML carryover entries
3. Apply filters
4. Output matching entries in table format

### Output
```
Carryovers: 4 pending, 28 fixed

Pending:
  GAP-041-07 (medium): No E2E test route in M47
  GAP-041-08 (medium): Atomicity not addressed in sync design
  GAP-041-04 (low): F-05 registry schema lint not covered
  GAP-041-06 (medium): No CHANGELOG update route — ✅ fixed 2026-06-04
```

## Verification

- [ ] `--pending` shows only pending carryovers
- [ ] `--severity high` filters correctly
- [ ] `--audit 41` shows audit-041 carryovers
- [ ] `--keyword test` finds E2E test-related carryovers

## Dependencies

None.
