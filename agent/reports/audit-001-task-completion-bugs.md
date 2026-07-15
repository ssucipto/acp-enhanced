# Audit Report 001 — Task Completion & Bug Inventory

**Date:** 2026-05-03  
**Executor:** Persona A (Copilot)  
**Scope:** Full audit of task completion status, code bugs, test coverage gaps, and metadata integrity.

---

## 1. Task Completion Status

| Task | Title | Status |
|------|-------|--------|
| task-001 | Unify command invocation syntax to /acp-<command> | ✅ Complete (2026-05-03) |
| task-002 | Migrate .agent/ to agent/ — unify directory layout | ✅ Complete (2026-05-03) |
| task-003 | Update install/update scripts for ACP Enhanced directory layout | ✅ Complete (2026-05-03) |
| task-004 | Fix e2e test assertions and skill files for /acp-* syntax | ✅ Complete (2026-05-03) |
| task-005 | Auto-migrate legacy .agent/ on install/update | ✅ Complete (2026-05-03) |
| task-006 | Deep audit — bugs, consistency, usability of ACP Enhanced | ✅ Complete (2026-05-03) |
| task-007 | Fix display_available_commands — list all 50 commands | ✅ Complete (2026-05-03) |
| task-008 | Fix yaml-parser test hang at Group 7 edge cases | ✅ Complete (2026-05-03) |
| task-009 | Fix set_preference round-trip + migrate production pref files | ✅ Complete (2026-05-03) |
| task-010 | Fix namespace placeholder refs in 7 command files body text | ✅ Complete (2026-05-03) |
| task-011 | Fix 12 pre-existing e2e test failures | 🔵 Open (next priority) |

**All milestone tasks 001–010 complete.** task-011 is the active open item.

---

## 2. Bugs Found and Fixed (This Audit)

### BUG-01 — task-template.md id placeholder was `task-001`
- **File:** `agent/routing/tasks/task-template.md`
- **Symptom:** Task status grep showed a phantom `task-001 | NOT_DONE | Example task title` entry in every `/acp-status` report.
- **Root cause:** Template had `id: task-001` instead of a real placeholder.
- **Fix:** Changed to `id: task-NNN`. ✅ Fixed in this session.

### BUG-02 — task-002.md title was corrupted by sed migration
- **File:** `agent/routing/tasks/task-002.md`
- **Symptom:** Title read "Migrate agent/ to agent/ — unify directory layout" (both sides identical).
- **Root cause:** The task-002 migration script used `sed 's/.agent\//agent\//g'` which also replaced the `.agent/` in the title string.
- **Fix:** Restored correct title "Migrate .agent/ to agent/ — unify directory layout". ✅ Fixed in this session.

### BUG-03 — task-006.md missing completion date
- **File:** `agent/routing/tasks/task-006.md`
- **Symptom:** Task appeared as NOT_DONE in status reports despite being complete.
- **Root cause:** `completed:` field left blank when task was closed.
- **Fix:** Set `completed: 2026-05-03`. ✅ Fixed in this session.

### BUG-04 — awk 3-argument match() in acp.project-remove.sh fails on macOS
- **File:** `agent/scripts/acp.project-remove.sh`, line 187
- **Symptom:** `acp.project-remove.sh` exited with code 2 on all macOS runs. Error: `awk: syntax error … match($0, /pattern/, arr)`.
- **Root cause:** Three-argument `match()` is a gawk extension; macOS ships BSD awk (POSIX only).
- **Fix:** Replaced with POSIX-compatible key extraction using `sub()` twice. ✅ Fixed in this session.  
  All 25 project-remove tests now pass (was 0/25).

### BUG-05 — package-list global test created manifest at wrong path
- **File:** `e2e/acp.package-list.test.sh`
- **Symptom:** Global package-list test triggered a full ACP install instead of showing "No global packages installed".
- **Root cause:** Tests created `$fake_home/.acp/manifest.yaml` but the script reads `$HOME/.acp/agent/manifest.yaml`. The missing `agent/` dir caused `init_global_acp` to run a full install (cloning ACP from GitHub).
- **Fix:** Tests now create `$fake_home/.acp/agent/manifest.yaml` + `$fake_home/.acp/AGENT.md` (the sentinel `init_global_acp` checks). Also corrected `~/.acp/packages` → `~/.acp/agent/` in one assertion. ✅ Fixed in this session.  
  All 18 package-list tests now pass (was 17/18).

---

## 3. Bugs Found — Not Yet Fixed

### BUG-06 — display_available_commands shows `@git.init` / `@git.commit` (old syntax)
- **File:** `agent/scripts/acp.common.sh`, lines 1544–1545
- **Symptom:** The command listing under "Git Commands" uses `@git.init` and `@git.commit` while all other entries use `/acp-*` syntax.
- **Status:** Intentionally deferred — git commands live in a different namespace (`@git.*`) and may not map to `/acp-*`. Needs design decision before fixing.
- **Tracking:** Add to task-011 or create task-012.

