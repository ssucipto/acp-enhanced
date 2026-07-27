---
id: task-281
milestone: M83
title: "Executing E2E harness for the review scanner"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 1
depends_on: [task-280]
audit_findings: [F-102-08]
files_affected:
  - e2e/acp.review-scan.test.sh
  - tests/fixtures/review-scan/
  - agent/wiki/domain.yml
---

## Objective

Add an E2E suite that **executes** `acp.review-scan.sh` against committed fixtures and asserts findings, rather than asserting documentation strings.

## Context

**F-102-08 (MEDIUM):** `e2e/acp.review.test.sh` is 248 lines of `assert_contains` against `acp.review.md`, `package.yaml`, and `taxonomy.yml`. It never invokes the scanner. This is why the multi-path scope loss and the missing `--self` flag went undetected from 2026-07-15 to 2026-07-27.

This task is the milestone's guardrail: every later phase depends on it to prevent silent regression.

## Steps

1. **(F-104-04)** `mkdir -p tests/fixtures/review-scan/` — the `tests/fixtures/` directory does **not** exist yet. Addability is verified (no gitignore rule catches it), but M81 task-270 also claims to create `tests/fixtures/`, so tolerate pre-existence. Commit fixture files (positive and negative per rule).
2. Create `e2e/acp.review-scan.test.sh` following the existing E2E conventions (no `set -e`; `assert_*` helpers).
3. Assert behaviours, not docs:
   - multi-path: two dirs → findings from both
   - `--self`: exits 0, scans four paths, skips missing dirs
   - `.mjs`/`.cjs` traversal
   - `--ci` exits 1 on CRITICAL/HIGH, 0 on MEDIUM/LOW only
   - `--json` emits parseable JSON (`jq` round-trip)
   - missing path exits 2
   - SH-01 allowlist: sourced libraries exempt (F-M82-05 behaviour preserved)
4. **(F-104-03)** Register in `agent/schemas/command-e2e-coverage.yaml` by **appending to the existing `acp.review:` → `suites:` array**. The registry keys on *commands*, not scripts — creating an `acp.review-scan:` key would match no command doc and could fail `validateCommandE2eCoverage`.
5. **(F-104-07)** Correct `agent/wiki/domain.yml:390`, which currently claims `acp.review.test.sh` covers "acp.review-scan.sh behavioral fixtures". That coverage never existed (F-102-08). Move the claim to this suite and fix `test_count`.
5. Keep `e2e/acp.review.test.sh` for doc assertions — this suite is additive, not a replacement.

## Verification

- [x] Suite fails when task-280's fixes are reverted (proves it detects the real defects)
- [x] All assertions pass on the fixed scanner
- [x] Appended to `acp.review.suites[]` (no new registry key); `acp-validate.ts` E2E coverage check passes
- [x] `domain.yml:390` no longer claims fixture coverage that does not exist
- [x] Runs on macOS + Linux; no CRLF issues

## User-Observable Acceptance

`bash e2e/acp.review-scan.test.sh` executes the scanner and fails loudly if scanner behaviour regresses.
