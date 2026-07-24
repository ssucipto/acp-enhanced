#!/usr/bin/env bash
# Tests for acp-validate.ts new checks (M35)
# Covers: placeholder detection (task-178), frontmatter validation,
# triple-file parity check (task-179).
#
# Uses ACP_COMMANDS_DIR / ACP_PROMPTS_DIR / ACP_OPENCODE_DIR env vars
# to point at temp fixture directories instead of the real project dirs.
#
# NOTE: Do NOT add set -e. assert_* helpers return non-zero on failure.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

VALIDATE_CMD="npx tsx ${PROJECT_ROOT}/scripts/acp-validate.ts"

# ── Fixture setup ─────────────────────────────────────────────

TMPDIR_CMD="$(mktemp -d)"
TMPDIR_PROMPTS="$(mktemp -d)"
TMPDIR_OPENCODE="$(mktemp -d)"
TMPDIR_CURSOR="$(mktemp -d)"
TMPDIR_CLAUDE="$(mktemp -d)"

# Fixture: valid command file (no placeholders, all required fields)
cat > "${TMPDIR_CMD}/acp.valid-command.md" << 'EOF'
# Command: valid

**Namespace**: test
**Version**: 1.0.0
**Created**: 2026-01-01
**Status**: Active
**Scripts**: None

Line 3 of the command doc (safe).
Line 4 of the command doc (safe).
EOF

# Fixture: unresolved placeholder on line 3 (should be flagged)
cat > "${TMPDIR_CMD}/acp.placeholder-line3.md" << 'EOF'
# Command: placeholder

{COMMAND_NAME}
Line 4 content.

**Namespace**: test
**Version**: 1.0.0
**Status**: Active
**Scripts**: None
EOF

# Fixture: placeholder on line 4 (should be flagged)
cat > "${TMPDIR_CMD}/acp.placeholder-line4.md" << 'EOF'
# Command: placeholder

Line 3 content.
{NAMESPACE}

**Namespace**: test
**Version**: 1.0.0
**Status**: Active
**Scripts**: None
EOF

# Fixture: placeholder inside fenced code block (should NOT be flagged)
cat > "${TMPDIR_CMD}/acp.code-block-placeholder.md" << 'EOF'
# Command: code-block

Normal line 3.
Normal line 4.

```bash
echo {COMMAND_NAME}
```

**Namespace**: test
**Version**: 1.0.0
**Status**: Active
**Scripts**: None
EOF

# Fixture: numeric braces {1} on line 3 (should NOT be flagged)
cat > "${TMPDIR_CMD}/acp.numeric-braces.md" << 'EOF'
# Command: numeric

Step {1} of the sequence.
Step {2} continues.

**Namespace**: test
**Version**: 1.0.0
**Status**: Active
**Scripts**: None
EOF

# Fixture: missing Status field (frontmatter warning)
cat > "${TMPDIR_CMD}/acp.missing-status.md" << 'EOF'
# Command: missing-status

Line 3.
Line 4.

**Namespace**: test
**Version**: 1.0.0
**Scripts**: None
EOF

# Fixture: missing Namespace and Scripts (multiple warnings)
cat > "${TMPDIR_CMD}/acp.missing-multi.md" << 'EOF'
# Command: missing-multi

Line 3.
Line 4.

**Version**: 1.0.0
**Status**: Active
EOF

# Matching prompt/opencode/cursor/claude wrappers (5-surface parity — M72)
for f in valid-command placeholder-line3 placeholder-line4 code-block-placeholder numeric-braces missing-status missing-multi; do
  touch "${TMPDIR_PROMPTS}/acp-${f}.prompt.md"
  touch "${TMPDIR_OPENCODE}/acp-${f}.md"
  touch "${TMPDIR_CURSOR}/acp-${f}.md"
  touch "${TMPDIR_CLAUDE}/acp-${f}.md"
done

print_suite_header "acp-validate.ts — E2E Tests (M35)"

# ── Placeholder detection (task-178) ──────────────────────────

