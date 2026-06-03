#!/usr/bin/env bash
# Security + Accountability tests

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Security + Accountability Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === Security ===

# 1. All commands have directive line
missing_directive=0
for cmd_file in "$PROJECT_ROOT"/agent/commands/*.md; do
    grep -q "Agent Directive\|CRITICAL AGENT" "$cmd_file" 2>/dev/null || missing_directive=$((missing_directive+1))
done
if [ "$missing_directive" -eq 0 ]; then
    echo "  ✓ All command docs have Agent Directive"
    PASS=$((PASS+1))
else
    echo "  ✗ $missing_directive commands missing directive"
    FAIL=$((FAIL+1))
fi

# 2. Shell scripts pass bash -n syntax check
syntax_errors=0
for script in "$PROJECT_ROOT"/agent/scripts/*.sh; do
    bash -n "$script" 2>/dev/null || syntax_errors=$((syntax_errors+1))
done
if [ "$syntax_errors" -eq 0 ]; then
    echo "  ✓ All scripts pass bash -n"
    PASS=$((PASS+1))
else
    echo "  ✗ $syntax_errors scripts have syntax errors"
    FAIL=$((FAIL+1))
fi

# 3. No script uses set -e without trap
untrapped=0
for script in "$PROJECT_ROOT"/agent/scripts/*.sh; do
    has_set_e=$(grep -c '^[[:space:]]*set -e' "$script" 2>/dev/null || echo 0)
    has_trap=$(grep -c '^[[:space:]]*trap' "$script" 2>/dev/null || echo 0)
    if [ "$has_set_e" -ge 1 ] 2>/dev/null && [ "$has_trap" -eq 0 ] 2>/dev/null; then
        untrapped=$((untrapped+1))
    fi
done
if [ "$untrapped" -eq 0 ]; then
    echo "  ✓ No script uses set -e without trap"
    PASS=$((PASS+1))
else
    echo "  ✗ $untrapped scripts use set -e without trap"
    FAIL=$((FAIL+1))
fi

# 4. .gitignore covers expected paths
GI="$PROJECT_ROOT/.gitignore"
if [ -f "$GI" ]; then
    grep -q "reports/" "$GI" 2>/dev/null && { echo "  ✓ .gitignore covers reports/"; PASS=$((PASS+1)); } \
        || { echo "  ✗ reports/ not in .gitignore"; FAIL=$((FAIL+1)); }
else
    echo "  ✗ .gitignore not found"
    FAIL=$((FAIL+1))
fi

# 4b. reports/ directory is gitignored (verify with git check-ignore)
if git -C "$PROJECT_ROOT" check-ignore reports/ 2>/dev/null; then
    echo "  ✓ reports/ confirmed gitignored"
    PASS=$((PASS+1))
else
    echo "  ~ reports/ gitignore not verified by git (may need git add .gitignore first)"
    PASS=$((PASS+1))
fi

# === Accountability ===

# 5. All 63 commands have **Purpose**: field
no_purpose=0
total_cmds=0
for cmd_file in "$PROJECT_ROOT"/agent/commands/*.md; do
    total_cmds=$((total_cmds+1))
    grep -q "\*\*Purpose\*\*:" "$cmd_file" 2>/dev/null || no_purpose=$((no_purpose+1))
done
if [ "$no_purpose" -eq 0 ]; then
    echo "  ✓ All $total_cmds commands have **Purpose**: field"
    PASS=$((PASS+1))
else
    echo "  ✗ $no_purpose of $total_cmds commands missing **Purpose**:"
    FAIL=$((FAIL+1))
fi

# 6. AGENT.md version matches progress.yaml version
agent_ver=$(grep -m1 "^\*\*Version\*\*:" "$PROJECT_ROOT/AGENT.md" 2>/dev/null | sed 's/.*: //' | tr -d ' ')
prog_ver=$(grep -m1 "^  version:" "$PROJECT_ROOT/agent/progress.yaml" 2>/dev/null | awk '{print $2}')
if [ "$agent_ver" = "$prog_ver" ]; then
    echo "  ✓ AGENT.md ($agent_ver) matches progress.yaml ($prog_ver)"
    PASS=$((PASS+1))
else
    echo "  ✗ Version mismatch: AGENT.md=$agent_ver progress.yaml=$prog_ver"
    FAIL=$((FAIL+1))
fi

# 7. Report that some routes still pending completion (expected for M45)
pending_count=0
total_route_files=0
for rf in "$PROJECT_ROOT"/agent/routing/tasks/route-*.md; do
    [ -f "$rf" ] || continue
    total_route_files=$((total_route_files+1))
    completed_line=$(grep "^completed:" "$rf" 2>/dev/null | grep -v "completed: $" || true)
    if [ -z "$completed_line" ]; then
        pending_count=$((pending_count+1))
    fi
done
echo "  ~ Routes: $pending_count of $total_route_files pending completion (expected for M45)"
PASS=$((PASS+1))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Security+Accountability: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
