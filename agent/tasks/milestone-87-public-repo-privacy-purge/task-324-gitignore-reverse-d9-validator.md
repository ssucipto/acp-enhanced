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
depends_on: [task-322, task-323]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04', 'F-118-05', 'F-119-03', 'F-119-04']
files_affected:
  - agent/.gitignore
  - .gitignore
  - scripts/acp-validate.ts
  - scripts/acp-validate.test.ts
  - agent/commands/acp.validate.md
---

<!-- @acp.meta.task
topic: m87, gitignore, d9, validateProtocolDirAddability
description: Ignore reports and feedback like drafts; validator must not ERROR on untracked or ignored evidence dirs.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2, D5
depends_on: task-322, task-323
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Make local-only reports/feedback **legal** in one commit: gitignore (**CB-2**) + reverse D9 in `validateProtocolDirAddability` + stop `validateGitignoreConflicts` from requiring the reports **tree** to be un-ignored.

## Context

Live code: `probeDirs` at `scripts/acp-validate.ts:541` includes reports/feedback; walk at `:561-596` ERRORs untracked files; `trackedPaths` at `:2082` includes `agent/reports/`. Gitignore `*` would **not** ignore nested `coderabbit-local-*/chunk-*.raw.txt`.

## Steps

1. Apply **CB-2** to `agent/.gitignore` (replace the D9 “are tracked” comment). Keep root `reports/` and `!agent/reports/`.
2. **Same commit**, edit `validateProtocolDirAddability`:
   - `probeDirs` = `["agent/memory", "agent/tasks"]` only.
   - Delete the `for (const dir of ["agent/reports", "agent/feedback"])` walk.
   - Success log must not say “evidence files tracked” for those dirs.
3. `validateGitignoreConflicts`: remove `"agent/reports/"` from `trackedPaths` (optional: check `"agent/reports/.gitkeep"` is **not** ignored).
4. Update `acp.validate.md` M72 table row (protocol dir addability) to match ADR-27.
5. Extend `scripts/acp-validate.test.ts` so a temp dir with ignored `agent/reports/foo.md` plus tracked `.gitkeep` yields **zero** D9 errors (not only “returns array”).
6. Run **CB-2** syntax check (`git check-ignore -v`). Then validate. Do **not** `git rm` (328). Do not commit report bodies.

## Verification

- [ ] `git check-ignore` exit 0 on `agent/reports/audit-dummy.md`
- [ ] `git check-ignore` exit 1 on `agent/reports/.gitkeep`
- [ ] Nested path `agent/reports/a/b.md` is ignored (`**` not `*`)
- [ ] `npx tsx scripts/acp-validate.ts` green with local audits present
- [ ] Gitignore + validator + test + validate.md in **one** commit

## User-Observable Acceptance

`/acp-audit` can write a local report; `git status` does not list it; validate does not fail.

## Expected Output

### Files Created / Modified
- `agent/.gitignore`, `.gitignore` if needed
- `scripts/acp-validate.ts`, `scripts/acp-validate.test.ts`
- `agent/commands/acp.validate.md`

### Notes
Install-script gitignore is task-326. Tree purge is 328.
