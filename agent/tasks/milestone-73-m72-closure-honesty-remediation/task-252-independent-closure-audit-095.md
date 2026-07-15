---
id: task-252
milestone: M73
title: "Independent closure audit-095 — seeded negative probes"
status: planned
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-07-15
started: null
completed: null
route: route-241
audit_findings: [F-094-02, F-094-06]
depends_on: [task-248, task-249, task-250, task-251]
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Produce audit-095 as an **independent** re-verification of M72 runtime fixes with mandatory seeded negative probes. Supersede audit-093 self-certification.

## Context

audit-093 was written by the M72 implementing agent without negative probes (F-094-02). F-091 carryovers have inconsistent `verified_in_audit: task-241` instead of closure audit (F-094-06).

**Independence rule**: Run `/acp-audit M72 closure re-verify` in a fresh session OR explicitly document that the auditor did not implement tasks 240–247.

## Steps

1. Confirm tasks 248–251 complete (restored carryovers, green sweep, D4 ERROR)
2. Execute design D2 seeded probes — document before/after for each:
   - Instruction-file hash mismatch → ERROR → restore
   - Dot-stray in `.claude/commands/` → ERROR → delete
   - Missing wrapper rename → ERROR → restore
   - package.yaml version off → ERROR → restore
   - D9 probe file in `agent/reports/` → addable → remove
3. Run live positive probes: validate, vitest, shellcheck, manifest verify, D9 file counts
4. Write `agent/reports/audit-095-m72-independent-closure.md` with PASS/FAIL per finding
5. On PASS: stamp F-091-01..14 and F-092-01..04 carryovers `verified_in_audit: audit-095`
6. Append F-094-01..10 to carryovers as `fixed` with `verified_in_audit: audit-095` (or audit-096 if fixed in later tasks)

## Verification

- [ ] audit-095 report exists with 5 seeded probe sections (command + output)
- [ ] Verdict PASS only if all probes behave correctly
- [ ] F-091-* carryovers cite `audit-095` not `task-241` or `audit-093`
- [ ] Implementing agent identity disclosed in report metadata
- [ ] audit-093 cross-linked as SUPERSEDED

## User-Observable Acceptance

M72 closure has third-party-quality evidence — not self-signed.
