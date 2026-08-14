#!/bin/bash
# Test suite for acp.yaml-parser.sh - Generic YAML Parser with AST
# Tests lexer, parser, AST construction, and query engine
# NOTE: set -e intentionally omitted — test suites track failures via counters,
# not shell exit codes. assert_* functions return 1 on failure by design.

# Source test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "${SCRIPT_DIR}/tests/common.sh"

# Source the YAML parser
. "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh"

# Create test YAML files
setup_test_files() {
    # Use unique temp directory to avoid parallel test conflicts
    FIXTURE_DIR="${FIXTURE_DIR:-$(mktemp -d)}"
    mkdir -p "$FIXTURE_DIR"
    
    # Simple YAML
    cat > "$FIXTURE_DIR/simple.yaml" << 'EOF'
name: test-package
version: 1.0.0
description: Test package
author: Test Author
EOF
    
    # Nested YAML
    cat > $FIXTURE_DIR/nested.yaml << 'EOF'
project:
  name: test-project
  version: 1.0.0
  metadata:
    author: Test Author
    license: MIT
EOF
    
    # Simple array YAML
    cat > $FIXTURE_DIR/array.yaml << 'EOF'
tags:
  - tag1
  - tag2
  - tag3
EOF
    
    # Object array YAML
    cat > $FIXTURE_DIR/object-array.yaml << 'EOF'
contents:
  patterns:
    - name: namespace.pattern1.md
      version: 1.0.0
    - name: namespace.pattern2.md
      version: 1.1.0
  commands:
    - name: namespace.command1.md
      version: 2.0.0
EOF
    
    # Complex nested structure
    cat > $FIXTURE_DIR/complex.yaml << 'EOF'
project:
  name: complex-project
  version: 2.5.0
  metadata:
    author: Complex Author
    tags:
      - production
      - stable
  dependencies:
    - name: dep1
      version: 1.0.0
    - name: dep2
      version: 2.0.0
EOF
    
    # Mixed structure
    cat > $FIXTURE_DIR/mixed.yaml << 'EOF'
name: mixed
version: 1.0.0
tags:
  - tag1
  - tag2
config:
  enabled: true
  timeout: 30
items:
  - name: item1
    value: 100
  - name: item2
    value: 200
EOF
}

# Cleanup test files
cleanup_test_files() {
    if [ -n "${FIXTURE_DIR:-}" ] && [ -d "$FIXTURE_DIR" ]; then
        rm -rf "$FIXTURE_DIR"
    fi
}

