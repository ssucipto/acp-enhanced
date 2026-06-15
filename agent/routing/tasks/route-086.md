---
id: route-086
title: "E2E tests — repair tools and --memory validation"
task_type: testing
milestone: M48
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.pattern-sync.md
  - agent/commands/acp.session-sync.md
  - agent/commands/acp.validate.md
  - agent/patterns/local.e2e-testing.md
  - agent/patterns/local.e2e-testing-pattern.md
files_affected:
  - e2e/acp.repair-tools.test.sh (new)
  - e2e/acp.validate-memory.test.sh (new)
  - run-e2e-tests.sh (register new test files)
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 086: E2E Tests — Repair Tools & --memory Validation

## Objective

Create E2E tests for `/acp-pattern-sync`, `/acp-session-sync`, and `/acp-validate --memory`.

## Context

M47 added repair tools and --memory validation. These need automated tests to
ensure they work correctly across macOS and Linux.

## Test Cases

### Pattern Sync
1. **--dry-run shows planned changes**: Run `--dry-run` with missing documents → shows counts, no files written.
2. **--all creates missing**: Registry has 3 entries, 0 documents → `--all` creates 3 files.
3. **Idempotent**: Re-run `--all` → 0 created, 3 skipped.
4. **--name syncs specific**: `--name <name>` creates only that document.

### Session Sync
5. **--dry-run previews**: Same as pattern sync.
6. **--date targets specific**: `--date <YYYY-MM-DD>` syncs only that session.
7. **Weekly-summary skipped**: `type: weekly-summary` entries in registry are not synced.

### --memory Validation
8. **Valid YAML passes**: Clean patterns.md, sessions.md, progress.yaml → exit 0.
9. **Bad YAML fails with line number**: Malformed YAML (duplicate key, bad indent, unquoted colon) → exit 1 with line number in error message.
10. **All three files checked**: Each of patterns.md, sessions.md, progress.yaml is validated.

### Test Runner Integration

Register both test files in `run-e2e-tests.sh`:
- Add `e2e/acp.repair-tools.test.sh` and `e2e/acp.validate-memory.test.sh`
- Verify via `./run-e2e-tests.sh` (or `--parallel 4`)
- Follow conventions from `agent/patterns/local.e2e-testing.md`

## Verification

- [ ] All 10 test cases pass
- [ ] Tests runnable via `e2e/acp.repair-tools.test.sh` and `e2e/acp.validate-memory.test.sh`
- [ ] Both test files registered in `run-e2e-tests.sh` and run in suite
- [ ] Follows e2e testing conventions

## Dependencies

- route-085 (shared test infrastructure)
