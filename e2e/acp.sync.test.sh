#!/usr/bin/env bash
# E2E smoke test for @acp.sync command doc and meta-scan integration.
# Verifies structural integrity: required steps, integration points, traceability fields.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

SYNC_CMD="${PROJECT_ROOT}/agent/commands/acp.sync.md"
META_SCAN="${PROJECT_ROOT}/agent/scripts/acp.meta-scan.sh"

echo "${BLUE}Running E2E Tests: acp.sync command doc + meta-scan integration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: acp.sync.md exists
# ---------------------------------------------------------------------------
assert_file_exists "$SYNC_CMD" "acp.sync.md exists"

# ---------------------------------------------------------------------------
# Test 2: File references acp.meta-scan.sh (integration point present)
# ---------------------------------------------------------------------------
meta_ref=$(grep "meta-scan" "$SYNC_CMD" || true)
assert_not_empty "$meta_ref" "acp.sync.md references meta-scan"

# ---------------------------------------------------------------------------
# Test 3: File contains Step 1.3 (marker-stream scan step)
# ---------------------------------------------------------------------------
step13=$(grep "1\.3" "$SYNC_CMD" || true)
assert_not_empty "$step13" "acp.sync.md contains Step 1.3"

# ---------------------------------------------------------------------------
# Test 4: File references 'covers:' (spec-task traceability field)
# ---------------------------------------------------------------------------
covers_ref=$(grep "covers:" "$SYNC_CMD" || true)
assert_not_empty "$covers_ref" "acp.sync.md references 'covers:' field"

# ---------------------------------------------------------------------------
# Test 5: File references 'incorporates:' (design-task traceability field)
# ---------------------------------------------------------------------------
incorp_ref=$(grep "incorporates:" "$SYNC_CMD" || true)
assert_not_empty "$incorp_ref" "acp.sync.md references 'incorporates:' field"

# ---------------------------------------------------------------------------
# Test 6: File is ≥100 lines (not accidentally truncated)
# ---------------------------------------------------------------------------
line_count=$(wc -l < "$SYNC_CMD")
if [ "$line_count" -ge 100 ]; then
    assert_equals "ok" "ok" "acp.sync.md is ≥100 lines ($line_count)"
else
    assert_equals "≥100 lines" "$line_count lines" "acp.sync.md is ≥100 lines"
fi

# ---------------------------------------------------------------------------
# Test 7: acp.meta-scan.sh exists
# ---------------------------------------------------------------------------
assert_file_exists "$META_SCAN" "acp.meta-scan.sh exists"

# ---------------------------------------------------------------------------
# Test 8: acp.meta-scan.sh references @acp.meta sentinel
# ---------------------------------------------------------------------------
sentinel=$(grep "@acp\.meta" "$META_SCAN" || true)
assert_not_empty "$sentinel" "acp.meta-scan.sh references @acp.meta sentinel"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: acp.sync command doc + meta-scan integration"
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
