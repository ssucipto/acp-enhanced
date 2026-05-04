#!/usr/bin/env bash
# Unified E2E Test Runner for Agent Context Protocol
# Usage:
#   bash run-e2e-tests.sh                    # Run all E2E tests
#   bash run-e2e-tests.sh sessions           # Run only tests matching "sessions"
#   bash run-e2e-tests.sh --skip-network     # Skip tests marked ACP_NETWORK_TEST=true
#   bash run-e2e-tests.sh sessions --skip-network

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
FILTER=""
SKIP_NETWORK=false
for arg in "$@"; do
    case "$arg" in
        --skip-network) SKIP_NETWORK=true ;;
        --*) ;;  # ignore unknown flags
        *) FILTER="$arg" ;;
    esac
done

# Per-test timeout in seconds (macOS-compatible: no GNU timeout)
TIMEOUT_SECS=30

passed=0
failed=0
skipped=0
timed_out=0
failed_tests=()
total=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ACP E2E Test Runner"
if [[ "$SKIP_NETWORK" == "true" ]]; then
    echo "  (network tests skipped — pass without --skip-network to include)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for test_file in "$SCRIPT_DIR"/e2e/*.test.sh "$SCRIPT_DIR"/tests/*.test.sh; do
    test_name="$(basename "$test_file")"

    # Apply filter if provided
    if [[ -n "$FILTER" ]] && [[ "$test_name" != *"$FILTER"* ]]; then
        skipped=$((skipped + 1))
        continue
    fi

    # Skip network tests if requested
    if [[ "$SKIP_NETWORK" == "true" ]] && grep -q "^# ACP_NETWORK_TEST=true" "$test_file" 2>/dev/null; then
        skipped=$((skipped + 1))
        printf "  %-50s ⏭  SKIP (network)\n" "$test_name"
        continue
    fi

    total=$((total + 1))
    printf "  %-50s " "$test_name"

    # Run test with macOS-compatible timeout (background job + kill-guard)
    tmpout=$(mktemp)
    bash "$test_file" > "$tmpout" 2>&1 &
    test_pid=$!
    ( sleep "$TIMEOUT_SECS" && kill "$test_pid" 2>/dev/null ) &
    guard_pid=$!
    wait "$test_pid" 2>/dev/null
    exit_code=$?
    kill "$guard_pid" 2>/dev/null
    wait "$guard_pid" 2>/dev/null
    output=$(cat "$tmpout")
    rm -f "$tmpout"

    # Normalize timeout exit codes (SIGTERM=143, SIGKILL=137)
    if [[ $exit_code -eq 143 || $exit_code -eq 137 ]]; then
        echo "⏱  TIMEOUT (${TIMEOUT_SECS}s)"
        timed_out=$((timed_out + 1))
        failed=$((failed + 1))
        failed_tests+=("$test_name (TIMEOUT)")
        continue
    fi

    if [[ $exit_code -eq 0 ]]; then
        echo "✅ PASS"
        passed=$((passed + 1))
    else
        echo "❌ FAIL (exit $exit_code)"
        failed=$((failed + 1))
        failed_tests+=("$test_name")

        # Show last 20 lines of output for debugging
        echo ""
        echo "    ── Output (last 20 lines) ──"
        echo "$output" | tail -20 | sed 's/^/    /'
        echo "    ────────────────────────────"
        echo ""
    fi
done

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

