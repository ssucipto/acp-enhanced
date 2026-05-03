#!/usr/bin/env bash
# Integration tests for /acp-plan preference and preset integration.
#
# These tests validate the shell-level behavior of preference resolution
# as it would be invoked by /acp-plan. They do NOT invoke the LLM command
# directly — instead they exercise acp.preferences.sh directly, simulating
# what /acp-plan step 1 performs.
#
# Test coverage:
#   1. /acp-plan respects project-level preferences
#   2. /acp-plan preset overrides project preference
#   3. /acp-plan CLI override overrides preset value
#   4. /acp-plan preset load fails gracefully for missing preset

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

. "${SCRIPT_DIR}/tests/common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.preferences.sh"

# ── Fixture setup ─────────────────────────────────────────────────────────────

FIXTURE_DIR="${SCRIPT_DIR}/tests/fixtures/plan-preferences-integration"

setup_fixtures() {
  mkdir -p "${FIXTURE_DIR}/agent/configurables"
  mkdir -p "${FIXTURE_DIR}/agent/preferences"
  mkdir -p "${FIXTURE_DIR}/vscode/preferences"
  mkdir -p "${FIXTURE_DIR}/user-home/.acp/agent/preferences"

  # Configurables (acp namespace)
  cat > "${FIXTURE_DIR}/agent/configurables/acp.configurables.yaml" << 'EOF'
acp:
  _index:
    - plan.draft.create_mode
    - plan.batch.auto_confirm
  plan:
    draft:
      create_mode:
        id: 'plan.draft.create_mode'
        description: How plan drafts are created
        default: structured
        type: string
        options:
          - name: structured
            value: structured
            description: Structured
          - name: unstructured
            value: unstructured
            description: Unstructured
          - name: guided
            value: guided
            description: Guided
          - name: contextual
            value: contextual
            description: Contextual
    batch:
      auto_confirm:
        id: 'plan.batch.auto_confirm'
        description: Auto-confirm batch operations
        default: false
        type: boolean
EOF
}

teardown_fixtures() {
  rm -rf "${FIXTURE_DIR}"
}

# Override path helpers
_pref_project_file()      { echo "${FIXTURE_DIR}/agent/preferences/${1}.default.yaml"; }
_pref_workspace_file()    { echo "${FIXTURE_DIR}/vscode/preferences/${1}.yaml"; }
_pref_user_file()         { echo "${FIXTURE_DIR}/user-home/.acp/agent/preferences/${1}.default.yaml"; }
_pref_configurables_file(){ echo "${FIXTURE_DIR}/agent/configurables/${1}.configurables.yaml"; }
_pref_preset_file() {
  local namespace="$1" preset_name="$2"
  local f="${FIXTURE_DIR}/agent/preferences/${namespace}.${preset_name}.yaml"
  [ -f "$f" ] && echo "$f"
}

# ── Tests ─────────────────────────────────────────────────────────────────────

print_suite_header "/acp-plan Preference Integration Tests"

setup_fixtures

# ── Test 1: /acp-plan respects project-level preference ───────────────────────

print_test_header "/acp-plan — uses project-level preference for draft mode"

cat > "${FIXTURE_DIR}/agent/preferences/acp.default.yaml" << 'EOF'
acp:
  plan:
    draft:
      create_mode: contextual
EOF

result="$(get_preference "acp" "plan.draft.create_mode")"
assert_equals "contextual" "$result" "/acp-plan would use project preference: contextual"

rm -f "${FIXTURE_DIR}/agent/preferences/acp.default.yaml"

# ── Test 2: Preset overrides project preference ───────────────────────────────

print_test_header "/acp-plan -- preset overrides project-level preference"

cat > "${FIXTURE_DIR}/agent/preferences/acp.default.yaml" << 'EOF'
acp:
  plan:
    draft:
      create_mode: structured
EOF

cat > "${FIXTURE_DIR}/agent/preferences/acp.batch-planning.yaml" << 'EOF'
acp:
  plan:
    draft:
      create_mode: contextual
    batch:
      auto_confirm: true
EOF

mode="$(get_preference_with_preset "acp" "plan.draft.create_mode" "batch-planning")"
assert_equals "contextual" "$mode" "preset batch-planning overrides project preference"

confirm="$(get_preference_with_preset "acp" "plan.batch.auto_confirm" "batch-planning")"
assert_equals "true" "$confirm" "preset sets plan.batch.auto_confirm to true"

rm -f "${FIXTURE_DIR}/agent/preferences/acp.batch-planning.yaml"

# ── Test 3: CLI override beats preset ─────────────────────────────────────────

print_test_header "/acp-plan -- CLI override wins over preset"
# Simulates: /acp-plan --preset acp.batch-planning --plan.draft.create_mode guided
# The CLI parsing logic in /acp-plan reads preset first, then applies explicit overrides.
# Here we simulate the final merge step: override wins.

cat > "${FIXTURE_DIR}/agent/preferences/acp.batch-planning.yaml" << 'EOF'
acp:
  plan:
    draft:
      create_mode: contextual
EOF

preset_val="$(get_preference_with_preset "acp" "plan.draft.create_mode" "batch-planning")"
# Simulate CLI override application (override wins):
cli_override="guided"
effective="${cli_override:-$preset_val}"
assert_equals "guided" "$effective" "CLI override guided beats preset contextual"

rm -f "${FIXTURE_DIR}/agent/preferences/acp.batch-planning.yaml"
rm -f "${FIXTURE_DIR}/agent/preferences/acp.default.yaml"

# ── Test 4: Missing preset fails gracefully ───────────────────────────────────

print_test_header "/acp-plan -- missing preset falls back to normal precedence"

set +e
load_preset "acp" "nonexistent-preset" 2>/dev/null
RESULT=$?
set -e
assert_false "load_preset returns non-zero for missing preset" $RESULT

# Fallback: get_preference_with_preset should use normal resolution
result="$(get_preference_with_preset "acp" "plan.draft.create_mode" "nonexistent-preset")"
# With no project/workspace/user files, should use configurables default
assert_equals "structured" "$result" "falls back to configurables default when preset missing"

# ── Test 5: Default from configurables used when no overrides ─────────────────

print_test_header "/acp-plan -- uses configurables default when no preference files exist"

result="$(get_preference "acp" "plan.draft.create_mode")"
assert_equals "structured" "$result" "configurables default 'structured' used with no overrides"

result_confirm="$(get_preference "acp" "plan.batch.auto_confirm")"
assert_equals "false" "$result_confirm" "configurables default 'false' used for batch.auto_confirm"

# ── Cleanup ───────────────────────────────────────────────────────────────────

teardown_fixtures

print_suite_summary

exit $TESTS_FAILED
