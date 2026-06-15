---
id: route-074
title: "/acp-commit step 2b — auto-sync sessions documents from registry"
task_type: command-doc-write
milestone: M47
complexity: high
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/memory/sessions.md
  - agent/sessions/ (currently missing — must be created)
files_affected:
  - agent/commands/acp.commit.md
  - agent/sessions/ (new directory)
tokens_est: 500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 074: Commit Auto-Sync — Sessions Documents

## Objective

Extend `/acp-commit` step 2 with a new sub-step 2b that automatically generates or updates
markdown documents in `agent/sessions/` from the `agent/memory/sessions.md` registry after
every successful commit.

## Context

ACP Enhanced currently has a dual-store model for sessions:
- **Registry**: `agent/memory/sessions.md` (YAML list, written by `/acp-commit` step 2)
- **Documents**: `agent/sessions/*.md` (individual files, currently NOT auto-generated)

The `agent/sessions/` directory **does not exist** in the ACP Enhanced repo. Agents,
`/acp-init`, and the visualizer read from the document directory — meaning all session
data is invisible to downstream consumers. FIFOZ had 14 session entries in the registry
but zero document files until manual remediation.

## Steps

### 2b. Auto-Sync Sessions Documents (NEW)

After writing the session entry to `agent/memory/sessions.md` (Step 2), auto-generate
or update the corresponding markdown document:

1. **Read the registry**: Parse `agent/memory/sessions.md` to identify the entry just
   written (top entry, today's date).
2. **Generate filename**: `agent/sessions/{date}-{slug}.md` where:
   - `{date}` = the entry's `date:` field (YYYY-MM-DD format)
   - `{slug}` = kebab-case of first `done:` item, or executor name if no done items
3. **Create directory** if `agent/sessions/` does not exist.
4. **Write session document** in markdown format:
   ```markdown
   # Session: {date}
   
   **Executor**: {executor}
   **Branch**: {branch or "N/A"}
   
   ## Completed Tasks
   - {done item 1}
   - {done item 2}
   
   ## Deferred
   - {deferred item 1 → task-ID}
   
   ## Key Fact
   {key_fact}
   ```
5. **Idempotency**: If the file already exists with identical content, skip. If registry
   entry changed, update the file. Track a `_hash` or compare content.

### Confirmation Output Update

Step 7 confirm output should include sync counts:
```
[ACP] Session committed | 15 entries in sessions.md | sessions: 1 created, 0 updated | compacted: n
```

## Verification

- [ ] After default `/acp-commit`, `agent/sessions/{date}-{slug}.md` exists
- [ ] File content matches registry entry
- [ ] Re-running commit without changes does not rewrite file (idempotent)
- [ ] `--no-sync` flag skips this step
- [ ] Confirmation output shows sync counts
- [ ] Existing session documents are updated if registry entry changed (not overwritten if identical)

## Dependencies

- route-076 (step 6b re-sync after compaction)
- route-077 (repair sync tools share this engine)
