---
id: task-312
milestone: M86
title: "/acp-pr command with CI gate delegation"
status: completed
priority: 5
complexity: high
estimated_hours: 5
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 1b
depends_on: [task-311]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-03']
files_affected:
  - agent/commands/acp.pr.md
  - agent/scripts/acp.pr.sh
---

<!-- @acp.meta.task
topic: m86, fifoz, acp, pr, delegation
description: Ship `/acp-pr` that prepares/opens PRs and **only** runs gates by calling `acp.ci.sh`.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D2
depends_on: task-311
status: completed
updated: 2026-08-14
@acp.meta.end -->

## Objective

Ship `/acp-pr` that prepares/opens PRs and **only** runs gates by calling `acp.ci.sh`.

## Context

Inbox pr.md v1.2.0 is the shape. Remove FIFOZ CodeRabbit/m50 specifics or make them optional via preferences. Branch safety must respect AE git_workflow (develop → mainline).

## Steps

1. Author `acp.pr.md` from inbox; retarget production_branch to `mainline`, working branch `develop`.
2. Implement `acp.pr.sh`:
   - Branch safety check (identity.yml git_workflow)
   - Gate delegation table: default→`--fast`, `--strict-local`→`--full`, release base→full
   - **Grep the script: no duplicated tsc/lint/test gate implementations**
   - Metadata derivation (--auto) from commits since base
   - Optional gh pr create; dry-run mode
3. CodeRabbit path-filter check: if `acp.coderabbit.sh` / coderabbit preferences exist, run the check; if not configured, emit **SKIP** (not silent pass) with install/config hint.
4. Document that `/acp-ci --fast` beforehand is feedback; this step is enforcement.
5. **FORBIDDEN**: any duplicated tsc/lint/test/shellcheck gate implementation inside `acp.pr.sh`.

## Verification

- [x] `rg -n "tsc|jest|eslint" agent/scripts/acp.pr.sh` shows no gate implementations (or only string mentions in help)
- [x] Script calls `acp.ci.sh`
- [x] --dry-run prints plan without network

## User-Observable Acceptance

`bash agent/scripts/acp.pr.sh --dry-run` prints `delegating to: acp.ci.sh --fast` (or equivalent).

## Expected Output

### Files Created / Modified
- `agent/commands/acp.pr.md`
- `agent/scripts/acp.pr.sh`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
Landed from `agent/reports/m86-drafts/acp.pr.*.draft`. CodeRabbit SKIP when `.coderabbit.yaml` / configurables absent (script may still exist as detection library).
