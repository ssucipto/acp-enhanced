---
id: task-172
milestone: M33
title: Port acp.driver-yaml.sh (8 POSIX helpers, macOS-safe)
status: completed
priority: 2
complexity: medium
estimated_hours: 4
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-06
---

## Objective

Create `agent/scripts/acp.driver-yaml.sh` with 8 POSIX-portable helper functions for reading and querying `agent/driver.yaml`, compatible with macOS bash 3.2+ and Linux bash 4+.

## Context

Upstream implements `acp.driver-yaml.sh` with helpers that other scripts source to query driver configuration. ACP Enhanced's integration hooks in `acp.sync.md` and `acp.proceed.md` (task-174) will call these helpers.

**Hard macOS constraints** (non-negotiable):
- No `declare -A` associative arrays (bash 4+ only)
- No `mapfile` / `readarray` (bash 4+ only)
- `sed -i` requires `sed -i '' 's/...'` on macOS (BSD sed)
- Use `while IFS= read -r line` for line iteration
- Use `grep` + `awk` for field extraction, not `${!var}` indirect expansion
- Use `date` without `+%N` (nanoseconds not available in macOS `date`)

## Implementation

Create `agent/scripts/acp.driver-yaml.sh` with these 8 functions:

```bash
# driver_get <tool> [field]

<!-- @acp.meta.task
topic: driverget, tool, field
description: Port acp.driver-yaml.sh (8 POSIX helpers, macOS-safe)
milestone: M33
status: completed
updated: 2026-05-05
@acp.meta.end -->


# Returns driver config for a tool. If field specified, returns only that field's value.
# Returns empty string if driver.yaml doesn't exist or tool not configured.
driver_get() { ... }

# driver_list
# Lists all configured tool names, one per line
driver_list() { ... }

# driver_query <tool> <field>
# Returns specific field value for a tool driver
driver_query() { ... }

# driver_type <tool>
# Returns driver type (native|mcp|http|custom) for a tool, or 'native' if not configured
driver_type() { ... }

# driver_is_native <tool>
# Returns 0 (true) if tool uses native driver or driver.yaml doesn't exist
driver_is_native() { ... }

# driver_override <tool> <field> <value>
# Writes a field override to driver.yaml (POSIX-safe write)
driver_override() { ... }

# driver_validate
# Validates driver.yaml structure against required fields
# Returns 0 if valid, 1 with error message if not
driver_validate() { ... }

# driver_status
# Prints summary of configured drivers in human-readable format
driver_status() { ... }
```

Implementation approach: all functions parse YAML using `grep`/`awk` (same pattern as `acp.yaml-parser.sh`). No external deps.

Driver config is read from `"${DRIVER_YAML:-agent/driver.yaml}"` — path can be overridden via env var for testing.

## Expected Output

### Files Created
- `agent/scripts/acp.driver-yaml.sh`

## Verification
- [ ] `bash -n agent/scripts/acp.driver-yaml.sh` (syntax check passes)
- [ ] `shellcheck agent/scripts/acp.driver-yaml.sh` passes (or deviations are documented)
- [ ] `driver_is_native git` returns 0 when driver.yaml absent
- [ ] All 8 functions are defined
- [ ] No bash 4+ features used (`declare -A`, `mapfile`, `${!var}`)
- [ ] BSD sed compatibility: any `sed -i` uses `sed -i ''` form

## User-Observable Acceptance
`source agent/scripts/acp.driver-yaml.sh && driver_status` prints current driver configuration. `driver_is_native git` works correctly both with and without `agent/driver.yaml` present.
