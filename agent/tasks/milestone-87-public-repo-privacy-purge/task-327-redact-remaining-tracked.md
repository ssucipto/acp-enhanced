---
id: task-327
milestone: M87
title: "Redact remaining tracked files ($HOME, consumer internals)"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 3
depends_on: [task-322]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-03', 'F-118-06', 'F-118-07']
files_affected:
  - agent/memory/sessions.md
  - CHANGELOG.md
  - agent/progress.yaml
---

<!-- @acp.meta.task
topic: m87, redact, home-path, consumer-internals
description: Strip absolute home paths and consumer product internals from files that remain tracked after the reports purge.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D6, D7
depends_on: task-322
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

After reports/feedback leave git, remaining tracked files must not still contain `$HOME` paths or consumer product internals. Keep IG-37 email in `identity.yml`. Keep consented consumer **names** in CHANGELOG if already public; drop internals.

## Context

audit-118 listed `$HOME` in audit-114 and measure logs (those files leave with the tree). Also scan sessions, progress `active_handoff.path`, consolidated feedback docs, and wiki snippets that quote inbox paths.

## Steps

1. Grep tracked files (exclude `agent/reports` and `agent/feedback` bodies you are about to delete) for `/Users/`, `FIFOZ` product-spec dumps, vendor `orgId`, `isProUser`.
2. Redact or generalize hits. Replace `active_handoff.path` if it points at a report that will not exist on clone (completed handoff: keep status, drop or generalize path).
3. Do **not** paste the original secret/path into the replacement commit message or this task file.
4. Keep `agent/core/identity.yml` team email (F-118-08 / IG-37).
5. Do not stamp F-118-* here — history still has the blobs until 331.

## Verification

- [ ] `git grep` on tracked files has no `/Users/<operator>`
- [ ] No vendor billing UUID in tracked files
- [ ] identity.yml email unchanged
- [ ] progress.yaml handoff path does not require a public report body

## User-Observable Acceptance

A GitHub file search on the tip after 328 does not show operator home directories.

## Expected Output

### Files Created / Modified
- Remaining tracked docs from the grep (sessions, CHANGELOG excerpts, progress.yaml, any consolidated feedback doc)

### Notes
This is tip hygiene. History rewrite is 330.
