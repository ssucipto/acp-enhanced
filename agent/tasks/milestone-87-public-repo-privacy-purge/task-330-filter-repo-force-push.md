---
id: task-330
milestone: M87
title: "filter-repo SOP + operator-confirmed force-push"
status: planned
priority: 5
complexity: high
estimated_hours: 4
created: 2026-08-27
started: null
completed: null
phase: 4
depends_on: [task-323, task-328]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-01', 'F-118-02', 'F-118-03']
files_affected:
  - agent/reports/
  - agent/feedback/
---

<!-- @acp.meta.task
topic: m87, git-filter-repo, force-push, history
description: Rewrite develop and mainline history to drop report/feedback bodies; force-push only after explicit operator confirmation.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D4
depends_on: task-323, task-328
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Remove `agent/reports/**` and `agent/feedback/**` **blobs from git history** on `develop` and `mainline`, then force-push **only** when the operator types an explicit confirmation (not implied by `/acp-proceed`).

## Context

Public GitHub still serves old blobs after 328. Secure removal is a history rewrite. User rules: never force-push unless explicitly requested. This task **stops and asks** before `git push --force`.

## Steps

1. Confirm 323 archive restore still works. Take a full `git clone --mirror` backup **off-remote** (unpushed).
2. Write a short SOP in this task’s notes: install `git-filter-repo`; path drop for reports/feedback except keepers; expire reflog; `git gc`.
3. Run the rewrite on a **throwaway clone** first. Verify `git log --all --full-history -- agent/reports/` has no bodies.
4. Apply on the working clone only after throwaway proof.
5. **STOP.** Print: both `develop` and `mainline` must be force-pushed; GitHub cache/forks retain copies until they refetch; collaborators must re-clone. Ask the operator to reply with an explicit force-push yes for **both** branches.
6. If yes: force-push `develop` and `mainline` (and tags only if they contain the blobs — prefer leaving tags until verified). If no: leave rewritten local commits unpushed; do not mark this task complete.
7. Do not stamp F-118-* until 331 clone proof against **origin**.

## Verification

- [ ] Mirror backup exists off-remote
- [ ] Throwaway clone rewrite verified
- [ ] Operator explicit force-push confirmation recorded in session notes (not a secret)
- [ ] Both branches updated on origin **or** task remains in_progress with reason “awaiting confirm”

## User-Observable Acceptance

After confirmation, `git clone` from origin and `git log --all -- agent/feedback` shows no design-spec blob.

## Expected Output

### Files Created / Modified
- Local SOP notes on this task
- Git history (rewritten)
- Remotes (only after confirm)

### Notes
Never automate force-push. Never put credentials in the SOP.
