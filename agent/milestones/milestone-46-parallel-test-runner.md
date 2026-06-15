# Milestone 46: Parallel Test Runner + Runner Improvements

**Milestone**: M46  
**Version Target**: 6.8.4  
**Priority**: 4  
**Status**: completed  
**Source**: audit-039 (next steps) + agent/design/local.parallel-test-runner.md

## Overview

Add `--parallel N` flag to `run-e2e-tests.sh` to run E2E and unit tests concurrently using background bash subshells. Currently ~38 tests run serially taking 15-20 minutes. Parallel execution with 4 workers reduces runtime to ~5 minutes. Also includes runner improvements (argument parsing robustness, better error reporting).

## Scope

| Route | Description | Est. Effort |
|:-----:|-------------|:-----------:|
| 071 | `--parallel` flag implementation in run-e2e-tests.sh | 1-2 h |
| 072 | Runner argument parsing robustness + help flag | 0.5 h |
| 073 | CI workflow update + parallel mode validation | 0.5 h |
| **Total** | **3 routes** | **2-3 h** |

## Design

See `agent/design/local.parallel-test-runner.md` — full design with approach, API, edge cases, and acceptance criteria.

## Acceptance Criteria

- [ ] `bash run-e2e-tests.sh --parallel 4` completes all 38 tests
- [ ] All existing tests pass (no regressions)
- [ ] Output format matches serial mode exactly
- [ ] `--parallel` with `--skip-network` and `--filter` works
- [ ] macOS + Linux compatible (no GNU deps)
- [ ] Parallel runtime < 40% of serial with 4+ workers
- [ ] `--help` flag documents all options
