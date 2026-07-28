#!/usr/bin/env bash
# Unified E2E Test Runner for Agent Context Protocol
# Usage:
#   bash run-e2e-tests.sh                           # Run all tests (serial)
#   bash run-e2e-tests.sh sessions                  # Filter: tests matching "sessions"
#   bash run-e2e-tests.sh --skip-network            # Skip network tests
#   bash run-e2e-tests.sh --parallel 4              # Run 4 tests at once
#   bash run-e2e-tests.sh --parallel                # Auto-detect CPU count
#   bash run-e2e-tests.sh --parallel 4 sessions --skip-network  # Combined
#   bash run-e2e-tests.sh --help                    # Show usage

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Argument Parsing ─────────────────────────────────────────────
FILTER=""
SKIP_NETWORK=false
PARALLEL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            echo "Usage: bash run-e2e-tests.sh [options] [filter]"
            echo ""
            echo "Options:"
            echo "  --parallel [N]    Run N tests concurrently (default: CPU count)"
            echo "  --skip-network    Skip tests marked ACP_NETWORK_TEST=true"
            echo "  --help, -h        Show this help"
            echo ""
            echo "Filter: substring match on test filename (e.g. 'sessions')"
            echo ""
            echo "Examples:"
            echo "  bash run-e2e-tests.sh                            # All tests, serial"
            echo "  bash run-e2e-tests.sh --parallel 4               # All tests, 4 workers"
            echo "  bash run-e2e-tests.sh --parallel sessions        # Filtered, parallel"
            echo "  bash run-e2e-tests.sh --parallel --skip-network   # Skip network tests"
            exit 0
            ;;
        --parallel)
            if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
                PARALLEL="$2"; shift 2
            else
                PARALLEL=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
                shift
            fi
            ;;
        --parallel=*)
            PARALLEL="${1#*=}"
            if ! [[ "$PARALLEL" =~ ^[1-9][0-9]*$ ]]; then
                echo "ERROR: --parallel requires a positive integer, got '$PARALLEL'" >&2
                exit 1
            fi
            shift
            ;;
        --skip-network)
            SKIP_NETWORK=true; shift
            ;;
        --*)
            echo "Unknown flag: $1 (use --help for usage)" >&2
            exit 1
            ;;
        *)
            FILTER="$1"; shift
            ;;
    esac
done

# Validate parallel value
if [[ "$PARALLEL" -gt 0 ]] && [[ "$PARALLEL" -lt 1 ]]; then
    echo "ERROR: --parallel must be >= 1, got $PARALLEL" >&2
    exit 1
fi

# ── Test File Collection ─────────────────────────────────────────
# Per-test timeout in seconds (macOS-compatible: no GNU timeout)
# 180s accommodates slow tests under parallel CPU contention (project-workflow,
# preferences-validate, sessions). Tests take longer in --parallel 4 mode.
#
# The Windows-specific 600s budget added earlier in this release is gone: it was
# treating a symptom. audit-110 found the real cause — gitleaks_active() and
# dupehound_active() each resolved a preference (a ~1.5s pure-bash YAML walk)
# BEFORE checking whether the tool was installed, so every scanner invocation
# paid ~3s for two questions it did not need to ask. acp.review.test.sh went from
# 66s to 3s once that was fixed. A uniform limit keeps the signal honest on every
# platform; if a suite needs more than this again, that is a regression worth
# failing on rather than accommodating.
TIMEOUT_SECS=180
total=0
passed=0
failed=0
skipped=0
timed_out=0
failed_tests=()

# Windows Git Bash: yaml_query / project-registry / version-update-preserve
# suites hang indefinitely (route-099 class). Per e2e-tests.yaml: skip
# non-portable suites rather than burn the 180s timeout x N and fail the matrix job.
_acp_is_windows() {
    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

_acp_windows_skip_suite() {
    local name="$1"
    case "$name" in
        acp.yaml-parser.test.sh|\
        acp.preferences.test.sh|\
        acp.preferences-validate.test.sh|\
        acp.preferences-preset.test.sh|\
        acp.project-info.test.sh|\
        acp.project-list.test.sh|\
        acp.project-remove.test.sh|\
        acp.project-set.test.sh|\
        acp.project-update.test.sh|\
        acp.project-workflow.test.sh|\
        acp.sessions.test.sh|\
        acp.bootstrap-preserve.test.sh|\
        acp.version-update-preserve.test.sh|\
        acp.integrity.test.sh)
            return 0 ;;
        *) return 1 ;;
    esac
}

