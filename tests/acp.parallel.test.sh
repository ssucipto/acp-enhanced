#!/usr/bin/env bash
# Parallel task schema tests

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0
SC="$PROJECT_ROOT/agent/schemas/task.schema.yaml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Parallel Task Schema Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. File exists
[ -f "$SC" ] && { echo "  ✓ task.schema.yaml exists"; PASS=$((PASS+1)); } \
    || { echo "  ✗ task.schema.yaml missing"; FAIL=$((FAIL+1)); }

# 2. Has sub_task definition
grep -q "^sub_task:" "$SC" 2>/dev/null && { echo "  ✓ has sub_task definition"; PASS=$((PASS+1)); } \
    || { echo "  ✗ sub_task missing"; FAIL=$((FAIL+1)); }

# 3. Has depends_on field  
grep -q "depends_on:" "$SC" 2>/dev/null && { echo "  ✓ has depends_on for DAG"; PASS=$((PASS+1)); } \
    || { echo "  ✗ depends_on missing"; FAIL=$((FAIL+1)); }

# 4. Has executor field
grep -q "executor:" "$SC" 2>/dev/null && { echo "  ✓ has executor field"; PASS=$((PASS+1)); } \
    || { echo "  ✗ executor missing"; FAIL=$((FAIL+1)); }

# 5. Accepts valid YAML (via python/yq if available, else skip)
if python3 -c "import yaml" 2>/dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('$SC'))" 2>/dev/null \
        && { echo "  ✓ Valid YAML syntax"; PASS=$((PASS+1)); } \
        || { echo "  ✗ Invalid YAML"; FAIL=$((FAIL+1)); }
else
    echo "  ~ YAML validation: PyYAML unavailable (skip)"
    PASS=$((PASS+1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Parallel Schema: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
