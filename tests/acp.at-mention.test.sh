#!/usr/bin/env bash
# @-mention skills + Parallel task schema tests

cd "$(dirname "$0")/.."
PROJECT_ROOT="$(pwd)"
source tests/common.sh 2>/dev/null || true

PASS=0
FAIL=0
TX="$PROJECT_ROOT/agent/routing/taxonomy.yml"
SC="$PROJECT_ROOT/agent/schemas/task.schema.yaml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  @-mention + Parallel Schema Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# === @-mention skills ===

grep -q "skills_catalog:" "$TX" && { echo "  ✓ skills_catalog in taxonomy"; PASS=$((PASS+1)); } \
    || { echo "  ✗ skills_catalog missing"; FAIL=$((FAIL+1)); }

# Count skills_catalog entries
sk_count=$(sed -n '/skills_catalog:/,/^[a-z]/p' "$TX" 2>/dev/null | grep -c "^  - name:" || echo 0)
if [ "$sk_count" -ge 7 ]; then
    echo "  ✓ skills_catalog: $sk_count entries (≥7)"
    PASS=$((PASS+1))
else
    echo "  ✗ skills_catalog: $sk_count entries (<7)"
    FAIL=$((FAIL+1))
fi

# Each mention maps to existing file
missing_skills=0
while IFS= read -r line; do
    fpath=$(echo "$line" | sed "s/.*file: //" | tr -d ' ')
    if [ -n "$fpath" ] && [ ! -f "$PROJECT_ROOT/$fpath" ]; then
        missing_skills=$((missing_skills+1))
        echo "  ✗ Missing skill file: $fpath"
    fi
done < <(grep -A3 "mention:" "$TX" 2>/dev/null | grep "file:" || true)
if [ "$missing_skills" -eq 0 ]; then
    echo "  ✓ All @-mention triggers map to existing skill files"
    PASS=$((PASS+1))
else
    FAIL=$((FAIL+1))
fi

# Each @{mention} value in skills_catalog is unique (no duplicate entries)
dup_mentions=$(sed -n '/^skills_catalog:/,/^[a-z]/p' "$TX" 2>/dev/null | grep -o '\@{[^}]*}' | sort | uniq -d | wc -l | tr -d ' ')
if [ "$dup_mentions" -eq 0 ]; then
    echo "  ✓ All @{mention} values in skills_catalog are unique"
    PASS=$((PASS+1))
else
    echo "  ✗ Found $dup_mentions duplicate @{mention} values in catalog"
    FAIL=$((FAIL+1))
fi

# Each skill file has mention attribute
mention_count=$(grep -l 'mention=' "$PROJECT_ROOT"/agent/skills/*.md | wc -l | tr -d ' ')
if [ "$mention_count" -ge 7 ]; then
    echo "  ✓ All $mention_count skill files have @{mention} attribute"
    PASS=$((PASS+1))
else
    echo "  ✗ Only $mention_count skill files have mention (expected 7)"
    FAIL=$((FAIL+1))
fi

# === Parallel tasks ===

grep -q "^  parallel:" "$TX" && { echo "  ✓ task_type: parallel in taxonomy"; PASS=$((PASS+1)); } \
    || { echo "  ✗ parallel task type missing"; FAIL=$((FAIL+1)); }

grep -q "orchestrator-workers:" "$TX" && { echo "  ✓ task_type: orchestrator-workers in taxonomy"; PASS=$((PASS+1)); } \
    || { echo "  ✗ orchestrator-workers missing"; FAIL=$((FAIL+1)); }

grep -q "sub_task_default_executor:" "$TX" && { echo "  ✓ parallel has sub_task_default_executor"; PASS=$((PASS+1)); } \
    || { echo "  ✗ sub_task_default_executor missing"; FAIL=$((FAIL+1)); }

# sub-task schema
if [ -f "$SC" ]; then
    grep -q "depends_on:" "$SC" && { echo "  ✓ task.schema.yaml has depends_on field"; PASS=$((PASS+1)); } \
        || { echo "  ✗ depends_on missing from task schema"; FAIL=$((FAIL+1)); }
    grep -q "executor:" "$SC" && { echo "  ✓ task.schema.yaml has executor field"; PASS=$((PASS+1)); } \
        || { echo "  ✗ executor missing from task schema"; FAIL=$((FAIL+1)); }
else
    echo "  ✗ task.schema.yaml does not exist"
    FAIL=$((FAIL+2))
fi

# A3.1 in proceed.md
grep -q "A3.1. Parallel" "$PROJECT_ROOT/agent/commands/acp.proceed.md" \
    && { echo "  ✓ acp.proceed.md has A3.1 parallel section"; PASS=$((PASS+1)); } \
    || { echo "  ✗ A3.1 parallel section missing"; FAIL=$((FAIL+1)); }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  @-mention + Parallel: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
