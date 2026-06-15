# Task 125: Re-Validate M6 Test Suite End-to-End

<!-- @acp.meta.task
topic: re-validate, m6, test, suite, end-to-end
description: Task 125: Re-Validate M6 Test Suite End-to-End
milestone: M19
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Task ID**: task-125  
**Milestone**: M19 — Preferences System Bug Fix Sprint  
**Priority**: High  
**Estimated Hours**: 2–3  
**Files**: `tests/acp.preferences*.test.sh`, `e2e/acp.plan-with-preferences.test.sh`  

---

## Objective

After completing tasks 121–124, run the full M6 test suite to confirm all preferences
functionality works end-to-end and no regressions have been introduced in the core
scripts (`acp.yaml-parser.sh`, `acp.common.sh`).

---

## Context

The M6 test suite was written correctly — the test logic, fixture setup, assertion
calls, and coverage are all sound. The tests were non-passing not because of test
authorship errors but because the implementation they test was broken.

After the fixes in tasks 121–124:
- `acp.preferences.test.sh` — tests `get_preference()`, `has_preference()`, `get_preference_or()`, `get_preference_source()`, `generate_preferences()`
- `acp.preferences-validate.test.sh` — tests `validate_preference()` for all three types
- `acp.preferences-preset.test.sh` — tests `get_preference_with_preset()`, `load_preset()`, `list_presets()`
- `e2e/acp.plan-with-preferences.test.sh` — integration tests simulating `@acp.plan` preference loading

Additionally, the existing YAML parser tests (`tests/acp.yaml-parser.test.sh`) and
project registry tests (`tests/acp.project-registry.test.sh`) must continue to pass
(regression check).

---

## Steps

### Step 1 — Verify test fixture format alignment

The fixture files created in `setup_fixtures()` across all test files must use nested
YAML format (updated in task-121). Before running tests, visually inspect the heredoc
blocks in:
- `tests/acp.preferences.test.sh` — `setup_fixtures()` sections
- `tests/acp.preferences-validate.test.sh` — `setup_fixtures()` sections
- `tests/acp.preferences-preset.test.sh` — `setup_fixtures()` sections
- `e2e/acp.plan-with-preferences.test.sh` — `setup_fixtures()` sections

Confirm all fixture preference files use nested YAML:
```yaml
# Correct (nested):
acp:
  plan:
    draft:
      create_mode: contextual

# Wrong (flat-dot — must not appear):
acp:
  plan.draft.create_mode: contextual
```

### Step 2 — Run the preferences unit test suite

```bash
bash tests/acp.preferences.test.sh
```

Expected: All assertions pass. Key assertions to watch:
- `get_preference "testns" "plan.draft.create_mode"` returns `"incremental"` (project wins)
- `get_preference "testns" "task.create.granularity"` returns `"7"` (workspace wins)
- `get_preference "testns" "validation.auto_fix.enabled"` returns `"true"` (user fallback)
- `get_preference "testns" "output.verbosity.level"` returns `"normal"` (configurables default)
- `has_preference "testns" "plan.draft.create_mode"` exits 0
- `has_preference "testns" "totally.missing.key"` exits non-zero
- `get_preference_source "testns" "plan.draft.create_mode"` returns `"project"`
- `get_preference_source "testns" "nonexistent"` returns `"none"` AND exits 0 (post BUG-10 fix)
- `generate_preferences "testns" "yaml"` outputs a non-empty YAML block

### Step 3 — Run the validate_preference test suite

```bash
bash tests/acp.preferences-validate.test.sh
```

Expected: All assertions pass. Key assertions:
- `validate_preference "acp" "plan.draft.create_mode" "structured"` exits 0
- `validate_preference "acp" "plan.draft.create_mode" "invalid_mode"` exits 1 with error message to stderr
- `validate_preference "acp" "task.create.granularity" "5"` exits 0
- `validate_preference "acp" "task.create.granularity" "0"` exits 1 (below min=1)
- `validate_preference "acp" "task.create.granularity" "11"` exits 1 (above max=10)
- `validate_preference "acp" "validation.auto_fix.enabled" "true"` exits 0
- `validate_preference "acp" "validation.auto_fix.enabled" "maybe"` exits 1

