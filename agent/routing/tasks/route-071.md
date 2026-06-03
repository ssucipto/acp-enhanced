---
id: route-071
title: Implement --parallel flag in run-e2e-tests.sh
task_type: bash-script
milestone: M46
complexity: medium
executor: copilot
context_required:
  - agent/design/local.parallel-test-runner.md
  - run-e2e-tests.sh
files_affected:
  - run-e2e-tests.sh
  - CHANGELOG.md
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-03
completed:
depends_on: []
---

Add `--parallel [N]` flag to run-e2e-tests.sh. Collect test files into array, split into N batches, fork background subshells, buffer output, print ordered results.

Acceptance:
- [ ] `--parallel 4` runs tests concurrently
- [ ] Output format matches serial mode
- [ ] All 38 tests still pass
- [ ] macOS + Linux compatible
- [ ] `--parallel` (auto-detect CPU) works
