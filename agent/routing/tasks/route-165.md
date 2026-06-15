---
id: route-165
title: E2E tests for 8 core commands (init, proceed, plan, dispatch, commit, validate, audit, route)
task_type: e2e-test-write
milestone: M60
complexity: high
executor: copilot
context_required:
  - patterns/local.e2e-testing.md
  - skills/testing.md
files_affected:
  - e2e/acp.init.test.sh
  - e2e/acp.proceed.test.sh
  - e2e/acp.plan.test.sh
  - e2e/acp.dispatch.test.sh
  - e2e/acp.commit.test.sh
  - e2e/acp.validate.test.sh
  - e2e/acp.audit.test.sh
  - e2e/acp.route.test.sh
tokens_est: 14000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Add E2E test files for the 8 core-workflow commands that currently have no automated coverage. These commands control the entire ACP loop; a regression in any of them would go undetected today.

## Context

46 of 68 commands (68%) have no E2E test (audit-065 CRIT-065-003). Tier 1 targets the highest-risk core commands first so "no critical command without a smoke test." Follows `agent/patterns/local.e2e-testing.md` conventions and the parallel-safety lessons (mktemp -d, no shared fixture dirs).

## Steps

1. Read `agent/patterns/local.e2e-testing.md` and an existing exemplar (`e2e/acp.integrity.test.sh`, `e2e/acp.sessions.test.sh`) for structure (`tests/common.sh`, `assert_*`, `print_suite_header`).
2. For each of the 8 commands, create `e2e/acp.<cmd>.test.sh` with at minimum:
   - Structural assertion: command doc exists with Agent Directive + required sections.
   - Behavioural smoke: drive the command's observable effect in an isolated `mktemp -d` HOME/project.
   - At least one **negative** assertion (failure path), not happy-path only.
3. Per-command minimum assertions:
   - `/acp-init`: loads core files; emits mode banner; sets `routing.yml context_modes.current`.
   - `/acp-proceed`: reads next route; respects pending carryovers; no-op when nothing pending.
   - `/acp-plan`: scans progress.yaml; creates milestone/route stub; updates progress.yaml.
   - `/acp-dispatch`: builds context within budget; non-destructive routing.yml update (cross-check route-159).
   - `/acp-commit`: writes sessions.md entry; dual-store sync; >15-entry compaction trigger.
   - `/acp-validate`: detects a malformed command doc; version consistency check.
   - `/acp-audit`: produces audit-N report; appends carryovers.
   - `/acp-route`: classifies task_type; creates route-NNN with valid frontmatter.
4. Register new tests in `run-e2e-tests.sh` discovery (if not auto-globbed).
5. Ensure all pass serially and with `--parallel 4`.

## Expected Output

### Files Created
- 8 new `e2e/acp.<cmd>.test.sh` files

## Verification (double-verify)

- [ ] **Automated**: all 8 suites pass serial AND `--parallel 4`; each has ≥1 negative assertion
- [ ] **Manual**: deliberately break one command doc → its suite goes red
- [ ] `bash -n` + `shellcheck --severity=error` clean for all new files
- [ ] Untested-command count drops by 8 (68%→≤56%)

## User-Observable Acceptance

- `bash run-e2e-tests.sh` runs the 8 new suites green
- Removing `## Steps` from a command makes `/acp-validate` test fail

## Addresses

audit-065 CRIT-065-003 (tier 1) — consolidated register C2
