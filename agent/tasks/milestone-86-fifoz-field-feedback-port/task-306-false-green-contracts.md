---
id: task-306
milestone: M86
title: "False-green contracts in constraints.yml + pattern"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: null
completed:
phase: 0
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-05', 'F-114-06', 'F-114-07']
files_affected:
  - agent/core/constraints.yml
  - agent/patterns/local.false-green-contracts.md
---

<!-- @acp.meta.task
topic: m86, fifoz, false, green, contracts
description: Encode FG-1…FG-7 as hard rules agents and scripts must follow, including `set +e` vs ERR trap.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: FG-1, FG-2, FG-3, FG-4, FG-5, FG-6, FG-7

status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Encode FG-1…FG-7 as hard rules agents and scripts must follow, including `set +e` vs ERR trap.

## Context

feedback-009 found `set +e` does not suppress ERR traps; empty `--only` plans PASS; exit-code proxies miss CI greps. These must live in constraints + a pattern before `/acp-ci` is written so implementers cannot "discover" them later.

## Steps

1. Add to `agent/core/constraints.yml` → `bash_rules`:
   - `set_plus_e_does_not_suppress_err_trap` (document `if cmd; then s=0; else s=$?; fi`)
   - `never_report_success_with_zero_units_executed`
   - `assert_output_contract_not_exit_code_alone` (when contract is output)
   - `probe_dependencies_in_execution_context` (bash -c, not agent shell functions)
2. Create `agent/patterns/local.false-green-contracts.md` documenting FG-1…FG-7 with bad/good examples from feedback-009.
3. Cross-link from `agent/skills/scripts.md` if present (one paragraph) OR from pattern only — do not bloat AGENTS.md.
4. Do not implement `/acp-ci` here — contracts only.

## Verification

- [ ] constraints.yml contains the four new bash_rules (or equivalent named FG rules)
- [ ] Pattern file exists with FG-1…FG-7 and examples
- [ ] No command scripts changed in this task

## User-Observable Acceptance

An agent reading `constraints.yml` and the new pattern can state why `set +e` under `trap ERR` aborts and why empty plans must not PASS.

## Expected Output

### Files Created / Modified
- `agent/core/constraints.yml`
- `agent/patterns/local.false-green-contracts.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
