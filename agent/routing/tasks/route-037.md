---
id: route-037
title: M42 — Add validateSessionsMemory() to acp-validate.ts (MEMORY-002)
task_type: typescript-feature
milestone: M42
complexity: medium
executor: copilot
context_required:
  - scripts/acp-validate.ts
  - agent/memory/sessions.md
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
files_affected:
  - scripts/acp-validate.ts
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Add a `validateSessionsMemory()` function to `scripts/acp-validate.ts` that checks the YAML structure of `agent/memory/sessions.md`. BUG-001 (malformed session entry) went undetected for an entire milestone (M40) because no automated check existed. This function should catch the class of error where a `- date:` header is missing from a session block.

## Context

From audit-015 MEMORY-002:
> `acp-validate.ts` has no sessions.md YAML structure check — malformed entries go undetected across full milestones. BUG-001 was present for one full milestone without detection.

The sessions.md file uses `\n- date:` as the entry delimiter (same pattern as `getLastNSessions()` in `acp-dispatch.ts`). Each valid entry must have: `date:`, `executor:`, `tasks:`, `done:`.

## Acceptance Criteria

### Function implementation
- [ ] `validateSessionsMemory()` function added to `scripts/acp-validate.ts`
- [ ] Reads `agent/memory/sessions.md` — handles file-not-found gracefully (warn + skip, do not crash)
- [ ] Splits content on `\n- date:` pattern to get individual entry strings
- [ ] For each entry, verifies presence of required YAML keys:
  - `date:` — present and non-empty
  - `executor:` — present and non-empty
  - `tasks:` — present (may be array or string)
  - `done:` — present (may be array or string)
- [ ] On missing key: print error with entry index (1-based) and key name:
  ```
  ❌ sessions.md: Entry #3 missing required key: executor
  ```
- [ ] On malformed date (not YYYY-MM-DD format): print warning (not hard fail)
- [ ] On all entries valid: print `✅ sessions.md: [N] entries — all valid`
- [ ] Returns boolean (true = valid, false = has errors) for use in overall validate pass/fail

### Integration
- [ ] Called from the no-args (full validate) path in the main validate logic
- [ ] NOT called from `--parity-only` path (keep parity check fast and focused)
- [ ] Validate run exit code is non-zero if `validateSessionsMemory()` returns false

### Edge cases
- [ ] Empty sessions.md (0 entries): print `✅ sessions.md: 0 entries (empty)` — not a failure
- [ ] Sessions.md with YAML front-matter comments at top: strip comments before splitting
- [ ] Single malformed entry does not abort checking remaining entries — report all failures

## Implementation Notes

Read the current `acp-validate.ts` structure before adding this function. Follow the existing function naming and return type conventions already in the file. The sessions.md split pattern should match the `getLastNSessions()` implementation in `acp-dispatch.ts` exactly to avoid divergence.
