#!/usr/bin/env bash
# E2E Smoke Test: acp.claude-commands-sync.sh
# Verifies script produces correct output with proper naming, wrapper content, and parity.
# Mirrors e2e/acp.cursor-commands-sync.test.sh for the .claude/commands/ surface.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/tests/common.sh"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

SYNC_SCRIPT="$PROJECT_ROOT/agent/scripts/acp.claude-commands-sync.sh"
CMD_DIR="$PROJECT_ROOT/agent/commands"
CLAUDE_DIR="$PROJECT_ROOT/.claude/commands"

# ═══════════════════════════════════════════════════════════
# 1. Sync script exists and is executable
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: script exists and executable"
if [[ -f "$SYNC_SCRIPT" ]] && [[ -x "$SYNC_SCRIPT" ]]; then assert_true "script exists + executable" 0; else assert_true "script exists + executable" 1; fi
assert_contains "$(head -20 "$SYNC_SCRIPT")" "exit 3" "trap ERR present (SH-01)"

# ═══════════════════════════════════════════════════════════
# 2. Sync runs without error
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: runs without error"
if bash "$SYNC_SCRIPT" > /dev/null 2>&1; then assert_true "sync exits 0" 0; else assert_true "sync exits 0" 1; fi

# ═══════════════════════════════════════════════════════════
# 3. .claude/commands/ directory exists
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: .claude/commands/ directory exists"
if [[ -d "$CLAUDE_DIR" ]]; then assert_true ".claude/commands/ exists" 0; else assert_true ".claude/commands/ exists" 1; fi

# ═══════════════════════════════════════════════════════════
# 4. File count parity: claude commands ≥ source commands
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: file count parity"
_src_count=$(find "$CMD_DIR" -maxdepth 1 \( -name "acp.*.md" -o -name "git.*.md" \) 2>/dev/null | wc -l | tr -d ' ')
_cl_count=$(find "$CLAUDE_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$_cl_count" -ge "$_src_count" ]]; then assert_true "claude $_cl_count ≥ source $_src_count" 0; else assert_true "claude $_cl_count ≥ source $_src_count" 1; fi

# ═══════════════════════════════════════════════════════════
# 5. Naming: acp.init → acp-init.md (dots → hyphens)
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: naming convention (dots→hyphens)"
if [[ -f "$CLAUDE_DIR/acp-init.md" ]]; then assert_true "acp.init → acp-init.md" 0; else assert_true "acp.init → acp-init.md" 1; fi

# ═══════════════════════════════════════════════════════════
# 6. Naming: git.commit → git-commit.md
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: git.commit → git-commit.md"
if [[ -f "$CLAUDE_DIR/git-commit.md" ]]; then assert_true "git.commit → git-commit.md" 0; else assert_true "git.commit → git-commit.md" 1; fi

# ═══════════════════════════════════════════════════════════
# 7. Wrapper has YAML frontmatter (starts with ---)
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: wrapper has YAML frontmatter"
_first=$(head -1 "$CLAUDE_DIR/acp-init.md" 2>/dev/null)
if [[ "$_first" = "---" ]]; then assert_true "YAML frontmatter present" 0; else assert_true "YAML frontmatter present" 1; fi

# ═══════════════════════════════════════════════════════════
# 8. Wrapper has description field
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: wrapper has description"
if grep -q 'description:' "$CLAUDE_DIR/acp-init.md" 2>/dev/null; then assert_true "description field present" 0; else assert_true "description field present" 1; fi

# ═══════════════════════════════════════════════════════════
# 9. Wrapper references canonical source
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: wrapper references canonical source"
if grep -q 'agent/commands/' "$CLAUDE_DIR/acp-init.md" 2>/dev/null; then assert_true "canonical source reference present" 0; else assert_true "canonical source reference present" 1; fi

# ═══════════════════════════════════════════════════════════
# 10. Re-run is idempotent
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: re-run is idempotent"
_cl_before=$(find "$CLAUDE_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
bash "$SYNC_SCRIPT" > /dev/null 2>&1
_cl_after=$(find "$CLAUDE_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$_cl_before" -eq "$_cl_after" ]]; then assert_true "idempotent (${_cl_before}→${_cl_after})" 0; else assert_true "idempotent (${_cl_before}→${_cl_after})" 1; fi

# ═══════════════════════════════════════════════════════════
# 11. local.* wrapper in temp dir; skip-if-exists (M89; do not pollute agent/commands)
# ═══════════════════════════════════════════════════════════
print_test_header "claude-sync: local.* wrapper + skip-if-exists (temp dir)"
_tmp="$(mktemp -d)"
_cmd_tmp="${_tmp}/commands"
_out_tmp="${_tmp}/claude"
mkdir -p "$_cmd_tmp" "$_out_tmp"
cat > "${_cmd_tmp}/local.foo.md" << 'EOF'
**Purpose**: Temp local overlay for sync E2E
EOF
ACP_SYNC_CMD_DIR="$_cmd_tmp" ACP_SYNC_OUT_DIR="$_out_tmp" bash "$SYNC_SCRIPT" > /dev/null 2>&1
if [[ -f "${_out_tmp}/local-foo.md" ]]; then assert_true "creates local-foo.md when missing" 0; else assert_true "creates local-foo.md when missing" 1; fi
printf 'CUSTOM_WRAPPER\n' > "${_out_tmp}/local-foo.md"
ACP_SYNC_CMD_DIR="$_cmd_tmp" ACP_SYNC_OUT_DIR="$_out_tmp" bash "$SYNC_SCRIPT" > /dev/null 2>&1
if grep -q 'CUSTOM_WRAPPER' "${_out_tmp}/local-foo.md"; then assert_true "does not overwrite existing local wrapper" 0; else assert_true "does not overwrite existing local wrapper" 1; fi
rm -rf "$_tmp"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  acp-claude-commands-sync Smoke Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Tests run:    $TESTS_RUN"
echo "  Tests passed: $TESTS_PASSED"
echo "  Tests failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[[ "$TESTS_FAILED" -gt 0 ]] && exit 1
exit 0
