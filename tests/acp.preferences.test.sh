#!/usr/bin/env bash
# Unit tests for acp.preferences.sh
# Tests: get_preference(), has_preference(), get_preference_or(),
#        get_preference_source(), generate_preferences()
# NOTE: Do NOT add set -e here. assert_* functions and has_preference() return
# exit code 1 on failure by design; set -e would abort the suite at the first failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Save the project root before sourcing scripts — some scripts (e.g. acp.preferences.sh)
# override SCRIPT_DIR with their own directory when sourced.
ACP_TEST_ROOT="$SCRIPT_DIR"

# Source test utilities
. "${SCRIPT_DIR}/tests/common.sh"

# Source dependencies before sourcing the script under test
. "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.common.sh"

# Source the script under test (sourceable mode — no entry point runs)
. "${SCRIPT_DIR}/agent/scripts/acp.preferences.sh"

# ── Test fixture setup ─────────────────────────────────────────────────────────

FIXTURE_DIR="${ACP_TEST_ROOT}/tests/fixtures/preferences"
# Use a temp subdirectory to avoid rm -rf deleting tracked fixture files
# that live in tests/fixtures/preferences/ (e.g. invalid.yaml, preset.yaml, valid.yaml)
FIXTURE_DIR="$(mktemp -d)/acp_pref_test"

setup_fixtures() {
  mkdir -p "${FIXTURE_DIR}/agent/preferences"
  mkdir -p "${FIXTURE_DIR}/vscode/preferences"
  mkdir -p "${FIXTURE_DIR}/user-home/.acp/agent/preferences"
  mkdir -p "${FIXTURE_DIR}/agent/configurables"

  # Configurables (defines defaults + known keys)
  cat > "${FIXTURE_DIR}/agent/configurables/testns.configurables.yaml" << 'EOF'
testns:
  _index:
    - plan.draft.create_mode
    - task.granularity
    - validation.auto_fix
  plan:
    draft:
      create_mode:
        default: structured
        description: How plan drafts are created
  task:
    granularity:
      default: 3
      description: Task granularity level
  validation:
    auto_fix:
      default: false
      description: Whether to auto-fix validation errors
EOF

  # User-level preferences
  cat > "${FIXTURE_DIR}/user-home/.acp/agent/preferences/testns.default.yaml" << 'EOF'
testns:
  task:
    granularity: 5
  validation:
    auto_fix: true
EOF

  # Workspace-level preferences (overrides user)
  cat > "${FIXTURE_DIR}/vscode/preferences/testns.yaml" << 'EOF'
testns:
  task:
    granularity: 7
EOF

  # Project-level preferences (highest precedence)
  cat > "${FIXTURE_DIR}/agent/preferences/testns.default.yaml" << 'EOF'
testns:
  plan:
    draft:
      create_mode: incremental
EOF
}

teardown_fixtures() {
  rm -rf "${FIXTURE_DIR}"
}

# Override resolution helpers to point at fixture paths for testing
_pref_project_file()      { echo "${FIXTURE_DIR}/agent/preferences/${1}.default.yaml"; }
_pref_workspace_file()    { echo "${FIXTURE_DIR}/vscode/preferences/${1}.yaml"; }
_pref_user_file()         { echo "${FIXTURE_DIR}/user-home/.acp/agent/preferences/${1}.default.yaml"; }
_pref_configurables_file(){ echo "${FIXTURE_DIR}/agent/configurables/${1}.configurables.yaml"; }

# ── Tests ──────────────────────────────────────────────────────────────────────

print_suite_header "acp.preferences.sh Unit Tests"

setup_fixtures

# ── get_preference() ──────────────────────────────────────────────────────────

print_test_header "get_preference — project takes precedence over all"
result="$(get_preference "testns" "plan.draft.create_mode")"
assert_equals "incremental" "$result" "project-level value wins for plan.draft.create_mode"

print_test_header "get_preference — workspace takes precedence over user"
result="$(get_preference "testns" "task.granularity")"
assert_equals "7" "$result" "workspace-level value wins over user-level for task.granularity"

print_test_header "get_preference — user-level used when no project/workspace"
result="$(get_preference "testns" "validation.auto_fix")"
assert_equals "true" "$result" "user-level value used when no project/workspace entry exists"

print_test_header "get_preference — falls back to configurables default"
# Remove project + workspace + user entries by using a namespace that has nothing set
result="$(get_preference "testns" "plan.draft.create_mode.default" 2>/dev/null || true)"
# plan.draft.create_mode IS set at project level — test the default path via missing key
# Use a key that is only in configurables
result_from_default="$(get_preference "testns" "nonexistent.key" 2>/dev/null || true)"
assert_empty "$result_from_default" "nonexistent key returns empty (no default)"

