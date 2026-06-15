---
id: route-167
title: Add windows-latest to E2E CI matrix
task_type: ci-cd-setup
milestone: M61
complexity: medium
executor: copilot
context_required:
  - skills/testing.md
files_affected:
  - .github/workflows/e2e-tests.yaml
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Add a `windows-latest` runner to the E2E test matrix so the documented Windows target is actually tested in CI.

## Context

`e2e-tests.yaml` matrix is `[ubuntu-latest, macos-latest]` only, yet Windows is a documented target with dedicated QUICKSTART docs (audit-065 HIGH-065-005). The `.gitattributes` LF enforcement (integrity-001 fix) is a prerequisite and is already committed.

## Steps

1. Add `windows-latest` to the `strategy.matrix.os` array in `e2e-tests.yaml`.
2. Ensure bash availability on Windows runner (Git Bash is preinstalled; set `shell: bash` for steps).
3. Address Windows-specific issues likely to surface:
   - Line endings (verify .gitattributes covers `*.sh`).
   - Path separators / `mktemp` availability under Git Bash.
   - `--skip-network` honored.
4. If certain suites are not Windows-portable, mark them skipped on Windows with a documented reason rather than failing.
5. Iterate until the Windows job is green.

## Expected Output

### Files Modified
- `.github/workflows/e2e-tests.yaml` — windows-latest added to matrix

## Verification (double-verify)

- [ ] **Automated**: Windows E2E job runs and passes (or skips with documented reasons)
- [ ] **Manual**: CI matrix shows 3 OSes; Windows logs show suites executing under bash
- [ ] No CRLF-induced failures

## User-Observable Acceptance

- A PR shows green E2E across ubuntu, macOS, and Windows

## Addresses

audit-065 HIGH-065-005 (consolidated register H5)
