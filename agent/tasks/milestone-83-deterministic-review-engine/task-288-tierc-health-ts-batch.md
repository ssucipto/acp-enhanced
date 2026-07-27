---
id: task-288
milestone: M83
title: "Tier C rules — code health + TypeScript (CH-01/03/06/07, TS-03/04/06/07/08/13)"
status: completed
priority: 4
complexity: medium
estimated_hours: 5
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 3
depends_on: [task-283, task-284]
audit_findings: []
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-corpus/
---

## Objective

Ship the code-health and TypeScript-strictness Tier C rules, including two config-file rules that read `tsconfig.json`.

## Context

audit-102 measured false-positive risk on this batch specifically:

- CH-01 `TODO|FIXME` → 28 raw hits on this repo, but `e2e/*.test.sh` lines like `assert_not_contains "$STEPS" "TODO"` are **not** violations
- CH-06 `console.log` → hits `acp-validate.ts` and `acp-dispatch.ts`, which are **CLI tools where console output is the product**

Both need allowlisting, and both benefit from task-283's test-file exclusion.

## Steps

1. **CH-01** MEDIUM — `TODO`/`FIXME` without a linked `task-NNN`. Excluded by test-file rules; string literals already neutralised by task-282.
2. **CH-03** MEDIUM — functions exceeding 50 lines (brace counting on neutralised text).
3. **CH-06** LOW — `console.log`/`console.debug`. Allowlist CLI entry points via a configurable path list; default-exclude `scripts/` in this repo and document why.
4. **CH-07** LOW — imported identifiers never referenced in the file body.
5. **TS-03** MEDIUM — `as any` without an explanatory comment on the same or preceding line.
6. **TS-04** MEDIUM — `!` non-null assertion without an explanatory comment.
7. **TS-06** LOW — plain `enum` (prefer `const enum` / union literals).
8. **TS-07** MEDIUM — `catch (e)` without `: unknown`.
9. **TS-08** HIGH + **TS-13** MEDIUM — read `tsconfig.json`; flag missing `strictNullChecks`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`. Project-level finding, emitted once, not per-file.

## Verification

- [x] E2E assertion strings containing `TODO` produce no CH-01 finding
- [x] CLI entry points produce no CH-06 finding; a genuine app-code `console.log` fixture does
- [x] TS-03/TS-04 recognise explanatory comments on the same and preceding line
- [x] TS-08/TS-13 emit once per project, not per file; no finding when `tsconfig.json` is absent
- [x] Aggregate precision ≥ 90% on the corpus

## User-Observable Acceptance

`/acp-review --rules code-health,typescript` reports 10 additional rule classes without flagging this repo's own CLI tools or test assertions.
