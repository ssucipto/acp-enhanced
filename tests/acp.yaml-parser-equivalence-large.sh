#!/usr/bin/env bash
# task-300 (M85): parser equivalence for large YAML files.
#
# Deliberately NOT named *.test.sh: run-e2e-tests.sh globs tests/*.test.sh
# into the timeout-sensitive parallel suite (180s/test — see
# run-e2e-tests.sh TIMEOUT_SECS). agent/progress.yaml (9,480 lines / 7,880
# nodes) alone takes ~100s to parse with the CURRENT parser because
# add_child rewrites the whole growing AST_FILE with `sed -i` on every child
# appended — an O(n^2) cost M85's field-access optimisation never touched.
#
# This script covers exactly the files tests/acp.yaml-parser-equivalence.test.sh
# excludes (>= LARGE_FILE_LINES, see that file's header for the full
# rationale and the golden-fixture design both scripts share). Run it
# manually before a mainline merge, or from a dedicated slow CI job — not on
# every push.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACP_YAML_EQUIV_LIB_ONLY=1
. "${SCRIPT_DIR}/tests/acp.yaml-parser-equivalence.test.sh"

if [ ! -s "$GOLDEN_FIXTURE" ]; then
    echo -e "${RED}✗ Golden fixture not found: $GOLDEN_FIXTURE${NC}"
    exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

YAML_FILES=()
while IFS= read -r _f || [ -n "$_f" ]; do
    [ -z "$_f" ] && continue
    _lines=$(wc -l < "${SCRIPT_DIR}/${_f}" 2>/dev/null | tr -d ' ')
    if [ "${_lines:-0}" -ge "$LARGE_FILE_LINES" ]; then
        YAML_FILES[${#YAML_FILES[@]}]="$_f"
    fi
done < <(git -C "$SCRIPT_DIR" ls-files -- '*.yaml' '*.yml' | sort)

if [ "${#YAML_FILES[@]}" -eq 0 ]; then
    echo -e "${YELLOW}ℹ No large files (>= ${LARGE_FILE_LINES} lines) currently tracked — nothing to do.${NC}"
    exit 0
fi

echo -e "${YELLOW}ℹ Checking ${#YAML_FILES[@]} large file(s) against the golden fixture (this is slow by design):${NC}"
printf '    %s\n' "${YAML_FILES[@]}"
echo ""

run_equivalence_check "$WORKDIR"

print_test_summary
exit $?
