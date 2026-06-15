---
id: route-085
title: "E2E tests — commit auto-sync document generation"
task_type: testing
milestone: M48
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/patterns/local.e2e-testing.md
  - agent/patterns/local.e2e-testing-pattern.md
  - e2e/ (test directory)
files_affected:
  - e2e/acp.commit-sync.test.sh (new)
  - run-e2e-tests.sh (register new test file)
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 085: E2E Tests — Commit Auto-Sync

## Objective

Create E2E tests verifying that `/acp-commit` correctly auto-syncs session and
pattern documents from registries (steps 2b, 3b).

## Context

M47 added commit-integrated auto-sync (steps 2b, 3b) but no automated tests.
Industry standard: every user-facing feature should have tests. These tests
verify the end-to-end flow: commit → registry written → documents generated.

## Test Cases

### Sessions Sync
1. **Document created on commit**: After `/acp-commit`, verify `agent/sessions/{date}-{slug}.md` exists with correct content matching the registry entry.
2. **Idempotent**: Re-run commit without registry changes → document NOT rewritten (same mtime/content hash).
3. **--no-sync skips**: Commit with `--no-sync` → no session document created.
4. **Content accuracy**: Session document contains executor, branch, completed tasks, deferred items, key_fact matching registry.

### Patterns Sync
5. **Pattern document created**: After commit with a new pattern, verify `agent/patterns/{name}.md` exists.
6. **Idempotent**: Re-run without pattern changes → document NOT rewritten.
7. **Namespace respected**: Project patterns use `local.` prefix; package patterns use namespace prefix.

### Test Runner Integration

After creating the test file, register it in `run-e2e-tests.sh`:
- Add `e2e/acp.commit-sync.test.sh` to the test file list or discovery pattern
- Verify it runs via `./run-e2e-tests.sh` (or `./run-e2e-tests.sh --parallel 4`)
- Test file must follow conventions from `agent/patterns/local.e2e-testing.md`

## Verification

- [ ] All test cases pass
- [ ] Tests runnable via `e2e/acp.commit-sync.test.sh`
- [ ] Test registered in `run-e2e-tests.sh` and runs in suite
- [ ] Compatible with macOS and Linux (BSD + GNU)
- [ ] Follows conventions from `agent/patterns/local.e2e-testing.md`

## Dependencies

- route-086 (repair tool + --memory tests share test infrastructure)
