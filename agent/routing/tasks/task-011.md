---
id: task-011
title: Fix 12 pre-existing e2e test failures (investigation + fixes)
task_type: shell-scripting
milestone: M26-audit
complexity: high
executor: persona-a
context_required:
  - agent/skills/scripts.md
  - agent/skills/testing.md
  - e2e/acp.experimental-features.test.sh
  - e2e/acp.index.test.sh
  - e2e/acp.package-install-list.test.sh
  - e2e/acp.package-list.test.sh
  - e2e/acp.project-remove.test.sh
  - e2e/acp.project-update.test.sh
  - e2e/acp.project-workflow.test.sh
  - e2e/acp.projects-sync.test.sh
  - e2e/acp.script-command-binding.test.sh
  - e2e/acp.sessions.test.sh
  - e2e/acp.template-files.test.sh
  - e2e/acp.yaml-parser.test.sh
  - agent/scripts/acp.package-install.sh
  - agent/scripts/acp.yaml-parser.sh
files_affected: []
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed:
override_reason:
---

## Task: Investigate and fix 12 pre-existing e2e test failures

These failures existed before the M26 audit sprint. None were introduced by tasks 007-010.
Discovered by running `bash run-e2e-tests.sh` on 2026-05-03.

## Failures

### Group A — acp.package-install.sh core bug (affects 3 tests)
- **acp.experimental-features.test.sh** — `declare: usage: declare [-afFirtx] [-p] [name[=value] ...]` at line 205
  — This is a `declare -A` associative array incompatibility on macOS bash 3.x/5.x. Fix: use bash 4+ guard or rewrite with indexed arrays.
- **acp.index.test.sh** — "Package install should succeed" fails (exit 1)
  — Same install script failure propagating.
- **acp.package-install-list.test.sh** — `--list` flag exits 1 instead of 0
  — Same install script failure.

### Group B — acp.script-command-binding.test.sh (22/28 fail)
- Script files missing after install — `cmd1 script should exist` fails.
- Likely related to same `declare -A` failure in package-install.sh.

### Group C — acp.template-files.test.sh (24/34 fail)
- `-y` overwrite flag not working: `File was overwritten with package content` fails.
- Template files not being replaced even with explicit `-y`.

### Group D — acp.package-list.test.sh
- Shows `@git.init` / `@git.commit` in package list output (pre-task-001 syntax?)
  OR the test asserts a specific format that changed.
- Full output needed: run `bash e2e/acp.package-list.test.sh 2>&1` to inspect.

### Group E — Project management failures (3 tests)
- **acp.project-remove.test.sh** — exits 2 instead of 0 (wrong exit code convention)
- **acp.project-update.test.sh** — 18/20 pass (2 specific assertions fail)
- **acp.project-workflow.test.sh** — fails at "Filtering and Querying Workflow" step

### Group F — acp.projects-sync.test.sh
- "Scanning for ACP projects" expected but "No projects directory found" shown
  — Projects dir path is `~/.acp/projects` not where the test expects.

### Group G — acp.sessions.test.sh
- "Active Sessions (2)" expected but "No active sessions." shown
  — Session register calls not persisting across test steps.

### Group H — acp.yaml-parser.test.sh (Group 20)
- Known O(N²) performance issue: ~7s after 85 prior warm-up parse calls.
  — Not a correctness bug. Could be fixed with awk-based `yaml_get` to reduce fork overhead.

## Acceptance Criteria
- [ ] All 12 failing e2e tests pass (or individual failures are documented as "by design")
- [ ] No regressions in the currently-passing 13 tests
- [ ] `bash run-e2e-tests.sh` reports 25/25 (or documented exceptions)

## Investigation Order (suggested)
1. Fix Group A (`declare -A` in acp.package-install.sh) — resolves Groups A, B likely
2. Fix Group C (template overwrite `-y` flag)
3. Fix Group F (projects-sync path)
4. Fix Group G (sessions register persistence)
5. Investigate Groups D, E, H individually

## Notes
- macOS ships with bash 3.2; `declare -A` requires bash 4+
- acp.yaml-parser.sh Group 20 is a known performance limitation, not a bug (documented in commit e1a6930)
