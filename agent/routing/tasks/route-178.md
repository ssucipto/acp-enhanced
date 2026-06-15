---
id: route-178
title: E2E tests for remaining Tier 2 & 3 commands (~38 commands)
task_type: e2e-test-write
milestone: M63
complexity: high
executor: copilot
context_required:
  - patterns/local.e2e-testing.md
  - skills/testing.md
files_affected:
  - e2e/acp.package-create.test.sh
  - e2e/acp.package-install.test.sh
  - e2e/acp.project-create.test.sh
  - e2e/acp.preferences-set.test.sh
  - e2e/acp.handoff.test.sh
  - e2e/acp.status.test.sh
tokens_est: 16000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Complete E2E coverage for the remaining ~38 commands (Tier 2 package/project/preferences families, then Tier 3 reporting/visualization), reaching ≥80% command coverage.

## Context

After M60's Tier 1 (8 core commands), ~38 commands remain untested (audit-065 CRIT-065-003 tier 2/3). Tier 2 = package/project/preferences subsystems (data-mutating, highest residual risk); Tier 3 = read-mostly reporting/visualize commands. This route may be split into batches during execution; the `files_affected` list is representative, not exhaustive.

## Steps

1. **Tier 2 (priority)** — package-* (create/install/list/remove/update/publish/validate/info/search), project-* (create/list/set/info/update/remove), preferences-* (set/get/show/create/validate). For each: structural + behavioural smoke in isolated `mktemp -d`, with negative assertions for the data-mutating ones.
2. **Tier 3** — status, report, cost-report, stakeholder-report, visualize, index, handoff, resume, sessions(if not done), dispatch(if not done), etc. Structural + light behavioural.
3. Reuse helpers from `tests/common.sh`; keep suites parallel-safe (no shared dirs).
4. Track coverage: maintain a count of tested vs total commands; goal ≥80%.
5. Batch commits per subsystem to keep PRs reviewable.

## Expected Output

### Files Created
- ~38 new `e2e/acp.<cmd>.test.sh` files (delivered in subsystem batches)

## Verification (double-verify)

- [ ] **Automated**: all new suites green serial + `--parallel 4`; data-mutating commands have negative assertions
- [ ] **Manual**: command coverage ≥80% (tested/total); spot-check 3 suites fail when their command is broken
- [ ] `shellcheck --severity=error` clean across new files

## User-Observable Acceptance

- `bash run-e2e-tests.sh` exercises ≥80% of commands green
- Package/project/preferences subsystems have regression protection

## Addresses

audit-065 CRIT-065-003 (tier 2/3) — consolidated register C2
