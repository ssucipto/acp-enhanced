#!/bin/bash
# E2E Tests for acp.meta-scan.sh
# Tests language-agnostic @acp.meta.* marker parsing across file types,
# --kind filtering, comment prefix stripping, and field extraction.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

. "${PROJECT_ROOT}/tests/common.sh"

SCANNER="${PROJECT_ROOT}/agent/scripts/acp.meta-scan.sh"
FIXTURES="${SCRIPT_DIR}/fixtures/meta-scan"

TEST_NAME="acp.meta-scan.sh"
TEST_FAILURES=0

echo "${BLUE}Running E2E Tests: ${TEST_NAME}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ---------------------------------------------------------------------------
# Test 1: Basic scan returns non-empty output for a file containing a marker
# ---------------------------------------------------------------------------
output=$(bash "$SCANNER" "$FIXTURES/spec-markers.md")
assert_not_empty "$output" "basic scan returns output for spec-markers.md"

# ---------------------------------------------------------------------------
# Test 2: Output contains 'kind: spec' for spec marker
# ---------------------------------------------------------------------------
assert_contains "$output" "kind: spec" "output contains 'kind: spec'"

# ---------------------------------------------------------------------------
# Test 3: Output contains 'file:' field pointing to the scanned file
# ---------------------------------------------------------------------------
assert_contains "$output" "file:" "output contains 'file:' field"

# ---------------------------------------------------------------------------
# Test 4: 'topic:' field is parsed and emitted
# ---------------------------------------------------------------------------
assert_contains "$output" "topic: pen-pal-unlock" "'topic:' field parsed correctly"

# ---------------------------------------------------------------------------
# Test 5: 'requirements:' field is parsed and emitted
# ---------------------------------------------------------------------------
assert_contains "$output" "requirements: R10, R11, R12" "'requirements:' field parsed correctly"

# ---------------------------------------------------------------------------
# Test 6: --kind spec returns only spec markers (not task markers)
# ---------------------------------------------------------------------------
task_output=$(bash "$SCANNER" --kind task "$FIXTURES/spec-markers.md")
assert_empty "$task_output" "--kind task returns empty output when only spec marker present"

# ---------------------------------------------------------------------------
# Test 7: --kind spec filter returns the spec marker from spec-markers.md
# ---------------------------------------------------------------------------
spec_only=$(bash "$SCANNER" --kind spec "$FIXTURES/spec-markers.md")
assert_contains "$spec_only" "kind: spec" "--kind spec returns spec marker"

# ---------------------------------------------------------------------------
# Test 8: TypeScript file — '//' comment prefix stripped correctly
# ---------------------------------------------------------------------------
ts_output=$(bash "$SCANNER" "$FIXTURES/code-markers.ts")
assert_not_empty "$ts_output" "TypeScript code markers produce output"
assert_contains "$ts_output" "kind: code" "TypeScript marker kind parsed as 'code'"

# ---------------------------------------------------------------------------
# Test 9: TypeScript 'implements:' field extracted after comment strip
# ---------------------------------------------------------------------------
assert_contains "$ts_output" "implements: R10" "TypeScript 'implements:' field parsed after '//' strip"

# ---------------------------------------------------------------------------
# Test 10: Task marker 'covers:' field parsed correctly
# ---------------------------------------------------------------------------
task_out=$(bash "$SCANNER" "$FIXTURES/task-markers.md")
assert_contains "$task_out" "covers: R10, R11" "'covers:' field parsed in task marker"

# ---------------------------------------------------------------------------
# Test 11: Task marker 'incorporates:' field parsed correctly
# ---------------------------------------------------------------------------
assert_contains "$task_out" "incorporates: D3, D7" "'incorporates:' field parsed in task marker"

# ---------------------------------------------------------------------------
# Test 12: Multi-marker file produces multiple '---' separator blocks
# ---------------------------------------------------------------------------
multi_out=$(bash "$SCANNER" "$FIXTURES/multi-markers.md")
sep_count=$(echo "$multi_out" | grep -c "^---$")
assert_equals "3" "$sep_count" "multi-marker file produces 3 '---' separators"

# ---------------------------------------------------------------------------
# Test 13: Multi-marker file contains all 3 kinds (spec, task, note)
# ---------------------------------------------------------------------------
assert_contains "$multi_out" "kind: spec" "multi-marker contains kind: spec"
assert_contains "$multi_out" "kind: task" "multi-marker contains kind: task"
assert_contains "$multi_out" "kind: note" "multi-marker contains kind: note"

# ---------------------------------------------------------------------------
# Test 14: --kind spec,task returns spec and task markers but not note
# ---------------------------------------------------------------------------
filtered=$(bash "$SCANNER" --kind spec,task "$FIXTURES/multi-markers.md")
assert_contains "$filtered" "kind: spec" "--kind spec,task includes spec"
assert_contains "$filtered" "kind: task" "--kind spec,task includes task"
note_check=$(echo "$filtered" | grep "kind: note" || true)
assert_empty "$note_check" "--kind spec,task excludes note markers"

# ---------------------------------------------------------------------------
# Test 15: No-markers file produces empty output (exit 0)
# ---------------------------------------------------------------------------
no_marker_out=$(bash "$SCANNER" "$FIXTURES/no-markers.md")
assert_empty "$no_marker_out" "no-marker file produces empty output"

# Exit code for no-markers file is 0
bash "$SCANNER" "$FIXTURES/no-markers.md" > /dev/null 2>&1
assert_true "no-marker file exits with code 0" "$?"

# ---------------------------------------------------------------------------
# Test 16: Unknown --kind returns empty output (exit 0)
# ---------------------------------------------------------------------------
unknown_out=$(bash "$SCANNER" --kind nosuchthing "$FIXTURES/spec-markers.md")
assert_empty "$unknown_out" "--kind nosuchthing returns empty output"

# ---------------------------------------------------------------------------
# Test 17: Scan of entire agent/ tree returns at least one result
# ---------------------------------------------------------------------------
tree_out=$(bash "$SCANNER" "${PROJECT_ROOT}/agent/specs" 2>/dev/null || bash "$SCANNER" "${PROJECT_ROOT}/agent" 2>/dev/null || true)
assert_not_empty "$tree_out" "scan of agent/ tree returns at least 1 result"

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary: ${TEST_NAME}"
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
