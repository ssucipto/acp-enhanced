---
id: route-072
title: Runner argument parsing robustness + --help flag
task_type: bash-script
milestone: M46
complexity: low
executor: copilot
context_required:
  - run-e2e-tests.sh
files_affected:
  - run-e2e-tests.sh
tokens_est: 2000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-03
completed:
depends_on: [route-071]
---

Improve run-e2e-tests.sh argument parser: validate --parallel value is positive integer, add --help flag documenting all options, handle unknown flags gracefully with usage hint.

Acceptance:
- [ ] `--help` prints usage with all options
- [ ] `--parallel 0` rejects with error
- [ ] `--parallel abc` rejects with error
- [ ] Unknown flags print usage hint
