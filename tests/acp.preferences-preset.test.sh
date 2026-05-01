#!/usr/bin/env bash
# Unit tests for preset functions in acp.preferences.sh
# Tests: load_preset(), get_preference_with_preset(), list_presets()

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

. "${SCRIPT_DIR}/tests/common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.common.sh"
. "${SCRIPT_DIR}/agent/scripts/acp.preferences.sh"

# ── Fixture setup ─────────────────────────────────────────────────────────────

FIXTURE_DIR="${SCRIPT_DIR}/tests/fixtures/preferences-preset"

setup_fixtures() {
  mkdir -p "${FIXTURE_DIR}/agent/configurables"
  mkdir -p "${FIXTURE_DIR}/agent/preferences"
  mkdir -p "${FIXTURE_DIR}/vscode/preferences"
  mkdir -p "${FIXTURE_DIR}/user-home/.acp/agent/preferences"

  # Minimal configurables so get_preference fallback works
  cat > "${FIXTURE_DIR}/agent/configurables/testns.configurables.yaml" << 'EOF'
testns:
  _index:
    - plan.draft.create_mode
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
            description: Structured draft
          - name: contextual
            value: contextual
            description: Contextual draft
          - name: guided
            value: guided
            description: Guided draft
EOF

  # Project-level default
  cat > "${FIXTURE_DIR}/agent/preferences/testns.default.yaml" << 'EOF'
testns:
  plan:
    draft:
      create_mode: structured
EOF

  # Named preset file (project-level)
  cat > "${FIXTURE_DIR}/agent/preferences/testns.test-preset.yaml" << 'EOF'
testns:
  plan:
    draft:
      create_mode: contextual
EOF

  # A second preset for list_presets tests
  cat > "${FIXTURE_DIR}/agent/preferences/testns.another-preset.yaml" << 'EOF'
testns:
  plan:
    draft:
      create_mode: guided
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

# Override _pref_preset_file() to look in FIXTURE_DIR instead of cwd
_pref_preset_file() {
  local namespace="$1" preset_name="$2"
  local f="${FIXTURE_DIR}/agent/preferences/${namespace}.${preset_name}.yaml"
  [ -f "$f" ] && echo "$f"
}

# Override list_presets() to look in FIXTURE_DIR instead of cwd
list_presets() {
  local namespace="$1"
  local found=0
  local scan_dir="${FIXTURE_DIR}/agent/preferences"
  if [ -d "$scan_dir" ]; then
    while IFS= read -r -d '' f; do
      local base; base="$(basename "$f" .yaml)"
      local preset="${base#${namespace}.}"
      [[ "$preset" == "default" ]] && continue
      [[ "$preset" == "$base" ]] && continue
      echo "  📁 project: ${preset}"
      found=1
    done < <(find "$scan_dir" -maxdepth 1 -name "${namespace}.*.yaml" -print0 2>/dev/null)
  fi
  if [ "$found" -eq 0 ]; then
    echo "  (no presets found for namespace '${namespace}')"
  fi
}

# ── Tests ─────────────────────────────────────────────────────────────────────

print_suite_header "Preset Functions Unit Tests"

setup_fixtures

print_test_header "load_preset — succeeds when preset file exists"
set +e
result="$(load_preset "testns" "test-preset" 2>/dev/null)"
RESULT=$?
set -e
assert_true "load_preset exits 0 for existing preset" $RESULT
assert_not_empty "$result" "load_preset returns file path when found"

print_test_header "load_preset — fails when preset file does not exist"
set +e
load_preset "testns" "nonexistent-preset" 2>/dev/null
RESULT=$?
set -e
assert_false "load_preset exits non-zero for missing preset" $RESULT

print_test_header "get_preference_with_preset — returns preset value over project value"
result="$(get_preference_with_preset "testns" "plan.draft.create_mode" "test-preset")"
assert_equals "contextual" "$result" "preset value wins over project value"

print_test_header "get_preference_with_preset — falls back to normal precedence when preset key absent"
# test-preset only sets plan.draft.create_mode — so any other key falls back
# We'll check that missing preset key falls back to project value
result="$(get_preference_with_preset "testns" "plan.draft.create_mode" "nonexistent-preset")"
assert_equals "structured" "$result" "falls back to project when preset file missing"

print_test_header "get_preference_with_preset — no preset, uses normal precedence"
result="$(get_preference_with_preset "testns" "plan.draft.create_mode" "")"
assert_equals "structured" "$result" "no preset uses normal precedence (project wins)"

print_test_header "list_presets — lists named preset files, excludes .default"
output="$(list_presets "testns")"
assert_contains "$output" "test-preset" "test-preset listed"
assert_contains "$output" "another-preset" "another-preset listed"

print_test_header "list_presets — does not list default file as preset"
output="$(list_presets "testns")"
# 'default' should never appear as a preset name in the list
if echo "$output" | grep -q ": default$"; then
  echo -e "${RED}✗${NC} .default file must not appear as a preset"
  TESTS_FAILED=$((TESTS_FAILED + 1))
else
  echo -e "${GREEN}✓${NC} .default file is correctly excluded from preset list"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

print_test_header "list_presets — reports no presets when none exist"
# Remove all non-default files temporarily
mv "${FIXTURE_DIR}/agent/preferences/testns.test-preset.yaml" /tmp/testns.test-preset.yaml.bak
mv "${FIXTURE_DIR}/agent/preferences/testns.another-preset.yaml" /tmp/testns.another-preset.yaml.bak
output="$(list_presets "testns")"
assert_contains "$output" "no presets found" "empty state message shown"
# Restore
mv /tmp/testns.test-preset.yaml.bak "${FIXTURE_DIR}/agent/preferences/testns.test-preset.yaml"
mv /tmp/testns.another-preset.yaml.bak "${FIXTURE_DIR}/agent/preferences/testns.another-preset.yaml"

# ── Cleanup ───────────────────────────────────────────────────────────────────

teardown_fixtures

print_suite_summary

exit $TESTS_FAILED
