---
id: route-082
title: "Dual-store wiki documentation — patterns and sessions"
task_type: docs-update
milestone: M47
complexity: low
executor: copilot
context_required:
  - agent/wiki/architecture.md
  - agent/memory/patterns.md
  - agent/memory/sessions.md
files_affected:
  - agent/wiki/architecture.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 082: Dual-Store Wiki Documentation

## Objective

Document the dual-store architecture for patterns and sessions in `agent/wiki/architecture.md`,
explaining the relationship between registries and document directories, and when each is used.

## Context

FIFOZ feedback-001/002 (F-03, F-07) identified that the dual-store model is undocumented.
Agents and developers don't know:
- That `agent/memory/patterns.md` is a registry, while `agent/patterns/*.md` are individual documents
- That `/acp-commit` writes registries, and auto-sync (v6.9) bridges to documents
- When to read from registry vs documents
- How the visualizer consumes data

## Changes

### Add to `agent/wiki/architecture.md`

New section: "Memory Layer — Dual-Store Architecture"

```markdown
## Memory Layer — Dual-Store Architecture

ACP Enhanced maintains a two-tier storage model for patterns and sessions:

### Registry (source of truth)
- `agent/memory/patterns.md` — YAML list of all pattern entries
- `agent/memory/sessions.md` — YAML list of all session entries
- Written by `/acp-commit` steps 2 and 3
- Compact representation, suitable for diffing and version control

### Document Directories (consumption layer)
- `agent/patterns/{name}.md` — Individual pattern documents
- `agent/sessions/{date}-{slug}.md` — Individual session documents
- Auto-synced from registries by `/acp-commit` steps 2b/3b (v6.9+)
- Consumed by `/acp-init`, `/acp-plan`, `/acp-proceed`, and the visualizer
- Human-readable markdown, one file per entry

### Sync Flow
/acp-commit
  Step 2  → writes agent/memory/sessions.md (registry)
  Step 2b → auto-syncs agent/sessions/*.md (documents) [v6.9+]
  Step 3  → writes agent/memory/patterns.md (registry)
  Step 3b → auto-syncs agent/patterns/*.md (documents) [v6.9+]

### Repair Path
- `/acp-pattern-sync --all` — regenerate all pattern documents from registry
- `/acp-session-sync --all` — regenerate all session documents from registry
- Use when documents drift from registry (e.g., manual edits, pre-v6.9 projects)
```

## Verification

- [ ] architecture.md has dual-store section
- [ ] Explains registry vs documents for both patterns and sessions
- [ ] Documents sync flow (commit steps 2b/3b)
- [ ] Documents repair path (sync commands)
- [ ] Clear about when each store is used

## Dependencies

- route-074/075 (auto-sync must exist before documenting it)
