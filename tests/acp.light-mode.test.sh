#!/usr/bin/env bash
# Light-mode protocol tests — verify routing.yml context_modes

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0
R="$PROJECT_ROOT/agent/core/routing.yml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Light-Mode Protocol Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. context_modes section exists
grep -q "context_modes:" "$R" && { echo "  ✓ context_modes section"; PASS=$((PASS+1)); } \
    || { echo "  ✗ context_modes missing"; FAIL=$((FAIL+1)); }

# 2. Light mode steps
grep -q "load_identity" "$R" && grep -q "load_progress" "$R" && grep -q "load_recent" "$R" \
    && { echo "  ✓ Light mode steps (identity+progress+recent)"; PASS=$((PASS+1)); } \
    || { echo "  ✗ Light mode missing required steps"; FAIL=$((FAIL+1)); }

# 3. Full mode steps
grep -q "load_core" "$R" && grep -q "load_taxonomy" "$R" && grep -q "load_skill" "$R" \
    && grep -q "load_memory" "$R" && grep -q "load_reference" "$R" \
    && { echo "  ✓ Full mode steps (core+taxonomy+skill+memory+reference)"; PASS=$((PASS+1)); } \
    || { echo "  ✗ Full mode missing required steps"; FAIL=$((FAIL+1)); }

# 4. budget_limit_tokens for both modes
grep -q "budget_limit_tokens:" "$R" && { echo "  ✓ budget_limit_tokens set"; PASS=$((PASS+1)); } \
    || { echo "  ✗ budget_limit_tokens missing"; FAIL=$((FAIL+1)); }

# 5. recommend_full_for includes architecture-design
grep -q "architecture-design" <(grep -A10 "recommend_full_for:" "$R") \
    && { echo "  ✓ recommend_full_for has architecture-design"; PASS=$((PASS+1)); } \
    || { echo "  ✗ recommend_full_for missing architecture-design"; FAIL=$((FAIL+1)); }

# 6. recommend_light_for includes bug-fix
grep -q "bug-fix" <(grep -A10 "recommend_light_for:" "$R") \
    && { echo "  ✓ recommend_light_for has bug-fix"; PASS=$((PASS+1)); } \
    || { echo "  ✗ recommend_light_for missing bug-fix"; FAIL=$((FAIL+1)); }

# 7. mode_selection.default is light
grep -A2 "mode_selection:" "$R" | grep -q "default: light" \
    && { echo "  ✓ mode_selection.default = light"; PASS=$((PASS+1)); } \
    || { echo "  ✗ mode_selection.default not light"; FAIL=$((FAIL+1)); }

# 8. confirm_output template variables
grep -q "confirm_output:" "$R" && grep -q "{executor}" "$R" \
    && { echo "  ✓ confirm_output template with variables"; PASS=$((PASS+1)); } \
    || { echo "  ✗ confirm_output template missing"; FAIL=$((FAIL+1)); }

# 9. auto_full_triggers
grep -A3 "auto_full_triggers:" "$R" | grep -q "acp.init" \
    && { echo "  ✓ auto_full_triggers includes acp.init"; PASS=$((PASS+1)); } \
    || { echo "  ✗ auto_full_triggers missing acp.init"; FAIL=$((FAIL+1)); }

# 10. command_suggestions has 20+ entries
sug_count=$(awk '/^command_suggestions:/{flag=1; next} /^[a-zA-Z]/{flag=0} flag && /^  [a-z]/' "$R" | wc -l | tr -d ' ')
if [ "$sug_count" -ge 20 ]; then
    echo "  ✓ command_suggestions: $sug_count entries (≥20)"
    PASS=$((PASS+1))
else
    echo "  ✗ command_suggestions: $sug_count entries (<20)"
    FAIL=$((FAIL+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Light-mode: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
