#!/usr/bin/env bash
# E2E Tests for agent/drafts/ convention
# Verifies that the directory, .gitkeep, and draft.template.md are present
# and that the template contains the required 3-question structure.
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

DRAFTS_DIR="${PROJECT_ROOT}/agent/drafts"

# ── Suite ─────────────────────────────────────────────────────────────────────

print_suite_header "agent/drafts/ Convention — E2E Tests"

# Test 1: directory exists
print_test_header "agent/drafts/ directory exists"
assert_dir_exists "${DRAFTS_DIR}" "agent/drafts/ directory exists"

# Test 2: .gitkeep present
print_test_header "agent/drafts/.gitkeep is present"
assert_file_exists "${DRAFTS_DIR}/.gitkeep" "agent/drafts/.gitkeep present"

# Test 3: draft.template.md present
print_test_header "agent/drafts/draft.template.md is present"
assert_file_exists "${DRAFTS_DIR}/draft.template.md" "agent/drafts/draft.template.md present"

# Test 4: template has ≥3 question sections
print_test_header "draft.template.md contains ≥3 question sections"
QUESTION_COUNT="$(grep -c "^## Question" "${DRAFTS_DIR}/draft.template.md" 2>/dev/null || echo 0)"
assert_true "draft.template.md has ≥3 question sections (found ${QUESTION_COUNT})" \
    "$([ "${QUESTION_COUNT}" -ge 3 ] && echo 0 || echo 1)"

# Test 5: agent/.gitignore includes drafts/** pattern
print_test_header "agent/.gitignore has drafts/** entry (not bare drafts/)"
assert_true "agent/.gitignore contains drafts/**" \
    "$(grep -q "drafts/\*\*" "${PROJECT_ROOT}/agent/.gitignore" 2>/dev/null && echo 0 || echo 1)"

# Test 6: .gitkeep is excluded from gitignore (tracked exception)
print_test_header "agent/.gitignore has !drafts/.gitkeep exception"
assert_true "agent/.gitignore has !drafts/.gitkeep" \
    "$(grep -q "!drafts/.gitkeep" "${PROJECT_ROOT}/agent/.gitignore" 2>/dev/null && echo 0 || echo 1)"

# Test 7: draft.template.md is excluded from gitignore (tracked exception)
print_test_header "agent/.gitignore has !drafts/draft.template.md exception"
assert_true "agent/.gitignore has !drafts/draft.template.md" \
    "$(grep -q "!drafts/draft.template.md" "${PROJECT_ROOT}/agent/.gitignore" 2>/dev/null && echo 0 || echo 1)"

# ── Summary ───────────────────────────────────────────────────────────────────

print_suite_summary

[ "${TESTS_FAILED}" -eq 0 ]
