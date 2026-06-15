---
id: task-175
milestone: M33
title: Create driver e2e tests and acp.validate Step 11.5
status: completed
priority: 2
complexity: medium
estimated_hours: 3
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

## Objective

Create `e2e/acp.driver-yaml.test.sh` testing all 8 `acp.driver-yaml.sh` helpers, and add Step 11.5 to `agent/commands/acp.validate.md` for driver binding consistency validation.

## Context

The driver system (tasks 171–174) needs test coverage. Tests require a fixture `agent/driver.yaml` — the test suite creates this in a temp dir and tears it down after. `acp.validate.md` currently has Steps 1–11 (Probes 1–3); a new Probe for driver consistency fits here.

## Implementation

### Part 1: `e2e/acp.driver-yaml.test.sh`

```bash
#!/usr/bin/env bash
# Tests for acp.driver-yaml.sh helper functions

<!-- @acp.meta.task
topic: tests, for, acpdriver-yamlsh, helper, functions
description: Create driver e2e tests and acp.validate Step 11.5
milestone: M33
status: completed
updated: 2026-05-05
@acp.meta.end -->



source tests/common.sh

SCRIPT="agent/scripts/acp.driver-yaml.sh"

# Create temp driver.yaml fixture
TMPDIR_DRIVER=$(mktemp -d)
DRIVER_YAML="$TMPDIR_DRIVER/driver.yaml"
cat > "$DRIVER_YAML" << 'EOF'
---
drivers:
  git:
    type: mcp
    server: git-mcp
    method: git_exec
  shell:
    type: native
  lint:
    type: http
    url: https://lint.internal/api
EOF
export DRIVER_YAML

# Source the script
source "$SCRIPT" 2>/dev/null || fail "Failed to source $SCRIPT"

# Test driver_type
assert_eq "$(driver_type git)" "mcp" "driver_type: git is mcp"
assert_eq "$(driver_type shell)" "native" "driver_type: shell is native"
assert_eq "$(driver_type unknown)" "native" "driver_type: unknown defaults to native"

# Test driver_is_native
driver_is_native shell && pass "driver_is_native shell returns 0" || fail "driver_is_native shell should be 0"
driver_is_native git && fail "driver_is_native git should return 1" || pass "driver_is_native git returns 1 (correct)"

# Test driver_query
assert_eq "$(driver_query git server)" "git-mcp" "driver_query git server"
assert_eq "$(driver_query git method)" "git_exec" "driver_query git method"
assert_eq "$(driver_query lint url)" "https://lint.internal/api" "driver_query lint url"

# Test driver_list (output has 3 drivers)
count=$(driver_list | wc -l | tr -d ' ')
assert_eq "$count" "3" "driver_list returns 3 entries"

# Test driver_validate
driver_validate && pass "driver_validate passes for valid fixture" || fail "driver_validate should pass"

# Cleanup
rm -rf "$TMPDIR_DRIVER"

# Test driver_is_native when driver.yaml absent
unset DRIVER_YAML
driver_is_native git && pass "driver_is_native defaults to native when no driver.yaml" || fail "should default to native"
```

Write at least **12 assertions** (the examples above are the minimum). Use `assert_eq`, `pass`, `fail` from `tests/common.sh`.

### Part 2: acp.validate.md Step 11.5

Find the end of the current validation steps in `acp.validate.md` (near Step 11). Add:

```markdown
### Step 11.5 — Driver Binding Consistency (skip if agent/driver.yaml absent)

If `agent/driver.yaml` exists:
1. Source `agent/scripts/acp.driver-yaml.sh`
2. Run `driver_validate` — report any validation errors
3. For each driver of type `mcp`:
   - Verify `server:` field is present (error if missing)
   - Verify `method:` field is present (error if missing)
4. For each driver of type `http`:
   - Verify `url:` field is present (error if missing)
5. Check that `overrides:` keys (if any) reference known command names
6. Report: "Driver binding: N drivers configured, M errors found"
7. Non-blocking: validation failures are warnings, not fatal errors
```

## Expected Output

### Files Created
- `e2e/acp.driver-yaml.test.sh`

### Files Updated
- `agent/commands/acp.validate.md`

## Verification
- [ ] `bash e2e/acp.driver-yaml.test.sh` passes with ≥12 assertions
- [ ] All 8 `acp.driver-yaml.sh` functions are tested
- [ ] acp.validate.md has Step 11.5
- [ ] Step 11.5 has "skip if absent" guard
- [ ] Tests use existing `tests/common.sh` helpers

## User-Observable Acceptance
Running `bash e2e/acp.driver-yaml.test.sh` from repo root outputs PASS for all assertions. Running `/acp-validate` with a valid `driver.yaml` reports "Driver binding: 3 drivers configured, 0 errors".