### Step 4 — Run the preset test suite

```bash
bash tests/acp.preferences-preset.test.sh
```

Expected: All assertions pass. Key assertions:
- `get_preference_with_preset "acp" "plan.draft.create_mode" "batch-planning"` returns preset value
- `get_preference_with_preset "acp" "plan.draft.create_mode" ""` falls back to `get_preference`
- `load_preset "acp" "batch-planning"` returns file path and exits 0
- `load_preset "acp" "nonexistent-preset"` exits 1 with error message

### Step 5 — Run the E2E plan-with-preferences test

```bash
bash e2e/acp.plan-with-preferences.test.sh
```

Expected: All 4 integration scenarios pass:
1. `@acp.plan` respects project-level preference — `contextual` returned
2. Preset `batch-planning` overrides project preference — `contextual` and `true` returned
3. CLI override wins over preset — override value returned, preference files unchanged
4. Missing preset fails gracefully — exits 1 with error, no crash

### Step 6 — Run regression suite for YAML parser and project registry

```bash
bash tests/acp.yaml-parser.test.sh
bash tests/acp.project-registry.test.sh
bash tests/yaml-array-operations.test.sh
```

All three must pass without changes — they test code that was not modified in M19.
If any failures appear, triage before proceeding.

### Step 7 — Run full E2E suite

```bash
bash run-e2e-tests.sh
```

All existing E2E tests (16 files) must continue to pass. The preference-related fixes
must not have introduced regressions in package management, project management, or
session commands.

### Step 8 — Check for temp file leaks

After running all tests:
```bash
ls /tmp/tmp.* 2>/dev/null | wc -l
```
Should return `0` (or close to it). The `trap cleanup_ast EXIT` added in task-123
should prevent all leaks.

---

## Verification

- [ ] `bash tests/acp.preferences.test.sh` — all tests PASS, 0 failures
- [ ] `bash tests/acp.preferences-validate.test.sh` — all tests PASS, 0 failures
- [ ] `bash tests/acp.preferences-preset.test.sh` — all tests PASS, 0 failures
- [ ] `bash e2e/acp.plan-with-preferences.test.sh` — all 4 integration tests PASS
- [ ] `bash tests/acp.yaml-parser.test.sh` — no regressions
- [ ] `bash tests/acp.project-registry.test.sh` — no regressions
- [ ] `bash tests/yaml-array-operations.test.sh` — no regressions
- [ ] `bash run-e2e-tests.sh` — all 16 E2E tests PASS
- [ ] No orphaned `/tmp/tmp.*` files after test run
- [ ] `./acp.preferences.sh generate acp yaml` on a real repo outputs all 8 preferences

---

## Test Failure Triage Guide

| Symptom | Likely Cause | Check |
|---------|-------------|-------|
| `get_preference` returns empty | task-121 incomplete — `yaml_query` still called | `grep yaml_query acp.preferences.sh` |
| `validate_preference` rejects valid string | task-122 incomplete — options count not iterated | Check `opt_count` / index loop |
| Range check always passes (allows `0`) | task-123 BUG-6 — `bc` not installed + fallback to 0 | Verify bash arithmetic used |
| `get_preference_source` causes script exit | task-124 BUG-10 — still `return 1` for none | Check last `return` in function |
| Temp files persist after tests | task-123 BUG-8 — trap not in `init_ast` | `grep 'trap.*cleanup_ast' acp.yaml-parser.sh` |
| Fixtures not resolving (nested format) | task-121 Step 3 incomplete — flat-dot still in fixtures | Review `setup_fixtures()` heredocs |

---

## Files Modified

None — this task is validation only. If test failures are found, the fix belongs in
tasks 121–124. Append a note to the failing task rather than fixing code here.

---

## Dependencies

- task-121, task-122, task-123, task-124 must all be complete before running this task
