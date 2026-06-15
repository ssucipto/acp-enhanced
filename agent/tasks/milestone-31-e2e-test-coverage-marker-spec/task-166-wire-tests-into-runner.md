---
id: task-166
milestone: M31
title: Wire new e2e tests into run-e2e-tests.sh
status: completed
priority: 3
complexity: trivial
estimated_hours: 0.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: wire, new, e2e, tests, into, run-e2e-testssh
description: Wire new e2e tests into run-e2e-tests.sh
milestone: M31
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Ensure all new E2E test files created in M31 (tasks 162–165) are picked up by `run-e2e-tests.sh` and that the test runner correctly counts and reports them.

## Context

`run-e2e-tests.sh` may use either a glob pattern or an explicit file list to discover tests. If it uses an explicit list, new test files must be added manually. If it uses a glob, this task is mostly a verification.

## Implementation

1. Open `run-e2e-tests.sh` and determine discovery mode:
   - If glob (`e2e/*.test.sh`): verify all new files match the pattern
   - If explicit list: add all new test files from tasks 162–165

2. New files to add if using explicit list:
   - `e2e/acp.meta-scan.test.sh`
   - `e2e/acp.spec.test.sh`
   - `e2e/acp.sync.test.sh`
   - `e2e/acp.drafts.test.sh`
   - `e2e/acp.package-create.test.sh`
   - `e2e/acp.package-validate.test.sh`
   - `e2e/acp.install.test.sh`

3. Run `bash run-e2e-tests.sh` to verify all new tests execute and the summary count increases

4. Verify tests/acp.preferences.test.sh is also picked up (it's in `tests/` not `e2e/` — confirm run-e2e-tests.sh covers both)

## Expected Output

### Files Updated
- `run-e2e-tests.sh` (if explicit list mode)

## Verification
- [ ] `bash run-e2e-tests.sh` output shows all new test files
- [ ] Total test count in run-e2e-tests.sh output increases by ≥7 test files vs pre-M31
- [ ] No new test files are silently skipped

## User-Observable Acceptance
`bash run-e2e-tests.sh` runs all tests including the new M31 ones and reports a higher total assertion count. The test runner is the single source of truth for all E2E coverage.