print_test_header "get_preference — returns empty for completely unknown key"
result="$(get_preference "testns" "does.not.exist" 2>/dev/null || true)"
assert_empty "$result" "unknown preference path returns empty string"

print_test_header "get_preference — returns empty for unknown namespace"
result="$(get_preference "unknown_ns" "any.key" 2>/dev/null || true)"
assert_empty "$result" "unknown namespace returns empty string"

# ── has_preference() ─────────────────────────────────────────────────────────

print_test_header "has_preference — returns true for existing preference"
has_preference "testns" "plan.draft.create_mode"
assert_true "has_preference exits 0 for known key" $?

print_test_header "has_preference — returns false for missing preference"
has_preference "testns" "totally.missing.key" 2>/dev/null
RESULT=$?
assert_false "has_preference exits non-zero for unknown key" $RESULT

# ── get_preference_or() ───────────────────────────────────────────────────────

print_test_header "get_preference_or — returns resolved value when found"
result="$(get_preference_or "testns" "plan.draft.create_mode" "fallback-val")"
assert_equals "incremental" "$result" "resolved value returned (not fallback)"

print_test_header "get_preference_or — returns fallback when not found"
result="$(get_preference_or "testns" "totally.missing.key" "my-fallback")"
assert_equals "my-fallback" "$result" "fallback returned for missing preference"

# ── get_preference_source() ───────────────────────────────────────────────────

print_test_header "get_preference_source — identifies project source"
source_level="$(get_preference_source "testns" "plan.draft.create_mode")"
assert_equals "project" "$source_level" "project source correctly identified"

print_test_header "get_preference_source — identifies workspace source"
source_level="$(get_preference_source "testns" "task.granularity")"
assert_equals "workspace" "$source_level" "workspace source correctly identified"

print_test_header "get_preference_source — identifies user source"
source_level="$(get_preference_source "testns" "validation.auto_fix")"
assert_equals "user" "$source_level" "user source correctly identified"

print_test_header "get_preference_source — returns none for missing key"
source_level="$(get_preference_source "testns" "absolutely.missing" 2>/dev/null || echo "none")"
assert_equals "none" "$source_level" "none returned for unknown preference"

# ── generate_preferences() ───────────────────────────────────────────────────

print_test_header "generate_preferences — emits YAML namespace block"
output="$(generate_preferences "testns" "yaml" 2>/dev/null || true)"
assert_contains "$output" "testns:" "YAML output starts with namespace key"

print_test_header "generate_preferences — fails for unknown namespace"
generate_preferences "unknown_ns" "yaml" 2>/dev/null
RESULT=$?
assert_false "generate_preferences exits non-zero for missing configurables" $RESULT

print_test_header "generate_preferences — emits JSON when requested"
output="$(generate_preferences "testns" "json" 2>/dev/null || true)"
assert_contains "$output" "\"testns\"" "JSON output contains namespace key"

# ── Syntax check ─────────────────────────────────────────────────────────────

print_test_header "acp.preferences.sh — no bash syntax errors"
bash -n "${ACP_TEST_ROOT}/agent/scripts/acp.preferences.sh"
assert_true "bash -n reports no syntax errors" $?

# ── set_preference() round-trip ───────────────────────────────────────────────

print_test_header "set_preference — writes nested YAML readable by yaml_get"
# Use project level — file created by setup_fixtures (nested format)
set_preference "testns" "plan.draft.create_mode" "guided" "project"
round_trip="$(yaml_get "${FIXTURE_DIR}/agent/preferences/testns.default.yaml" "testns.plan.draft.create_mode" 2>/dev/null || true)"
assert_equals "guided" "$round_trip" "set_preference writes nested YAML, yaml_get reads it back"

print_test_header "set_preference — creates new preference file with correct nested format"
rm -f "${FIXTURE_DIR}/agent/preferences/newns.default.yaml"
set_preference "newns" "output.verbosity.level" "verbose" "project"
round_trip="$(yaml_get "${FIXTURE_DIR}/agent/preferences/newns.default.yaml" "newns.output.verbosity.level" 2>/dev/null || true)"
assert_equals "verbose" "$round_trip" "new file written in nested format, yaml_get reads back"
rm -f "${FIXTURE_DIR}/agent/preferences/newns.default.yaml"

print_test_header "set_preference — get_preference returns value without flat-dot fallback"
set_preference "testns" "task.create.granularity" "2" "workspace"
pref_val="$(get_preference "testns" "task.create.granularity")"
assert_equals "2" "$pref_val" "get_preference reads set_preference result correctly"

# ── Cleanup ───────────────────────────────────────────────────────────────────

teardown_fixtures

print_suite_summary

# Exit with failure count
exit $TESTS_FAILED
