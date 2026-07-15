#!/usr/bin/env bash
# acp.post-milestone-sweep.sh — Post-Milestone Verification Gate
# Version: 1.0.0 (M62 — route-179)
#
# Runs 6 automated verification gates after /acp-proceed --complete.
# Exits 0 when all gates pass, non-zero when any gate fails.
# Non-interactive, CI-friendly, and mechanical — no human judgment needed.
#
# Triggered by: constraints.yml hooks → post-milestone-sweep
# Manual: bash agent/scripts/acp.post-milestone-sweep.sh

set -euo pipefail
trap 'echo "[acp.post-milestone-sweep] Error on line $LINENO" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "$PROJECT_ROOT"

# ── Version detection ──────────────────────────────────────────
VERSION="unknown"
if [ -f "CHANGELOG.md" ]; then
  VERSION=$(head -20 CHANGELOG.md | grep -oE '^## \[[0-9.]+\]' | head -1 | sed 's/^## \[//;s/\]$//' || echo "unknown")
fi

TOTAL_GATES=6
PASSED=0
FAILED=0
WITH_WARNINGS=0

# ── Output helpers ─────────────────────────────────────────────
divider() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

pass_gate() {
  echo "  Gate $1: $2 ................ ✅ ($3)"
  PASSED=$((PASSED + 1))
}

fail_gate() {
  echo "  Gate $1: $2 ................ ❌ ($3)"
  FAILED=$((FAILED + 1))
}

warn_gate() {
  echo "  Gate $1: $2 ................ ⚠️  ($3)"
  WITH_WARNINGS=$((WITH_WARNINGS + 1))
  PASSED=$((PASSED + 1))  # warnings don't fail
}

# ── Header ─────────────────────────────────────────────────────
divider
echo "  ACP Post-Milestone Sweep — v${VERSION}"
divider
echo ""

# ────────────────────────────────────────────────────────────────
# Gate 1: TypeScript Type-Check
# ────────────────────────────────────────────────────────────────
GATE_1_NAME="TypeScript type-check"
if [ -d "scripts" ] && [ -f "scripts/tsconfig.json" ]; then
  TSC_OUTPUT=$(cd scripts && npx tsc --noEmit 2>&1) && TSC_EXIT=$? || TSC_EXIT=$?
  if [ "$TSC_EXIT" -eq 0 ]; then
    pass_gate "1" "$GATE_1_NAME" "0 errors"
  else
    TSC_ERROR_COUNT=$(echo "$TSC_OUTPUT" | grep -c "error TS" || echo "?")
    fail_gate "1" "$GATE_1_NAME" "${TSC_ERROR_COUNT} errors"
  fi
else
  warn_gate "1" "$GATE_1_NAME" "scripts/ not found — skipped"
fi

# ────────────────────────────────────────────────────────────────
# Gate 2: Unit Tests
# ────────────────────────────────────────────────────────────────
GATE_2_NAME="Unit tests"
if [ -d "scripts" ] && command -v npx >/dev/null 2>&1; then
  VITEST_OUTPUT=$(cd scripts && npx vitest run 2>&1) && VITEST_EXIT=$? || VITEST_EXIT=$?
  if [ "$VITEST_EXIT" -eq 0 ]; then
    VITEST_COUNT=$(echo "$VITEST_OUTPUT" | grep -oE '[0-9]+ passed' | tail -1 | grep -oE '[0-9]+' || echo "?")
    pass_gate "2" "$GATE_2_NAME" "${VITEST_COUNT}/${VITEST_COUNT} passing"
  else
    fail_gate "2" "$GATE_2_NAME" "tests failed (exit $VITEST_EXIT)"
  fi
else
  warn_gate "2" "$GATE_2_NAME" "npx not available — skipped"
fi

# ────────────────────────────────────────────────────────────────
# Gate 3: Git Tags
# ────────────────────────────────────────────────────────────────
GATE_3_NAME="Git tags"
TAG_LIST=$(git tag --list "v${VERSION}" 2>/dev/null || echo "")
if [ -n "$TAG_LIST" ]; then
  pass_gate "3" "$GATE_3_NAME" "v${VERSION} exists"
else
  fail_gate "3" "$GATE_3_NAME" "v${VERSION} missing"
  echo "         Run: git tag -a v${VERSION} -m \"ACP v${VERSION}\" HEAD"
fi

