---
id: task-80
title: Add CHANGELOG [6.2.2] block for M20 fixes
milestone: M21
task_type: docs
complexity: low
executor: Persona A (Copilot)
files_affected:
  - CHANGELOG.md
created: 2026-05-01
completed: 2026-05-01
---

<!-- @acp.meta.task
topic: problem
description: Add CHANGELOG [6.2.2] block for M20 fixes
milestone: M21
status: draft
updated: 2026-05-01
@acp.meta.end -->


## Problem

M20 (commit 393d9e6) fixed 20+ bugs and bumped the version to 6.2.2, but no CHANGELOG entry
exists for this version. The CHANGELOG only has a [6.2.1] block.

## Required CHANGELOG entry

Add `## [6.2.2] - 2026-05-01 — M20 Consistency Cleanup` above the [6.2.1] block.

Content should cover all 5 task categories from M20:
- BUG-A: 9 directive headers with `@acp-*` hyphen notation
- BUG-B: 26 body-text `@acp-*` refs in 5 command files
- BUG-C: AGENT.md directory tree comments
- BUG-D: 13 missing commands + 1 script added to package.yaml
- BUG-E: CHANGELOG entry for post-M19 audit (afcf61d)

## Acceptance Criteria

- [ ] `## [6.2.2]` block exists in CHANGELOG.md
- [ ] Block is positioned above the [6.2.1] block (newest first)
- [ ] Documents all 5 M20 bug categories
