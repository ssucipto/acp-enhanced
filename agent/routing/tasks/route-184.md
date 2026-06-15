---
id: route-184
title: Keystone — per-rule fixture matrix + real clean-codebase false-positive baseline for /acp-integrity
task_type: test-e2e
milestone: M64
complexity: high
executor: copilot
context_required:
  - skills/testing.md
  - reports/audit-070-m55-m58-gateway-deep-dive.md
  - milestones/milestone-56-acp-integrity-command.md
files_affected:
  - e2e/acp.integrity.test.sh
  - agent/benchmarks/fixtures/integrity/
tokens_est: 11000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Give the integrity gateway real behavioral test coverage: a true-positive AND true-negative fixture for every script-backed rule, each run against the REAL script with assertions on rule ID + exit code, plus the clean-codebase false-positive baseline M56 §8 mandated but never delivered. This is the keystone — it makes every other M64 fix (and future regressions) visible.

## Context

audit-070 F-070-03 (HIGH): `e2e/acp.integrity.test.sh` is structural/smoke only — B1 never invokes the unicode scanner (just greps the fixture); B2/B3 only assert clean-file exit 0; B4 "baseline" only greps AGENTS.md for 4 phrases; the other four scripts get only `bash -n`. The mandated `assert_finding_count CRITICAL/HIGH 0` over the clean codebase does not exist. F-070-14 (LOW): the rule-count assertion uses `grep -cE '^\| IG-\d+'` — `\d` is literal in ERE → count 0, `[ 0 -ge 55 ]` fails (masked by `|| echo 0`).

## Steps

1. Create `agent/benchmarks/fixtures/integrity/` with one subdir per rule family. For EACH script-backed rule (the enforced set after routes 179/180/183), add:
   - `IG-NN-positive.<ext>` — minimal code that MUST be flagged
   - `IG-NN-negative.<ext>` — similar-looking code that MUST NOT be flagged
   - a one-line `manifest` row: `rule, fixture, expect(positive|negative), severity`
2. Add a behavioral test block to `e2e/acp.integrity.test.sh` that, for each fixture, runs the REAL script and asserts:
   - positive → output contains `IG-NN` with the expected `[SEVERITY]` and a non-empty match
   - negative → no `IG-NN` finding
   - (use the route-182 canonical output format)
3. Replace the broken B1/B2/B3 smoke checks with real invocations (B1 must actually run `acp.unicode-scan.sh` on the U+200D fixture and assert it flags IG-14).
4. Implement the **real false-positive baseline** (M56 §8): run the full integrity scan over the clean ACP repo and `assert_finding_count CRITICAL == 0` and `HIGH == 0`. If a rule is noisy on the clean repo, the rule (or its fixture) is wrong — fix before merge.
5. Add the **coverage cross-check** (supports route-181): assert that every rule listed as enforced in `agent/skills/code-integrity.md` has a fixture in the matrix; fail otherwise.
6. Fix F-070-14: change `grep -cE '^\| IG-\d+'` → `grep -cE '^\| IG-[0-9]+'`; assert the real wiki count.
7. Ensure the suite is discovered by `e2e/run-e2e-tests.sh` and runs in CI (it already is; confirm).

## Expected Output

### Files Created
- `agent/benchmarks/fixtures/integrity/**` — positive/negative fixtures + manifest

### Files Modified
- `e2e/acp.integrity.test.sh` — real per-rule behavioral matrix, false-positive baseline, coverage cross-check, fixed rule-count regex

## Verification (double-verify)

- [ ] **Automated**: the suite FAILS if any script-backed rule lacks a fixture, if a positive fixture is missed, if a negative fixture false-positives, or if the clean repo yields any CRITICAL/HIGH
- [ ] **Automated**: deliberately reverting route-179 (entropy crash) makes the entropy true-positive test FAIL (proves the test catches the regression)
- [ ] **Manual**: `bash e2e/acp.integrity.test.sh` → all assertions pass; summary shows N rules × 2 fixtures
- [ ] Rule-count assertion computes the true wiki count (not 0)

## User-Observable Acceptance

- CI proves `/acp-integrity` actually detects what it claims and stays quiet on clean code — no more green-but-broken gateway.

## Addresses

audit-070 F-070-03 (HIGH), F-070-14 (LOW); also resolves audit-067 MED-067-003 at the source
