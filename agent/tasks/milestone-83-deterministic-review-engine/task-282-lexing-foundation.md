---
id: task-282
milestone: M83
title: "Precision foundation — comment/string stripping + token-boundary matching"
status: planned
priority: 5
complexity: high
estimated_hours: 6
created: 2026-07-27
started: null
completed: null
phase: 1b
depends_on: [task-281]
audit_findings: [F-103-01, F-103-02]
blocks: [task-286, task-287, task-288, task-289]
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-scan/
---

## Objective

Stop matching rule patterns against raw source text. Strip comments and string literals before applying line regexes, and replace substring containment tests with token-boundary matching.

## Context

**F-103-01 (HIGH):** the scanner regexes raw lines. Measured 2/2 false positives on a clean fixture — one TS-01 hit on a code comment, one on a string literal. This is the root cause of the precision failure and of F-103-05/06.

**F-103-02 (HIGH):** `acp.review-scan.sh:102` tests `if "try" not in body` — a **substring**. Any async body containing `retry`, `telemetry`, `entry`, `country`, `industry`, `symmetry`, `sentry` silently disables EH-01. Proven: an async function with an unhandled `await` and the string `"we should retry this later"` produced no finding. Those words are common in exactly the async retry/telemetry code EH-01 targets.

**This task gates Phase 3.** Expanding the ruleset before it lands multiplies false positives ~4×.

## Steps

1. Add a preprocessing pass for TS/JS content that neutralises (replaces with equivalent-length blanks, preserving line numbers):
   - `//` line comments and `/* */` block comments
   - single-, double-, and backtick-quoted string literals, honouring escapes
   - Preserve line/column numbering so reported positions stay accurate.
2. Apply all line-based rules (SC-01, TS-01, TS-02, AP-01, NC-01) to the neutralised text; report positions from the original.
3. Replace the EH-01 substring test with token matching — `\btry\b` and `\.catch\s*\(` on the neutralised body.
4. Apply the same neutralisation to the EH-02 empty-catch matcher.
5. Add fixtures to `tests/fixtures/review-scan/` for each defect above, wired into task-281's suite.

## Verification

- [ ] `// … : any …` in a comment produces no TS-01 finding
- [ ] `"use as any …"` in a string produces no TS-01 finding
- [ ] `async` fn whose body contains `"retry"` **and** an unhandled `await` **is** flagged EH-01
- [ ] Reported line numbers still point at the original source lines
- [ ] Template literals with `${}` interpolation handled without crashing
- [ ] No regression in the 8 existing rules' true positives

## User-Observable Acceptance

Findings point at real code. Comments and strings never produce findings.
