# Milestone 37: Audit-007 Fixes — gitignore Completeness

<!-- @acp.meta.milestone
topic: gitignore, install, memory, git-tracking, audit
description: Fix the two actionable findings from audit-007 — bare drafts/ pattern in project-create command doc, and stale git tracking of gitignored memory files.
tasks: task-185..task-186
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Resolve the two actionable findings from audit-007 before pushing to remote: (1) bare `agent/drafts/` pattern in `acp.project-create.md`'s sample gitignore, and (2) `lessons.md` + `decisions.md` still tracked by git despite being in `.gitignore`.  
**Duration**: 0.5 day  
**Priority**: High (Finding 1 affects every new project created; Finding 2 leaks instance data to remote)

---

## Overview

Audit #007 (`agent/reports/audit-007-post-push-implementation-review.md`) found two actionable issues after the M30/M34 push:

1. **HIGH**: `acp.project-create.md` embeds `agent/drafts/` (bare) in its sample `.gitignore` template. New projects created via `/acp-project-create` will have a broken drafts gitignore where `!agent/drafts/.gitkeep` exception rules are silently blocked. The same bug was fixed in `agent/.gitignore` and `acp.install.sh` as part of M30, but the command doc was missed.

2. **MEDIUM**: `agent/memory/lessons.md` and `agent/memory/decisions.md` are in `agent/.gitignore` (rule: `memory/lessons.md`, `memory/decisions.md`) but were committed before the gitignore rule was applied. `git rm --cached` was never run. They show as `M` in `git status`, and their instance-specific content leaks into remote history on every push.

---

## Deliverables

### 1. Fix project-create command doc (Finding 1)
- `agent/commands/acp.project-create.md` line 292: `agent/drafts/` → `agent/drafts/**` + two exception lines

### 2. Untrack gitignored memory files (Finding 2)  
- `git rm --cached agent/memory/lessons.md agent/memory/decisions.md`
- Verify files still exist locally (only removed from git index, not disk)
- Commit the untracking

---

## Success Criteria

- [ ] `acp.project-create.md` sample gitignore uses `agent/drafts/**` with `!agent/drafts/.gitkeep` and `!agent/drafts/draft.template.md` exceptions
- [ ] `git ls-files agent/memory/lessons.md` returns empty (no longer tracked)
- [ ] `git ls-files agent/memory/decisions.md` returns empty (no longer tracked)
- [ ] Both files still exist on disk (only untracked, not deleted)
- [ ] `git status` shows clean working tree for memory files
- [ ] All e2e tests that were passing still pass

---

## Key Files to Modify

```
agent/commands/acp.project-create.md   (update — fix bare agent/drafts/ pattern)
agent/memory/lessons.md                (git rm --cached only — file stays on disk)
agent/memory/decisions.md             (git rm --cached only — file stays on disk)
```

---

## Audit Reference

- Audit: `agent/reports/audit-007-post-push-implementation-review.md`
- Finding 1 (HIGH): line ~292 in `acp.project-create.md`
- Finding 2 (MEDIUM): git index contains `agent/memory/lessons.md`, `agent/memory/decisions.md`
- Pattern applied: `install-script-gitignore-heredoc-sync` (agent/memory/patterns.md)
