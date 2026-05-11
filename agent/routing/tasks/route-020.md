---
id: route-020
title: M40 — Add Step 4.4 carryover check to context-loading protocol
task_type: command-doc-update
milestone: M40
complexity: low
executor: deepseek-v4-flash
context_required:
  - AGENTS.md
  - agent/memory/audit-carryovers.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
tokens_est: 2500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Add Step 4.4 to the Step 4 (Load Working Memory) block in all three protocol files. The new
sub-step checks `agent/memory/audit-carryovers.md` for pending items at session start and
surfaces them before work begins, preventing silent carryover loss between sessions.

## Acceptance Criteria

- [ ] Step 4.4 added in `AGENTS.md` Step 4 block (after existing sub-step 3)
- [ ] Step 4.4 added in `CLAUDE.md` Step 4 block
- [ ] Step 4.4 added in `.github/copilot-instructions.md` Step 4 block
- [ ] Step 4.4 reads `agent/memory/audit-carryovers.md` if it exists
- [ ] Step 4.4 outputs a warning if any entries have `status: pending`
- [ ] Warning lists each pending `finding_id` and one-line description
- [ ] Step 4.4 is a no-op (silent skip) when `audit-carryovers.md` does not exist
- [ ] All 3 files identical (synced copies)

## Implementation Notes

Add as sub-step 4 inside the Step 4 block, after the existing sub-step 3 (lessons.md):

```markdown
4. Check `agent/memory/audit-carryovers.md` (if it exists):
   - If the file does not exist → skip silently
   - If the file exists, read the `carryovers:` list. If any entries have `status: pending`:
     Output before starting any work:
     ```
     ⚠️ [ACP] Open audit carryovers: [N] pending items require attention.
     [finding_id]: [one-line finding description]
     [finding_id]: [one-line finding description]
     Review before starting to avoid re-discovering fixed or stale items.
     ```
   - If all entries are `status: fixed` → skip silently
```

## Dependency

Requires route-018 (audit-carryovers.md exists) to be meaningful in practice.
