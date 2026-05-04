---
id: route-009
title: Fix set_preference round-trip + migrate production pref files
task_type: bash-script-fix
milestone: M26-audit
complexity: medium
executor: deepseek-v4-pro
context_required:
  - agent/scripts/acp.preferences.sh
  - agent/preferences/acp.default.yaml
  - agent/memory/lessons.md
files_affected:
  - agent/scripts/acp.preferences.sh
  - agent/preferences/acp.default.yaml
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
---

## Task: Fix set_preference round-trip + migrate production pref files

## Problem

Two related known bugs (priority:high in lessons.md):

### Bug A — set_preference() write path broken
`set_preference()` writes flat-dot format (e.g. `plan.draft.create_mode: val` indented
under a namespace block). `yaml_get` cannot traverse flat-dot keys — it expects nested
YAML. `_flat_dot_get()` fallback was added to the read path, but this means:
- `set_preference("acp", "plan.draft.create_mode", "guided")` writes flat-dot
- `get_preference("acp", "plan.draft.create_mode")` reads via `_flat_dot_get` fallback
- Works, but only because of the fallback — not via proper yaml_get traversal
- `yaml_get` path tests still fail for any value written by `set_preference()`

### Bug B — Production preference file in flat-dot format
`agent/preferences/acp.default.yaml` uses flat-dot format (`plan.draft.create_mode: val`).
Test fixtures were migrated to nested YAML in a prior milestone, but this production file
was not. It should match the nested YAML format that `yaml_get` can traverse natively.

## Acceptance Criteria

- [ ] `set_preference()` writes nested YAML (e.g. `plan:\n  draft:\n    create_mode: val`)
- [ ] `get_preference()` reads written values via `yaml_get` without needing `_flat_dot_get`
- [ ] `_flat_dot_get()` can be retained as a migration compatibility layer or removed
- [ ] `agent/preferences/acp.default.yaml` converted to nested YAML format
- [ ] Existing preference e2e tests still pass after the fix
- [ ] Round-trip test: `set_preference` → `get_preference` returns correct value

## Notes

- See agent/memory/lessons.md entries dated 2026-05-01 for full context
- Only `acp.default.yaml` confirmed in `agent/preferences/` — verify no other preset files
  before migrating (check `ls agent/preferences/`)
