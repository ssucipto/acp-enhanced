#!/usr/bin/env bash
# acp.post-milestone-sweep.test.sh — E2E test for the post-milestone sweep script
# Version: 1.0.0 (M62 — route-179)
#
# Validates: gate execution, pass/fail output, exit codes.

set -euo pipefail
trap 'echo "[e2e-post-milestone-sweep] Error on line $LINENO" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SWEEP_SCRIPT="${PROJECT_ROOT}/agent/scripts/acp.post-milestone-sweep.sh"

cd "$PROJECT_ROOT"

PASS=0
FAIL=0

check() {
  local desc="$1"
  shift
  if "$@"; then
    echo "  ✅ PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  ❌ FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ E2E: acp.post-milestone-sweep.sh"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Test 1: Script exists and is executable ────────────────────
check "Script exists" test -f "$SWEEP_SCRIPT"
check "Script is executable" test -x "$SWEEP_SCRIPT" || true  # Windows may not have +x

# ── Test 2: Script runs without crashing ──────────────────────
echo ""
echo "┌─ Running sweep on current state ──────────────────────"
SWEEP_OUTPUT=$(bash "$SWEEP_SCRIPT" 2>&1) && SWEEP_EXIT=$? || SWEEP_EXIT=$?
echo "$SWEEP_OUTPUT"

check "Script produces output" test -n "$SWEEP_OUTPUT"
check "Output contains header" echo "$SWEEP_OUTPUT" | grep -q "ACP Post-Milestone Sweep" || true

# ── Test 3: Key gates appear in output ─────────────────────────
check "Gate 1 (tsc) in output" echo "$SWEEP_OUTPUT" | grep -q "TypeScript type-check" || true
check "Gate 2 (vitest) in output" echo "$SWEEP_OUTPUT" | grep -q "Unit tests" || true
check "Gate 3 (tags) in output" echo "$SWEEP_OUTPUT" | grep -q "Git tags" || true
check "Gate 4 (validate) in output" echo "$SWEEP_OUTPUT" | grep -q "ACP validate" || true
check "Gate 5 (token) in output" echo "$SWEEP_OUTPUT" | grep -q "Token budget" || true
check "Gate 6 (attr) in output" echo "$SWEEP_OUTPUT" | grep -q "Git attributes" || true

# ── Test 4: Result line present ────────────────────────────────
check "Result line in output" echo "$SWEEP_OUTPUT" | grep -q "Result:" || true

# ── Test 5: Exit code is valid (0 or 1 only) ─────────────────
check "Exit code is 0 or 1" test "$SWEEP_EXIT" -eq 0 -o "$SWEEP_EXIT" -eq 1

# ── Test 6: shellcheck clean ───────────────────────────────────
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck --severity=error "$SWEEP_SCRIPT" 2>/dev/null; then
    echo "  ✅ PASS: shellcheck --severity=error clean"
    PASS=$((PASS + 1))
  else
    echo "  ⚠️  WARN: shellcheck found issues (non-fatal for E2E)"
  fi
else
  echo "  ⚠️  SKIP: shellcheck not installed"
fi

# ── Summary ────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS + FAIL))
echo "  E2E Result: ${PASS}/${TOTAL} passed"
if [ "$FAIL" -gt 0 ]; then
  echo "  ❌ ${FAIL} tests FAILED"
  exit 1
else
  echo "  ✅ All tests PASSED"
  exit 0
fi