# ────────────────────────────────────────────────────────────────
# Gate 4: ACP Validate
# ────────────────────────────────────────────────────────────────
GATE_4_NAME="ACP validate"
VALIDATE_EXIT=0
VALIDATE_OUTPUT=$(npx tsx scripts/acp-validate.ts 2>&1) || VALIDATE_EXIT=$?
WARN_COUNT=$(echo "$VALIDATE_OUTPUT" | grep -c "⚠" 2>/dev/null || true)
WARN_COUNT=${WARN_COUNT:-0}
ERR_COUNT=$(echo "$VALIDATE_OUTPUT" | grep -c "❌" 2>/dev/null || true)
ERR_COUNT=${ERR_COUNT:-0}

if [ "$VALIDATE_EXIT" -eq 0 ]; then
  if [ "$WARN_COUNT" -gt 0 ]; then
    warn_gate "4" "$GATE_4_NAME" "0 errors, ${WARN_COUNT} warnings"
  else
    pass_gate "4" "$GATE_4_NAME" "0 errors, 0 warnings"
  fi
else
  fail_gate "4" "$GATE_4_NAME" "${ERR_COUNT} errors, ${WARN_COUNT} warnings"
fi

# ────────────────────────────────────────────────────────────────
# Gate 5: Token Budget
# ────────────────────────────────────────────────────────────────
GATE_5_NAME="Token budget"
TOKEN_DETAILS=()
TOTAL_TOKENS=0
TOKEN_FAILS=0
# Align with constraints.yml context_budget.total_max_tokens (5000); routing.yml is legitimately large
TOTAL_MAX=5000
PER_FILE_MAX=3000
for FILE in agent/core/identity.yml agent/core/constraints.yml agent/core/routing.yml; do
  if [ -f "$FILE" ]; then
    BYTES=$(wc -c < "$FILE" 2>/dev/null | tr -d ' ' || echo "0")
    TOKENS=$((BYTES / 4))
    TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))
    if [ "$TOKENS" -gt "$PER_FILE_MAX" ]; then
      TOKEN_FAILS=$((TOKEN_FAILS + 1))
    fi
    TOKEN_DETAILS+=("${FILE##*/}=${TOKENS}t")
  fi
done

if [ "$TOKEN_FAILS" -eq 0 ] && [ "$TOTAL_TOKENS" -le "$TOTAL_MAX" ]; then
  pass_gate "5" "$GATE_5_NAME" "${TOTAL_TOKENS}/${TOTAL_MAX} tokens (per-file ≤${PER_FILE_MAX}, ${TOKEN_DETAILS[*]})"
else
  fail_gate "5" "$GATE_5_NAME" "${TOTAL_TOKENS}/${TOTAL_MAX} tokens — ${TOKEN_FAILS} file(s) over per-file ${PER_FILE_MAX}t limit"
fi

# ────────────────────────────────────────────────────────────────
# Gate 6: Git Attributes
# ────────────────────────────────────────────────────────────────
GATE_6_NAME="Git attributes"
ATTR_OK=true
MISSING_RULES=()

for TYPE in "*.sh" "*.yml" "*.ts" "*.json"; do
  ESCAPED_TYPE=$(printf '%s\n' "$TYPE" | sed 's/[.*^$[]/\\&/g')
  if ! grep -qE "${ESCAPED_TYPE}[[:space:]]+text[[:space:]]+eol=lf" .gitattributes 2>/dev/null; then
    ATTR_OK=false
    MISSING_RULES+=("${TYPE}")
  fi
done

if $ATTR_OK; then
  pass_gate "6" "$GATE_6_NAME" "all types covered"
else
  fail_gate "6" "$GATE_6_NAME" "missing: ${MISSING_RULES[*]}"
fi

# ── Result ──────────────────────────────────────────────────────
echo ""
divider

# Final pass/fail
if [ "$FAILED" -eq 0 ]; then
  STATUS="passed"
  if [ "$WITH_WARNINGS" -gt 0 ]; then
    STATUS="${PASSED}/${TOTAL_GATES} passed (${WITH_WARNINGS} with warnings)"
  else
    STATUS="${PASSED}/${TOTAL_GATES} passed"
  fi
  echo "  Result: ${STATUS}"
divider
  exit 0
else
  echo "  Result: ${PASSED}/${TOTAL_GATES} passed, ${FAILED}/${TOTAL_GATES} failed"
divider
  exit 1
fi
