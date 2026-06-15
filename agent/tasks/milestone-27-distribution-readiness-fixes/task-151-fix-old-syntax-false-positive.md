---
id: task-151
milestone: M27
title: Fix @acp.meta.task false positive in acp.task-create.md
status: in_progress
priority: 5
complexity: trivial
estimated_hours: 0.25
created: 2026-05-04
started: 2026-05-04
completed:
---

<!-- @acp.meta.task
topic: fix, acpmetatask, false, positive, in, acptask-createmd
description: Fix @acp.meta.task false positive in acp.task-create.md
milestone: M27
status: in_progress
updated: 2026-05-04
@acp.meta.end -->


## Objective

Fix a false positive in `e2e/acp.command-docs.test.sh` caused by prose references to `@acp.meta.task` as a YAML field name in `agent/commands/acp.task-create.md`.

## Context

The command-docs E2E test scans every command doc for old-syntax invocations using `grep -c "@acp\."`. This correctly catches command invocations like `@acp.proceed`, but it also matches prose text that mentions `@acp.meta.task` as a YAML field name reference. Two lines in `acp.task-create.md` trigger this false positive:

- Line 288: `...Use the YAML frontmatter completed: field and the @acp.meta.task depends_on: field instead.`
- Line 306: `...The YAML frontmatter completed: field and @acp.meta.task depends_on: field supersede them.`

These are not command invocations — they're describing a YAML schema field called `meta.task`. The test should not flag them, but the correct fix is to reword the prose rather than change the test (the test pattern is appropriate for its purpose).

## Implementation

Reword both lines to drop the `@acp.` prefix. Use backtick code span for the field reference so it's clear this is a YAML key, not a command.

**Line 288 change**: Replace `the @acp.meta.task depends_on: field` → `the \`meta.task\` \`depends_on:\` field`

**Line 306 change**: Replace `@acp.meta.task depends_on: field` → `the \`meta.task\` \`depends_on:\` field`

## Expected Output

### Files Modified
- `agent/commands/acp.task-create.md` — lines 288 and 306 reworded

## Verification
- [ ] `grep -c "@acp\." agent/commands/acp.task-create.md` returns 0 (or only legitimate command invocations)
- [ ] `bash e2e/acp.command-docs.test.sh 2>&1 | grep "acp.task-create"` shows PASS (no old-syntax failures)

## User-Observable Acceptance
`bash e2e/acp.command-docs.test.sh` passes 361/361 tests (no failures).
