---
id: task-311
milestone: M86
title: "E2E /acp-ci — real execution + fail-closed behaviors"
status: planned
priority: 5
complexity: high
estimated_hours: 5
created: 2026-08-14
started: null
completed:
phase: 1
depends_on: [task-309]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-06', 'F-114-07']
files_affected:
  - e2e/acp.ci.test.sh
  - agent/schemas/command-e2e-coverage.yaml
  - scripts/acp-validate.test.ts
  - scripts/acp-validate.ts
---

<!-- @acp.meta.task
topic: m86, fifoz, e2e, acp, ci
description: Prove `/acp-ci` with assertions that execute real static gates and fail closed on empty/unknown plans — dry-run alone is insufficient.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: FG-3, FG-4, FG-5, FG-6
depends_on: task-309
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Prove `/acp-ci` with assertions that execute real static gates and fail closed on empty/unknown plans — dry-run alone is insufficient.

## Context

feedback-009 §2.5–2.7: FIFOZ claimed verified after dry-run; empty `--only` PASS; exit-code-only review-scan. Adapt inbox `acp.ci.test.sh`; add AE-specific cases. Record executed_steps in coverage yaml.

## Steps

1. Port/adapt E2E from inbox; remove FIFOZ-only assertions.
2. Required cases:
   - --help / --doctor exit 0, no gate side effects
   - --only unknown → non-zero
   - --dry-run lists steps, exit 0, executes nothing
   - --static executes ≥1 real cheap gate and asserts expected success markers
   - If a step uses output_contains, fail the step when output lacks it even if exit 0 (fixture or injectable stub)
   - SKIP path: missing optional tool → SKIP row, banner not claiming full parity
3. **REQUIRED (F3-03 / P-VAL-1)**: extend `agent/schemas/command-e2e-coverage.yaml` to allow optional `executed_steps: [id, ...]` on command rows. Update `scripts/acp-validate.ts` → `validateCommandE2eCoverage` to:
   - accept the field
   - for `acp.ci`, `acp.pr`, and `acp.upgrade-guard` (when present): **require** non-empty `executed_steps`
   - add/extend unit tests in `scripts/acp-validate.test.ts`
4. Register `acp.ci` with suites + non-empty `executed_steps` listing really executed static step ids (not dry-run-only).
5. Run the suite on macOS bash 3.2; note Linux CI expectation.

## Verification

- [ ] e2e/acp.ci.test.sh passes locally
- [ ] Coverage yaml lists executed_steps including a non-dry-run step
- [ ] Unknown id and zero-executed cases covered
- [ ] validateCommandE2eCoverage accepts executed_steps; acp.ci row required non-empty
- [ ] acp-validate.test.ts covers the new field

## User-Observable Acceptance

`bash e2e/acp.ci.test.sh` exits 0 and includes a test name proving `--only bogus` fails.

## Expected Output

### Files Created / Modified
- `e2e/acp.ci.test.sh`
- `agent/schemas/command-e2e-coverage.yaml`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
