---
id: task-75
title: Add E2E parity test for opencode commands
task_type: testing
milestone: M28
complexity: low
executor: copilot
context_required:
  - agent/core/identity.yml
  - agent/skills/testing.md
files_affected:
  - e2e/acp.opencode-commands.test.sh
tokens_est: 800
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed: 2026-05-04
override_reason:
---

<!-- @acp.meta.task
topic: task, add, e2e, parity, test, for, opencode, commands
description: Add E2E parity test for opencode commands
milestone: M28
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Task: Add E2E parity test for opencode commands

Create `e2e/acp.opencode-commands.test.sh` that enforces 1:1 parity between `.github/prompts/` (canonical) and `.opencode/commands/` (derived). Per ADR-6, this test is the parity enforcement mechanism — it fails if someone adds a Copilot prompt without adding the matching opencode command.

## Test Suites

1. **Directory Structure** — Both directories exist
2. **File-by-File Check** — Every `.github/prompts/*.prompt.md` has a matching `.opencode/commands/*.md`, and vice versa (no orphans)
3. **Content Validation** — Each opencode file: no `mode:` field, has `description:`, has frontmatter delimiters
4. **Count Summary** — File counts are equal

## Acceptance Criteria

- [x] Test file exists at `e2e/acp.opencode-commands.test.sh`
- [x] Test is executable
- [x] Sources `tests/common.sh` for assertion helpers
- [x] 293 assertions pass on clean repo (58 files × ~5 assertions + directory/count tests)
- [x] Test exits 1 if any file is missing or malformed
- [x] Remediation hint printed on failure

## Implementation Notes

293/293 assertions pass. Test correctly uses `assert_false` for the `mode:` check (we assert the grep finds nothing). Uses `bash e2e/acp.opencode-commands.test.sh` to run.
