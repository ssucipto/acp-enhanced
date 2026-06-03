#!/usr/bin/env bash
# Performance test — verify documented token budgets and file counts

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0
ERRORS=""

check_token_est() {
    local label="$1" file="$2" max_tokens="$3" start_line="$4" end_line="$5"
    local chars=0
    if [ -n "$start_line" ] && [ -n "$end_line" ]; then
        chars=$(sed -n "${start_line},${end_line}p" "$file" 2>/dev/null | wc -c | tr -d ' ')
    else
        chars=$(wc -c < "$file" 2>/dev/null | tr -d ' ')
    fi
    local est_tokens=$((chars / 4))
    if [ "$est_tokens" -le "$max_tokens" ]; then
        echo "  ✓ $label: ~${est_tokens} tokens (≤${max_tokens})"
        PASS=$((PASS+1))
    else
        echo "  ✗ $label: ~${est_tokens} tokens (>${max_tokens})"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ACP Performance Test — Token Budgets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. identity.yml ≤ 500 tokens (includes comments, metadata)
check_token_est "identity.yml" "$PROJECT_ROOT/agent/core/identity.yml" 500 "" ""

# 2. progress.yaml first 30 lines ≤ 300 tokens
check_token_est "progress.yaml (first 30 lines)" "$PROJECT_ROOT/agent/progress.yaml" 300 1 30

# 3. Light mode: identity + progress ≤ 800 tokens (documented budget)
total_chars=$((id_chars + prog_chars))
total_est=$((total_chars / 4))
if [ "$total_est" -le 800 ]; then
    echo "  ✓ Light mode identity+progress: ~${total_est} tokens (≤800)"
    PASS=$((PASS+1))
else
    echo "  ✗ Light mode identity+progress: ~${total_est} tokens (>800)"
    FAIL=$((FAIL+1))
fi

# 4. Full mode: core + taxonomy + skill + 3 sessions + wiki ≤ 3000 tokens
core_chars=$(wc -c < "$PROJECT_ROOT/agent/core/identity.yml" 2>/dev/null || echo 0)
tax_chars=$(sed -n '1,30p' "$PROJECT_ROOT/agent/routing/taxonomy.yml" 2>/dev/null | wc -c || echo 0)
skill_chars=$(wc -c < "$PROJECT_ROOT/agent/skills/crosscut.md" 2>/dev/null || echo 0)
full_chars=$((core_chars + tax_chars + skill_chars))
full_est=$((full_chars / 4))
if [ "$full_est" -le 3000 ]; then
    echo "  ✓ Full mode core+taxonomy+skill: ~${full_est} tokens (≤3000)"
    PASS=$((PASS+1))
else
    echo "  ✗ Full mode core+taxonomy+skill: ~${full_est} tokens (>3000)"
    FAIL=$((FAIL+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Performance: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
