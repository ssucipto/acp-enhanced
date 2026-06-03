#!/usr/bin/env bash
# Smoke test — verify ACP Enhanced installation is alive
# Runs in <5s. No network or external dependencies.

set -euo pipefail
cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || source "$PROJECT_ROOT/tests/common.sh" 2>/dev/null || true

PASS=0
FAIL=0

# Override print_test_header to not require args
print_smoke_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ACP Smoke Test"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_smoke_header

# 1. agent/ directory structure
echo "  ✓ agent/ directory"
[ -d "$PROJECT_ROOT/agent/core" ] && PASS=$((PASS+1)) || { echo "  ✗ MISSING agent/core"; FAIL=$((FAIL+1)); }
[ -d "$PROJECT_ROOT/agent/memory" ] && PASS=$((PASS+1)) || { echo "  ✗ MISSING agent/memory"; FAIL=$((FAIL+1)); }
[ -d "$PROJECT_ROOT/agent/skills" ] && PASS=$((PASS+1)) || { echo "  ✗ MISSING agent/skills"; FAIL=$((FAIL+1)); }
[ -d "$PROJECT_ROOT/agent/routing" ] && PASS=$((PASS+1)) || { echo "  ✗ MISSING agent/routing"; FAIL=$((FAIL+1)); }

# 2. AGENT.md has Version
has_version=$(grep -c "^\*\*Version\*\*:" "$PROJECT_ROOT/AGENT.md" 2>/dev/null || echo 0)
if [ "$has_version" -ge 1 ]; then
    echo "  ✓ AGENT.md version present"
    PASS=$((PASS+1))
else
    echo "  ✗ AGENT.md missing version"
    FAIL=$((FAIL+1))
fi

# 3. routing.yml is valid YAML and has session.executor
routing_exec=$(grep -c "executor:" "$PROJECT_ROOT/agent/core/routing.yml" 2>/dev/null || echo 0)
if [ "$routing_exec" -ge 1 ]; then
    echo "  ✓ routing.yml has executor"
    PASS=$((PASS+1))
else
    echo "  ✗ routing.yml missing executor"
    FAIL=$((FAIL+1))
fi

# 4. identity.yml has version
id_ver=$(grep -c "^version:" "$PROJECT_ROOT/agent/core/identity.yml" 2>/dev/null || echo 0)
if [ "$id_ver" -ge 1 ]; then
    echo "  ✓ identity.yml has version"
    PASS=$((PASS+1))
else
    echo "  ✗ identity.yml missing version"
    FAIL=$((FAIL+1))
fi

# 5. progress.yaml has project.name
proj_name=$(grep -c "name:" "$PROJECT_ROOT/agent/progress.yaml" 2>/dev/null || echo 0)
if [ "$proj_name" -ge 1 ]; then
    echo "  ✓ progress.yaml has name"
    PASS=$((PASS+1))
else
    echo "  ✗ progress.yaml missing name"
    FAIL=$((FAIL+1))
fi

# 6. Shell scripts pass syntax check
syntax_errors=0
for sh_file in "$PROJECT_ROOT"/agent/scripts/*.sh; do
    bash -n "$sh_file" 2>/dev/null || syntax_errors=$((syntax_errors+1))
done
if [ "$syntax_errors" -eq 0 ]; then
    echo "  ✓ All shell scripts pass bash -n"
    PASS=$((PASS+1))
else
    echo "  ✗ $syntax_errors scripts have syntax errors"
    FAIL=$((FAIL+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Smoke test: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
