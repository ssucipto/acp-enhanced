# Task 122: Fix generate_preferences Enumeration and Option Validation

<!-- @acp.meta.task
topic: fix, generatepreferences, enumeration, and, option, validation
description: Task 122: Fix generate_preferences Enumeration and Option Validation
milestone: M19
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Task ID**: task-122  
**Milestone**: M19 — Preferences System Bug Fix Sprint  
**Priority**: Critical  
**Estimated Hours**: 3–4  
**Bugs Fixed**: BUG-2, BUG-3  
**Files**: `agent/scripts/acp.preferences.sh`  

---

## Objective

Fix two bugs that make `generate_preferences` always output an empty namespace block
and `validate_preference` always reject valid string values:

1. **BUG-2**: `generate_preferences` calls `yaml_get_array(configurables_file, "${ns}.configurables")`.
   No `configurables` array exists in `acp.configurables.yaml` — the structure is a
   nested map. Additionally, `yaml_get_array` returns an **integer count** of child
   nodes, not the elements. The function then iterates over that integer as if it were a
   newline-separated list of key names, producing nothing.

2. **BUG-3**: `validate_preference` uses `yaml_get_array` to fetch the options list
   (same API misunderstanding), gets back a count like `"4"`, runs through the while
   loop once with `opt_line="4"`, finds no `value:` field via `grep -oP`, and concludes
   `found=false` — incorrectly failing every valid option. Additionally, `grep -oP` is a
   GNU-only flag unavailable on macOS/BSD.

---

## Context

### yaml_get_array returns a count, not elements

From `acp.yaml-parser.sh`:
```bash
yaml_get_array() {
    ...
    echo "$children" | tr ',' '\n' | wc -l   # Returns INTEGER count
}
```

`generate_preferences` and `validate_preference` both treat this integer as a
newline-delimited list of preference keys or option entries. This is the wrong API
for iteration.

**Correct approach**: Use `yaml_get` with indexed path notation to iterate by index.
The YAML parser supports array element access via `path[N]`:
```bash
yaml_get "file.yaml" "acp.plan.draft.create_mode.options[0].value"
```

### generate_preferences: no `configurables` array

`acp.configurables.yaml` does **not** have a structure like:
```yaml
acp:
  configurables:
    - plan.draft.create_mode
    - task.create.granularity
```

It uses a nested map. To enumerate all preference keys from the configurables file,
the implementation must either:
- Walk the configurables map recursively and collect leaf `id` values, or
- Use the `id` field present on each preference entry (e.g. `'plan.draft.create_mode'`)

The simplest reliable approach: read the `id` field from each known configurable using
direct path access, using the list of known preference paths (which the configurables
schema already defines via the `id` fields).

### Correct iteration pattern

```bash
# Get count of options for a preference:
count="$(yaml_get_array "$configurables_file" "${namespace}.${pref_path}.options")"

# Iterate by index to get each option's value field:
local i=0
while [ "$i" -lt "$count" ]; do
  local opt_val
  opt_val="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.options[${i}].value" 2>/dev/null || true)"
  [[ "$opt_val" == "$value" ]] && found=true && break
  i=$((i + 1))
done
```

---

## Steps

### Step 1 — Rewrite `generate_preferences` to enumerate from configurables

The function must:
1. Parse the configurables file
2. Collect all preference `id` values from the nested map structure
3. For each id, call `get_preference` to resolve the effective value
4. Emit the result in the requested format

**Implementation approach** — use a known-paths array via `yaml_get`:

The configurables file structure (nested map) does not have a flat list of paths.
The most reliable approach is to use the YAML parser to walk the configurables
structure and collect `id` fields. Since `yaml_get_array` returns counts, use it to
count children, then iterate:

```bash
generate_preferences() {
  local namespace="$1"
  local format="${2:-yaml}"
  local configurables_file
  configurables_file="$(_pref_configurables_file "$namespace")"

  if [[ ! -f "$configurables_file" ]]; then
    echo "Error: Configurables not found: $configurables_file" >&2
    return 1
  fi

  # Load the configurables file once
  yaml_parse "$configurables_file" 2>/dev/null || {
    echo "Error: Failed to parse configurables" >&2; return 1
  }

  # Collect preference IDs by finding all nodes that have an 'id' field.
  # We do this by iterating over known top-level category keys under the namespace,
  # then recursively collecting 'id' values.
  # Simpler alternative: maintain an explicit list as part of the configurables.
  #
  # RECOMMENDED approach (minimal change): add a top-level index array to
  # acp.configurables.yaml:
  #
  #   acp:
  #     _index:
  #       - plan.draft.create_mode
  #       - plan.batch.auto_confirm
  #       - task.create.granularity
  #       ...
  #
  # Then yaml_get_array gives the count, and yaml_get with [N] gives each id.

  local count
  count="$(yaml_get_array "$configurables_file" "${namespace}._index" 2>/dev/null || echo 0)"

  if [[ "$count" -eq 0 ]]; then
    if [[ "$format" == "yaml" ]]; then echo "${namespace}: {}"; else echo "{\"${namespace}\": {}}"; fi
    return 0
  fi

  # Emit output
  if [[ "$format" == "yaml" ]]; then
    echo "${namespace}:"
    local i=0
    while [[ "$i" -lt "$count" ]]; do
      local pref_id
      pref_id="$(yaml_get "$configurables_file" "${namespace}._index[${i}]" 2>/dev/null || true)"
      [[ -z "$pref_id" ]] && { i=$((i+1)); continue; }
      local val
      val="$(get_preference "$namespace" "$pref_id" 2>/dev/null || echo "")"
      echo "  ${pref_id}: '${val}'"
      i=$((i + 1))
    done
  elif [[ "$format" == "json" ]]; then
    echo "{"; echo "  \"${namespace}\": {"
    local first=true i=0
    while [[ "$i" -lt "$count" ]]; do
      local pref_id
      pref_id="$(yaml_get "$configurables_file" "${namespace}._index[${i}]" 2>/dev/null || true)"
      [[ -z "$pref_id" ]] && { i=$((i+1)); continue; }
      local val
      val="$(get_preference "$namespace" "$pref_id" 2>/dev/null || echo "")"
      [[ "$first" == "true" ]] && first=false || echo ","
      printf '    "%s": "%s"' "$pref_id" "$val"
      i=$((i + 1))
    done
    echo ""; echo "  }"; echo "}"
  fi
}
```

