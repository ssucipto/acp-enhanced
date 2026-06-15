# Design: Parallel Test Execution in run-e2e-tests.sh

<!-- @acp.meta.design
topic: design, parallel, test, execution, in, run-e2e-testssh
description: Add a `--parallel N` flag to `run-e2e-tests.sh` that runs E2E and unit tests concurrently using background subshells. Currently all ~38 tests run seri
status: active
updated: 2026-06-15
@acp.meta.end -->

**Design**: local.parallel-test-runner  
**Created**: 2026-06-03  
**Last Updated**: 2026-06-15  
**Informs**: run-e2e-tests.sh  

---

## Overview

Add a `--parallel N` flag to `run-e2e-tests.sh` that runs E2E and unit tests concurrently using background subshells. Currently all ~38 tests run serially, taking 15-20 minutes. Parallel execution with 4 workers reduces runtime to ~5 minutes.

---

## Design

### Approach: Background Subshells (Not GNU Parallel)

GNU parallel is not available by default on macOS or in CI runners. Instead, we use native bash background subshells with result buffering.

```
  Serial (current):     T1 → T2 → T3 → T4 → T5 → ...   (15-20 min)

  Parallel (proposed):  ┌ T1 ──┐ ┌ T5 ──┐
                        ├ T2 ──┤ ├ T6 ──┤
                        ├ T3 ──┤ ├ T7 ──┤   (~5 min with 4 workers)
                        └ T4 ──┘ └ T8 ──┘
```

### Result Ordering

Results are buffered per-test in `/tmp` and printed in original test file order after all workers complete — not first-completed order. This keeps CI output deterministic and readable.

### Timeout Handling

Each subshell applies the existing 30s timeout per test. The timeout guard process runs inside the subshell, so parallel tests time out independently.

---

## Implementation

### Phase 1 — Argument Parsing

Add `--parallel [N]` to the argument parser:

```bash
PARALLEL=0
for arg in "$@"; do
    case "$arg" in
        --parallel)
            PARALLEL=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
            ;;
        --parallel=*)
            PARALLEL="${arg#*=}"
            ;;
        --skip-network) SKIP_NETWORK=true ;;
        --*) ;;  # ignore unknown flags
        *) FILTER="$arg" ;;
    esac
done
```

Validates `PARALLEL` is a positive integer. Defaults to CPU count.

### Phase 2 — Test File Collection

Collect all test files into an array BEFORE forking:

```bash
test_files=()
for test_file in "$SCRIPT_DIR"/e2e/*.test.sh "$SCRIPT_DIR"/tests/*.test.sh; do
    test_name="$(basename "$test_file")"
    # Apply filter
    [[ -n "$FILTER" ]] && [[ "$test_name" != *"$FILTER"* ]] && continue
    # Apply skip-network
    [[ "$SKIP_NETWORK" == "true" ]] && grep -q "^# ACP_NETWORK_TEST=true" "$test_file" 2>/dev/null && continue
    test_files+=("$test_file")
done
```

### Phase 3 — Parallel Execution

```bash
if [[ $PARALLEL -gt 1 ]]; then
    run_tests_parallel
else
    run_tests_serial
fi
```

**Parallel logic**:
1. Split `test_files[]` into `$PARALLEL` batches (round-robin distribution)
2. Fork each batch as background subshell, redirecting output to `/tmp/acp-test-$$-$batch.out`
3. Each subshell runs the same per-test logic (timeout guard, exit code tracking)
4. `wait` for all subshells
5. Read output files in original order, print results
6. Aggregate pass/fail/skip/timeout counts
7. `trap` cleanups temp files on EXIT

**Serial logic**: Unchanged from current implementation.

### Phase 4 — Output

```bash
cleanup() { rm -f /tmp/acp-test-$$-*.out; }
trap cleanup EXIT
```

Output format matches serial mode exactly — no differences in CI log format.

---

## API / Usage

```bash
# Current (unchanged)
bash run-e2e-tests.sh                          # Serial, all tests
bash run-e2e-tests.sh sessions                 # Serial, filtered

# New
bash run-e2e-tests.sh --parallel 4             # 4 parallel workers
bash run-e2e-tests.sh --parallel               # Auto-detect CPU count
bash run-e2e-tests.sh --parallel 4 sessions    # Parallel + filter
bash run-e2e-tests.sh --parallel --skip-network # Parallel + skip network
```

---

## Edge Cases

| Case | Behavior |
|------|----------|
| `--parallel 1` | Falls back to serial (no forking overhead) |
| `--parallel 99` | Caps at number of test files |
| Zero test files | Exit 0 with message |
| Subshell SIGTERM | Tracked via exit code 143 |
| Two tests writing ~/.acp/ | Relies on existing per-test isolation |
| macOS `wait -n` unavailable | Not used — simple `wait` (all) + ordered readback |

---

## Risks

| Risk | Mitigation |
|------|-----------|
| Interleaved stdout | Per-batch output files, printed in order |
| Two tests sharing global state | Tests already isolated; if not, fix tests first |
| Memory overhead from temp files | Each ~5KB output file, ~38 files = ~190KB total |
| CI agent only has 1 CPU | `--parallel` auto-detects CPU count; falls back to 2 workers minimum |

---

## Acceptance Criteria

- [ ] `bash run-e2e-tests.sh --parallel 4` completes all tests
- [ ] All 38 existing tests pass (no regressions)
- [ ] Output format matches serial mode exactly
- [ ] `--parallel` with `--skip-network` and filter works
- [ ] macOS + Linux compatible (no GNU deps)
- [ ] Parallel runtime < 40% of serial runtime with 4+ workers
