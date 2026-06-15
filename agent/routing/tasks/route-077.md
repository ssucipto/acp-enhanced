---
id: route-077
title: "/acp-pattern-sync and /acp-session-sync — manual repair tools"
task_type: command-doc-write
milestone: M47
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.commit.md (sync engine)
  - agent/memory/patterns.md
  - agent/memory/sessions.md
files_affected:
  - agent/commands/acp.pattern-sync.md (new)
  - agent/commands/acp.session-sync.md (new)
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 077: Manual Repair Sync Tools

## Objective

Create `/acp-pattern-sync` and `/acp-session-sync` as standalone repair tools that use
the same sync engine as commit steps 2b/3b, but can be invoked without a full commit.

These are **secondary** tools — the primary workflow is commit-integrated sync.

## Context

FIFOZ feedback-001 identified that:
- 36 pattern registry entries had zero document files
- 14 session registry entries had zero document files
- Manual remediation required scripting — should be a command

These tools provide a repair path for projects that accumulated registry entries before
commit auto-sync existed (pre-v6.9).

## Command: /acp-pattern-sync

### Arguments
- `--dry-run` — Show what would be created/updated without writing
- `--all` — Sync ALL registry entries (default: only new/changed since last sync)
- `--name <pattern-name>` — Sync specific pattern only

### Steps
1. Read `agent/memory/patterns.md`
2. For each entry, check if `agent/patterns/{name}.md` exists and matches
3. Create missing files, update changed files, report skipped (unchanged) files
4. Output: `Patterns synced: N created, M updated, K skipped`

## Command: /acp-session-sync

### Arguments
- `--dry-run` — Show what would be created/updated without writing
- `--all` — Sync ALL registry entries
- `--date <YYYY-MM-DD>` — Sync specific session

### Steps
1. Read `agent/memory/sessions.md`
2. For each entry (excluding weekly-summary blocks), check if `agent/sessions/{date}-{slug}.md` exists
3. Create missing files, report skipped
4. Output: `Sessions synced: N created, M skipped`

## Shared Engine

Both commands and commit steps 2b/3b/6b use the same core logic:
- Registry parsing
- Document filename generation
- Content hashing for idempotency
- Creation/update/skip logic

## Verification

- [ ] `/acp-pattern-sync --dry-run` shows planned changes without writing
- [ ] `/acp-pattern-sync --all` creates missing pattern documents
- [ ] `/acp-session-sync --dry-run` shows planned changes without writing
- [ ] `/acp-session-sync --all` creates missing session documents
- [ ] Both commands are idempotent
- [ ] Both command docs follow ACP command doc conventions

## Dependencies

- route-074 (session sync engine)
- route-075 (pattern sync engine)
