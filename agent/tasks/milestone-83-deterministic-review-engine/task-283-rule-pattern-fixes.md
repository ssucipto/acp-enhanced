---
id: task-283
milestone: M83
title: "Rule pattern fixes — TS-01, TS-02, NC-01, test/fixture exclusion"
status: planned
priority: 5
complexity: medium
estimated_hours: 5
created: 2026-07-27
started: null
completed: null
phase: 1b
depends_on: [task-282]
audit_findings: [F-103-04, F-103-05, F-103-06, F-103-07]
blocks: [task-286, task-287, task-288, task-289]
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-scan/
---

## Objective

Fix the four recall defects measured in audit-103 so the existing rules detect the forms they claim to cover.

## Context

Measured recall on seeded fixtures — each item below was **missed**:

**F-103-04 (HIGH) TS-02, 0/4:** pattern `^export (async )?function [a-zA-Z0-9_]+\([^)]*\)\s*\{` cannot match `export const f = () =>`, `export function f<T>(`, `export default function`, or parameters spanning lines.

**F-103-05 (MEDIUM) TS-01, 0/2:** `:\s*any\b|as\s+any\b` misses generic positions — `Record<string, any>`, `Promise<any>`.

**F-103-06 (MEDIUM) NC-01, 0/2:** `^(const|let|var)` is anchored at column 0, so every indented declaration is skipped — i.e. most real code.

**F-103-07 (MEDIUM):** traversal excludes only `node_modules` and `.git`. Test fixtures routinely hold placeholder credentials; flagging them CRITICAL is the classic credibility-destroying false positive.

## Steps

1. **TS-02** — broaden to cover: exported arrow functions (`export const f = (…) =>`), generic signatures (`function f<T>(`), `export default function`, and multi-line parameter lists (accumulate until balanced `)`).
2. **TS-01** — add generic-argument positions: `<any>`, `<…, any>`, `<any, …>`.
3. **NC-01** — allow leading whitespace: `^[[:space:]]*(const|let|var)\b`.
4. **Test/fixture exclusion** — skip paths matching `*test*`, `*spec*`, `*fixture*`, `*__mocks__*`, `*.generated.*`, `*.min.js` by default; add `--include-tests` to opt back in.
5. Add a fixture per sub-case to task-281's suite.

## Verification

- [ ] All 4 TS-02 forms from the audit-103 fixture are detected
- [ ] `Record<string, any>` and `Promise<any>` detected
- [ ] Indented `const my_snake_var` detected
- [ ] A fixture file with a placeholder secret is skipped by default, flagged with `--include-tests`
- [ ] No new false positives on the clean fixture
- [ ] Exclusion list documented in `acp.review.md`

## User-Observable Acceptance

Recall on the seeded corpus rises from ≈8% toward the ≥90% target; test fixtures no longer emit CRITICAL noise.