print_test_header "placeholder: valid file — no errors"
output="$(ACP_COMMANDS_DIR="${TMPDIR_CMD}" ACP_PROMPTS_DIR="${TMPDIR_PROMPTS}" ACP_OPENCODE_DIR="${TMPDIR_OPENCODE}" ACP_CURSOR_DIR="${TMPDIR_CURSOR}" ACP_CLAUDE_DIR="${TMPDIR_CLAUDE}" ${VALIDATE_CMD} 2>&1 || true)"
assert_not_contains "${output}" "acp.valid-command.md" "valid file not reported in errors"

_validate_env() {
  ACP_COMMANDS_DIR="${TMPDIR_CMD}" ACP_PROMPTS_DIR="${TMPDIR_PROMPTS}" \
  ACP_OPENCODE_DIR="${TMPDIR_OPENCODE}" ACP_CURSOR_DIR="${TMPDIR_CURSOR}" \
  ACP_CLAUDE_DIR="${TMPDIR_CLAUDE}" ${VALIDATE_CMD} 2>&1
}

print_test_header "placeholder: {COMMAND_NAME} on line 3 — detected"
output="$(_validate_env || true)"
assert_contains "${output}" "acp.placeholder-line3.md" "placeholder on line 3 detected"

print_test_header "placeholder: {NAMESPACE} on line 4 — detected"
assert_contains "${output}" "acp.placeholder-line4.md" "placeholder on line 4 detected"

print_test_header "placeholder: code block exclusion — {COMMAND_NAME} inside backticks not flagged"
assert_not_contains "${output}" "acp.code-block-placeholder.md" "code-block placeholder not flagged"

print_test_header "placeholder: numeric braces {1} on line 3 — not flagged"
assert_not_contains "${output}" "acp.numeric-braces.md:3" "numeric braces not treated as placeholder"

# ── Frontmatter validation (task-179) ─────────────────────────

print_test_header "frontmatter: missing Status field — warning produced"
assert_contains "${output}" "acp.missing-status.md" "missing Status field warned"

print_test_header "frontmatter: missing Namespace and Scripts — multiple warnings"
namespace_count="$(echo "${output}" | grep -c "acp.missing-multi.md" || true)"
assert_true "missing-multi.md produces >=2 warnings" $(( namespace_count >= 2 ? 0 : 1 ))

# ── Parity check (task-179) ───────────────────────────────────

print_test_header "parity: equal counts (7/7/7) — in sync"
assert_contains "${output}" "all matched" "parity check reports in sync when counts equal"

print_test_header "parity: output contains count info"
assert_contains "${output}" "commands" "parity check output mentions commands"

# ── Summary lines (task-178 + task-179) ───────────────────────

print_test_header "summary: placeholder check line present"
assert_contains "${output}" "Placeholder check" "summary has placeholder check line"

print_test_header "summary: frontmatter check line present"
assert_contains "${output}" "Frontmatter check" "summary has frontmatter check line"

print_test_header "summary: parity check line present"
assert_contains "${output}" "Parity:" "summary has parity check line"

# ── Parity mismatch (task-179) ────────────────────────────────

print_test_header "parity: mismatch detected when prompt count differs"
TMPDIR_MISMATCH_PROMPTS="$(mktemp -d)"
# Only 6 prompts vs 7 commands
for f in valid-command placeholder-line3 placeholder-line4 code-block-placeholder numeric-braces missing-status; do
  touch "${TMPDIR_MISMATCH_PROMPTS}/acp-${f}.prompt.md"
done
mismatch_output="$(ACP_COMMANDS_DIR="${TMPDIR_CMD}" ACP_PROMPTS_DIR="${TMPDIR_MISMATCH_PROMPTS}" ACP_OPENCODE_DIR="${TMPDIR_OPENCODE}" ACP_CURSOR_DIR="${TMPDIR_CURSOR}" ACP_CLAUDE_DIR="${TMPDIR_CLAUDE}" ${VALIDATE_CMD} 2>&1)"
assert_contains "${mismatch_output}" "mismatch" "parity mismatch reported when counts differ"
rm -rf "${TMPDIR_MISMATCH_PROMPTS}"

# ── Cleanup ───────────────────────────────────────────────────

rm -rf "${TMPDIR_CMD}" "${TMPDIR_PROMPTS}" "${TMPDIR_OPENCODE}" "${TMPDIR_CURSOR}" "${TMPDIR_CLAUDE}"

# ── Summary ───────────────────────────────────────────────────

print_test_summary
