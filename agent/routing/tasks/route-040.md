---
id: route-040
title: M42 — Add lessons.md archive mechanism + update getFilteredLessons() (MEMORY-001)
task_type: typescript-feature
milestone: M42
complexity: medium
executor: copilot
context_required:
  - scripts/acp-dispatch.ts
  - agent/memory/lessons.md
  - agent/core/constraints.yml
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
files_affected:
  - scripts/acp-dispatch.ts
  - agent/memory/lessons.md
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add an archive/expiry mechanism to `agent/memory/lessons.md` and update `getFilteredLessons()` in `scripts/acp-dispatch.ts` to skip archived entries. This prevents superseded lessons from consuming context budget on every dispatch call forever.

The TikrFlow overflow postmortem lesson is a known example: it was added as `priority: high` when the context overflow event occurred, but its fix is now codified in `constraints.yml` as `context_overflow_commit_first`. The lesson still loads on every task, redundantly consuming context.

## Context

From audit-015 MEMORY-001:
> `lessons.md has no expiry/archive mechanism — superseded lessons load on every dispatch call forever. TikrFlow overflow lesson is redundant — its fix is codified in constraints.yml as context_overflow_commit_first.`

## Acceptance Criteria

### Schema documentation update (lessons.md)
- [ ] Read current `agent/memory/lessons.md` to understand existing schema (comments at top of file, if any)
- [ ] Add schema comment block at top of file (after any existing header comments) documenting the new optional fields:
  ```yaml
  # Optional fields added in v6.8.0:
  #   status: active       # Default if absent. active = load normally
  #   status: archived     # Archived lessons are skipped by getFilteredLessons()
  #   superseded_by: "constraints.yml:context_overflow_commit_first"
  #                        # Reference to what now encodes this knowledge
  ```
- [ ] Do NOT modify existing active lesson entries (no `status: active` needed — backward compatible)

### Archive the TikrFlow overflow lesson
- [ ] Locate the TikrFlow overflow postmortem lesson in `agent/memory/lessons.md`
  - It should be identifiable by keywords: TikrFlow, context overflow, commit triggers, or similar
- [ ] Add to that specific entry:
  ```yaml
  status: archived
  superseded_by: "constraints.yml:context_overflow_commit_first"
  ```
- [ ] Preserve all other fields of the lesson (do not delete it — archived entries serve as audit trail)
- [ ] If no TikrFlow lesson found: add a `status: archived` only to any high-priority lesson that is demonstrably covered by constraints.yml; do not archive anything speculatively

### getFilteredLessons() update in acp-dispatch.ts
- [ ] Locate `getFilteredLessons()` function in `scripts/acp-dispatch.ts`
- [ ] Read its current implementation before modifying
- [ ] Add a filter step: after collecting lessons, skip any entry where `status === 'archived'`
  - Entries with no `status` field: treat as `active` (load normally — backward compatible)
  - Entries with `status: active`: load normally
  - Entries with `status: archived`: skip entirely
- [ ] The task_type and priority filters already in `getFilteredLessons()` must continue to work correctly after this change
- [ ] Add a brief inline comment: `// Skip archived lessons (see lessons.md schema comment)`

### Verification
- [ ] After change, a dispatch call should NOT include the TikrFlow overflow lesson in its context output
- [ ] Lessons with `priority: high` and `status: active` (or no status) still load correctly
- [ ] Lessons with `priority: normal` and matching `trigger` still load correctly

## Implementation Notes

Be conservative: only archive lessons that are explicitly covered by constraints.yml. Do not archive anything based on judgment alone. If the TikrFlow lesson is spread across multiple entries (e.g., postmortem + lesson), archive only the one that is truly superseded. Read the file before making any changes.
