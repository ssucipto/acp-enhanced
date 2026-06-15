---
id: route-186
title: Add cross-layer status + dangling-pointer checks to /acp-validate (desync prevention)
task_type: typescript-feature
milestone: M65
complexity: medium
executor: copilot
context_required:
  - reports/audit-069-m57-m58-post-sync-reaudit.md
files_affected:
  - scripts/acp-validate.ts
  - agent/commands/acp.validate.md
  - e2e/acp.validate.test.sh
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Make the desync that audit-069 found impossible to reintroduce silently: `/acp-validate` should FAIL when a milestone/route document's status disagrees with `progress.yaml`, or when a `file:` pointer in `progress.yaml` references a non-existent file.

## Context

audit-069 F-069-01/F-069-09: the merge reintroduced status desync (milestone docs "planned" vs progress.yaml "completed/in-progress") and a dangling M54 pointer, and nothing caught it. The fix in route-185 is one-time; this route is the guard.

## Steps

1. Add `validateStatusConsistency()` to `scripts/acp-validate.ts`:
   - Parse `progress.yaml` milestones (id, status, file).
   - For each milestone with a `file:`, open the milestone doc, read its `**Status**:` (or `Status:`) field; FAIL if it disagrees with progress.yaml status (allow a documented mapping: planned/active/in_progress/completed).
   - For routes referenced as complete in progress.yaml counts, optionally spot-check `completed:` presence (warn, not fail, to limit scope).
2. Add `validateFilePointers()`:
   - For every `file:` path in progress.yaml (milestones) and every milestone "Build Order" route reference, assert the file exists; FAIL listing each dangling pointer.
   - Flag `tasks_total: 0` combined with `status: active|in_progress` as an inconsistency.
3. Wire both into the no-args validate path AND ensure `acp-validate.ts` runs in CI (coordinates with M59 route-161 / HIGH-066-005 — if not yet wired, note the dependency).
4. Update `agent/commands/acp.validate.md` Step list to document the two new checks.
5. Add `e2e/acp.validate.test.sh` assertions (or extend existing) with a deliberately-mismatched fixture (temp milestone doc whose status disagrees) proving the check FAILS, then passes when aligned.

## Expected Output

### Files Modified
- `scripts/acp-validate.ts` — two new checks
- `agent/commands/acp.validate.md` — documented
- `e2e/acp.validate.test.sh` — regression fixtures

## Verification (double-verify)

- [ ] **Automated**: a mismatched-status fixture makes `acp-validate` exit non-zero; aligned state exits 0
- [ ] **Automated**: a dangling `file:` pointer fixture is reported by name and fails validation
- [ ] **Manual**: `npx ts-node scripts/acp-validate.ts` on the current (post-route-185) repo passes clean
- [ ] `npx tsc --noEmit` clean

## User-Observable Acceptance

- Running `/acp-validate` catches milestone/progress.yaml status drift and dangling pointers before they reach a reader or a merge.

## Addresses

audit-069 F-069-01 (prevention), F-069-09 (prevention); supports audit-066 HIGH-066-005 (validate in CI)
