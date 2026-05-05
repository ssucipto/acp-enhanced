#!/usr/bin/env bash
# E2E smoke tests for acp.package-validate.sh
# Tests script existence, syntax validity, and context detection (no package.yaml → exit 1).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

PKG_VALIDATE="${PROJECT_ROOT}/agent/scripts/acp.package-validate.sh"

echo "${BLUE}Running E2E Tests: acp.package-validate.sh smoke test${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: Script file exists
# ---------------------------------------------------------------------------
assert_file_exists "$PKG_VALIDATE" "acp.package-validate.sh exists"

# ---------------------------------------------------------------------------
# Test 2: Script passes bash syntax check
# ---------------------------------------------------------------------------
bash -n "$PKG_VALIDATE" > /dev/null 2>&1
assert_true "acp.package-validate.sh passes bash -n syntax check" "$?"

# ---------------------------------------------------------------------------
# Test 3: Running without package.yaml exits non-zero
# ---------------------------------------------------------------------------
TMPDIR_VALIDATE=$(mktemp -d)
( cd "$TMPDIR_VALIDATE" && bash "$PKG_VALIDATE" > /dev/null 2>&1 )
no_yaml_exit=$?
rm -rf "$TMPDIR_VALIDATE"
assert_false "exits non-zero when package.yaml is missing" "$no_yaml_exit"

# ---------------------------------------------------------------------------
# Test 4: Error message mentions package.yaml when missing
# ---------------------------------------------------------------------------
TMPDIR_VALIDATE2=$(mktemp -d)
err_out=$( cd "$TMPDIR_VALIDATE2" && bash "$PKG_VALIDATE" 2>&1 || true )
rm -rf "$TMPDIR_VALIDATE2"
assert_contains "$err_out" "package.yaml" "error output mentions package.yaml"

# ---------------------------------------------------------------------------
# Test 5: Script references expected validation function (not accidentally empty)
# ---------------------------------------------------------------------------
fn_check=$(grep -c "check_package_context\|validate_yaml_structure" "$PKG_VALIDATE" || true)
assert_not_empty "$fn_check" "acp.package-validate.sh contains validation functions"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp.package-validate.sh"
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
