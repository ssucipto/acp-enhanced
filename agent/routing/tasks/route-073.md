---
id: route-073
title: CI workflow update for parallel test mode
task_type: ci-pipeline
milestone: M46
complexity: low
executor: copilot
context_required:
  - .github/workflows/e2e-tests.yaml
  - run-e2e-tests.sh
files_affected:
  - .github/workflows/e2e-tests.yaml
  - .github/workflows/benchmark.yaml
tokens_est: 1500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-03
completed:
depends_on: [route-071]
---

Update CI workflows to use `--parallel` flag for faster test runs. Update benchmark workflow to compare serial vs parallel timings.

Acceptance:
- [ ] CI e2e-tests.yaml runs with `--parallel` flag
- [ ] Benchmark workflow reports serial vs parallel timing
- [ ] Both workflows pass on macOS + Ubuntu
