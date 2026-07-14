# Milestone 19: Preferences System Bug Fix Sprint

**Status**: completed  
**Priority**: Critical  
**Estimated Duration**: 1–2 weeks  
**Created**: 2026-05-01  
**Milestone ID**: M19  

---

## Overview

A critical review of the project (conducted 2026-05-01) revealed that the **ACP Preferences System
(M6)**, while architecturally well-designed and fully documented, is **non-functional in
implementation**. All five preference resolution functions fail silently due to a fundamental API
misuse — the wrong YAML parser function is called throughout `acp.preferences.sh`. Additional bugs
compound the failure: option validation rejects all valid values, `generate_preferences` always
outputs an empty namespace block, and the flat-dot key format used in preference files is
structurally incompatible with the YAML parser's dot-path traversal.

This milestone fixes all identified bugs, validates that all M6 unit and integration tests pass,
and updates stale project metadata.

---

## Goals

1. Make `get_preference()`, `has_preference()`, `get_preference_or()`, `get_preference_source()`,
   and `generate_preferences()` function correctly end-to-end.
2. Make `validate_preference()` correctly validate all three types (string with options, number
   range, boolean).
3. Fix all portability issues that prevent the scripts from running on macOS.
4. Fix minor bugs that cause silent failures or misleading output.
5. Confirm all M6 test suites pass (unit + integration).

---

## Context

The preferences system was designed and implemented as M6 (tasks 37–44). It was marked
completed 2026-05-01. The critical review discovered that while the architecture, file layout,
configurables schema, command documentation, and test suite are all correct, **the
`acp.preferences.sh` implementation has systematic API usage errors** that prevent any preference
from ever resolving.

Root cause: `acp.yaml-parser.sh` defines two APIs:
- `yaml_query(path)` — queries the **currently-loaded** AST (requires prior `yaml_parse` call)
- `yaml_get(file, path)` — auto-loads the file into the AST, then queries

All calls in `acp.preferences.sh` pass `(file, path)` arguments to `yaml_query`, which accepts
only one argument. The file path is silently interpreted as the query path (always fails), and the
actual query path is ignored.

A secondary incompatibility: preference files store keys in flat-dot format (`plan.draft.create_mode`)
under a namespace block, but the parser traverses dot-separated path segments. A query for
`acp.plan.draft.create_mode` traverses `acp → plan → draft → create_mode`, not
`acp → plan.draft.create_mode`. This means even with the correct function, flat-dot keys cannot
be found. The fix is to adopt the same nested YAML structure used in `acp.configurables.yaml`.

---

## Deliverables

- Corrected `agent/scripts/acp.preferences.sh` — all functions working correctly
- Updated preference file format documentation and examples
- All M6 unit tests passing: `tests/acp.preferences.test.sh`, `tests/acp.preferences-validate.test.sh`, `tests/acp.preferences-preset.test.sh`
- E2E integration test passing: `e2e/acp.plan-with-preferences.test.sh`
- Minor fixes across: `acp.package-install.sh`, `acp.common.sh`, `acp.yaml-parser.sh`, `AGENT.md`

---

## Tasks

| ID       | Title                                          | Priority | Est. Hours |
|----------|------------------------------------------------|----------|------------|
| task-121 | Fix yaml_query API misuse and key format       | Critical | 3–4        |
| task-122 | Fix generate_preferences and option validation | Critical | 3–4        |
| task-123 | Fix portability and safety issues              | High     | 2–3        |
| task-124 | Fix minor bugs and stale metadata              | Normal   | 1–2        |
| task-125 | Re-validate M6 test suite end-to-end          | High     | 2–3        |

---

## Success Criteria

- [ ] `./agent/scripts/acp.preferences.sh get acp plan.draft.create_mode` returns the correct value
- [ ] `./agent/scripts/acp.preferences.sh generate acp yaml` outputs all 8 preferences with resolved values
- [ ] `./agent/scripts/acp.preferences.sh validate acp plan.draft.create_mode structured` exits 0
- [ ] `./agent/scripts/acp.preferences.sh validate acp plan.draft.create_mode invalid` exits 1 with error
- [ ] `bash tests/acp.preferences.test.sh` — all assertions pass
- [ ] `bash tests/acp.preferences-validate.test.sh` — all assertions pass
- [ ] `bash tests/acp.preferences-preset.test.sh` — all assertions pass
- [ ] `bash e2e/acp.plan-with-preferences.test.sh` — all assertions pass
- [ ] All scripts run cleanly on macOS (no `grep -oP`, no `date +%N`, no GNU-only sed)
- [ ] No temp file leaks under `/tmp` after any preference script exits
- [ ] `AGENT.md` version header reads `6.2.0`
- [ ] `progress.yaml` `project.status` reads `completed`

---

## References

- Bug report: Critical review output, 2026-05-01
- M6 implementation: tasks 37–44 in progress.yaml
- Test suites: `tests/acp.preferences*.test.sh`, `e2e/acp.plan-with-preferences.test.sh`
- YAML parser API: `agent/scripts/acp.yaml-parser.sh` — `yaml_get()` vs `yaml_query()`
- Configurables schema: `agent/configurables/acp.configurables.yaml`
