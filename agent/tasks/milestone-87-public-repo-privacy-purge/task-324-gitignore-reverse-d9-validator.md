---
id: task-324
milestone: M87
title: "Gitignore reports/feedback and reverse D9 validator"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 2
depends_on: [task-322]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04', 'F-118-05']
files_affected:
  - agent/.gitignore
  - .gitignore
  - scripts/acp-validate.ts
---

<!-- @acp.meta.task
topic: m87, gitignore, d9, validateProtocolDirAddability
description: Ignore reports and feedback like drafts; validator must not ERROR on untracked or ignored evidence dirs.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2, D5
depends_on: task-322
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Make local-only reports/feedback **legal** in ACP: gitignore them, and reverse `validateProtocolDirAddability` so ignored/untracked files there are not errors.

## Context

M72 D9 made untracked files in `agent/reports/` and `agent/feedback/` an ERROR, and also ERRORed if gitignore rejected new files. ADR-27 supersedes that for this public repo. Treat those dirs like `drafts/` / `clarifications/`. Keep `.gitkeep` (and a short README) tracked.

## Steps

1. Update `agent/.gitignore` (and root `.gitignore` exceptions if needed) so new files under `agent/reports/` and `agent/feedback/` are ignored except `.gitkeep` and `README.md`.
2. Change `validateProtocolDirAddability` in `scripts/acp-validate.ts`: reports/feedback must **not** require addability; untracked files on disk there must **not** ERROR.
3. Keep memory/tasks/design tracked (do not widen ignore).
4. Run `acp-validate` (or the validate wrapper) and confirm it is green with local audit files present but ignored.
5. Do not `git rm` the tree yet (that is 328). Do not commit ignored report bodies.

## Verification

- [ ] New `agent/reports/audit-dummy.md` is ignored
- [ ] Validator green with ignored reports present
- [ ] `.gitkeep` still tracked
- [ ] No D9 “untracked evidence = ERROR” for reports/feedback

## User-Observable Acceptance

`/acp-audit` can write a local report; `git status` does not list it; validate does not fail.

## Expected Output

### Files Created / Modified
- `agent/.gitignore`
- `.gitignore` (if exceptions need flipping)
- `scripts/acp-validate.ts`

### Notes
Keepers stay: `.gitkeep` + short README only.
