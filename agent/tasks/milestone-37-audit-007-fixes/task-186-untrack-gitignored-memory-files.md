---
id: task-186
milestone: M37
title: Untrack gitignored memory files (lessons.md + decisions.md)
status: completed
priority: 2
complexity: trivial
estimated_hours: 0.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
completed:
---

<!-- @acp.meta.task
topic: untrack, gitignored, memory, files, lessonsmd, decisionsmd
description: Untrack gitignored memory files (lessons.md + decisions.md)
milestone: M37
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Remove `agent/memory/lessons.md` and `agent/memory/decisions.md` from the git index using `git rm --cached`, so that git stops tracking them. Files remain on disk. Commit the untracking.

## Context

Audit-007 Finding 2 (MEDIUM): Both files are listed in `agent/.gitignore` as instance-specific memory:
```
memory/sessions.md
memory/lessons.md
memory/decisions.md
```
However, they were committed before this gitignore rule was applied (commit `d32a0d9`). Because they are tracked by git, they appear as `M` in `git status` whenever their local content changes, and their instance-specific content leaks into remote history on every push.

`agent/memory/sessions.md` is correctly untracked (confirmed: `git ls-files agent/memory/sessions.md` returns empty). Only `lessons.md` and `decisions.md` need the fix.

## Steps

1. Verify current tracked state:
   ```bash
   git ls-files agent/memory/lessons.md agent/memory/decisions.md
   ```
   Both should appear in output (confirming they are currently tracked).

2. Remove from git index (keep files on disk):
   ```bash
   git rm --cached agent/memory/lessons.md agent/memory/decisions.md
   ```

3. Verify files still exist on disk:
   ```bash
   ls -la agent/memory/lessons.md agent/memory/decisions.md
   ```

4. Verify no longer tracked:
   ```bash
   git ls-files agent/memory/lessons.md agent/memory/decisions.md
   ```
   Both should return empty.

5. Verify gitignore now correctly excludes them:
   ```bash
   git status agent/memory/lessons.md agent/memory/decisions.md
   ```
   Should show nothing (correctly ignored).

6. Commit:
   ```bash
   git add -A
   git commit -m "chore(M37): untrack gitignored memory files (lessons.md + decisions.md)"
   ```

## Verification

- [ ] `git ls-files agent/memory/lessons.md` returns empty
- [ ] `git ls-files agent/memory/decisions.md` returns empty
- [ ] `ls agent/memory/lessons.md` succeeds (file exists on disk)
- [ ] `ls agent/memory/decisions.md` succeeds (file exists on disk)
- [ ] `git status` shows no `M` for either file
- [ ] Commit created successfully

## Caution

This is a git index operation, not a file deletion. `git rm --cached` does NOT delete the files from disk — it only removes them from the git index so git stops tracking future changes. Any existing history still contains the files (as expected — we are not rewriting history). Going forward, changes to these files will not appear in `git status` and will not be committed.

## References

- Audit: `agent/reports/audit-007-post-push-implementation-review.md` (Finding 2)
- gitignore rules: `agent/.gitignore` lines 29–31
- Precedent: `agent/memory/sessions.md` was correctly untracked (model for this fix)
