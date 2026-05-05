#!/usr/bin/env bash
# E2E smoke tests for acp.package-create.sh
# Tests script existence, syntax validity, argument validation, and reserved name rejection.
# Does NOT test full package creation (requires network access for git clone).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

PKG_CREATE="${PROJECT_ROOT}/agent/scripts/acp.package-create.sh"

echo "${BLUE}Running E2E Tests: acp.package-create.sh smoke test${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: Script file exists
# ---------------------------------------------------------------------------
assert_file_exists "$PKG_CREATE" "acp.package-create.sh exists"

# ---------------------------------------------------------------------------
# Test 2: Script passes bash syntax check
# ---------------------------------------------------------------------------
bash -n "$PKG_CREATE" > /dev/null 2>&1
assert_true "acp.package-create.sh passes bash -n syntax check" "$?"

# ---------------------------------------------------------------------------
# Test 3: --help flag exits 0 and prints usage
# ---------------------------------------------------------------------------
help_out=$(bash "$PKG_CREATE" --help 2>&1)
assert_true "acp.package-create.sh --help exits 0" "$?"
assert_contains "$help_out" "Usage:" "acp.package-create.sh --help prints Usage:"

# ---------------------------------------------------------------------------
# Test 4: Reserved package name 'acp' is rejected with exit non-zero
# ---------------------------------------------------------------------------
bash "$PKG_CREATE" \
    --name acp \
    --description "test" \
    --author "test" \
    --repository "https://example.com/test.git" \
    > /dev/null 2>&1
reserved_exit=$?
assert_false "reserved name 'acp' rejected with non-zero exit" "$reserved_exit"

# ---------------------------------------------------------------------------
# Test 5: Missing required --name arg exits non-zero when stdin is empty
# ---------------------------------------------------------------------------
echo "" | bash "$PKG_CREATE" > /dev/null 2>&1
missing_arg_exit=$?
assert_false "missing required args exits non-zero" "$missing_arg_exit"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp.package-create.sh"
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