### BUG-07 — 2 preferences tests fail under e2e runner (not when run directly)
- **Files:** `tests/acp.preferences.test.sh`, `agent/scripts/acp.preferences.sh`
- **Symptom:** 21/21 pass direct; 2 fail under `run-e2e-tests.sh`.
  1. `bash -n` path double-prefixes: `agent/scripts/agent/scripts/acp.preferences.sh`
  2. `get_preference` returns empty after `generate_preferences` changes `YAML_CURRENT_FILE` state.
- **Root cause:** e2e runner overrides `SCRIPT_DIR` after sourcing; YAML parser global state contamination.
- **Tracking:** task-011 Group H.

### BUG-08 — 10 remaining pre-existing e2e test failures
- **Files:** Multiple — see task-011.md for full breakdown by group.
- Groups: A (`declare -A` macOS compat in acp.package-install.sh), B (script-command binding depends on A), C (template -y overwrite), E/F/G (project mgmt, projects-sync path, sessions register).
- **Tracking:** task-011.

### BUG-09 — Untracked test fixture files (`tests/fixtures/`)
- **Files:** `tests/fixtures/array-ops.yaml`, `tests/fixtures/large.yaml`, `tests/fixtures/package.yaml`
- **Symptom:** These files appear untracked in `git status` because tests generate them at runtime and don't clean up.
- **Root cause:** Tests write fixtures to `tests/fixtures/` but don't `rm` after. Alternatively: these should be in `.gitignore`.
- **Recommendation:** Add to `.gitignore` or add cleanup in the test teardown.

### BUG-10 — ADR-5 in decisions.md was corrupted (fixed separately, but pattern risk remains)
- **Context:** task-002 migration sed command also corrupted ADR-5 description text in decisions.md. Fixed in bb88629.
- **Recommendation:** Any future sed-based migration must scope to specific YAML keys (use `awk` with line matching, not global sed on entire file).

---

## 4. E2E Test Coverage Map

| Test File | Tests | Status | Commands Covered |
|-----------|-------|--------|-----------------|
| acp.command-docs.test.sh | 361 | ✅ All pass | Structure of all 53 command docs |
| acp.version.test.sh | 12 | ✅ All pass | version-check, version-check-for-updates, version-update |
| acp.package-list.test.sh | 18 | ✅ All pass | /acp-package-list |
| acp.package-info.test.sh | — | ✅ | /acp-package-info |
| acp.package-remove.test.sh | — | ✅ | /acp-package-remove |
| acp.package-search.test.sh | — | ✅ | /acp-package-search |
| acp.package-update.test.sh | — | ✅ | /acp-package-update |
| acp.project-remove.test.sh | 25 | ✅ All pass (fixed) | /acp-project-remove |
| acp.project-info.test.sh | — | ✅ | /acp-project-info |
| acp.project-list.test.sh | — | ✅ | /acp-project-list |
| acp.project-set.test.sh | — | ✅ | /acp-project-set |
| acp.project-update.test.sh | — | ✅ | /acp-project-update |
| acp.project-workflow.test.sh | — | ✅ | project workflow |
| acp.projects-sync.test.sh | — | ❌ Failures | /acp-projects-sync |
| acp.sessions.test.sh | — | ❌ Failures | /acp-sessions |
| acp.package-install-list.test.sh | — | ❌ Failures | /acp-package-install (declare -A) |
| acp.script-command-binding.test.sh | — | ❌ Failures | script binding |
| acp.experimental-features.test.sh | — | ❌ Failures | experimental |
| acp.template-files.test.sh | — | ❌ Failures | template -y |
| acp.index.test.sh | — | ❌ Failures | /acp-index |
| acp.plan-with-preferences.test.sh | — | ✅ | preferences + plan |
| tests/acp.preferences*.test.sh | 21 | ✅ Direct (2 fail e2e runner) | /acp-preferences-* |
| tests/acp.yaml-parser.test.sh | 19 groups | ✅ (Group 20 slow) | yaml-parser |
| tests/yaml-array-operations.test.sh | — | ✅ | yaml array ops |
| tests/acp.project-registry.test.sh | — | ✅ | project registry |

**27 commands have no dedicated e2e test** (covered only by acp.command-docs.test.sh structural check). These are the pure-LLM commands that execute no shell scripts.

---

## 5. .gitignore Findings

- `agent/preferences/acp.default.yaml` is tracked in git (committed) but `agent/preferences/` has no .gitignore entry.
- `tests/fixtures/array-ops.yaml`, `large.yaml`, `package.yaml` are untracked runtime artifacts (BUG-09).
- Recommendation: add to root `.gitignore`:
  ```
  # Runtime test fixtures (generated by tests)
  tests/fixtures/array-ops.yaml
  tests/fixtures/large.yaml
  tests/fixtures/package.yaml
  ```

---

## 6. Summary

| Category | Count |
|----------|-------|
| Tasks completed (001–010) | 10 |
| Bugs fixed this audit | 5 (BUG-01 through BUG-05) |
| Bugs open / deferred | 5 (BUG-06 through BUG-10) |
| E2E pass rate before | 13/25 suites passing |
| E2E pass rate after | 15/25 suites passing (+2) |

Next session should start with task-011, Group A: replace `declare -A` with POSIX-compatible associative logic in `acp.package-install.sh`.
