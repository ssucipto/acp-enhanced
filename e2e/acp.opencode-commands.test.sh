#!/usr/bin/env bash
# E2E Tests: opencode command parity with GitHub Copilot prompts
# Verifies that .opencode/commands/ contains a matching file for every
# .github/prompts/acp-*.prompt.md (and git-*.prompt.md) file, and that
# the opencode files are properly formatted (no mode: agent, has description).
#
# Enforces ADR-6: Cross-tool slash command parity via per-tool command directories.
# .github/prompts/ is the canonical source; .opencode/commands/ must mirror it.

# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure by design.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COPILOT_DIR="${PROJECT_ROOT}/.github/prompts"
OPENCODE_DIR="${PROJECT_ROOT}/.opencode/commands"

# ── Suite 1: Directory exists ──────────────────────────────────────────────────

print_suite_header "opencode Command Parity — Directory Structure"

print_test_header ".opencode/commands/ directory exists"
assert_dir_exists "$OPENCODE_DIR" ".opencode/commands/ directory exists"

print_test_header ".github/prompts/ directory exists (canonical source)"
assert_dir_exists "$COPILOT_DIR" ".github/prompts/ directory exists"

# ── Suite 2: 1:1 file parity ───────────────────────────────────────────────────

print_suite_header "opencode Command Parity — File-by-File Check"

missing_count=0
extra_count=0
parity_ok=0

for copilot_file in "$COPILOT_DIR"/*.prompt.md; do
  [ -f "$copilot_file" ] || continue
  basename_no_ext="$(basename "$copilot_file" .prompt.md)"
  expected_opencode="${OPENCODE_DIR}/${basename_no_ext}.md"

  print_test_header "${basename_no_ext}: matching opencode file exists"
  if assert_file_exists "$expected_opencode" "${basename_no_ext}: .opencode/commands/${basename_no_ext}.md exists"; then
    parity_ok=$((parity_ok + 1))
  else
    missing_count=$((missing_count + 1))
  fi
done

# Check for extra files in .opencode/commands/ with no Copilot source
if [ -d "$OPENCODE_DIR" ]; then
  for oc_file in "$OPENCODE_DIR"/*.md; do
    [ -f "$oc_file" ] || continue
    oc_base="$(basename "$oc_file" .md)"
    expected_copilot="${COPILOT_DIR}/${oc_base}.prompt.md"
    print_test_header "${oc_base}: has matching Copilot source (no orphans)"
    if assert_file_exists "$expected_copilot" "${oc_base}: source .github/prompts/${oc_base}.prompt.md exists"; then
      : # ok
    else
      extra_count=$((extra_count + 1))
    fi
  done
fi

# ── Suite 3: Content validation ────────────────────────────────────────────────

print_suite_header "opencode Command Parity — Content Validation"

if [ -d "$OPENCODE_DIR" ]; then
  for oc_file in "$OPENCODE_DIR"/*.md; do
    [ -f "$oc_file" ] || continue
    oc_name="$(basename "$oc_file" .md)"

    # Must NOT contain "mode: agent" (VS Code-specific field)
    print_test_header "${oc_name}: does not contain 'mode: agent'"
    if grep -q "^mode:" "$oc_file"; then
      assert_false "${oc_name}: must not have 'mode:' field" 0
    else
      assert_false "${oc_name}: must not have 'mode:' field" 1
    fi

    # Must contain a description field
    print_test_header "${oc_name}: has 'description:' field"
    if grep -q "^description:" "$oc_file"; then
      assert_true "${oc_name}: has 'description:' field" 0
    else
      assert_true "${oc_name}: has 'description:' field" 1
    fi

    # Must have frontmatter delimiters
    print_test_header "${oc_name}: has frontmatter (--- delimiters)"
    fm_count=$(grep -c "^---$" "$oc_file" 2>/dev/null || echo 0)
    if [ "$fm_count" -ge 2 ]; then
      assert_true "${oc_name}: has at least 2 '---' frontmatter delimiters" 0
    else
      assert_true "${oc_name}: has at least 2 '---' frontmatter delimiters" 1
    fi
  done
fi

# ── Suite 4: Count parity summary ─────────────────────────────────────────────

print_suite_header "opencode Command Parity — Count Summary"

copilot_count=$(ls "$COPILOT_DIR"/*.prompt.md 2>/dev/null | wc -l | tr -d ' ')
opencode_count=$(ls "$OPENCODE_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

print_test_header "File count: .github/prompts/ vs .opencode/commands/ are equal"
assert_equals "$copilot_count" "$opencode_count" \
  "File count matches: Copilot=${copilot_count} opencode=${opencode_count}"

# ── Suite 5: Body content parity ──────────────────────────────────────────────

print_suite_header "opencode Command Parity — Body Content Parity"

if [ -d "$OPENCODE_DIR" ] && [ -d "$COPILOT_DIR" ]; then
  for copilot_file in "$COPILOT_DIR"/*.prompt.md; do
    [ -f "$copilot_file" ] || continue
    base="$(basename "$copilot_file" .prompt.md)"
    oc_file="${OPENCODE_DIR}/${base}.md"
    [ -f "$oc_file" ] || continue

    copilot_body=$(awk 'BEGIN{fm=0} /^---/{fm++; next} fm>=2{print}' "$copilot_file")
    oc_body=$(awk 'BEGIN{fm=0} /^---/{fm++; next} fm>=2{print}' "$oc_file")

    print_test_header "${base}: body content matches Copilot source"
    if [ "$copilot_body" = "$oc_body" ]; then
      assert_true "${base}: body content identical to Copilot source" 0
    else
      assert_true "${base}: body content identical to Copilot source" 1
    fi
  done
fi

# ── Summary ────────────────────────────────────────────────────────────────────

print_suite_summary

if [ "$TESTS_FAILED" -gt 0 ]; then
  echo "To regenerate .opencode/commands/ from source, run:"
  echo "  bash scripts/acp-bootstrap.sh"
  echo ""
  exit 1
fi

exit 0
