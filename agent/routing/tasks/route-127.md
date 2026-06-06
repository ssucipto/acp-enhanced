---
id: route-127
title: "E2E test for cursor-commands-sync: file count parity, naming, wrapper content"
task_type: e2e-test-write
milestone: M53
complexity: medium
executor: copilot
context_required:
  - agent/scripts/acp.cursor-commands-sync.sh
  - agent/patterns/local.e2e-testing.md
files_affected:
  - e2e/acp.cursor-commands-sync.test.sh
tokens_est: 350
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 127: E2E Test — Cursor Commands Sync

## Objective

Create `e2e/acp.cursor-commands-sync.test.sh` verifying the sync script produces correct output with proper naming, content, and parity with command sources.

## Context

Per feedback-001 §3.6 acceptance criteria: "E2E test asserts file count parity and naming." The test should verify the sync script works correctly in isolation and produces wrappers matching ACP conventions.

## Changes

### Create `e2e/acp.cursor-commands-sync.test.sh`

Test assertions (10 items):

1. **Sync script exists**: `agent/scripts/acp.cursor-commands-sync.sh` present and executable
2. **Sync runs without error**: `bash agent/scripts/acp.cursor-commands-sync.sh` exits 0
3. **File count parity**: `.cursor/commands/` file count ≥ `agent/commands/acp.*.md` + `git.*.md` count
4. **Naming convention**: `acp.init` → `acp-init.md` (dots → hyphens)
5. **Naming convention**: `git.commit` → `git-commit.md`
6. **Wrapper has YAML frontmatter**: Each `.cursor/commands/*.md` starts with `---`
7. **Wrapper has description**: Frontmatter contains `description:` field (non-empty)
8. **Wrapper references canonical source**: Contains `agent/commands/` reference
9. **Wrapper references equivalent invocations**: Contains `/acp-*` or `@acp-*` references
10. **Re-run is idempotent**: Second run produces same output, no errors

### Test structure

- Run sync script in project root
- Verify `.cursor/commands/` output
- Count and compare
- Follow `local.e2e-testing.md` conventions
- Clean up test-generated `.cursor/commands/` or run in temp dir

## Verification

- [ ] Test file exists at `e2e/acp.cursor-commands-sync.test.sh`
- [ ] All 10 assertions defined
- [ ] `bash e2e/acp.cursor-commands-sync.test.sh` passes
- [ ] Test handles case where `.cursor/commands/` already exists
- [ ] macOS BSD sed compatible
