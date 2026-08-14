---
id: task-309
milestone: M86
title: "/acp-ci command + abstract orchestrator + AE step bodies"
status: completed
priority: 5
complexity: high
estimated_hours: 8
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 1
depends_on: [task-308]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-02', 'F-114-05', 'F-114-06', 'F-114-07']
files_affected:
  - agent/commands/acp.ci.md
  - agent/scripts/acp.ci.sh
  - agent/scripts/acp.ci-steps.sh
  - agent/integrity-manifest.yaml
---

<!-- @acp.meta.task
topic: m86, fifoz, acp, ci, orchestrator
description: Ship `/acp-ci` that predicts AE CI via config-driven steps, enforcing all false-green contracts.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D1, FG-1, FG-2, FG-3, FG-4, FG-5, FG-7
depends_on: task-308
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Ship `/acp-ci` that predicts AE CI via config-driven steps, enforcing all false-green contracts.

## Context

Inbox `acp.ci.md`/`acp.ci.sh` are references. Port the **directive shape** and orchestrator control flow; replace step bodies with AE commands from task-305/308. Must implement: tiers, --only, --dry-run, --doctor, preflight, SKIP tri-state, zero-executed fail-closed, unknown-id non-zero, output_contains asserts, if-context status capture (never set +e under trap).

## Steps

1. Author `agent/commands/acp.ci.md` (adapt inbox; remove FIFOZ-only examples; document AE tiers).
2. Implement `agent/scripts/acp.ci.sh`:
   - `set -euo pipefail` + `trap ERR`
   - Load ci.yml via existing yaml helpers / python — no stack-specific forks
   - Preflight tools for selected tier before step 1
   - Execute in cost_rank order; print summary in ci_rank/CI job order
   - FG contracts enforced
3. Put AE step command bodies in `agent/scripts/acp.ci-steps.sh` (REQUIRED path — audit-115 F3-01; never top-level `scripts/acp-ci-steps.sh`). Keep orchestrator ignorant of what `validate` means beyond config.
4. Use `if cmd >out 2>&1; then s=0; else s=$?; fi` for tools that may exit non-zero. **Never** use `set +e` under `trap ERR`.
5. Probe tools with `bash -c 'command -v …'` not interactive shell.
6. Banner examples must distinguish PASS vs PASS (with SKIPs).
7. **REQUIRED (P-CI-2)**: regenerate `agent/integrity-manifest.yaml` in this task when scripts land. Task-319 regenerates again after review-scan merge — do not skip here.

## Verification

- [x] `bash agent/scripts/acp.ci.sh --doctor` exits 0, runs no gates
- [x] `bash agent/scripts/acp.ci.sh --only nonexistent` exits non-zero
- [x] Empty plan cannot PASS (test in 311; smoke here)
- [x] No FIFOZ product paths in scripts
- [x] Command doc has Agent Directive + Verification + User-observable section per template norms

## User-Observable Acceptance

`bash agent/scripts/acp.ci.sh --static` prints a PASS/FAIL/SKIP table whose step ids map to AE CI jobs.

## Expected Output

### Files Created / Modified
- `agent/commands/acp.ci.md`
- `agent/scripts/acp.ci.sh`
- `agent/scripts/acp.ci-steps.sh`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
