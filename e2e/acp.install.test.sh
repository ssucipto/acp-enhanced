#!/usr/bin/env bash
# E2E smoke tests for scripts/acp-bootstrap.sh
# Tests script existence, syntax validity, and directory creation in a temp dir.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

BOOTSTRAP="${PROJECT_ROOT}/scripts/acp-bootstrap.sh"

echo "${BLUE}Running E2E Tests: acp-bootstrap.sh smoke test${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: Bootstrap script exists
# ---------------------------------------------------------------------------
assert_file_exists "$BOOTSTRAP" "acp-bootstrap.sh exists"

# ---------------------------------------------------------------------------
# Test 2: Script passes bash syntax check
# ---------------------------------------------------------------------------
bash -n "$BOOTSTRAP" > /dev/null 2>&1
assert_true "acp-bootstrap.sh passes bash -n syntax check" "$?"

# ---------------------------------------------------------------------------
# Tests 3-5: Bootstrap creates expected directories in a temp dir
# ---------------------------------------------------------------------------
TMPDIR_BOOTSTRAP=$(mktemp -d)
( cd "$TMPDIR_BOOTSTRAP" && bash "$BOOTSTRAP" > /dev/null 2>&1 )
bootstrap_exit=$?

assert_true "acp-bootstrap.sh runs without error in empty directory" "$bootstrap_exit"
assert_dir_exists "$TMPDIR_BOOTSTRAP/agent/core" "bootstrap creates agent/core directory"
assert_dir_exists "$TMPDIR_BOOTSTRAP/agent/drafts" "bootstrap creates agent/drafts directory"
assert_dir_exists "$TMPDIR_BOOTSTRAP/agent/memory" "bootstrap creates agent/memory directory"
assert_dir_exists "$TMPDIR_BOOTSTRAP/.github/prompts" "bootstrap creates .github/prompts directory"

rm -rf "$TMPDIR_BOOTSTRAP"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp-bootstrap.sh"
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
