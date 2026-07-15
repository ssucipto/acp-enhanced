# Audit Report: task-184 run-readiness

**Audit**: #006
**Date**: 2026-05-05
**Subject**: Can task-184 (`acp.install.sh` local.* skill exclusion) run now, before other M29 tasks?

---

## Summary

task-184 is **fully unblocked** and safe to run immediately. It touches exactly one file (`agent/scripts/acp.install.sh`), has zero dependency on any other M29 task, and is a strictly additive safety fix — the behavior for non-`local.*` skill files is identical before and after the change. The fix pattern it applies already exists elsewhere in the same install script for `agent/index/` files, so no new convention is being introduced.

No test suite exercises the skills copy directly today, so verification is a 2-step manual check (create a `local.test.md`, run the script, confirm it survives). The fix is 9 lines replacing 3.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| [agent/scripts/acp.install.sh](../scripts/acp.install.sh) | source | Target file — line 163-165 is the exact change site |
| [agent/tasks/milestone-29-upstream-integration-audit/task-184-install-skill-local-exclusion.md](../tasks/milestone-29-upstream-integration-audit/task-184-install-skill-local-exclusion.md) | task | Full implementation spec including before/after code |
| [agent/tasks/milestone-29-upstream-integration-audit/task-155-feature-parity-matrix.md](../tasks/milestone-29-upstream-integration-audit/task-155-feature-parity-matrix.md) | task | M29 peer task — no dependency on task-184 |
| [agent/tasks/milestone-29-upstream-integration-audit/task-156-port-compatibility-audit.md](../tasks/milestone-29-upstream-integration-audit/task-156-port-compatibility-audit.md) | task | M29 peer task — depends on task-155 output, not task-184 |
| [agent/tasks/milestone-29-upstream-integration-audit/task-157-upstream-integration-runbook.md](../tasks/milestone-29-upstream-integration-audit/task-157-upstream-integration-runbook.md) | task | M29 peer task — standalone, no dependency on task-184 |
| [agent/skills/](../skills/) | directory | 6 files — none are `local.*`; all would still be copied after fix |

---

## Key Findings

| Finding | Location | Notes |
|---------|----------|-------|
| Change site is isolated | [acp.install.sh:163-165](../scripts/acp.install.sh#L163) | Single `if` block for skills — no other code references it |
| Same pattern already exists for index files | [acp.install.sh:233](../scripts/acp.install.sh#L233) | `find … ! -name "local.*"` already excludes local.* for `agent/index/` |
| No `local.*` skill files exist today | `agent/skills/` | 6 files: commands.md, crosscut.md, schemas.md, scripts.md, testing.md, upstream-sync.md — all baseline, all will still be overwritten after fix |
| No test covers the skills copy | `e2e/`, `tests/` | No E2E test exercises `acp.install.sh` skills block — manual verification required |
| task-155 depends on task-156 (sequential) | task-156 context | task-156 consumes task-155 output; task-184 has no such chain |
| task-184 has no consumers | M29 task list | No other task depends on task-184 being complete first |
| Fix is bash 3.2-safe | task-184 spec | Uses `case … esac` + `for` loop — no bash 4+ constructs |

---

## Dependency Graph

```
task-155 → task-156   (task-156 reads task-155 output)
task-157              (standalone, no input dependency)
task-158              (standalone, wiki sync)
task-184              (standalone, install script only)
```

task-184 is a leaf node with no upstream or downstream dependencies within M29 or any other active milestone.

---

## Key Decisions

- `local.*` = project-local, never shipped convention is already established (patterns/, index/) — task-184 extends it to skills/; no new decision needed
- Fix uses `case … esac` (not `[[ =~ ]]`) deliberately for bash 3.2 compat — consistent with macOS constraint in `agent/core/identity.yml`
- `unset _skill_file _skill_basename` at end of loop prevents variable leakage into the rest of the install script

---

## Code Pointers

| Location | Description |
|----------|-------------|
| [acp.install.sh:163-165](../scripts/acp.install.sh#L163) | Exact 3-line block to replace |
| [acp.install.sh:233](../scripts/acp.install.sh#L233) | Reference pattern: `find … ! -name "local.*"` already protecting agent/index/ |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-05 | 036dd88 | task-184 created; Direction B gap identified |
| 2026-05-05 | 09f9ec6 | upstream-sync.md added to agent/skills/ (new baseline skill) |
| 2026-05-04 | 0f0b2ed | acp.install.sh last touched (agent/ path fix for .agent/ → agent/) |

---

## Verdict

| Check | Result |
|-------|--------|
| Depends on other M29 tasks? | ✅ No |
| Depends on M28 or M30? | ✅ No |
| Risk of breaking existing behavior? | ✅ Zero — no `local.*` skills exist today; non-local files unaffected |
| Implementation fully specified? | ✅ Yes — before/after code in task-184 |
| Bash 3.2-safe? | ✅ Yes — `case … esac` |
| E2E test needed first? | ✅ No — manual verify is sufficient (listed in task-184 verification) |

**CLEAR TO RUN NOW.**

---

## Recommendations

1. Implement task-184 immediately — it unblocks safer upgrades for all downstream projects right now
2. After implementing: run the manual verification (create `agent/skills/local.test.md`, run install against a temp project, confirm the file survives)
3. No need to wait for M28, M30, or any other M29 task to complete first
