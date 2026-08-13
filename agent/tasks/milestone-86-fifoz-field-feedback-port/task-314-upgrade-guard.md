---
id: task-314
milestone: M86
title: "upstream-delta register + upgrade-guard + version-update hook"
status: planned
priority: 5
complexity: high
estimated_hours: 5
created: 2026-08-14
started: null
completed:
phase: 2
depends_on: [task-307]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-04', 'F-114-11']
files_affected:
  - agent/upstream-delta.template.yml
  - agent/scripts/acp.upgrade-guard.sh
  - agent/scripts/acp.version-update.sh
  - agent/commands/acp.version-update.md
---

<!-- @acp.meta.task
topic: m86, fifoz, upgrade, guard
description: Adopt FIFOZ upgrade-collision register as a first-class ACP concept and run the guard after version updates.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D3
depends_on: task-307
status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Adopt FIFOZ upgrade-collision register as a first-class ACP concept and run the guard after version updates.

## Context

ADR-25. Inbox upstream-delta.yml and upgrade-guard.sh are portable. AE ships a **template** plus optional empty project file; guard reads `agent/upstream-delta.yml` if present. Hook version-update to run guard when file exists. Policy text: prefer-upstream-when-superseded.

## Steps

1. Port `acp.upgrade-guard.sh` (as-is logic; paths AE-compatible).
2. Add `agent/upstream-delta.template.yml` documenting schema; optionally create empty/minimal `agent/upstream-delta.yml` for AE self-collisions from task-310.
3. Populate AE collisions for files M86 actually edits (routing, common.sh, etc.) with greppable sentinels.
4. Wire `acp.version-update.sh` to invoke upgrade-guard at end when delta file exists (fail update soft or hard — document; prefer fail with clear remediation).
5. Update version-update command doc with the hook + policy.
6. Do not claim overwrite-safety from audit-080 is solved — guard is complementary.

## Verification

- [ ] Removing a sentinel makes guard exit non-zero
- [ ] Restoring sentinel makes guard exit 0
- [ ] version-update doc mentions guard
- [ ] No FIFOZ product paths in delta file

## User-Observable Acceptance

`bash agent/scripts/acp.upgrade-guard.sh --list` prints collision entries; deliberate sentinel deletion is detected.

## Expected Output

### Files Created / Modified
- `agent/upstream-delta.template.yml`
- `agent/scripts/acp.upgrade-guard.sh`
- `agent/scripts/acp.version-update.sh`
- `agent/commands/acp.version-update.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
