#!/usr/bin/env bash
# E2E tests for acp.preferences.sh CLI subcommand interface.
# Tests the direct invocation mode (not the sourced function API tested in tests/acp.preferences.test.sh).
# Covers: help, get, has, set, validate, generate, unknown-subcommand error handling.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

PREF="${PROJECT_ROOT}/agent/scripts/acp.preferences.sh"

echo "${BLUE}Running E2E Tests: acp.preferences.sh CLI interface${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: Script exists
# ---------------------------------------------------------------------------
assert_file_exists "$PREF" "acp.preferences.sh exists"

# ---------------------------------------------------------------------------
# Test 2: No-arg invocation (help) exits 0
# ---------------------------------------------------------------------------
bash "$PREF" > /dev/null 2>&1
assert_true "no-arg invocation exits 0 (shows help)" "$?"

# ---------------------------------------------------------------------------
# Test 3: 'help' subcommand exits 0 and prints Usage:
# ---------------------------------------------------------------------------
help_out=$(bash "$PREF" help 2>&1)
assert_true "'help' subcommand exits 0" "$?"
assert_contains "$help_out" "Usage:" "'help' subcommand prints Usage:"

# ---------------------------------------------------------------------------
# Test 4: Unknown subcommand exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" no_such_subcommand > /dev/null 2>&1
assert_false "unknown subcommand exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Test 5: 'get' with missing args exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" get > /dev/null 2>&1
assert_false "'get' with no args exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Test 6: 'get' on non-existent namespace/key exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" get "e2e_test_ns_nonexistent" "nonexistent.key" > /dev/null 2>&1
assert_false "'get' for unknown namespace/key exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Test 7: 'has' on non-existent key exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" has "e2e_test_ns_nonexistent" "nonexistent.key" > /dev/null 2>&1
assert_false "'has' for unknown key exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Test 8: 'set' and 'get' round-trip in a temp directory
# ---------------------------------------------------------------------------
TMPDIR_PREF=$(mktemp -d)
mkdir -p "$TMPDIR_PREF/agent/preferences"
(
    cd "$TMPDIR_PREF"
    bash "$PREF" set "acp" "plan.draft.create_mode" "turbo" "project" > /dev/null 2>&1
)
set_exit=$?
assert_true "'set' exits 0 when writing a preference" "$set_exit"

# Verify the value was written (file should now exist and contain the key)
pref_file="$TMPDIR_PREF/agent/preferences/acp.default.yaml"
if [ -f "$pref_file" ]; then
    # set_preference writes nested YAML: key is 'create_mode: turbo', not the flat-dot path
    written=$(grep "create_mode" "$pref_file" || true)
    assert_not_empty "$written" "'set' writes the preference key to the project file"
else
    assert_equals "file exists" "file missing" "preferences file created by 'set'"
fi

rm -rf "$TMPDIR_PREF"

# ---------------------------------------------------------------------------
# Test 9: 'validate' with missing args exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" validate > /dev/null 2>&1
assert_false "'validate' with no args exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Test 10: 'generate' with missing args exits non-zero
# ---------------------------------------------------------------------------
bash "$PREF" generate > /dev/null 2>&1
assert_false "'generate' with no args exits non-zero" "$?"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp.preferences.sh CLI interface"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Tests run:    ${TESTS_RUN}"
echo "  Tests passed: ${TESTS_PASSED}"
echo "  Tests failed: ${TESTS_FAILED}"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo "${RED}✗ ${TESTS_FAILED} test(s) failed${NC}"
    exit 1
fi
