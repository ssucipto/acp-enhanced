---
id: task-322
milestone: M87
title: "Lock ADR-27 + citation map of tracked reports/feedback"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 0
depends_on: []
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04', 'F-119-05']
files_affected:
  - agent/memory/decisions.md
  - agent/design/local.public-repo-privacy-purge.md
  - agent/milestones/milestone-87-public-repo-privacy-purge.md
---

<!-- @acp.meta.task
topic: m87, adr-27, privacy, citation-map
description: Confirm ADR-27 and cookbook; inventory every command/E2E/wiki that assumes tracked reports.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1, D6
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Produce a **path-only** citation map so 324–327 cannot miss a live reference. Confirm the design cookbook (CB-1…CB-6) has no secrets.

## Context

ADR-27 and the design already exist. Do **not** skip this task. Audit-119 listed extra files beyond the first `files_affected` lists.

## Steps

1. Re-read ADR-27 and design cookbook. Confirm no consumer spec bodies, no `$HOME` usernames, no vendor account identifiers.
2. Run (record **paths only** in this task’s notes):

```bash
rg -l 'agent/reports|agent/feedback|validateProtocolDirAddability|Untracked evidence' \
  agent/commands agent/scripts scripts e2e tests agent/wiki agent/patterns \
  agent/core .github docs AGENT.md README.md package.yaml
```

3. Classify each hit: (a) local writer — keep, (b) validator/E2E — 324/325, (c) install/pattern — 326, (d) leftover pointer in remaining tracked files — 327.
4. Confirm F-R006-* is **not** on the map.
5. Do not `git add` any `agent/reports/` or `agent/feedback/` bodies (CB-6).

## Verification

- [ ] Cookbook CB-1…CB-6 present in design
- [ ] Citation map includes at least: `acp.install.sh`, `acp.package-create.sh`, `acp.design-spec.md`, `acp.validate.md`, `acp.ci.sh`, `architecture.md`, `acp-validate.test.ts`
- [ ] No new secrets in planning docs

## User-Observable Acceptance

Task notes list every file 324–327 must touch.

## Expected Output

### Files Created / Modified
- This task file (citation map notes)

### Notes
Source: audit-119. Cookbook is canonical; do not invent flags.
