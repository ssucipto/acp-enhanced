#!/usr/bin/env bash
# E2E Tests for version scripts
# Tests acp.version-check.sh and acp.version-check-for-updates.sh (--silent flag only
# — no network calls in tests). acp.version-update.sh is tested for structure only
# (network clone cannot be mocked in CI without real network access).
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

VERSION_CHECK_SH="${PROJECT_ROOT}/agent/scripts/acp.version-check.sh"
VERSION_UPDATES_SH="${PROJECT_ROOT}/agent/scripts/acp.version-check-for-updates.sh"
VERSION_UPDATE_SH="${PROJECT_ROOT}/agent/scripts/acp.version-update.sh"

# ── Syntax checks ─────────────────────────────────────────────────────────────

print_suite_header "Version Scripts — E2E Tests"

print_test_header "acp.version-check.sh — no bash syntax errors"
bash -n "${VERSION_CHECK_SH}" 2>/dev/null
assert_true "bash -n acp.version-check.sh exits 0" $?

print_test_header "acp.version-check-for-updates.sh — no bash syntax errors"
bash -n "${VERSION_UPDATES_SH}" 2>/dev/null
assert_true "bash -n acp.version-check-for-updates.sh exits 0" $?

print_test_header "acp.version-update.sh — no bash syntax errors"
bash -n "${VERSION_UPDATE_SH}" 2>/dev/null
assert_true "bash -n acp.version-update.sh exits 0" $?

# ── acp.version-check.sh ──────────────────────────────────────────────────────

# Set up a temp project root with a minimal AGENT.md
TMPDIR_ROOT="$(mktemp -d)"

cat > "${TMPDIR_ROOT}/AGENT.md" << 'EOF'
# Agent Context Protocol

**Version**: 9.9.9
**Created**: 2026-01-01
**Status**: Active

This is a test AGENT.md file.
EOF

print_test_header "acp.version-check — exits 0 when AGENT.md exists"
(cd "${TMPDIR_ROOT}" && bash "${VERSION_CHECK_SH}" 2>/dev/null)
assert_true "version-check exits 0 with AGENT.md present" $?

print_test_header "acp.version-check — outputs version number"
output="$(cd "${TMPDIR_ROOT}" && bash "${VERSION_CHECK_SH}" 2>/dev/null || true)"
assert_contains "${output}" "9.9.9" "version number appears in output"

print_test_header "acp.version-check — outputs 'ACP is installed' confirmation"
assert_contains "${output}" "ACP is installed" "installed confirmation in output"

print_test_header "acp.version-check — fails when AGENT.md missing"
MISSING_DIR="$(mktemp -d)"
(cd "${MISSING_DIR}" && bash "${VERSION_CHECK_SH}" 2>/dev/null)
assert_false "version-check exits non-zero without AGENT.md" $?
rmdir "${MISSING_DIR}"

# ── acp.version-check-for-updates.sh --silent ─────────────────────────────────

# Test --silent flag exits with code 2 (curl/wget unavailable or no AGENT.md)
# We test without a real network call by using a missing AGENT.md — should exit 2.

print_test_header "acp.version-check-for-updates --silent — exits 2 when AGENT.md missing"
MISSING_DIR2="$(mktemp -d)"
(cd "${MISSING_DIR2}" && bash "${VERSION_UPDATES_SH}" --silent 2>/dev/null)
RESULT=$?
assert_equals "2" "${RESULT}" "--silent exits 2 when no AGENT.md"
rmdir "${MISSING_DIR2}"

print_test_header "acp.version-check-for-updates — exits 2 when AGENT.md missing (no --silent)"
MISSING_DIR3="$(mktemp -d)"
(cd "${MISSING_DIR3}" && bash "${VERSION_UPDATES_SH}" 2>/dev/null)
RESULT=$?
assert_equals "2" "${RESULT}" "exits 2 when no AGENT.md (no --silent flag)"
rmdir "${MISSING_DIR3}"

# ── acp.version-update.sh structure ───────────────────────────────────────────

print_test_header "acp.version-update — exits 1 when AGENT.md missing"
# The update script checks for AGENT.md before doing anything else
MISSING_DIR4="$(mktemp -d)"
(cd "${MISSING_DIR4}" && bash "${VERSION_UPDATE_SH}" 2>/dev/null)
RESULT=$?
assert_equals "1" "${RESULT}" "version-update exits 1 when no AGENT.md"
rmdir "${MISSING_DIR4}"

# ── Script metadata checks ────────────────────────────────────────────────────

print_test_header "acp.version-check — references acp.version-check-for-updates.sh"
assert_contains "$(cat "${VERSION_CHECK_SH}")" "version-check-for-updates" \
  "version-check.sh cross-references update checker"

print_test_header "acp.version-check — references acp.version-update.sh"
assert_contains "$(cat "${VERSION_CHECK_SH}")" "version-update" \
  "version-check.sh cross-references updater"

# ── Cleanup ───────────────────────────────────────────────────────────────────

rm -rf "${TMPDIR_ROOT}"

print_suite_summary

exit $TESTS_FAILED
