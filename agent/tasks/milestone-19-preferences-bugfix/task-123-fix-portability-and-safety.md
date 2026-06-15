# Task 123: Fix Portability and Safety Issues

<!-- @acp.meta.task
topic: fix, portability, and, safety, issues
description: Task 123: Fix Portability and Safety Issues
milestone: M19
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Task ID**: task-123  
**Milestone**: M19 — Preferences System Bug Fix Sprint  
**Priority**: High  
**Estimated Hours**: 2–3  
**Bugs Fixed**: BUG-5, BUG-6, BUG-7, BUG-8, BUG-12  
**Files**: `acp.preferences.sh`, `acp.yaml-parser.sh`, `acp.common.sh`  

---

## Objective

Fix five portability and safety issues:

| Bug | Severity | Summary |
|-----|----------|---------|
| BUG-5 | Moderate | `set_preference()` has dead `indent_key` variable + YAML injection via unescaped sed |
| BUG-6 | Moderate | `validate_preference` number check uses `bc` — not installed on all systems |
| BUG-7 | Moderate | `acp.common.sh` is `#!/bin/sh` but uses bash arrays and `${BASH_SOURCE[0]}` |
| BUG-8 | Minor | `acp.yaml-parser.sh` has no `trap cleanup_ast EXIT` — leaks temp files |
| BUG-12 | Minor | Duplicate `_sed_i` / `_yaml_sed_i` in `acp.common.sh` and `acp.yaml-parser.sh` |

---

## Context

### BUG-5: Dead variable and sed injection in `set_preference`

```bash
set_preference() {
  ...
  local indent_key
  indent_key="$(echo "$pref_path" | sed 's/\./__/g')"  # assigned but NEVER used
  ...
  # $value is embedded unescaped in sed replacement — '|' and '&' break this:
  sed -i.bak "s|${escaped_key}.*|${yaml_line}|" "$target_file"
}
```

A value like `"foo|bar"` causes sed to interpret the `|` as a delimiter in the
substitution expression, breaking the replacement or producing garbage output.

**Fix**: Escape the replacement string using `&` → `\&` substitution in the value,
or use an awk-based replacement that is not delimiter-sensitive.

### BUG-6: `bc` dependency for number range validation

```bash
if [[ -n "$min" ]] && (( $(echo "$value < $min" | bc -l 2>/dev/null || echo 0) )); then
```

`bc` is absent from Alpine Linux, many Docker base images, and some CI environments.
When `bc` is missing, `2>/dev/null` suppresses the error and `|| echo 0` makes the
comparison always evaluate to `0` (false), silently skipping the range check entirely.

**Fix**: Use bash arithmetic `(( ))` which handles integer comparisons natively:
```bash
if [[ -n "$min" ]] && (( value < min )); then
```
Floating point preferences are not currently defined in the schema (all number
preferences are integers). If float support is needed in future, add a note in the
schema and handle separately. For now, integer arithmetic is sufficient and has
zero external dependencies.

### BUG-7: `#!/bin/sh` shebang with bash-specific code in `acp.common.sh`

`acp.common.sh` declares `#!/bin/sh` at line 1 and its header comment says
"POSIX-compliant for maximum portability." However, `source_yaml_parser()` uses:
- Bash arrays: `local parser_locations=(...)`
- `${BASH_SOURCE[0]}` — a bash-only variable
- `for parser_path in "${parser_locations[@]}"`

If the file is invoked as `sh acp.common.sh`, bash arrays cause a syntax error.
When **sourced into bash** (which is the common path), it works fine — but the
shebang is misleading and the POSIX claim is false.

**Fix**: Change the shebang to `#!/usr/bin/env bash`. Remove the "POSIX-compliant"
claim from the header comment. This is consistent with how all other ACP scripts
declare their interpreter.

Alternative: Rewrite `source_yaml_parser()` to use POSIX sh syntax. However, since
`acp.common.sh` is always sourced into bash by its callers, the shebang fix is
simpler and lower risk.

### BUG-8: No EXIT trap for AST temp file cleanup

`acp.yaml-parser.sh` creates a temp file via `mktemp` in `init_ast()`:
```bash
init_ast() {
    AST_FILE=$(mktemp)
    echo "0|map||root|-1|" > "$AST_FILE"
}
```

`cleanup_ast()` exists but is never registered with `trap`. Scripts using
`set -euo pipefail` (including `acp.preferences.sh`) exit immediately on any
unexpected failure, skipping any explicit `cleanup_ast` calls in the code path,
leaving the temp file in `/tmp`.

**Fix**: Register the trap at the top of each script that calls `init_ast`:
```bash
# In acp.preferences.sh, after sourcing the parser:
trap 'cleanup_ast' EXIT
```

However, `acp.preferences.sh` is also used as a **sourced library** — setting a
global `trap EXIT` in sourced code affects the parent script's exit handler, which
is unsafe.

**Better fix**: Register the trap inside `init_ast` itself:
```bash
init_ast() {
    AST_FILE=$(mktemp)
    echo "0|map||root|-1|" > "$AST_FILE"
    trap 'cleanup_ast' EXIT  # register cleanup at init time
}
```

This is safe because it's always called in the context of a script that is about
to use the AST, whether that script is `acp.preferences.sh` run directly or any
other caller.