# Test Suite
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Generic YAML Parser with AST - Test Suite${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Setup
setup_test_files

# ============================================================================
# Test Group 1: Simple Key-Value Pairs
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 1: Simple Key-Value Pairs${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/simple.yaml"
result=$(yaml_query ".name")
assert_equals "test-package" "$result" "Query simple key: .name"

result=$(yaml_query ".version")
assert_equals "1.0.0" "$result" "Query simple key: .version"

result=$(yaml_query ".description")
assert_equals "Test package" "$result" "Query simple key: .description"

result=$(yaml_query ".author")
assert_equals "Test Author" "$result" "Query simple key: .author"

echo ""

# ============================================================================
# Test Group 2: Nested Objects
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 2: Nested Objects${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/nested.yaml"
result=$(yaml_query ".project.name")
assert_equals "test-project" "$result" "Query nested key: .project.name"

result=$(yaml_query ".project.version")
assert_equals "1.0.0" "$result" "Query nested key: .project.version"

result=$(yaml_query ".project.metadata.author")
assert_equals "Test Author" "$result" "Query deeply nested: .project.metadata.author"

result=$(yaml_query ".project.metadata.license")
assert_equals "MIT" "$result" "Query deeply nested: .project.metadata.license"

echo ""

# ============================================================================
# Test Group 3: Simple Arrays
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 3: Simple Arrays${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/array.yaml"
result=$(yaml_query ".tags[0]")
assert_equals "tag1" "$result" "Query array index: .tags[0]"

result=$(yaml_query ".tags[1]")
assert_equals "tag2" "$result" "Query array index: .tags[1]"

result=$(yaml_query ".tags[2]")
assert_equals "tag3" "$result" "Query array index: .tags[2]"

echo ""

# ============================================================================
# Test Group 4: Object Arrays
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 4: Object Arrays${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/object-array.yaml"
result=$(yaml_query ".contents.patterns[0].name")
assert_equals "namespace.pattern1.md" "$result" "Query object array: .contents.patterns[0].name"

result=$(yaml_query ".contents.patterns[0].version")
assert_equals "1.0.0" "$result" "Query object array: .contents.patterns[0].version"

result=$(yaml_query ".contents.patterns[1].name")
assert_equals "namespace.pattern2.md" "$result" "Query object array: .contents.patterns[1].name"

result=$(yaml_query ".contents.commands[0].name")
assert_equals "namespace.command1.md" "$result" "Query object array: .contents.commands[0].name"

result=$(yaml_query ".contents.commands[0].version")
assert_equals "2.0.0" "$result" "Query object array: .contents.commands[0].version"

echo ""

# ============================================================================
# Test Group 5: Complex Nested Structures
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 5: Complex Nested Structures${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/complex.yaml"
result=$(yaml_query ".project.name")
assert_equals "complex-project" "$result" "Complex: .project.name"

result=$(yaml_query ".project.metadata.author")
assert_equals "Complex Author" "$result" "Complex: .project.metadata.author"

result=$(yaml_query ".project.metadata.tags[0]")
assert_equals "production" "$result" "Complex: .project.metadata.tags[0]"

result=$(yaml_query ".project.metadata.tags[1]")
assert_equals "stable" "$result" "Complex: .project.metadata.tags[1]"

result=$(yaml_query ".project.dependencies[0].name")
assert_equals "dep1" "$result" "Complex: .project.dependencies[0].name"

result=$(yaml_query ".project.dependencies[0].version")
assert_equals "1.0.0" "$result" "Complex: .project.dependencies[0].version"

result=$(yaml_query ".project.dependencies[1].name")
assert_equals "dep2" "$result" "Complex: .project.dependencies[1].name"

echo ""

# ============================================================================
# Test Group 6: Mixed Structures
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 6: Mixed Structures${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/mixed.yaml"
result=$(yaml_query ".name")
assert_equals "mixed" "$result" "Mixed: .name"

result=$(yaml_query ".tags[0]")
assert_equals "tag1" "$result" "Mixed: .tags[0]"

result=$(yaml_query ".config.enabled")
assert_equals "true" "$result" "Mixed: .config.enabled"

result=$(yaml_query ".config.timeout")
assert_equals "30" "$result" "Mixed: .config.timeout"

result=$(yaml_query ".items[0].name")
assert_equals "item1" "$result" "Mixed: .items[0].name"

result=$(yaml_query ".items[0].value")
assert_equals "100" "$result" "Mixed: .items[0].value"

result=$(yaml_query ".items[1].name")
assert_equals "item2" "$result" "Mixed: .items[1].name"

echo ""

# ============================================================================
# Test Group 7: Edge Cases
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 7: Edge Cases${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/simple.yaml"

# Nonexistent key — yaml_query returns exit 1 for not-found; || true prevents
# set -e from aborting the test (we assert on the empty output, not exit code)
result=$(yaml_query ".nonexistent" 2>&1) || true
assert_empty "$result" "Edge case: nonexistent key returns empty"

# Out of bounds array index
yaml_parse "$FIXTURE_DIR/array.yaml"
result=$(yaml_query ".tags[99]" 2>&1) || true
assert_empty "$result" "Edge case: out of bounds array index returns empty"

# Invalid path
yaml_parse "$FIXTURE_DIR/simple.yaml"
result=$(yaml_query ".name.invalid" 2>&1) || true
assert_empty "$result" "Edge case: invalid nested path returns empty"

echo ""

# ============================================================================
# Test Group 8: Backward Compatibility
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 8: Backward Compatibility${NC}"
echo ""

# Test yaml_get wrapper
result=$(yaml_get "$FIXTURE_DIR/simple.yaml" "name")
assert_equals "test-package" "$result" "Backward compat: yaml_get"

# Test yaml_get_nested wrapper
result=$(yaml_get_nested "$FIXTURE_DIR/nested.yaml" "project.metadata.author")
assert_equals "Test Author" "$result" "Backward compat: yaml_get_nested"

result=$(yaml_get_nested "$FIXTURE_DIR/object-array.yaml" "contents.patterns[0].name")
assert_equals "namespace.pattern1.md" "$result" "Backward compat: yaml_get_nested with array"

echo ""

# ============================================================================
# Test Group 9: Update Operations (yaml_set)
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 9: Update Operations${NC}"
echo ""

# Create test file for updates
cp $FIXTURE_DIR/simple.yaml $FIXTURE_DIR/update-test.yaml

yaml_parse "$FIXTURE_DIR/update-test.yaml"
yaml_set ".version" "2.0.0"
result=$(yaml_query ".version")
assert_equals "2.0.0" "$result" "Update: yaml_set changes value in AST"

# Write back and verify
yaml_write "$FIXTURE_DIR/update-test.yaml"
yaml_parse "$FIXTURE_DIR/update-test.yaml"
result=$(yaml_query ".version")
assert_equals "2.0.0" "$result" "Update: yaml_write persists changes to file"

rm $FIXTURE_DIR/update-test.yaml

echo ""

# ============================================================================
# Test Group 10: Performance Tests
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 10: Performance Tests${NC}"
echo ""

# Parse time test
start_time=$(date +%s%N)
yaml_parse "$FIXTURE_DIR/complex.yaml"
end_time=$(date +%s%N)
parse_time=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds

echo -e "  Parse time: ${YELLOW}${parse_time}ms${NC}"
if [ "$parse_time" -lt 3000 ]; then
    echo -e "${GREEN}✓${NC} Parse performance acceptable (< 3s)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Parse performance too slow (>= 3s)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Query time test (multiple queries on same AST)
start_time=$(date +%s%N)
for i in 1 2 3 4 5 6 7 8 9 10; do
    yaml_query ".project.name" > /dev/null
done
end_time=$(date +%s%N)
query_time=$(( (end_time - start_time) / 10000000 ))  # Average per query in ms

echo -e "  Query time (avg): ${YELLOW}${query_time}ms${NC}"
if [ "$query_time" -lt 100 ]; then
    echo -e "${GREEN}✓${NC} Query performance acceptable (< 100ms)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Query performance too slow (>= 100ms)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

echo ""

# ============================================================================
# Test Group 11: AST Structure Tests
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 11: AST Structure Tests${NC}"
echo ""

yaml_parse "$FIXTURE_DIR/simple.yaml"
assert_not_empty "$AST_FILE" "AST: AST_FILE set after parse"
assert_file_exists "$AST_FILE" "AST: AST_FILE points to existing file"
assert_not_empty "$AST_ROOT_ID" "AST: Root ID set"

# Check node count is reasonable (line count of AST file = node count)
if [ -f "$AST_FILE" ]; then
    AST_NODE_COUNT=$(wc -l < "$AST_FILE" | tr -d ' ')
    if [ "$AST_NODE_COUNT" -ge 4 ]; then
        echo -e "${GREEN}✓${NC} AST: Node count reasonable (>= 4 for simple.yaml, got $AST_NODE_COUNT)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} AST: Node count too low (< 4, got $AST_NODE_COUNT)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
fi

echo ""

# ============================================================================
# Test Group 12: Utility Functions
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 12: Utility Functions${NC}"
echo ""

# Test get_indent_level
result=$(get_indent_level "  key: value")
assert_equals "2" "$result" "Util: get_indent_level with 2 spaces"

result=$(get_indent_level "    key: value")
assert_equals "4" "$result" "Util: get_indent_level with 4 spaces"

result=$(get_indent_level "key: value")
assert_equals "0" "$result" "Util: get_indent_level with no indent"

# Test strip_comments
result=$(strip_comments "key: value # comment")
assert_equals "key: value " "$result" "Util: strip_comments removes comment"

result=$(strip_comments "key: value")
assert_equals "key: value" "$result" "Util: strip_comments preserves line without comment"

# F2-09: # inside double-quoted scalars must not truncate
result=$(strip_comments 'quoted_hash: "tracked #42 open"')
assert_equals 'quoted_hash: "tracked #42 open"' "$result" "Util: strip_comments preserves # inside double quotes"

result=$(strip_comments "note: 'hash #tag kept'")
assert_equals "note: 'hash #tag kept'" "$result" "Util: strip_comments preserves # inside single quotes"

result=$(strip_comments 'url: https://example.com/path#frag  # trailing')
assert_equals 'url: https://example.com/path#frag  ' "$result" "Util: strip_comments keeps unquoted # without prior whitespace; strips spaced comment"

# Test trim
result=$(trim "  value  ")
assert_equals "value" "$result" "Util: trim removes whitespace"

# Test is_array_item
if is_array_item "  - item"; then
    echo -e "${GREEN}✓${NC} Util: is_array_item detects array item"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Util: is_array_item failed to detect array item"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if ! is_array_item "key: value"; then
    echo -e "${GREEN}✓${NC} Util: is_array_item rejects non-array"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Util: is_array_item false positive"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

echo ""

# ============================================================================
# Test Group 13: Real-World Package.yaml
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 13: Real-World package.yaml${NC}"
echo ""

# Create realistic package.yaml
cat > $FIXTURE_DIR/package.yaml << 'EOF'
name: acp-firebase
version: 1.2.0
description: Firebase patterns and commands for ACP
author: Test Author
license: MIT
repository: https://github.com/user/acp-firebase.git
homepage: https://github.com/user/acp-firebase
tags:
  - firebase
  - patterns
  - commands
contents:
  patterns:
    - name: firebase.firestore-pattern.md
      version: 1.0.0
    - name: firebase.auth-pattern.md
      version: 1.1.0
  commands:
    - name: firebase.deploy.md
      version: 2.0.0
    - name: firebase.init.md
      version: 1.5.0
  designs:
    - name: firebase.architecture-design.md
      version: 1.0.0
release:
  branch: main
EOF

yaml_parse "$FIXTURE_DIR/package.yaml"
result=$(yaml_query ".name")
assert_equals "acp-firebase" "$result" "Real-world: package name"

result=$(yaml_query ".version")
assert_equals "1.2.0" "$result" "Real-world: package version"

result=$(yaml_query ".tags[0]")
assert_equals "firebase" "$result" "Real-world: tags[0]"

result=$(yaml_query ".tags[1]")
assert_equals "patterns" "$result" "Real-world: tags[1]"

result=$(yaml_query ".contents.patterns[0].name")
assert_equals "firebase.firestore-pattern.md" "$result" "Real-world: patterns[0].name"

result=$(yaml_query ".contents.patterns[0].version")
assert_equals "1.0.0" "$result" "Real-world: patterns[0].version"

result=$(yaml_query ".contents.commands[0].name")
assert_equals "firebase.deploy.md" "$result" "Real-world: commands[0].name"

result=$(yaml_query ".contents.designs[0].name")
assert_equals "firebase.architecture-design.md" "$result" "Real-world: designs[0].name"

result=$(yaml_query ".release.branch")
assert_equals "main" "$result" "Real-world: release.branch"

echo ""

# ============================================================================
# Test Group 14: Stress Tests
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 14: Stress Tests${NC}"
echo ""

# Create large YAML file
cat > $FIXTURE_DIR/large.yaml << 'EOF'
project:
  name: large-project
  items:
EOF

# Add 50 items
for i in $(seq 1 50); do
    echo "    - name: item$i" >> $FIXTURE_DIR/large.yaml
    echo "      value: $i" >> $FIXTURE_DIR/large.yaml
done

yaml_parse "$FIXTURE_DIR/large.yaml"
result=$(yaml_query ".project.items[0].name")
assert_equals "item1" "$result" "Stress: First item in large array"

result=$(yaml_query ".project.items[49].name")
assert_equals "item50" "$result" "Stress: Last item in large array (50 items)"

result=$(yaml_query ".project.items[25].value")
assert_equals "26" "$result" "Stress: Middle item in large array"

echo ""

# ============================================================================
# Test Group 15: Error Handling
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 15: Error Handling${NC}"
echo ""

# Test parsing nonexistent file — yaml_parse returns 1; || true prevents set -e abort
result=$(yaml_parse "$FIXTURE_DIR/nonexistent.yaml" 2>&1) || true
if echo "$result" | grep -q "Error"; then
    echo -e "${GREEN}✓${NC} Error handling: nonexistent file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Error handling: should error on nonexistent file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test query without parse — clear AST_FILE to simulate no-AST state
# (AST_NODES is not the parser's state variable; AST_FILE is)
AST_FILE=""
result=$(yaml_query ".name" 2>&1) || true
if echo "$result" | grep -q "Error"; then
    echo -e "${GREEN}✓${NC} Error handling: query without parse"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} Error handling: should error when querying without parse"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

echo ""

# ============================================================================
# Test Group 16: Array Append Operations
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 16: Array Append Operations${NC}"
echo ""

cp $FIXTURE_DIR/array.yaml $FIXTURE_DIR/append-test-work.yaml
yaml_parse "$FIXTURE_DIR/append-test-work.yaml"

# Append item (capture node ID to avoid printing to stdout)
node_id=$(yaml_array_append ".tags" "tag4")

# Verify in AST (before write)
result=$(yaml_query ".tags[3]")
assert_equals "tag4" "$result" "Array append: new item at index 3 (in AST)"

# Append another
node_id=$(yaml_array_append ".tags" "tag5")

# Verify in AST
result=$(yaml_query ".tags[4]")
assert_equals "tag5" "$result" "Array append: new item at index 4 (in AST)"

# Write and verify persistence
yaml_write "$FIXTURE_DIR/append-test-work.yaml"
yaml_parse "$FIXTURE_DIR/append-test-work.yaml"

result=$(yaml_query ".tags[3]")
assert_equals "tag4" "$result" "Array append: item 4 persisted to file"

result=$(yaml_query ".tags[4]")
assert_equals "tag5" "$result" "Array append: item 5 persisted to file"

rm $FIXTURE_DIR/append-test-work.yaml

echo ""

# ============================================================================
# Test Group 17: Object Array Append
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 17: Object Array Append${NC}"
echo ""

cp $FIXTURE_DIR/mixed.yaml $FIXTURE_DIR/object-append-work.yaml
yaml_parse "$FIXTURE_DIR/object-append-work.yaml"

# Append new object (capture all node IDs)
obj_node=$(yaml_array_append_object ".items")
field1=$(yaml_object_set "$obj_node" "name" "item3")
field2=$(yaml_object_set "$obj_node" "value" "300")

# Verify in AST
result=$(yaml_query ".items[2].name")
assert_equals "item3" "$result" "Object append: new object name (in AST)"

result=$(yaml_query ".items[2].value")
assert_equals "300" "$result" "Object append: new object value (in AST)"

# Write and verify persistence
yaml_write "$FIXTURE_DIR/object-append-work.yaml"
yaml_parse "$FIXTURE_DIR/object-append-work.yaml"

result=$(yaml_query ".items[2].name")
assert_equals "item3" "$result" "Object append: new object name (persisted)"

result=$(yaml_query ".items[2].value")
assert_equals "300" "$result" "Object append: new object value (persisted)"

rm $FIXTURE_DIR/object-append-work.yaml

echo ""

# ============================================================================
# Test Group 18: Mixed Operations (Read, Modify, Append, Write)
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 18: Mixed Operations${NC}"
echo ""

cp $FIXTURE_DIR/mixed.yaml $FIXTURE_DIR/mixed-work.yaml
yaml_parse "$FIXTURE_DIR/mixed-work.yaml"

# Read existing value
result=$(yaml_query ".items[0].name")
assert_equals "item1" "$result" "Mixed: read existing value"

# Modify existing value
yaml_set ".items[0].value" "150"

# Append to array
obj_node=$(yaml_array_append_object ".items")
field1=$(yaml_object_set "$obj_node" "name" "item3")
field2=$(yaml_object_set "$obj_node" "value" "300")

# Write and re-read
yaml_write "$FIXTURE_DIR/mixed-work.yaml"
yaml_parse "$FIXTURE_DIR/mixed-work.yaml"

# Verify modification
result=$(yaml_query ".items[0].value")
assert_equals "150" "$result" "Mixed: modified value persisted"

# Verify append
result=$(yaml_query ".items[2].name")
assert_equals "item3" "$result" "Mixed: appended object persisted"

# Verify original items still there
result=$(yaml_query ".items[1].name")
assert_equals "item2" "$result" "Mixed: original item 2 still present"

rm $FIXTURE_DIR/mixed-work.yaml

echo ""

# ============================================================================
# Test Group 19: yaml_delete Function
# ============================================================================
echo -e "${BLUE}${BOLD}Test Group 19: yaml_delete Function${NC}"
echo ""

# Test 1: Delete simple scalar
cat > $FIXTURE_DIR/delete-test.yaml << 'EOF'
name: test
version: 1.0.0
description: Test package
EOF

yaml_parse $FIXTURE_DIR/delete-test.yaml
yaml_delete ".description"
yaml_write $FIXTURE_DIR/delete-test.yaml

yaml_parse $FIXTURE_DIR/delete-test.yaml
result=$(yaml_query ".description" 2>/dev/null || echo "")
assert_equals "" "$result" "Delete: simple scalar removed"
assert_equals "test" "$(yaml_query '.name')" "Delete: other fields remain"

# Test 2: Delete nested field
cat > $FIXTURE_DIR/delete-test.yaml << 'EOF'
project:
  name: test
  version: 1.0.0
  metadata:
    author: Test
    license: MIT
EOF

yaml_parse $FIXTURE_DIR/delete-test.yaml
yaml_delete ".project.metadata.license"
yaml_write $FIXTURE_DIR/delete-test.yaml

yaml_parse $FIXTURE_DIR/delete-test.yaml
result=$(yaml_query ".project.metadata.license" 2>/dev/null || echo "")
assert_equals "" "$result" "Delete: nested field removed"
assert_equals "Test" "$(yaml_query '.project.metadata.author')" "Delete: sibling fields remain"

# Test 3: Delete entire object
cat > $FIXTURE_DIR/delete-test.yaml << 'EOF'
projects:
  project1:
    name: Project 1
    type: web
  project2:
    name: Project 2
    type: cli
EOF

yaml_parse $FIXTURE_DIR/delete-test.yaml
yaml_delete ".projects.project1"
yaml_write $FIXTURE_DIR/delete-test.yaml

yaml_parse $FIXTURE_DIR/delete-test.yaml
result=$(yaml_query ".projects.project1.name" 2>/dev/null || echo "")
assert_equals "" "$result" "Delete: entire object removed"
assert_equals "Project 2" "$(yaml_query '.projects.project2.name')" "Delete: other objects remain"

# Test 4: Delete non-existent field (should error)
cat > $FIXTURE_DIR/delete-test.yaml << 'EOF'
name: test
EOF

yaml_parse $FIXTURE_DIR/delete-test.yaml
set +e
yaml_delete ".nonexistent" 2>/dev/null
exit_code=$?
set -e
assert_not_equals 0 "$exit_code" "Delete: non-existent field returns error"

rm -f $FIXTURE_DIR/delete-test.yaml

echo ""

# ============================================================================
# Test Group 20: Array Operations with yaml_set and yaml_array_append
# ============================================================================
echo -e "${BOLD}Test Group 20: Array Operations${NC}"
echo "Testing yaml_set with [] and yaml_array_append..."

# Test 1: Create empty array with yaml_set
cat > $FIXTURE_DIR/array-ops.yaml << 'EOF'
project:
  name: test
  version: 1.0.0
EOF

yaml_parse $FIXTURE_DIR/array-ops.yaml
yaml_set ".project.tags" "[]"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
# Check node type is array
node_type=$(grep "tags" "$AST_FILE" | cut -d'|' -f2)
assert_equals "array" "$node_type" "Array ops: yaml_set creates array node for []"

# Test 2: Append to empty array
yaml_array_append ".project.tags" "production"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
result=$(yaml_query ".project.tags")
assert_contains "$result" "production" "Array ops: append to empty array works"

# Test 3: Append second item
yaml_array_append ".project.tags" "staging"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
result=$(yaml_query ".project.tags")
assert_contains "$result" "production" "Array ops: first item preserved"
assert_contains "$result" "staging" "Array ops: second item added"

# Test 4: Convert existing scalar to empty array
cat > $FIXTURE_DIR/array-ops.yaml << 'EOF'
project:
  name: test
  tags: old-value
EOF

yaml_parse $FIXTURE_DIR/array-ops.yaml
yaml_set ".project.tags" "[]"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
node_type=$(grep "tags" "$AST_FILE" | cut -d'|' -f2)
assert_equals "array" "$node_type" "Array ops: convert scalar to array"

# Verify old value is gone
result=$(yaml_query ".project.tags")
assert_not_contains "$result" "old-value" "Array ops: old scalar value removed"

# Test 5: Append after conversion
yaml_array_append ".project.tags" "new-tag"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
result=$(yaml_query ".project.tags")
assert_contains "$result" "new-tag" "Array ops: append after conversion works"

# Test 6: Multiple appends in sequence
yaml_array_append ".project.tags" "tag1"
yaml_array_append ".project.tags" "tag2"
yaml_array_append ".project.tags" "tag3"
yaml_write $FIXTURE_DIR/array-ops.yaml

yaml_parse $FIXTURE_DIR/array-ops.yaml
result=$(yaml_query ".project.tags")
assert_contains "$result" "tag1" "Array ops: multiple appends - tag1"
assert_contains "$result" "tag2" "Array ops: multiple appends - tag2"
assert_contains "$result" "tag3" "Array ops: multiple appends - tag3"

rm -f $FIXTURE_DIR/array-ops.yaml

echo ""

# Cleanup
cleanup_test_files

# ============================================================================
# Summary
# ============================================================================
# ── F-112-01 / F2-06: delimiter survives the pipe-delimited AST record ─────────
# Before M85 task-299 any value containing `|` was silently truncated at the first
# pipe: records are "id|type|key|value|parent|children" and nothing escaped user
# data on the way in. The escaping that DID exist sat in a second, shadowed
# definition of create_node() that bash never used (F2-06).
print_test_header "PIPE — values containing the record delimiter round-trip"
PIPE_DIR="$(mktemp -d)"
cat > "${PIPE_DIR}/p.yaml" <<'PYEOF'
bare: a|b|c
mixed: x|y%z
pct: 100%
pct_seq: a%7Cb
plain: nopipe
PYEOF
assert_equals "a|b|c"  "$(yaml_get "${PIPE_DIR}/p.yaml" bare)"  "bare pipes round-trip"
assert_equals "x|y%z"  "$(yaml_get "${PIPE_DIR}/p.yaml" mixed)" "pipe and percent together round-trip"
assert_equals "100%"   "$(yaml_get "${PIPE_DIR}/p.yaml" pct)"   "literal percent round-trips"
# A literal "%7C" in source must NOT decode into a delimiter — this is why the
# encoder escapes `%` first and the decoder unescapes it last.
assert_equals "a%7Cb"  "$(yaml_get "${PIPE_DIR}/p.yaml" pct_seq)" "literal %7C is not read as an encoded pipe"
assert_equals "nopipe" "$(yaml_get "${PIPE_DIR}/p.yaml" plain)" "unaffected value unchanged"
rm -rf "${PIPE_DIR}"

print_test_header "F2-06 — create_node is defined exactly once"
CN_DEFS="$(grep -c '^create_node()' "${SCRIPT_DIR}/agent/scripts/acp.yaml-parser.sh" 2>/dev/null || echo 0)"
assert_equals "1" "$CN_DEFS" "exactly one create_node definition (no shadowing duplicate)"


echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Test Results${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_RUN -gt 0 ]; then
    pass_rate=$(( TESTS_PASSED * 100 / TESTS_RUN ))
    echo -e "Pass Rate:    ${YELLOW}${pass_rate}%${NC}"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✅ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}${BOLD}❌ Some tests failed${NC}"
    echo ""
    exit 1
fi
