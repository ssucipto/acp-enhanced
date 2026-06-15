---
id: task-185
milestone: M37
title: Fix bare agent/drafts/ pattern in acp.project-create.md sample gitignore
status: completed
priority: 1
complexity: trivial
estimated_hours: 0.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
completed:
---

<!-- @acp.meta.task
topic: fix, bare, agentdrafts, pattern, in, acpproject-createmd, sample, gitignore
description: Fix bare agent/drafts/ pattern in acp.project-create.md sample gitignore
milestone: M37
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Fix `agent/commands/acp.project-create.md` line 292: change the bare `agent/drafts/` gitignore entry to `agent/drafts/**` with the two required exception lines, matching the pattern applied to `agent/.gitignore` and `acp.install.sh` in M30.

## Context

Audit-007 Finding 1 (HIGH): `acp.project-create.md` Step 7 embeds a sample `.gitignore` for new user projects. Line 292 currently reads `agent/drafts/` (bare). The bare form blocks all `!exception` rules beneath it, meaning `.gitkeep` and `draft.template.md` would not be tracked in new projects. This is the exact bug fixed in M30 for the install scripts, but the command doc was missed.

Pattern applied: `install-script-gitignore-heredoc-sync` — whenever `agent/.gitignore` gets a pattern fix, grep all docs/scripts that embed gitignore content and apply the same fix.

## Steps

1. Open `agent/commands/acp.project-create.md`
2. Find the `# ACP local files (not committed)` gitignore block (around line 287–293)
3. Replace:
   ```
   agent/drafts/
   ```
   With:
   ```
   agent/drafts/**
   !agent/drafts/.gitkeep
   !agent/drafts/draft.template.md
   ```
4. Verify no other bare `agent/drafts/` patterns exist in the file
5. Run `grep -n "agent/drafts" agent/commands/acp.project-create.md` to confirm only the fixed form remains

## Verification

- [ ] `agent/commands/acp.project-create.md` line ~292 now reads `agent/drafts/**`
- [ ] Exception lines `!agent/drafts/.gitkeep` and `!agent/drafts/draft.template.md` added immediately after
- [ ] No other bare `agent/drafts/` or `drafts/` patterns remain in the command doc
- [ ] `grep -c "agent/drafts/\*\*" agent/commands/acp.project-create.md` returns 1
- [ ] All e2e tests still pass

## References

- Audit: `agent/reports/audit-007-post-push-implementation-review.md` (Finding 1)
- Pattern: `install-script-gitignore-heredoc-sync` in `agent/memory/patterns.md`
- Canonical source: `agent/.gitignore` lines 8–10