# Collect test files into ordered array (before forking)
test_files=()
test_names=()
for test_file in "$SCRIPT_DIR"/e2e/*.test.sh "$SCRIPT_DIR"/tests/*.test.sh; do
    test_name="$(basename "$test_file")"

    [[ -n "$FILTER" ]] && [[ "$test_name" != *"$FILTER"* ]] && continue
    [[ "$SKIP_NETWORK" == "true" ]] && grep -q "^# ACP_NETWORK_TEST=true" "$test_file" 2>/dev/null && continue
    if _acp_is_windows && _acp_windows_skip_suite "$test_name"; then
        printf "  %-50s ⏭  SKIP (Windows non-portable — yaml/project hang)\n" "$test_name"
        skipped=$((skipped + 1))
        continue
    fi

    test_files+=("$test_file")
    test_names+=("$test_name")
done

# ── Banner ────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ "$PARALLEL" -gt 1 ]]; then
    echo "  ACP E2E Test Runner (parallel: ${PARALLEL} workers, ${#test_files[@]} tests)"
else
    echo "  ACP E2E Test Runner (${#test_files[@]} tests)"
fi
[[ "$SKIP_NETWORK" == "true" ]] && echo "  (network tests skipped)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Run a single test (used by both serial and parallel modes) ───
# Outputs: result line to stdout, exit code for tracking
run_one_test() {
    local test_file="$1" test_name="$2"
    local tmpout exit_code

    tmpout=$(mktemp)
    bash "$test_file" > "$tmpout" 2>&1 &
    local test_pid=$!
    ( sleep "$TIMEOUT_SECS" && kill "$test_pid" 2>/dev/null ) &
    local guard_pid=$!
    wait "$test_pid" 2>/dev/null
    exit_code=$?
    kill "$guard_pid" 2>/dev/null
    wait "$guard_pid" 2>/dev/null

    if [[ $exit_code -eq 143 || $exit_code -eq 137 ]]; then
        printf "  %-50s ⏱  TIMEOUT (%ss)\n" "$test_name" "$TIMEOUT_SECS"
        rm -f "$tmpout"
        return 124  # timeout exit code
    fi

    if [[ $exit_code -eq 0 ]]; then
        printf "  %-50s ✅ PASS\n" "$test_name"
        rm -f "$tmpout"
        return 0
    else
        printf "  %-50s ❌ FAIL (exit %d)\n" "$test_name" "$exit_code"
        local output
        output=$(cat "$tmpout")
        echo ""
        echo "    ── Test Output ──"
        echo "$output" | sed 's/^/    /' 
        echo "    ────────────────────────────"
        echo ""
        rm -f "$tmpout"
        return "$exit_code"
    fi
}

# ── Execution ─────────────────────────────────────────────────────
_N="${#test_files[@]}"
if [[ "$_N" -eq 0 ]]; then
    echo "  No tests to run."
    exit 0
fi

if [[ "$PARALLEL" -le 1 ]]; then
    # ── Serial Mode ──────────────────────────────────────────────
    for ((i=0; i<_N; i++)); do
        printf "  %-50s " "${test_names[$i]}"
        run_one_test "${test_files[$i]}" "${test_names[$i]}"
        rc=$?
        case $rc in
            0)   passed=$((passed+1)) ;;
            124) timed_out=$((timed_out+1)); failed=$((failed+1))
                  failed_tests+=("${test_names[$i]} (TIMEOUT)") ;;
            *)   failed=$((failed+1))
                  failed_tests+=("${test_names[$i]}") ;;
        esac
        total=$((total+1))
    done
else
    # ── Parallel Mode ────────────────────────────────────────────
    PARALLEL=$(( PARALLEL < _N ? PARALLEL : _N ))  # cap at test count
    _outdir=$(mktemp -d)
    trap "rm -rf $_outdir" EXIT

    typeset -a _pids=()
    # Round-robin: each worker runs its batch of tests in background
    for ((w=0; w<PARALLEL; w++)); do
        (
            for ((i=w; i<_N; i+=PARALLEL)); do
                # run_one_test prints result line + optional failure details
                run_one_test "${test_files[$i]}" "${test_names[$i]}" > "$_outdir/out-$i" 2>&1
                echo $? > "$_outdir/rc-$i"
            done
        ) &
        _pids+=($!)
    done

    # Wait for all workers
    for _pid in "${_pids[@]}"; do wait "$_pid" 2>/dev/null; done

    # Collect and display results in test order
    for ((i=0; i<_N; i++)); do
        _rc=$(cat "$_outdir/rc-$i" 2>/dev/null || echo 1)

        # Print full test output (result line + failure details)
        cat "$_outdir/out-$i" 2>/dev/null || true

        case $_rc in
            0)   passed=$((passed+1)) ;;
            124) timed_out=$((timed_out+1)); failed=$((failed+1))
                  failed_tests+=("${test_names[$i]} (TIMEOUT)") ;;
            *)   failed=$((failed+1))
                  failed_tests+=("${test_names[$i]}") ;;
        esac
        total=$((total+1))
    done
fi

# ── Results Summary ───────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Total:   $total"
echo "  Passed:  $passed"
echo "  Failed:  $failed"
if [[ $timed_out -gt 0 ]]; then
    echo "  Timed out: $timed_out (limit: ${TIMEOUT_SECS}s per test)"
fi
if [[ $skipped -gt 0 ]]; then
    if [[ -n "$FILTER" && "$SKIP_NETWORK" == "true" ]]; then
        echo "  Skipped: $skipped (filter: '$FILTER' + network)"
    elif [[ -n "$FILTER" ]]; then
        echo "  Skipped: $skipped (filter: '$FILTER')"
    else
        echo "  Skipped: $skipped (network)"
    fi
fi
echo ""

if [[ ${#failed_tests[@]} -gt 0 ]]; then
    echo "  Failed tests:"
    for ft in "${failed_tests[@]}"; do
        echo "    ❌ $ft"
    done
    echo ""
fi

if [[ $failed -eq 0 ]]; then
    echo "  ✅ All tests passed!"
else
    echo "  ❌ $failed test(s) failed"
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $failed -eq 0 ]]

