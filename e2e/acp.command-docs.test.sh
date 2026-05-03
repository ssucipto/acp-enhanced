#!/usr/bin/env bash
# E2E Tests: Command doc structure validation
# Validates that every command doc in agent/commands/ has the required sections,
# uses the correct /acp-<command> invocation syntax, and has no unfilled placeholders.
# Covers all pure-LLM command docs that have no dedicated script-level e2e test.
#
# Commands covered by this test (structure only):
#   acp.artifact-glossary, acp.artifact-reference, acp.artifact-research,
#   acp.audit, acp.clarification-address, acp.clarification-capture, acp.clarification-create,
#   acp.command-create, acp.design-create, acp.design-reference, acp.handoff, acp.init,
#   acp.package-create, acp.package-install, acp.package-publish, acp.package-validate,
#   acp.pattern-create, acp.plan, acp.preferences-create, acp.preferences-get,
#   acp.preferences-set, acp.preferences-show, acp.preferences-validate, acp.proceed,
#   acp.project-create, acp.projects-restore, acp.report, acp.resume, acp.spec,
#   acp.status, acp.sync, acp.task-create, acp.update, acp.validate,
#   acp.version-check, acp.version-check-for-updates, acp.version-update,
#   git.commit, git.init  (and all existing command docs as regression guard)

# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure by design.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COMMANDS_DIR="${PROJECT_ROOT}/agent/commands"

# ── helpers ────────────────────────────────────────────────────────────────────

# Check a single command doc for all required structural properties.
# $1 = absolute path to .md file
check_command_doc() {
  local file="$1"
  local name
  name="$(basename "$file" .md)"

  # Skip the template file — it is expected to have placeholders
  if [[ "$name" == "command.template" ]]; then
    print_test_header "${name}: template file skipped (placeholders expected)"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} command.template skipped (expected placeholders)"
    return 0
  fi

  local pass=1

  # 1. Has # Command: OR # Directive: heading
  #    Shared directives (clarification-capture, design-reference, etc.) use "# Directive:"
  print_test_header "${name}: has '# Command:' or '# Directive:' heading"
  if grep -qE "^# (Command|Directive):" "$file"; then
    assert_true "has '# Command:' or '# Directive:' heading" 0
  else
    assert_true "has '# Command:' or '# Directive:' heading" 1
    pass=0
  fi

  # 2. Has Agent Directive line (any case — some use "CRITICAL AGENT DIRECTIVE")
  print_test_header "${name}: has 'Agent Directive' in file"
  if grep -qi "agent directive" "$file"; then
    assert_true "has 'Agent Directive'" 0
  else
    assert_true "has 'Agent Directive'" 1
    pass=0
  fi

  # 3. Has **Namespace**: field
  print_test_header "${name}: has **Namespace** field"
  if grep -q "^\*\*Namespace\*\*:" "$file"; then
    assert_true "has '**Namespace**:' field" 0
  else
    assert_true "has '**Namespace**:' field" 1
    pass=0
  fi

  # 4. Has **Purpose**: field
  print_test_header "${name}: has **Purpose** field"
  if grep -q "^\*\*Purpose\*\*:" "$file"; then
    assert_true "has '**Purpose**:' field" 0
  else
    assert_true "has '**Purpose**:' field" 1
    pass=0
  fi

  # 5. No unfilled @{namespace} invocation placeholder
  #    (Only catches @{namespace} style — NOT file-path convention descriptions like
  #     agent/commands/{namespace}.{cmd}.md or "must use {namespace}. format" which are
  #     intentional placeholders in naming convention documentation.)
  #    Lines starting with "Replace @{namespace}" are also excluded — they describe
  #    a find-replace instruction in templates, not an actual invocation.
  print_test_header "${name}: no unfilled @{namespace} invocation placeholder"
  local bad_ns
  bad_ns="$(grep -v "^[[:space:]]*-.*Replace " "$file" | grep -cE "@\{namespace\}" 2>/dev/null || true)"
  if [[ "$bad_ns" -eq 0 ]]; then
    assert_true "no '@{namespace}' invocation placeholder" 0
  else
    assert_true "no '@{namespace}' invocation placeholder (found ${bad_ns})" 1
    pass=0
    echo "  ⚠  occurrences: $(grep -nE "@\{namespace\}" "$file" | grep -v "Replace " | head -3)"
  fi

  # 6. Uses /acp- syntax in directive line (not @acp. or @{namespace})
  #    Only check commands in the acp namespace — git.* commands use different convention
  if [[ "$name" == acp.* ]]; then
    local cmd_slug
    cmd_slug="${name#acp.}"                         # strip "acp." prefix → e.g. "plan"
    local expected_slash="/acp-${cmd_slug}"         # e.g. "/acp-plan"
    print_test_header "${name}: directive uses ${expected_slash}"
    if grep -q "${expected_slash}" "$file"; then
      assert_true "directive contains '${expected_slash}'" 0
    else
      assert_true "directive contains '${expected_slash}'" 1
      pass=0
    fi

    # 7. No @acp.* invocations in directive lines (old syntax)
    print_test_header "${name}: no @acp.<command> old-syntax in directives"
    local old_syntax
    old_syntax="$(grep -c "@acp\." "$file" 2>/dev/null || true)"
    if [[ "$old_syntax" -eq 0 ]]; then
      assert_true "no '@acp.' old-syntax occurrences" 0
    else
      assert_true "no '@acp.' old-syntax occurrences (found ${old_syntax})" 1
      pass=0
      echo "  ⚠  occurrences: $(grep -n "@acp\." "$file" | head -3)"
    fi
  fi

  return 0
}

# ── Main ───────────────────────────────────────────────────────────────────────

print_suite_header "Command Doc Structure Validation"

echo "  Validating all files in: ${COMMANDS_DIR}"
echo ""

doc_count=0
for doc in "${COMMANDS_DIR}"/*.md; do
  [[ -f "$doc" ]] || continue
  doc_count=$((doc_count + 1))
  check_command_doc "$doc"
done

echo ""
echo "  Validated ${doc_count} command doc(s)."
echo ""

print_suite_summary

exit $TESTS_FAILED
