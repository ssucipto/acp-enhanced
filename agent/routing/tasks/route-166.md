---
id: route-166
title: Fix integrity E2E \d ERE regex bug + add CONTRIBUTING.md
task_type: e2e-test-write
milestone: M60
complexity: low
executor: copilot
context_required:
  - skills/testing.md
files_affected:
  - e2e/acp.integrity.test.sh
  - CONTRIBUTING.md
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Fix the rule-count assertion in the integrity E2E test that uses `\d` (invalid as a digit class in POSIX ERE / GNU `grep -E`), and add a `CONTRIBUTING.md` for the public fork.

## Context

`e2e/acp.integrity.test.sh:32` uses `grep -cE '^\| IG-\d+'`; in ERE `\d` matches literal `d`, so the count is wrong and the `>= 55` assertion is unreliable (audit-067 MED-067-003). No `CONTRIBUTING.md` exists despite the project being a public fork inviting contributions (audit-067 MED-067-005).

## Steps

1. Replace `\d` with `[0-9]` (portable) in the rule-count grep — `grep -cE '^\| IG-[0-9]+'`.
2. Add a fixture/known-count assertion proving the corrected count matches the actual `IG-` row count in `agent/wiki/integrity-rules.md`.
3. Create `CONTRIBUTING.md` covering:
   - Branch model (develop → mainline, gitflow-lite).
   - Required checks before PR: E2E green, `/acp-validate`, CHANGELOG entry.
   - Command-doc conventions (Agent Directive, Steps, Verification) — link to `agent/skills/commands.md`.
   - Script conventions (set -euo pipefail, ERR trap) — link to `agent/skills/scripts.md`.
4. Scan the repo for other `grep -E '...\d'` misuse and fix any found.

## Expected Output

### Files Modified
- `e2e/acp.integrity.test.sh` — corrected regex + count proof

### Files Created
- `CONTRIBUTING.md`

## Verification (double-verify)

- [ ] **Automated**: rule-count assertion computes the true count (matches manual `grep -c` with `[0-9]`)
- [ ] **Manual**: `grep -cE '^\| IG-[0-9]+' agent/wiki/integrity-rules.md` equals the value the test reads
- [ ] No remaining `\d` in any `grep -E` across the repo
- [ ] CONTRIBUTING.md links resolve

## User-Observable Acceptance

- Integrity test reports the correct rule count (not 0 / not miscounted)
- CONTRIBUTING.md present at repo root with branch model + test requirements

## Addresses

audit-067 MED-067-003, MED-067-005 (consolidated register M13)