### Step 2 — Add `_index` array to `agent/configurables/acp.configurables.yaml`

At the top of the `acp:` block, add an `_index` array listing every preference `id`
in the same order as the map entries. This makes enumeration O(N) without requiring
recursive map walking.

```yaml
acp:
  _index:
    - plan.draft.create_mode
    - plan.batch.auto_confirm
    - task.create.granularity
    - task.create.auto_number
    - validation.auto_fix.enabled
    - validation.strict_mode.enabled
    - output.verbosity.level
    - git.auto_commit.enabled
```

This is a non-breaking addition. Existing code that reads specific preference entries
via direct path is unaffected.

### Step 3 — Rewrite option validation in `validate_preference`

Replace the `grep -oP` approach with index-based iteration over the options array:

**Before (broken)**:
```bash
options_raw="$(yaml_get_array "$configurables_file" "${namespace}.${pref_path}.options" 2>/dev/null || true)"
if [[ -n "$options_raw" ]]; then
    local found=false
    while IFS= read -r opt_line; do
        [[ -z "$opt_line" ]] && continue
        local opt_val
        opt_val="$(echo "$opt_line" | grep -oP 'value:\s*\K\S+' || true)"
        [[ "$opt_val" == "$value" ]] && found=true && break
    done <<< "$options_raw"
    if [[ "$found" == "false" ]]; then
        echo "Error: Invalid value '${value}' for '${pref_path}'" >&2
        return 1
    fi
fi
```

**After (correct)**:
```bash
local opt_count
opt_count="$(yaml_get_array "$configurables_file" "${namespace}.${pref_path}.options" 2>/dev/null || echo 0)"
if [[ "$opt_count" -gt 0 ]]; then
    local found=false
    local i=0
    while [[ "$i" -lt "$opt_count" ]]; do
        local opt_val
        opt_val="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.options[${i}].value" 2>/dev/null || true)"
        [[ "$opt_val" == "$value" ]] && found=true && break
        i=$((i + 1))
    done
    if [[ "$found" == "false" ]]; then
        echo "Error: Invalid value '${value}' for '${pref_path}' (type: string with options)" >&2
        return 1
    fi
fi
```

Note: `yaml_get_array` is called with the file AND path — check that `yaml_parse` has
been called first for this file, or convert to `yaml_get_array` after a `yaml_parse` call.
The cleanest fix is to call `yaml_parse "$configurables_file"` at the top of
`validate_preference` before any queries, then use `yaml_query` for all sub-queries.

### Step 4 — Handle `yaml_get_array` file loading

`yaml_get_array(file, path)` calls `yaml_parse` internally only if
`YAML_CURRENT_FILE != file`. But `validate_preference` makes multiple `yaml_get` calls
that each reload the AST. A single `yaml_parse "$configurables_file"` at the top of
the function followed by `yaml_query`-based calls is more efficient and avoids
redundant reloads.

---

## Verification

- [ ] `./acp.preferences.sh generate acp yaml` outputs all 8 preferences, not `acp: {}`
- [ ] `./acp.preferences.sh validate acp plan.draft.create_mode structured` exits 0
- [ ] `./acp.preferences.sh validate acp plan.draft.create_mode unstructured` exits 0
- [ ] `./acp.preferences.sh validate acp plan.draft.create_mode guided` exits 0
- [ ] `./acp.preferences.sh validate acp plan.draft.create_mode contextual` exits 0
- [ ] `./acp.preferences.sh validate acp plan.draft.create_mode invalid_value` exits 1 with error message
- [ ] `./acp.preferences.sh validate acp task.create.granularity 5` exits 0
- [ ] `./acp.preferences.sh validate acp task.create.granularity 0` exits 1 (below minimum)
- [ ] `./acp.preferences.sh validate acp task.create.granularity 11` exits 1 (above maximum)
- [ ] `./acp.preferences.sh validate acp validation.auto_fix.enabled true` exits 0
- [ ] `./acp.preferences.sh validate acp validation.auto_fix.enabled maybe` exits 1
- [ ] No `grep -oP` remains in `acp.preferences.sh` (`grep -n 'grep -oP' agent/scripts/acp.preferences.sh` returns nothing)
- [ ] `acp.configurables.yaml` contains `_index` array with 8 entries

---

## Files Modified

- `agent/scripts/acp.preferences.sh` — rewrite `generate_preferences`, rewrite option check in `validate_preference`
- `agent/configurables/acp.configurables.yaml` — add `_index` array

---

## Dependencies

- task-121 must be complete (yaml_get foundation fix)
