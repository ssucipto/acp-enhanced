# Audit Report: Task Completion Status

**Audit**: #002  
**Date**: 2026-05-04  
**Subject**: Task completion status across `agent/routing/tasks/` and `agent/tasks/`, with bug and improvement findings  

---

## Summary

This audit cross-referenced task status in two locations: (1) **`agent/routing/tasks/`** (12 routing tasks, task-001 → task-012) and (2) **`agent/tasks/`** (148 task files across 18 milestone subdirectories). The ground truth is **`agent/progress.yaml`**, which tracks milestone/task status authoritatively.

**Key finding**: `agent/progress.yaml` correctly records all milestones M1–M24 as `completed`. However, **134 of 148 task files** in `agent/tasks/` have stale `**Status**: Not Started` or no status field at all, because task-file status is never updated after execution — only `progress.yaml` is updated. This creates a misleading picture if you read task files directly. One routing task (`task-011`) was left with a blank `completed:` field.

---

## Files Analyzed

| File / Directory | Type | Count | Relevance |
| --- |---| --- |---|
| `agent/routing/tasks/task-001..012.md` | Routing tasks | 12 | Primary task tracking layer |
| `agent/tasks/` (root) | Legacy task files (M1–M10 era) | ~45 | M1–M10 milestone tasks |
| `agent/tasks/milestone-*/` | Milestone subdirectories | 18 dirs, 103 files | M6–M25 task documents |
| `agent/progress.yaml` | Ground truth | 1 | Source of truth for completion |
| `agent/memory/sessions.md` | Session log | 1 | Work history cross-reference |

---

## Bug Findings

### BUG-01 (Minor): task-011 `completed:` field is blank

| Field | Value |
| --- |---|
| File | `agent/routing/tasks/task-011.md` |
| Issue | `completed:` field is blank despite task being fully implemented and committed |
| Evidence | `599d267` commit, sessions.md entry 2026-05-04 — task-011 done |
| Fix | Set `completed: 2026-05-04` |

### BUG-02 (Systemic): 134 task files have stale `**Status**: Not Started`

| Scope | Count |
| --- |---|
| Task files with `**Status**: Not Started` | 112 |
| Task files with `**Status**: Completed` | 22 |
| Task files with no status field at all | 11 |
| Task files in **completed milestones** with `Not Started` | ~90 |

Milestones fully done in `progress.yaml` but with stale task-file statuses:

| Milestone | progress.yaml | Task file statuses |
| --- |---| --- |
| M6 — Preferences System | ✅ completed | 8 files say "Not Started" |
| M7 — Project Registry | ✅ completed | 8 files say "Not Started" |
| M8 — Experimental Features | ✅ completed | 4 files say "Not Started" |
| M9 — Template Source Files | ✅ completed | 6 files say "Not Started" |
| M11 — Benchmark Suite | ✅ completed | 9 files say "Not Started" |
| M12 — Sessions System | ✅ completed | 4 files say "Not Started" |
| M13 — Cross-Platform CI | ✅ completed | 3 files say "Not Started" |
| M15 — Clarification Capture | ✅ completed | 4 files say "Not Started" |
| M16 — Design Reference | ✅ completed | 6 files say "Not Started" |
| M20 — Consistency Cleanup | ✅ completed | 5 files, no status field |
| M21 — Functional Readiness | ✅ completed | 5 files, no status field |
| M24 — AGENT.md Completeness | ✅ completed | 4 files say "Not Started" |

### BUG-03 (Minor): 11 task files have no status tracking field at all

Files in `milestone-20-consistency-cleanup/` (task-71 through task-75) and `milestone-21-functional-readiness/` (task-76 through task-80) have no `**Status**:` line and no `completed:` YAML field. These use the newer YAML frontmatter format but the `completed:` key was never filled in.

| File | Milestone | progress.yaml status |
| --- |---| --- |
| `task-76-fix-template-placeholders.md` | M21 | completed |
| `task-77-fix-readme-curl-url.md` | M21 | completed |
| `task-78-version-bump.md` | M21 | completed |
| `task-79-package-yaml-missing-scripts.md` | M21 | completed |
| `task-80-changelog-622.md` | M21 | completed |
| `task-71-fix-directive-headers.md` | M20 | completed |
| `task-72-fix-body-text-hyphen-refs.md` | M20 | completed |
| `task-73-fix-agent-md-comments.md` | M20 | completed |
| `task-74-package-yaml-missing-entries.md` | M20 | completed |
| `task-75-changelog-missing-entry.md` | M20 | completed |
| `task-120-implement-index-semantic-entry-types.md` | M18 | completed |

---

## Functionality Improvement Opportunities

### IMPROVEMENT-01 (High): `acp-bootstrap.sh` does not set `completed:` on routing tasks

When `/acp-commit` runs, it manually updates routing task files. But there is no automated mechanism to set `completed:` when a task is marked done in `progress.yaml`. The `git.commit` command template says "Mark completed tasks" but provides no script — it relies on the agent doing it manually. This is prone to omission (see BUG-01 above).