**Note**: Nested calls to `init_ast` (which replace `AST_FILE`) would leave the
previous temp file orphaned. Add a cleanup of the old file before creating a new one:
```bash
init_ast() {
    cleanup_ast  # remove prior temp file if any
    AST_FILE=$(mktemp)
    echo "0|map||root|-1|" > "$AST_FILE"
    trap 'cleanup_ast' EXIT
}
```

### BUG-12: Duplicate `_sed_i` / `_yaml_sed_i`

`acp.common.sh` defines `_sed_i()` and `acp.yaml-parser.sh` defines `_yaml_sed_i()`.
Both functions are identical wrappers for the macOS/GNU sed difference:
```bash
# acp.common.sh:
_sed_i() {
    if [ "$(uname)" = "Darwin" ]; then sed -i '' "$@"; else sed -i "$@"; fi
}

# acp.yaml-parser.sh (same logic, different name):
_yaml_sed_i() {
    if [ "$(uname)" = "Darwin" ]; then sed -i '' "$@"; else sed -i "$@"; fi
}
```

When both files are sourced (which they always are in `acp.preferences.sh`), both
functions exist. `acp.yaml-parser.sh` calls `_yaml_sed_i`, never `_sed_i`.

**Fix**: Have `acp.yaml-parser.sh` delegate `_yaml_sed_i` to `_sed_i` when available:
```bash
_yaml_sed_i() {
    if command -v _sed_i >/dev/null 2>&1; then
        _sed_i "$@"
    elif [ "$(uname)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}
```

This preserves backward compatibility (yaml-parser still works standalone) while
eliminating the duplication when loaded alongside `acp.common.sh`.

---

## Steps

### Step 1 — Fix `set_preference` dead variable and sed injection (BUG-5)

1. Remove the unused `indent_key` variable entirely.
2. Replace the sed-based value replacement with an awk-based approach that is
   immune to delimiter injection:

```bash
# Replace the sed line:
sed -i.bak "s|${escaped_key}.*|${yaml_line}|" "$target_file" && rm -f "${target_file}.bak"

# With awk (no injection risk — uses literal string match):
awk -v key="${yaml_key}" -v line="${yaml_line}" \
    'index($0, key) == 1 { $0 = line } { print }' \
    "$target_file" > "${target_file}.tmp" && mv "${target_file}.tmp" "$target_file"
```

### Step 2 — Replace `bc` with bash arithmetic (BUG-6)

In `validate_preference`, replace both bc-based comparisons:

```bash
# Before:
if [[ -n "$min" ]] && (( $(echo "$value < $min" | bc -l 2>/dev/null || echo 0) )); then
if [[ -n "$max" ]] && (( $(echo "$value > $max" | bc -l 2>/dev/null || echo 0) )); then

# After (bash integer arithmetic — no external dependency):
if [[ -n "$min" ]] && (( value < min )); then
if [[ -n "$max" ]] && (( value > max )); then
```

The regex check `^-?[0-9]+(\.[0-9]+)?$` already guards that `$value` is numeric
before these comparisons are reached. If the value is an integer (guaranteed by the
regex), bash arithmetic works correctly.

### Step 3 — Fix `acp.common.sh` shebang and header (BUG-7)

Change line 1:
```bash
# Before:
#!/bin/sh

# After:
#!/usr/bin/env bash
```

Update the header comment:
```bash
# Before:
# Common utilities for ACP scripts
# POSIX-compliant for maximum portability

# After:
# Common utilities for ACP scripts
# Requires bash 3.2+ (uses arrays and BASH_SOURCE)
```

### Step 4 — Add EXIT trap in `init_ast` (BUG-8)

In `acp.yaml-parser.sh`, update `init_ast()`:

```bash
init_ast() {
    cleanup_ast          # clean up any prior AST file
    AST_FILE=$(mktemp)
    echo "0|map||root|-1|" > "$AST_FILE"
    AST_ROOT_ID=0
    trap 'cleanup_ast' EXIT
}
```

### Step 5 — Consolidate duplicate sed helper (BUG-12)

In `acp.yaml-parser.sh`, replace the standalone `_yaml_sed_i` implementation with
a delegating wrapper:

```bash
_yaml_sed_i() {
    if declare -f _sed_i > /dev/null 2>&1; then
        _sed_i "$@"
    elif [ "$(uname)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}
```

---

## Verification

- [ ] `grep -n 'indent_key' agent/scripts/acp.preferences.sh` returns nothing
- [ ] `set_preference` with a value containing `|` does not corrupt the file
- [ ] `set_preference` with a value containing `&` does not corrupt the file
- [ ] `validate_preference acp task.create.granularity 0` exits 1 without needing `bc`
- [ ] `head -1 agent/scripts/acp.common.sh` returns `#!/usr/bin/env bash`
- [ ] `grep 'POSIX' agent/scripts/acp.common.sh` returns nothing (or updated comment)
- [ ] Running multiple `yaml_parse` calls in sequence leaves no orphaned temp files in `/tmp`
- [ ] `acp.yaml-parser.sh` sourced standalone: `_yaml_sed_i` works correctly
- [ ] `acp.yaml-parser.sh` sourced after `acp.common.sh`: `_yaml_sed_i` delegates to `_sed_i`

---

## Files Modified

- `agent/scripts/acp.preferences.sh` — `set_preference` (dead var, sed injection), `validate_preference` (bc removal)
- `agent/scripts/acp.yaml-parser.sh` — `init_ast` (cleanup + trap), `_yaml_sed_i` (delegation)
- `agent/scripts/acp.common.sh` — shebang + header comment

---

## Dependencies

- task-121 should be complete but these fixes are independently applicable
