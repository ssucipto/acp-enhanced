---
id: route-076
title: "/acp-commit step 6b — re-sync session documents after weekly compaction"
task_type: command-doc-write
milestone: M47
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/memory/sessions.md
files_affected:
  - agent/commands/acp.commit.md
tokens_est: 350
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 076: Commit Auto-Sync — Re-Sync After Compaction

## Objective

Extend `/acp-commit` step 6 with a new sub-step 6b that re-syncs affected session documents
after the weekly compaction replaces 10 oldest entries with a summary block.

## Context

`/acp-commit` step 6 compacts sessions when the registry exceeds 15 entries:
- Extracts key_facts from oldest 10 entries
- Replaces them with a single `type: weekly-summary` block
- This changes the registry structure — individual session files for the compacted entries
  may no longer have corresponding entries

Step 6b ensures the document directory stays consistent after compaction.

## Steps

### 6b. Re-Sync Affected Session Documents (NEW)

After compaction (Step 6), re-sync the affected session documents:

1. **Identify compacted entries**: Track which entries were compacted (the oldest 10).
2. **Remove orphaned documents**: If individual session files exist for compacted entries,
   remove them (they're now represented by the weekly-summary block only).
3. **Generate weekly-summary document** (optional): Create a `agent/sessions/weekly-{week}.md`
   file representing the compacted summary block.
4. **Confirmation**: Report how many documents were removed/created after compaction.

### YAML Quoting for Compaction

When writing the weekly-summary block in Step 6, ensure `key_facts` list items containing
`:` are quoted to prevent YAML parse failures (per route-080).

## Verification

- [ ] After compaction, old individual session files are cleaned up
- [ ] No orphaned session documents remain
- [ ] Weekly-summary block writes quoted key_facts (per route-080)
- [ ] Confirmation output reports compaction + re-sync counts

## Dependencies

- route-074 (session sync engine)
- route-080 (YAML quoting directives)