**Recommendation**: Add a `mark_task_complete()` function to `agent/scripts/acp.update.sh` (or the commit workflow) that:
1. Reads the routing task file
2. Sets `completed: <date>` in the YAML frontmatter
3. Called automatically by `/acp-commit` for each task in `tasks:` list

### IMPROVEMENT-02 (Medium): Two-tier status system creates confusion

`agent/tasks/` uses `**Status**: Not Started/In Progress/Completed` (markdown bold field).  
`agent/routing/tasks/` uses YAML frontmatter `completed: <date>`.  
`agent/progress.yaml` uses YAML `status: completed`.

Three different formats for the same concept. When reading a task file cold, it's impossible to determine completion without also checking `progress.yaml`.

**Recommendation**: Standardise. Add `completed:` YAML frontmatter to `agent/tasks/` files via the task template, and deprecate `**Status**:` markdown fields. The `/acp-task-create` command already uses the routing task frontmatter format — apply it to legacy task files during a migration pass.

### IMPROVEMENT-03 (Low): M25 tasks are all "Not Started" — appropriate, but M25 is greenfield in a *new* repo

`agent/tasks/milestone-25-acp-progress-visualizer/` has 8 tasks (task-137 → task-144), all "Not Started". This is correct — M25 creates a separate `agent-context-protocol-visualizer` repository. However, task-137 (`Bootstrap Repository`) has no dependency on this repo's codebase. Consider adding a prerequisite note so the visualizer repo gets created before `/acp-proceed` tries to bootstrap it.

### IMPROVEMENT-04 (Low): `agent/tasks/` root-level files have no milestone subdirectory

46 task files sit at the root of `agent/tasks/` (e.g., `task-5-manifest-system.md`, `task-65-script-command-binding.md`). These belong to M1–M10 milestones. Milestone subdirectories were introduced starting at M6. The root-level files predate that convention and were never migrated.

**Recommendation**: Move root-level task files into `milestone-N-*/` subdirectories to match the current convention. Low priority — files function fine in place.

---

## Key Decisions

- **`progress.yaml` is the single source of truth** for task/milestone completion. Task files are documentation artifacts; their `**Status**:` field is not authoritative.
- **Routing tasks (`agent/routing/tasks/`)** use a different, more structured YAML format than legacy task files. This is intentional (introduced when ACP Enhanced added the routing layer).
- **M25 (Progress Visualizer) is the only not-started milestone** as of 2026-05-04.

---

## Code Pointers

| Location | Description |
| --- |---|
| [agent/routing/tasks/task-011.md](../routing/tasks/task-011.md) | BUG-01: blank `completed:` field |
| [agent/tasks/milestone-21-functional-readiness/](../tasks/milestone-21-functional-readiness/) | BUG-03: 5 task files with no status field |
| [agent/tasks/milestone-20-consistency-cleanup/](../tasks/milestone-20-consistency-cleanup/) | BUG-03: 5 task files with no status field |
| [agent/progress.yaml#L9](../progress.yaml) | `current_milestone: M25` |
| [scripts/acp-bootstrap.sh:L519](../../scripts/acp-bootstrap.sh) | Section [6/7] prompt file generation |
| [agent/tasks/milestone-25-acp-progress-visualizer/task-137-bootstrap-repository.md](../tasks/milestone-25-acp-progress-visualizer/task-137-bootstrap-repository.md) | Next task to implement |

---

## Git History (relevant to subject)

| Date | Commit | Summary |
| --- |---| --- |
| 2026-05-04 | `a9b74a0` | feat(prompts): all 57 slash commands + bootstrap — v6.3.0 |
| 2026-05-04 | `599d267` | fix: task-011 — bash 3.2 compat, sessions UTC bug, yaml fixes |
| 2026-05-03 | `fdf0464` | chore: acp-commit — session 2026-05-03, audit-001 |
| 2026-05-03 | `3b528b5` | fix: audit-001 — task metadata, awk macOS compat |
| 2026-05-03 | `cf2df8d` | chore: add audit task-006 + fix tasks 007-010 |
| 2026-05-03 | `a1decf2` | chore: acp-commit — tasks 001-005 complete |

---

## Recommendations

1. **Fix BUG-01 immediately**: Set `completed: 2026-05-04` on `agent/routing/tasks/task-011.md` — takes 30 seconds.

2. **Fix BUG-03 (11 files, no status)**: Add `completed: 2026-05-01` to the YAML frontmatter of the 10 M20/M21 task files and the M18 task file. Low effort, removes ambiguity.

3. **Do NOT bulk-update 112 stale "Not Started" task files** from completed milestones: The effort is high, the files are historical artifacts, and `progress.yaml` is the authoritative record. Accept the two-tier system for now.

4. **Implement IMPROVEMENT-01**: Add auto-`completed:` stamping to the `/acp-commit` workflow. This prevents BUG-01 class issues from recurring.

5. **Start M25 (task-137)**: This is the next milestone. Create the visualizer repo and run the TanStack Start bootstrap before any other work.
