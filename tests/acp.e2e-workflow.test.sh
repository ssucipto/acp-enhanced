#!/usr/bin/env bash
# E2E workflow test — depends on route-063 (light-mode), 064 (@-mention+parallel), 065 (bootstrap+observability)

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Workflow Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Dependencies: route-063 (light-mode), route-064 (@-mention+parallel), route-065 (bootstrap)"
echo ""

# === Light-mode protocol verification (route-063) ===
R="$PROJECT_ROOT/agent/core/routing.yml"
grep -q "context_modes:" "$R" && { echo "  ✓ [063] context_modes in routing.yml"; PASS=$((PASS+1)); } \
    || { echo "  ✗ [063] missing context_modes"; FAIL=$((FAIL+1)); }

# Check light mode pipeline: identity → progress → sessions
grep -q "load_identity" "$R" && grep -q "load_progress" "$R" && grep -q "load_recent" "$R" \
    && { echo "  ✓ [063] light mode pipeline (identity→progress→recent)"; PASS=$((PASS+1)); } \
    || { echo "  ✗ [063] light mode pipeline incomplete"; FAIL=$((FAIL+1)); }

# === @-mention + Parallel (route-064) ===
TX="$PROJECT_ROOT/agent/routing/taxonomy.yml"
grep -q "skills_catalog:" "$TX" && grep -q "^  parallel:" "$TX" \
    && { echo "  ✓ [064] skills_catalog + parallel task_type in taxonomy"; PASS=$((PASS+1)); } \
    || { echo "  ✗ [064] missing skills_catalog or parallel task_type"; FAIL=$((FAIL+1)); }

# === Bootstrap + Observability (route-065) ===
BS="$PROJECT_ROOT/scripts/acp-bootstrap.sh"
PY="$PROJECT_ROOT/agent/progress.yaml"
grep -q "TEAM_SIZE" "$BS" && grep -q "observability:" "$PY" \
    && { echo "  ✓ [065] bootstrap TEAM_SIZE + progress observability"; PASS=$((PASS+1)); } \
    || { echo "  ✗ [065] missing bootstrap flag or observability"; FAIL=$((FAIL+1)); }

# === Integration: copilot-instructions.md references light mode ===
# Doc phrasing is "light + full modes" (AGENTS.md source); match intentional wording (F-100-03).
CI="$PROJECT_ROOT/.github/copilot-instructions.md"
grep -qE "light \+ full|light mode|Light mode|light-mode|light_mode" "$CI" \
    && { echo "  ✓ Integrated: copilot-instructions.md references light mode"; PASS=$((PASS+1)); } \
    || { echo "  ✗ copilot-instructions.md missing light mode reference"; FAIL=$((FAIL+1)); }

# === Integration: AGENT.md mentions @-mention ===
grep -q "@{\|@-mention\|@mention\|skill\|@{skill}" "$PROJECT_ROOT/AGENT.md" \
    && { echo "  ✓ Integrated: AGENT.md mentions @-mention skills"; PASS=$((PASS+1)); } \
    || { echo "  ✗ AGENT.md missing @-mention reference"; FAIL=$((FAIL+1)); }

# === Integration: CHANGELOG.md has 6.8.2 entry ===
grep -q "6.8.2\|6.8" "$PROJECT_ROOT/CHANGELOG.md" \
    && { echo "  ✓ Integrated: CHANGELOG.md has v6.8.x entry"; PASS=$((PASS+1)); } \
    || { echo "  ✗ CHANGELOG.md missing v6.8.x entry"; FAIL=$((FAIL+1)); }

# === Cross-file consistency: progress.yaml version matches identity.yml ===
pv=$(grep -m1 "^  version:" "$PY" 2>/dev/null | awk '{print $2}' | tr -d '"')
iv=$(grep -m1 "^version:" "$PROJECT_ROOT/agent/core/identity.yml" 2>/dev/null | awk '{print $2}' | tr -d '"')
if [ -n "$pv" ] && [ "$pv" = "$iv" ]; then
    echo "  ✓ Cross-file: progress.yaml ($pv) == identity.yml ($iv)"
    PASS=$((PASS+1))
else
    echo "  ✗ Cross-file: version mismatch progress=$pv identity=$iv"
    FAIL=$((FAIL+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Workflow: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
