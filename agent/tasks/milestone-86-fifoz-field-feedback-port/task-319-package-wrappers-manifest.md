---
id: task-319
milestone: M86
title: "Package.yaml, domain, coverage, integrity-manifest, AGENT entries"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 4
depends_on: task-311, task-313, task-315, task-316
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-02', 'F-114-03']
files_affected:
  - package.yaml
  - agent/wiki/domain.yml
  - agent/schemas/command-e2e-coverage.yaml
  - agent/integrity-manifest.yaml
  - AGENT.md
  - README.md
---

<!-- @acp.meta.task
topic: m86, fifoz, package, wrappers, manifest
description: Complete crosscut registration for new commands/scripts so validate/parity passes — no single-file done.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D1, D2
depends_on: task-311, task-313, task-315
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Complete crosscut registration for new commands/scripts so validate/parity passes — no single-file done.

## Context

crosscut skill: never update only one of AGENT/README/CHANGELOG/package. CHANGELOG/version are task-321; this task prepares all registrations.

## Steps

1. **REQUIRED exact package.yaml entries** (file-shaped, matching existing style):
   - `contents.commands`: `acp.ci.md`, `acp.pr.md`
   - `contents.scripts`: `acp.ci.sh`, `acp.pr.sh`, `acp.upgrade-guard.sh`, `acp.ci-steps.sh`
2. Update domain.yml command taxonomy sections for ci/pr/upgrade-guard.
3. Ensure coverage rows exist; `executed_steps` non-empty for acp.ci / acp.pr / acp.upgrade-guard (P-VAL-1).
4. **REQUIRED**: regenerate integrity-manifest.yaml **after** task-316 merge (this task depends on 316).
5. Add AGENT.md + README command table rows for `/acp-ci` and `/acp-pr`.
6. Run `npx tsx scripts/acp-validate.ts` and fix parity gaps.
7. Confirm all eight wrappers from 313 still present.

## Verification

- [x] acp-validate.ts exits 0
- [x] package.yaml lists new scripts
- [x] AGENT.md documents both commands
- [x] integrity-manifest includes new scripts

## User-Observable Acceptance

`npx tsx scripts/acp-validate.ts` exits 0 after registrations; README mentions `/acp-ci`.

## Expected Output

### Files Created / Modified
- `package.yaml`
- `agent/wiki/domain.yml`
- `agent/schemas/command-e2e-coverage.yaml`
- `agent/integrity-manifest.yaml`
- `AGENT.md`
- `README.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
