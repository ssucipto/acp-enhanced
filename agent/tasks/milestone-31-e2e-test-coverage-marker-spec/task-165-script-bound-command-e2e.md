---
id: task-165
milestone: M31
title: E2E tests for 8 script-bound commands with zero coverage
status: completed
priority: 3
complexity: medium
estimated_hours: 5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: e2e, tests, for, 8, script-bound, commands, with, zero, coverage
description: E2E tests for 8 script-bound commands with zero coverage
milestone: M31
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add E2E test coverage for the 8 script-bound commands that currently have zero test assertions: `package-create`, `package-publish`, `preferences-create`, `preferences-set`, `preferences-show`, `preferences-validate`, `package-validate`, and the `acp.install.sh` bootstrap.

## Context

`agent/memory/lessons.md` documents (priority: normal) that many script-bound commands have no E2E coverage. A script-bound command is one whose `acp.command.md` file lists scripts in the **Scripts** field and those scripts execute real bash logic.

The 8 commands confirmed without coverage as of 2026-05-05:
1. `acp-package-create` → `acp.package-create.sh`
2. `acp-package-publish` → `acp.package-publish.sh`
3. `acp-preferences-create` → `acp.preferences.sh create`
4. `acp-preferences-set` → `acp.preferences.sh set`
5. `acp-preferences-show` → `acp.preferences.sh show`
6. `acp-preferences-validate` → `acp.preferences.sh validate`
7. `acp-package-validate` → `acp.package-validate.sh`
8. `acp.install.sh` bootstrap (no command doc, but critical script)

**Verification approach**: Test script behavior (exit codes, output structure, file creation) rather than LLM command execution. Look at `tests/acp.preferences.test.sh` and `e2e/acp.package-list.test.sh` as format references.

## Implementation

For each untested command, identify what the underlying script does and write 3–5 minimal assertions:

**package-create** (`acp.package-create.sh`): Creates a package directory with package.yaml. Test: creates directory, creates package.yaml, YAML has required fields.

**package-publish** (`acp.package-publish.sh`): Publishes a package. Test: fails gracefully on missing package.yaml, outputs expected fields.

**preferences-create** (`acp.preferences.sh create`): Creates preferences file. Test: creates file, file is valid YAML.

**preferences-set** (`acp.preferences.sh set`): Sets a key. Test: sets value correctly, reads back correctly.

**preferences-show** (`acp.preferences.sh show`): Displays preferences. Test: exits 0, outputs key-value pairs.

**preferences-validate** (`acp.preferences.sh validate`): Validates preferences file. Test: passes on valid file, fails on invalid file.

**package-validate** (`acp.package-validate.sh`): Validates package.yaml structure. Test: passes on valid package.yaml, fails on missing required fields.

**acp.install.sh bootstrap**: Test: runs without error on empty directory, creates expected subdirectories.

Add tests to existing test files where appropriate (e.g., expand `tests/acp.preferences.test.sh`), or create new files where none exist.

## Expected Output

### Files Created/Updated
- `tests/acp.preferences.test.sh` (expand with preferences-create, preferences-set, preferences-show, preferences-validate)
- `e2e/acp.package-create.test.sh` (new)
- `e2e/acp.package-validate.test.sh` (new)
- `e2e/acp.install.test.sh` (new — bootstrap smoke test)

## Verification
- [ ] All 8 commands/scripts have at least 3 test assertions each
- [ ] All new tests pass in `bash run-e2e-tests.sh`
- [ ] No tests require network access (use `--offline` or mock fixtures)
- [ ] Each test file cleans up temp directories it creates

## User-Observable Acceptance
`bash run-e2e-tests.sh` shows all new test files PASS. The 8 previously-uncovered script-bound commands now have basic regression protection.
