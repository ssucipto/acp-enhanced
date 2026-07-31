---
id: task-304
milestone: M85
title: "Verify and close A-110-04, A-110-05, A-110-07"
status: not_started
priority: 5
complexity: low
estimated_hours: 3
created: 2026-07-28
started: null
completed: null
phase: 3
depends_on: [task-303]
audit_findings: [A-110-04, A-110-05, A-110-07]
files_affected:
  - agent/memory/audit-carryovers.md
  - agent/memory/sessions.md
---

## Objective

Confirm each carryover is actually resolved by measurement, then stamp it — and specifically prove the macOS flake is gone rather than merely absent once.

## Context

A-110-07 is the trap in this task. `acp.preferences-validate.test.sh` already passes intermittently: on identical code (`740db89`) the push run was green on all three platforms while the PR run failed on macOS. **One green macOS run proves nothing.** Closure requires repeated runs.

audit-111 also retracted A-110-06 as a false positive — `acp.review-scan.sh` never sourced `acp.coderabbit.sh`; a `grep -l` had matched a case pattern in an SH-01 allowlist. That was the third substring-vs-structure error in three audits, so any structural claim made while closing these must be re-verified with an anchored pattern.

## Steps

1. Re-measure every success criterion in the milestone doc and record actual values beside the targets.
2. **A-110-04** — measure `coderabbit_active()`; stamp only if under 200ms.
3. **A-110-05** — measure `yaml_parse` and a full `get_preference`. Note the milestone amended the `yaml_parse` criterion to the measured architectural floor (360 ms on the real preference file, down from 1369 ms); judge against that, not the original <150 ms.
4. **A-110-07** — root cause is already gone: `preferences-validate` runs **28s** against an unchanged 180s limit (was 159s, a 12% margin). Still trigger the E2E workflow **3 times** and require macOS green in all 3 — the whole point of this carryover is that one green run proved nothing. If any run fails, do not stamp; record the observed variance instead.
5. Stamp each with `status: fixed`, `fix_applied_date`, and `verified_in_audit`.
6. Write the session entry and any lesson. Verify the memory diff shows insertions and **zero deletions** — the audit-107 corruption removed a neighbouring entry's header, and the duplicate-key gate now catches it.
7. Re-verify any structural claim with an anchored pattern before recording it.

## Verification

- [ ] Every success criterion re-measured, actuals recorded next to targets
- [ ] macOS E2E green in 3 consecutive runs, run IDs recorded
- [ ] A-110-04 / A-110-05 / A-110-07 stamped with dates and verifying audit
- [ ] `npx tsx scripts/acp-validate.ts` exit 0, including the duplicate-key gate
- [ ] Memory diff shows zero deletions
- [ ] No test timeout was raised anywhere in the milestone

## User-Observable Acceptance

`/acp-audit` reports zero pending carryovers from the A-110 series, and three consecutive CI runs show macOS E2E green.
