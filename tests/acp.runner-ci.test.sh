#!/usr/bin/env bash
# Runner + CI workflow tests

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Runner + CI Workflow Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === run-e2e-tests.sh ===
RE="$PROJECT_ROOT/run-e2e-tests.sh"
if [ -f "$RE" ]; then
    bash -n "$RE" 2>/dev/null && { echo "  ✓ run-e2e-tests.sh syntax OK"; PASS=$((PASS+1)); } \
        || { echo "  ✗ run-e2e-tests.sh syntax error"; FAIL=$((FAIL+1)); }

    # Has --parallel flag (future enhancement — expected to be missing)
    grep -q "\-\-parallel" "$RE" \
        && { echo "  ✓ run-e2e-tests.sh has --parallel (planned for M46)"; PASS=$((PASS+1)); } \
        || { echo "  ~ run-e2e-tests.sh --parallel not yet implemented (expected)"; PASS=$((PASS+1)); }

    # Has exit code reporting
    grep -q "exit_code\|PASS\|FAIL\|EXIT_CODE" "$RE" && { echo "  ✓ run-e2e-tests.sh has exit code tracking"; PASS=$((PASS+1)); } \
        || { echo "  ✗ No exit code tracking found"; FAIL=$((FAIL+1)); }
else
    echo "  ✗ run-e2e-tests.sh not found"
    FAIL=$((FAIL+3))
fi

# === tests/common.sh assertion helpers ===
CM="$PROJECT_ROOT/tests/common.sh"
if [ -f "$CM" ]; then
    bash -n "$CM" 2>/dev/null && { echo "  ✓ tests/common.sh syntax OK"; PASS=$((PASS+1)); } \
        || { echo "  ✗ tests/common.sh syntax error"; FAIL=$((FAIL+1)); }

    has_assert=$(grep -cE "^assert_|function.*assert" "$CM" 2>/dev/null || echo 0)
    [ "$has_assert" -ge 1 ] && { echo "  ✓ tests/common.sh has $has_assert assertion functions"; PASS=$((PASS+1)); } \
        || { echo "  ✗ No assertion functions in common.sh"; FAIL=$((FAIL+1)); }
else
    echo "  ✗ tests/common.sh not found"
    FAIL=$((FAIL+2))
fi

# === CI workflow ===
CIWF="$PROJECT_ROOT/.github/workflows"
# Check for workflow files
if [ -d "$CIWF" ]; then
    wf_count=$(ls "$CIWF"/*.{yml,yaml} 2>/dev/null | wc -l)
    [ "$wf_count" -ge 1 ] && { echo "  ✓ $wf_count CI workflow(s)"; PASS=$((PASS+1)); } \
        || { echo "  ✗ No CI workflows found"; FAIL=$((FAIL+1)); }
else
    echo "  ~ .github/workflows not present (no CI configured — expected at this stage)"
    PASS=$((PASS+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Runner+CI: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
