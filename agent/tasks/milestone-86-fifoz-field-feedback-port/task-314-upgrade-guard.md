---
id: task-314
milestone: M86
title: "upstream-delta register + upgrade-guard + version-update hook"
status: completed
priority: 5
complexity: high
estimated_hours: 5
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 2
depends_on: task-307, task-310
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-04', 'F-114-11']
files_affected:
  - agent/upstream-delta.template.yml
  - agent/upstream-delta.yml
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
status: completed
updated: 2026-08-14
@acp.meta.end -->

## Objective

Adopt FIFOZ upgrade-collision register as a first-class ACP concept and run the guard after version updates.

## Context

ADR-25. Inbox upstream-delta.yml and upgrade-guard.sh are portable. AE ships a **template** plus optional empty project file; guard reads `agent/upstream-delta.yml` if present. Hook version-update to run guard when file exists. Policy text: prefer-upstream-when-superseded.

## Steps

**Phase A — plumbing (may start once 307 done; complete after 310 for sentinel content):**
1. Port `acp.upgrade-guard.sh` (inbox logic; AE paths). Support `--list`.
2. Add `agent/upstream-delta.template.yml` documenting schema + prefer-upstream-when-superseded policy (ADR-25).
3. Create live `agent/upstream-delta.yml` for this repo.

**Phase B — populate (REQUIRES task-310 sentinel draft):**
4. Populate `collisions:` for every upstream-owned file M86 edits (routing.yml, acp.common.sh, proceed/commit docs, etc.) using task-310’s sentinel list. Greppable sentinels only (no fancy quotes that break grep -F).

**Phase C — hook (REQUIRED policy P-UG-1):**
5. Wire `acp.version-update.sh` to run upgrade-guard at end when `agent/upstream-delta.yml` exists. **HARD fail** (non-zero exit) on missing sentinel — never soft-warn-only. Print remediation: restore sentinel or delete entry after preferring upstream.
6. Note: script already supports `--diff/--preserve-project-core/--force/--yes` (post-audit-080). Do not regress those flags.
7. Update `acp.version-update.md` with the hook + HARD-fail policy.
8. Guard complements overwrite-safety — do not claim audit-080 is fully solved.

## Verification

- [x] Removing a sentinel makes guard exit non-zero
- [x] Restoring sentinel makes guard exit 0
- [x] version-update invokes guard and HARD-fails on miss when delta exists
- [x] version-update doc states HARD-fail policy
- [x] Collisions include every file from task-310 sentinel draft
- [x] No FIFOZ product paths in delta file

## User-Observable Acceptance

`bash agent/scripts/acp.upgrade-guard.sh --list` prints collision entries; deliberate sentinel deletion is detected.

## Expected Output

### Files Created / Modified
- `agent/upstream-delta.template.yml`
- `agent/upstream-delta.yml`
- `agent/scripts/acp.upgrade-guard.sh`
- `agent/scripts/acp.version-update.sh`
- `agent/commands/acp.version-update.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
Sentinels aligned with `agent/reports/m86-drafts/task-310-sentinels.md` / live wires from task-310.
