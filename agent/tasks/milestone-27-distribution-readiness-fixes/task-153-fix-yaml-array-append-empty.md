---
id: task-153
milestone: M27
title: Fix yaml_array_append to empty array returns ':' instead of value
status: not_started
priority: 5
complexity: medium
estimated_hours: 2.0
created: 2026-05-04
started:
completed:
---

## Objective

Fix `yaml_array_append` in `agent/scripts/acp.yaml-parser.sh` so that appending to an array created via `yaml_set ".path" "[]"` correctly stores and returns the appended value.

## Context

Test Group 20 in `tests/acp.yaml-parser.test.sh` fails with:

```
✓ Array ops: yaml_set creates array node for []
✗ Array ops: append to empty array works
  Expected to contain: production
  Actual:              :
```

Steps to reproduce:
```bash
yaml_parse file.yaml
yaml_set ".project.tags" "[]"
yaml_write file.yaml
yaml_parse file.yaml
yaml_array_append ".project.tags" "production"
yaml_write file.yaml
yaml_parse file.yaml
result=$(yaml_query ".project.tags")
# result is ":" instead of "production"

<!-- @acp.meta.task
topic: result, is, instead, of, production
description: Fix yaml_array_append to empty array returns ':' instead of value
milestone: M27
status: draft
updated: 2026-05-04
@acp.meta.end -->


```

Root cause: `yaml_set "[]"` creates an array node in the AST with type `array` but empty value. `yaml_array_append` likely inserts a child node, but `yaml_query` on an array parent doesn't traverse children when the parent value is empty/null — it returns the parent value (which is `:` from the AST line format `key|type|value`).

## Implementation

1. **Diagnose**: Trace `yaml_array_append` in `acp.yaml-parser.sh` — check how it adds child nodes and how `yaml_query` renders array results.
2. **Fix**: Ensure that after `yaml_array_append`, the written YAML and re-parsed AST correctly represent `tags:\n  - production`.
3. **Verify**: All 4 sub-tests in Group 20 pass (append to empty, second append, scalar-to-array conversion, multi-item query).

## Expected Output

### Files Modified
- `agent/scripts/acp.yaml-parser.sh` — fix `yaml_array_append` (and possibly `yaml_write` or `yaml_query`) for empty array parent nodes

## Verification
- [ ] `bash tests/acp.yaml-parser.test.sh 2>&1 | grep -E "✗|✓" | tail -20` shows no ✗ failures
- [ ] `bash tests/acp.yaml-parser.test.sh 2>&1 | grep "Array ops"` shows 4 ✓ lines

## User-Observable Acceptance
`bash tests/acp.yaml-parser.test.sh` completes with 0 failures (all tests pass).
