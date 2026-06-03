#!/usr/bin/env bash
# Bootstrap flags + Observability tests

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bootstrap + Observability Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === Bootstrap flags ===
BS="$PROJECT_ROOT/scripts/acp-bootstrap.sh"

grep -q "\-\-team-size" "$BS" && { echo "  ✓ bootstrap.sh has --team-size flag"; PASS=$((PASS+1)); } \
    || { echo "  ✗ bootstrap.sh missing --team-size"; FAIL=$((FAIL+1)); }

grep -q "\-\-generate-prompts" "$BS" && echo "GENERATE_PROMPTS" && { echo "  ✓ bootstrap.sh has --generate-prompts flag"; PASS=$((PASS+1)); } \
    || { echo "  ✗ bootstrap.sh missing --generate-prompts"; FAIL=$((FAIL+1)); }

# Check for "solo" default handling
grep -q "TEAM_SIZE=" "$BS" && { echo "  ✓ bootstrap.sh has TEAM_SIZE variable"; PASS=$((PASS+1)); } \
    || { echo "  ✗ bootstrap.sh missing TEAM_SIZE"; FAIL=$((FAIL+1)); }

# bash -n syntax check
bash -n "$BS" 2>/dev/null && { echo "  ✓ bootstrap.sh syntax OK"; PASS=$((PASS+1)); } \
    || { echo "  ✗ bootstrap.sh syntax error"; FAIL=$((FAIL+1)); }

# === Observability ===
PY="$PROJECT_ROOT/agent/progress.yaml"

grep -q "observability:" "$PY" && { echo "  ✓ progress.yaml has observability section"; PASS=$((PASS+1)); } \
    || { echo "  ✗ observability section missing"; FAIL=$((FAIL+1)); }

grep -q "this_week:" "$PY" && { echo "  ✓ observability has this_week"; PASS=$((PASS+1)); } \
    || { echo "  ✗ this_week missing"; FAIL=$((FAIL+1)); }

grep -q "by_executor:" "$PY" && { echo "  ✓ observability has by_executor"; PASS=$((PASS+1)); } \
    || { echo "  ✗ by_executor missing"; FAIL=$((FAIL+1)); }

grep -q "weekly_trend:" "$PY" && { echo "  ✓ observability has weekly_trend"; PASS=$((PASS+1)); } \
    || { echo "  ✗ weekly_trend missing"; FAIL=$((FAIL+1)); }

# === Scaffold config in manifest ===
MF="$PROJECT_ROOT/agent/manifest.yaml"
grep -q "scaffold:" "$MF" && { echo "  ✓ manifest.yaml has scaffold config"; PASS=$((PASS+1)); } \
    || { echo "  ✗ scaffold config missing from manifest"; FAIL=$((FAIL+1)); }

grep -q "team_size:" "$MF" && { echo "  ✓ manifest.yaml has team_size"; PASS=$((PASS+1)); } \
    || { echo "  ✗ team_size missing from manifest"; FAIL=$((FAIL+1)); }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bootstrap+Observability: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
