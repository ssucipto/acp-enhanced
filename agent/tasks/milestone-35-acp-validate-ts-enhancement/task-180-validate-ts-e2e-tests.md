---
id: task-180
milestone: M35
title: Write acp.validate-ts.test.sh with ≥10 assertions
status: completed
priority: 3
complexity: medium
estimated_hours: 2
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

## Objective

Create `tests/acp.validate-ts.test.sh` with ≥10 assertions testing the new `acp-validate.ts` checks (placeholder detection from task-178, frontmatter validation and parity check from task-179) using fixture files with known violations.

## Context

`scripts/acp-validate.ts` has tests implied by its existing CI checks, but the new checks from M35 need explicit coverage. The test suite creates temporary fixture files with known violations, runs the validator, and checks exit codes and output.

## Implementation

```bash
#!/usr/bin/env bash
# Tests for acp-validate.ts new checks (M35)

<!-- @acp.meta.task
topic: tests, for, acp-validatets, new, checks, m35
description: Write acp.validate-ts.test.sh with ≥10 assertions
milestone: M35
status: completed
updated: 2026-05-05
@acp.meta.end -->


set -u

source tests/common.sh

VALIDATE_CMD="npx ts-node scripts/acp-validate.ts"
TMPDIR_FIXTURES=$(mktemp -d)

# ---- Fixture setup ----

# Fixture 1: valid command file
cat > "$TMPDIR_FIXTURES/acp.valid-command.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Status: active
Scripts: none
---

This command does something valid.
EOF

# Fixture 2: file with unresolved placeholder on line 3
cat > "$TMPDIR_FIXTURES/acp.placeholder-command.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Status: active
Scripts: none
---

{COMMAND_NAME} is a placeholder that should be replaced.
Some other content here.
EOF

# Fixture 3: placeholder in code block (should NOT be flagged)
cat > "$TMPDIR_FIXTURES/acp.code-block-command.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Status: active
Scripts: none
---

Normal text on line 3.

\`\`\`bash
echo {COMMAND_NAME}  # This is in a code block
\`\`\`
EOF

# Fixture 4: missing Status field
cat > "$TMPDIR_FIXTURES/acp.missing-status.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Scripts: none
---

No status field above.
EOF

# Fixture 5: missing multiple fields
cat > "$TMPDIR_FIXTURES/acp.missing-fields.md" << 'EOF'
---
title: incomplete
---

Missing Namespace, Version, Status, Scripts.
EOF

# ---- Tests ----

# Test 1: valid file produces no errors
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.valid-command.md 2>&1)
echo "$output" | grep -qv "error" && pass "Valid file: no errors" || fail "Valid file should produce no errors"

# Test 2: placeholder on non-code line 3 is detected
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.placeholder-command.md 2>&1)
echo "$output" | grep -qi "placeholder" && pass "Placeholder in line 3: detected" || fail "Should detect placeholder in line 3"

# Test 3: placeholder in code block is NOT flagged
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.code-block-command.md 2>&1)
echo "$output" | grep -qi "COMMAND_NAME" && fail "Placeholder in code block should NOT be flagged" || pass "Code block placeholder: not flagged"

# Test 4: missing Status field is warned
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.missing-status.md 2>&1)
echo "$output" | grep -qi "Status" && pass "Missing Status field: warning produced" || fail "Should warn about missing Status"

# Test 5: missing multiple fields → multiple warnings
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.missing-fields.md 2>&1)
warning_count=$(echo "$output" | grep -ic "missing required")
[ "$warning_count" -ge 3 ] && pass "Missing multiple fields: ≥3 warnings" || fail "Should warn about Namespace, Version, Status (got $warning_count)"

# Test 6: missing frontmatter entirely → error
cat > "$TMPDIR_FIXTURES/acp.no-frontmatter.md" << 'EOF'
# No frontmatter command

Just content, no YAML block.
EOF
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.no-frontmatter.md 2>&1)
echo "$output" | grep -qi "frontmatter" && pass "No frontmatter: error produced" || fail "Should error on missing frontmatter"

# Test 7: parity check shows count (basic smoke test)
output=$($VALIDATE_CMD --parity-only 2>&1)
echo "$output" | grep -qi "parity\|command\|prompt" && pass "Parity check: output contains count info" || fail "Parity check should output count info"

# Test 8: summary line present in output
output=$($VALIDATE_CMD 2>&1)
echo "$output" | grep -qi "placeholder check\|frontmatter check\|parity" && pass "Output has summary lines" || fail "Should have summary lines for new checks"

# Test 9: numeric-only {1} pattern not flagged as placeholder
cat > "$TMPDIR_FIXTURES/acp.numeric-braces.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Status: active
Scripts: none
---

Replace step {1} with content. This is a valid usage.
EOF
output=$(VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.numeric-braces.md 2>&1)
echo "$output" | grep -qi "Unresolved placeholder.*{1}" && fail "Numeric {1} should not be flagged" || pass "Numeric braces {1}: not flagged"

# Test 10: validate exits 0 when only warnings (no hard errors)
cat > "$TMPDIR_FIXTURES/acp.warnings-only.md" << 'EOF'
---
Namespace: test
Version: 1.0.0
Scripts: none
---

Content with no Status field (warning only).
EOF
VALIDATE_FIXTURES_DIR="$TMPDIR_FIXTURES" $VALIDATE_CMD --fixture acp.warnings-only.md 2>&1
# Warnings should not cause non-zero exit (policy: warnings don't fail CI)
[ $? -eq 0 ] && pass "Warnings only: exit code 0" || fail "Warnings-only file should exit 0"

# Cleanup
rm -rf "$TMPDIR_FIXTURES"

print_summary
```

**Note**: The `--fixture` and `--parity-only` flags may need to be added to `acp-validate.ts`. If the CLI doesn't support fixture paths, use `VALIDATE_FIXTURES_DIR` env var pattern or adapt the test to work with the existing CLI interface. Read `scripts/acp-validate.ts` first to understand the current CLI surface.

## Expected Output

### Files Created
- `tests/acp.validate-ts.test.sh`

## Verification
- [ ] Test file has ≥10 `pass`/`fail` assertions
- [ ] All 5 fixture scenarios are covered (valid, placeholder, code-block, missing-fields, no-frontmatter)
- [ ] Tests use `tests/common.sh` helpers
- [ ] `bash tests/acp.validate-ts.test.sh` runs without bash syntax errors

## User-Observable Acceptance
Running `bash tests/acp.validate-ts.test.sh` from repo root executes all ≥10 assertions against the updated `acp-validate.ts` and reports a PASS/FAIL summary.
