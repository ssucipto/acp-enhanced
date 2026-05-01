#!/usr/bin/env bash
# Unit tests for validate_preference() in acp.preferences.sh
# Tests: type validation, string options, number range, boolean

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

. "${SCRIPT_DIR}/tests/common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.preferences.sh"

# ── Fixture setup ─────────────────────────────────────────────────────────────

FIXTURE_DIR="${SCRIPT_DIR}/tests/fixtures/preferences-validate"

setup_fixtures() {
  mkdir -p "${FIXTURE_DIR}/agent/configurables"
  mkdir -p "${FIXTURE_DIR}/agent/preferences"
  mkdir -p "${FIXTURE_DIR}/vscode/preferences"
  mkdir -p "${FIXTURE_DIR}/user-home/.acp/agent/preferences"

  cat > "${FIXTURE_DIR}/agent/configurables/acp.configurables.yaml" << 'EOF'
acp:
  plan.draft.create_mode:
    id: 'plan.draft.create_mode'
    description: How plan drafts are created
    default: structured
    type: string
    options:
      - name: structured
        value: structured
        description: Structured draft
      - name: unstructured
        value: unstructured
        description: Unstructured draft
      - name: guided
        value: guided
        description: Guided draft
      - name: contextual
        value: contextual
        description: Contextual draft
  task.create.granularity:
    id: 'task.create.granularity'
    description: Task granularity 1-10
    default: 3
    type: number
    min: 1
    max: 10
  validation.auto_fix.enabled:
    id: 'validation.auto_fix.enabled'
    description: Auto-fix validation errors
    default: false
    type: boolean
EOF
}

teardown_fixtures() {
  rm -rf "${FIXTURE_DIR}"
}

# Override path helpers to point at test fixtures
_pref_project_file()      { echo "${FIXTURE_DIR}/agent/preferences/${1}.default.yaml"; }
_pref_workspace_file()    { echo "${FIXTURE_DIR}/vscode/preferences/${1}.yaml"; }
_pref_user_file()         { echo "${FIXTURE_DIR}/user-home/.acp/agent/preferences/${1}.default.yaml"; }
_pref_configurables_file(){ echo "${FIXTURE_DIR}/agent/configurables/${1}.configurables.yaml"; }

# ── Tests ─────────────────────────────────────────────────────────────────────

print_suite_header "validate_preference() Unit Tests"

setup_fixtures

print_test_header "validate_preference — accepts valid string option"
set +e
validate_preference "acp" "plan.draft.create_mode" "structured" 2>/dev/null
RESULT=$?
set -e
assert_true "structured is valid option" $RESULT

print_test_header "validate_preference — accepts all valid string options"
for mode in structured unstructured guided contextual; do
  set +e
  validate_preference "acp" "plan.draft.create_mode" "$mode" 2>/dev/null
  RESULT=$?
  set -e
  assert_true "$mode is a valid option" $RESULT
done

print_test_header "validate_preference — rejects invalid string option"
set +e
validate_preference "acp" "plan.draft.create_mode" "invalid_mode" 2>/dev/null
RESULT=$?
set -e
assert_false "invalid_mode is rejected" $RESULT

print_test_header "validate_preference — accepts number within range"
set +e
validate_preference "acp" "task.create.granularity" "5" 2>/dev/null
RESULT=$?
set -e
assert_true "5 is within range 1-10" $RESULT

print_test_header "validate_preference — accepts boundary numbers"
for num in 1 10; do
  set +e
  validate_preference "acp" "task.create.granularity" "$num" 2>/dev/null
  RESULT=$?
  set -e
  assert_true "$num is within valid range" $RESULT
done

print_test_header "validate_preference — rejects number below minimum"
set +e
validate_preference "acp" "task.create.granularity" "0" 2>/dev/null
RESULT=$?
set -e
assert_false "0 is below minimum (1)" $RESULT

print_test_header "validate_preference — rejects number above maximum"
set +e
validate_preference "acp" "task.create.granularity" "15" 2>/dev/null
RESULT=$?
set -e
assert_false "15 is above maximum (10)" $RESULT

print_test_header "validate_preference — accepts boolean true"
set +e
validate_preference "acp" "validation.auto_fix.enabled" "true" 2>/dev/null
RESULT=$?
set -e
assert_true "true is valid boolean" $RESULT

print_test_header "validate_preference — accepts boolean false"
set +e
validate_preference "acp" "validation.auto_fix.enabled" "false" 2>/dev/null
RESULT=$?
set -e
assert_true "false is valid boolean" $RESULT

print_test_header "validate_preference — rejects non-boolean string"
for bad in yes no 1 0 TRUE FALSE; do
  set +e
  validate_preference "acp" "validation.auto_fix.enabled" "$bad" 2>/dev/null
  RESULT=$?
  set -e
  assert_false "$bad is not a valid boolean" $RESULT
done

# ── Cleanup ───────────────────────────────────────────────────────────────────

teardown_fixtures

print_suite_summary

exit $TESTS_FAILED
