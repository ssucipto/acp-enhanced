#!/usr/bin/env bash
# E2E smoke test for @acp.spec command doc and spec.template.md structure.
# Tests file existence and required section presence — not LLM behavioral output.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

SPEC_CMD="${PROJECT_ROOT}/agent/commands/acp.spec.md"
SPEC_TMPL="${PROJECT_ROOT}/agent/specs/spec.template.md"

echo "${BLUE}Running E2E Tests: acp.spec command doc smoke test${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: acp.spec.md exists
# ---------------------------------------------------------------------------
assert_file_exists "$SPEC_CMD" "acp.spec.md exists"

# ---------------------------------------------------------------------------
# Test 2: File contains '# Command: spec' header
# ---------------------------------------------------------------------------
assert_contains "$(cat "$SPEC_CMD")" "# Command: spec" "acp.spec.md has '# Command: spec' header"

# ---------------------------------------------------------------------------
# Test 3: File contains '**Version**:' field
# ---------------------------------------------------------------------------
version_check=$(grep -F "**Version**:" "$SPEC_CMD" || true)
assert_not_empty "$version_check" "acp.spec.md has Version field"

# ---------------------------------------------------------------------------
# Test 4: File contains '**Status**: Active'
# ---------------------------------------------------------------------------
status_check=$(grep -F "**Status**: Active" "$SPEC_CMD" || true)
assert_not_empty "$status_check" "acp.spec.md has Status: Active"

# ---------------------------------------------------------------------------
# Test 5: File contains at least one FR- or R[0-9] reference
# ---------------------------------------------------------------------------
fr_check=$(grep -c "FR-\|R[0-9]" "$SPEC_CMD" || true)
assert_not_empty "$fr_check" "acp.spec.md contains FR-ID references"

# ---------------------------------------------------------------------------
# Test 6: File contains 'Behavior Table' or '## Behavior' section
# ---------------------------------------------------------------------------
behavior_check=$(grep -i "behavior table\|## behavior\|behavior.*table" "$SPEC_CMD" || true)
assert_not_empty "$behavior_check" "acp.spec.md has Behavior Table section"

# ---------------------------------------------------------------------------
# Test 7: spec.template.md exists
# ---------------------------------------------------------------------------
assert_file_exists "$SPEC_TMPL" "spec.template.md exists"

# ---------------------------------------------------------------------------
# Test 8: Template contains '@acp.meta.spec' marker
# ---------------------------------------------------------------------------
assert_contains "$(cat "$SPEC_TMPL")" "@acp.meta.spec" "spec.template.md has @acp.meta.spec marker"

# ---------------------------------------------------------------------------
# Test 9: Template contains 'requirements:' field inside the marker block
# ---------------------------------------------------------------------------
assert_contains "$(cat "$SPEC_TMPL")" "requirements:" "spec.template.md has requirements: field"

# ---------------------------------------------------------------------------
# Test 10: Template contains '## Purpose' section
# ---------------------------------------------------------------------------
assert_contains "$(cat "$SPEC_TMPL")" "## Purpose" "spec.template.md has ## Purpose section"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp.spec command doc smoke test"
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
