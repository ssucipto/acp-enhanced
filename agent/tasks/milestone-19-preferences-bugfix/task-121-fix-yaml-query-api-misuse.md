# Task 121: Fix yaml_query API Misuse and Flat-Dot Key Format Incompatibility

<!-- @acp.meta.task
topic: fix, yamlquery, api, misuse, and, flat-dot, key, format, incompatibility
description: Task 121: Fix yaml_query API Misuse and Flat-Dot Key Format Incompatibility
milestone: M19
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Task ID**: task-121  
**Milestone**: M19 — Preferences System Bug Fix Sprint  
**Priority**: Critical  
**Estimated Hours**: 3–4  
**Bugs Fixed**: BUG-1, BUG-4  
**File**: `agent/scripts/acp.preferences.sh`  

---

## Objective

Fix two interlocking bugs that prevent **all preference resolution** in
`acp.preferences.sh` from ever returning a value:

1. **BUG-1**: Every YAML lookup calls `yaml_query(file, path)` but `yaml_query` accepts
   only one argument — the dot-path query against the *already-loaded* AST. The correct
   function is `yaml_get(file, path)`, which auto-loads the file first.
2. **BUG-4**: Preference files store keys in flat-dot format
   (`plan.draft.create_mode: incremental`) but `yaml_get` traverses each dot-segment as
   a nested map key. `acp.plan.draft.create_mode` is traversed as four levels
   (`acp → plan → draft → create_mode`) — no match because the physical key is the
   literal string `"plan.draft.create_mode"` at depth 1 under `acp`.

These two bugs combine to ensure `get_preference()` **always returns empty and exits 1**,
which every caller suppresses with `|| true`. The entire preferences system silently
produces no output.

---

## Context

### The yaml-parser API

`acp.yaml-parser.sh` exposes two query functions:

```bash
# Requires prior yaml_parse call; takes ONE argument (the path):
yaml_query ".acp.plan.draft.create_mode"

# Auto-loads file, then queries; takes TWO arguments:
yaml_get "agent/preferences/acp.default.yaml" "acp.plan.draft.create_mode"
```

All 12 calls in `acp.preferences.sh` pass two arguments to `yaml_query`:
```bash
# WRONG — file path treated as query, actual path discarded:
value="$(yaml_query "$project_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
```

### The key format conflict

Current preference file format (flat-dot keys):
```yaml
# agent/preferences/acp.default.yaml
acp:
  plan.draft.create_mode: incremental   # key has dots in it
  task.create.granularity: 5
```

`yaml_get` with path `"acp.plan.draft.create_mode"` splits on `.` and traverses:
- Level 0: find child `"acp"` ✓
- Level 1: find child `"plan"` ✗ (no such child — the child is named `"plan.draft.create_mode"`)

**Fix**: Migrate preference files to nested YAML format, matching the structure already
used in `acp.configurables.yaml`:
```yaml
# agent/preferences/acp.default.yaml  (nested format)
acp:
  plan:
    draft:
      create_mode: incremental
  task:
    create:
      granularity: 5
```

With nested format, the path `"acp.plan.draft.create_mode"` traverses four clean levels
and resolves correctly.

---

## Steps

### Step 1 — Replace all `yaml_query` calls with `yaml_get`

In `acp.preferences.sh`, locate every call matching:
```
yaml_query "$<file_var>" "${namespace}.${pref_path}"
```
and replace with:
```
yaml_get "$<file_var>" "${namespace}.${pref_path}"
```

Affected functions (all calls within each):
- `get_preference()` — 4 calls (project, workspace, user, configurables default)
- `get_preference_source()` — 4 calls (same four levels)
- `validate_preference()` — 2 calls (`${namespace}.${pref_path}.type` and min/max fields)

**Before** (example from `get_preference`):
```bash
value="$(yaml_query "$project_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
```

**After**:
```bash
value="$(yaml_get "$project_file" "${namespace}.${pref_path}" 2>/dev/null || true)"
```

For the configurables default lookup, the path suffix is `.default` — keep that:
```bash
value="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.default" 2>/dev/null || true)"
```

For `validate_preference` type lookup:
```bash
# Before:
pref_type="$(yaml_query "$configurables_file" "${namespace}.${pref_path}.type" 2>/dev/null || true)"

# After:
pref_type="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.type" 2>/dev/null || true)"
```

### Step 2 — Migrate preference file examples to nested format

Update every `.yaml` example embedded in command docs, test fixtures, and design docs
that shows the flat-dot format. The canonical format is now nested, matching configurables.

Update `agent/design/preferences-best-practices.md` to show nested format examples.

Update `acp.preferences.sh` inline comments and help text to document the nested format.

### Step 3 — Update test fixtures

The test files in `tests/acp.preferences.test.sh`, `tests/acp.preferences-validate.test.sh`,
and `e2e/acp.plan-with-preferences.test.sh` create preference fixture files using the
flat-dot format in their `setup_fixtures()` functions.

Update the heredoc blocks in each `setup_fixtures()` to use nested YAML:

**Before** (in test fixture):
```yaml
testns:
  task.granularity: 7
  validation.auto_fix: true
```

**After**:
```yaml
testns:
  task:
    granularity: 7
  validation:
    auto_fix: true
```

Also update the query paths passed to `get_preference` in each test call — paths must
match the nested structure: `"task.granularity"` traverses `task → granularity`.

### Step 4 — Update `get_preference_with_preset` similarly

`get_preference_with_preset()` calls `yaml_get` (which is the correct function), but the
preset file format also uses flat-dot keys. Update the preset file examples in:
- `agent/preferences/*.yaml` examples in docs
- Fixture files in `tests/acp.preferences-preset.test.sh`

### Step 5 — Smoke-test the fix

Manually trace the execution path for a single resolution:

1. Create `agent/preferences/acp.default.yaml` with nested format
2. Call `./agent/scripts/acp.preferences.sh get acp plan.draft.create_mode`
3. Verify it outputs the correct value and exits 0
4. Remove the file, call again — verify it falls through to configurables default

---

## Verification

- [ ] `get_preference "acp" "plan.draft.create_mode"` returns the project-level value
- [ ] `get_preference "acp" "task.create.granularity"` returns workspace value when project absent
- [ ] `get_preference "acp" "output.verbosity.level"` returns `"normal"` (from configurables default)
- [ ] `get_preference "acp" "totally.unknown.key"` returns empty and exits 1
- [ ] `get_preference_source "acp" "plan.draft.create_mode"` returns `"project"` when set at project level
- [ ] No `yaml_query` calls remain in `acp.preferences.sh` (use `grep yaml_query agent/scripts/acp.preferences.sh` — should return nothing)
- [ ] All test fixture heredocs use nested YAML format

---

## Files Modified

- `agent/scripts/acp.preferences.sh` — replace all `yaml_query` calls
- `tests/acp.preferences.test.sh` — update fixture format
- `tests/acp.preferences-validate.test.sh` — update fixture format
- `tests/acp.preferences-preset.test.sh` — update fixture format
- `e2e/acp.plan-with-preferences.test.sh` — update fixture format
- `agent/design/preferences-best-practices.md` — update format examples

---

## Dependencies

None — this is the foundational fix. All other M19 tasks depend on this task being
complete first.
