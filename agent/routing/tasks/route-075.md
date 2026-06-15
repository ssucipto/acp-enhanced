---
id: route-075
title: "/acp-commit step 3b — auto-sync patterns documents from registry"
task_type: command-doc-write
milestone: M47
complexity: high
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/memory/patterns.md
  - agent/patterns/
files_affected:
  - agent/commands/acp.commit.md
  - agent/patterns/ (existing — sync into it)
tokens_est: 500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 075: Commit Auto-Sync — Patterns Documents

## Objective

Extend `/acp-commit` step 3 with a new sub-step 3b that automatically generates or updates
markdown documents in `agent/patterns/` from the `agent/memory/patterns.md` registry after
every successful commit.

## Context

ACP Enhanced currently has a dual-store model for patterns:
- **Registry**: `agent/memory/patterns.md` (YAML list, appended by `/acp-commit` step 3)
- **Documents**: `agent/patterns/*.md` (individual files, currently created only by
  `/acp-pattern-create` or manually)

The `agent/patterns/` directory in ACP Enhanced contains only 10 template/sample files.
FIFOZ had 36 registry entries but zero corresponding document files — all created manually.
Commands like `/acp-init`, `/acp-plan`, and `/acp-proceed` read from `agent/patterns/`,
not the registry.

## Steps

### 3b. Auto-Sync Patterns Documents (NEW)

After appending to `agent/memory/patterns.md` (Step 3), auto-generate or update
the corresponding markdown document:

1. **Read the registry**: Parse `agent/memory/patterns.md` to identify entries that are
   new or changed since last sync.
2. **Generate filename**: `agent/patterns/{name}.md` where `{name}` is the pattern's
   `name:` field.
3. **Write pattern document** in markdown format:
   ```markdown
   # Pattern: {name}
   
   **Date**: {date}
   **Task Type**: {task_type}
   **Code Ref**: {code_ref or "N/A"}
   
   ## Description
   {description}
   
   ## Template
   {template or "N/A"}
   ```
4. **Respect existing namespace**: If `agent/patterns/` already contains `local.*.md`
   files (project-specific), new patterns from the registry use the same namespace
   convention. Package patterns use `{namespace}.{name}.md`.
5. **Idempotency**: Same as route-074 — skip if identical, update if changed.

### Confirmation Output Update

Step 7 confirm output:
```
[ACP] Session committed | 15 entries in sessions.md | sessions: 1 created | patterns: 1 created | compacted: n
```

## Verification

- [ ] After default `/acp-commit`, `agent/patterns/{name}.md` exists for new/changed entries
- [ ] File content matches registry entry
- [ ] Re-running commit without changes is idempotent
- [ ] `--no-sync` flag skips this step
- [ ] Existing pattern documents are not overwritten if unchanged
- [ ] Namespace conventions preserved (local.* for projects, {ns}.* for packages)

## Dependencies

- route-074 (shares sync engine design)
- route-077 (repair sync tools share this engine)
- route-083 (pattern promotion in commit step 3)
