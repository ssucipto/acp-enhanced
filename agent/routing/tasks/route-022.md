---
id: route-022
title: M41a — Fix sessions.md malformed YAML entry (BUG-001)
task_type: bug-fix-simple
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/memory/sessions.md
  - agent/reports/audit-014-external-feedback-quality-and-improvement-plan.md
files_affected:
  - agent/memory/sessions.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Fix the malformed YAML entry in `agent/memory/sessions.md` identified in audit-014 BUG-001.

At approximately line 151, a session block for tasks `[task-156, task-157, task-158]` begins directly with `executor: copilot` without the required `- date: YYYY-MM-DD` list-item header. The `acp-dispatch.ts` function `getLastNSessions()` splits on `\n- date:` — this orphaned block is either silently skipped or concatenated into an adjacent entry, corrupting session context for every dispatch call.

## Acceptance Criteria

- [ ] Locate the orphaned block (starts with `  executor: copilot`, tasks task-156, task-157, task-158)
- [ ] Prepend `- date: 2026-05-05` as the list-item header (confirm date from git log context)
- [ ] Verify block now starts with `- date:` followed by `  executor:` at correct indentation
- [ ] Verify no other orphaned blocks exist in sessions.md (check all `executor:` lines without a preceding `- date:`)
- [ ] File remains valid YAML structure after fix

## Implementation Notes

The correct fix is a single-line insertion:
```yaml
- date: 2026-05-05   # ← insert this line before the orphaned block
  executor: copilot
  tasks: [task-156, task-157, task-158]
  done:
    - ...
```

Use `grep -n "^  executor:\|^- date:" agent/memory/sessions.md` to locate all entry boundaries and verify none are orphaned after the fix.
