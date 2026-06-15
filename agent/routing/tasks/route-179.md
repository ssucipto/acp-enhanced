---
id: route-179
title: "Create acp.post-milestone-sweep.sh — automated post-milestone verification gate"
task_type: bash-script-create
milestone: M62
complexity: medium
executor: deepseek-v4-pro
context_required: [agent/scripts/acp.git-provenance.sh, agent/core/constraints.yml, scripts/acp-validate.ts]
files_affected:
  - agent/scripts/acp.post-milestone-sweep.sh
  - e2e/acp.post-milestone-sweep.test.sh
tokens_est: 9000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

# Route 179: Post-milestone sweep script

## Context

Today's M61 autonomous completion missed critical post-completion checks: `tsc --noEmit`
never ran, vitest was never re-run, git tags were never created, and the A3.5 sweep in
the proceed command was interpreted as file-existence rather than test-execution. The
human cannot remember all these checks. A script can.

This route creates `agent/scripts/acp.post-milestone-sweep.sh` — a single script that
runs all post-milestone verification gates mechanically. The script is invoked by the
hook defined in route-178's constraints.yml additions, or manually via
`bash agent/scripts/acp.post-milestone-sweep.sh`.

## Objective

Create one bash script that runs 6 verification gates and outputs a pass/fail report.
The script is non-interactive, CI-friendly, and exits non-zero if any gate fails.

## Acceptance Criteria

- Script exits 0 when all gates pass, non-zero when any gate fails
- All bash conventions followed: `set -euo pipefail`, `trap ERR`, quoted variables
- Script passes `shellcheck --severity=error`
- E2E test validates all gates pass on a clean state and correctly fail on a
  deliberately broken state
- Script is registered in `agent/scripts/` and documented in the M62 milestone

## Expected Output

### Files Created
- `agent/scripts/acp.post-milestone-sweep.sh`
- `e2e/acp.post-milestone-sweep.test.sh`

### Files Modified
- None (route-178 handles constraints.yml hook)

## Gate Specifications

The script runs 6 gates in order. Each gate outputs a `✅` / `❌` line plus details:

### Gate 1: TypeScript Type-Check
Run `npx tsc --noEmit` from `scripts/` directory.
Pass if exit 0. Fail if any type errors.

### Gate 2: Unit Tests
Run `npx vitest run` from `scripts/` directory.
Pass if all tests pass. Fail if any test fails or no test files found.

### Gate 3: Git Tags
Check `git tag --list "v$(head -1 CHANGELOG.md | sed 's/.*\[\(.*\)\].*/\1/')"` is non-empty.
(Parse the latest CHANGELOG version, check if a tag exists for it.)
Fail if no tag found.

### Gate 4: ACP Validate
Run `npx tsx scripts/acp-validate.ts` (or the installed acp-validate command).
Pass if 0 errors. Warn on warnings but don't fail.

### Gate 5: Token Budget
Count bytes of `agent/core/identity.yml`, `agent/core/constraints.yml`, `agent/core/routing.yml`.
Estimate tokens as bytes/4. Report each. Fail if any exceeds stated limits
(from constraints.yml context_budget).

### Gate 6: Git Attributes
Check `.gitattributes` exists and contains LF enforcement for at least `*.sh`, `*.yml`, `*.ts`, `*.json`.
Fail if any expected type is missing.

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ACP Post-Milestone Sweep — vX.Y.Z
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Gate 1: TypeScript type-check ................ ✅ (0 errors)
  Gate 2: Unit tests ........................... ✅ (33/33 passing)
  Gate 3: Git tags ............................. ✅ (v6.20.9 exists)
  Gate 4: ACP validate ......................... ⚠️  (0 errors, 3 warnings)
  Gate 5: Token budget ......................... ✅ (405/500 tokens)
  Gate 6: Git attributes ....................... ✅ (all types covered)

  Result: 5/6 passed (1 with warnings)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Verification

- [ ] Script exists at `agent/scripts/acp.post-milestone-sweep.sh`
- [ ] Script is executable (`chmod +x`)
- [ ] `shellcheck --severity=error agent/scripts/acp.post-milestone-sweep.sh` passes
- [ ] Running from project root produces the expected output format
- [ ] Deliberately breaking a gate (e.g., removing a git tag) causes non-zero exit
- [ ] E2E test file exists at `e2e/acp.post-milestone-sweep.test.sh`
- [ ] E2E test validates both pass and fail scenarios
- [ ] Script uses `set -euo pipefail` with `trap ERR`
- [ ] All variables are quoted

## User-Observable Acceptance

- After running `/acp-proceed --complete M62` and all tasks complete, the user runs:
  ```
  $ bash agent/scripts/acp.post-milestone-sweep.sh
  ```
  And sees a gate-by-gate report showing whether the milestone's verification
  checklist items actually hold.
- A CI job can run the script and block PRs that fail any gate.
- Running the script on a deliberately broken state shows which gate failed and why
  (not just an exit code).
