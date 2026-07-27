---
id: task-289
milestone: M83
title: "Tier C rules — error handling + naming (EH-03/04/07/08/09, NC-02/04/06/09)"
status: planned
priority: 4
complexity: medium
estimated_hours: 5
created: 2026-07-27
started: null
completed: null
phase: 3
depends_on: [task-283, task-284]
audit_findings: []
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-corpus/
---

## Objective

Ship the remaining Tier C error-handling and naming rules, reusing the Python brace-matching helper already used by EH-01/EH-02.

## Context

audit-102 Tier C. The brace-matcher at `acp.review-scan.sh:87-108` already walks function bodies; EH-03/04/07 extend it rather than adding new machinery. All matching runs on task-282's neutralised text.

NC-04 is notable as the only rule needing **no** source parsing — it is a pure filename check and therefore fully deterministic.

## Steps

1. **EH-03** HIGH — `catch` body that only logs (`console.log`/`console.error`) with no rethrow or typed return.
2. **EH-04** HIGH — `Promise.all(` outside `try` and without `.catch(`. Use token matching, not substring (F-103-02 lesson).
3. **EH-07** MEDIUM — `return` inside a `finally` block.
4. **EH-08** LOW — `class X extends Error` without `this.name` assignment.
5. **EH-09** HIGH — project-level: no `process.on('unhandledRejection'` anywhere. Emit once; WEB scope only.
6. **NC-02** MEDIUM — classes / interfaces / type aliases / React components not `PascalCase`.
7. **NC-04** LOW — file naming: `kebab-case.ts` for modules, `PascalCase.tsx` for React components.
8. **NC-06** LOW — single-character identifiers outside `for`-loop indices.
9. **NC-09** MEDIUM — exported functions in hook position not prefixed `use`.

## Verification

- [ ] EH-04 not suppressed by a body containing the substring `try` (regression fixture for F-103-02)
- [ ] EH-09 emits once per project, not per file
- [ ] NC-04 flags `MyModule.ts` and accepts `my-module.ts` and `MyComponent.tsx`
- [ ] NC-06 does not flag `for (let i = 0; …)`
- [ ] Aggregate precision ≥ 90% on the corpus

## User-Observable Acceptance

Deterministic rule count reaches ~38; `/acp-review --rules error-handling,naming` reports 9 further rule classes.
