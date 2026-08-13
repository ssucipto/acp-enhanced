---
id: task-319
milestone: M86
title: "Package.yaml, domain, coverage, integrity-manifest, AGENT entries"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: null
completed:
phase: 4
depends_on: [task-311, task-313, task-315]
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
status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Complete crosscut registration for new commands/scripts so validate/parity passes — no single-file done.

## Context

crosscut skill: never update only one of AGENT/README/CHANGELOG/package. CHANGELOG/version are task-321; this task prepares all registrations.

## Steps

1. Add acp.ci / acp.pr / upgrade-guard to package.yaml commands/scripts.
2. Update domain.yml command taxonomy sections.
3. Ensure command-e2e-coverage rows exist with executed_steps.
4. Regenerate integrity-manifest.yaml.
5. Add AGENT.md + README command table rows for /acp-ci and /acp-pr.
6. Run `npx tsx scripts/acp-validate.ts` and fix parity gaps.
7. Confirm all wrappers from 313 still present.

## Verification

- [ ] acp-validate.ts exits 0
- [ ] package.yaml lists new scripts
- [ ] AGENT.md documents both commands
- [ ] integrity-manifest includes new scripts

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
