---
id: route-173
title: Upgrade 17 scripts from bare set -e to set -euo pipefail
task_type: bash-script-refactor
milestone: M62
complexity: medium
executor: copilot
context_required:
  - skills/scripts.md
files_affected:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.package-create.sh
  - agent/scripts/acp.package-info.sh
  - agent/scripts/acp.package-install-optimized.sh
  - agent/scripts/acp.package-install.sh
  - agent/scripts/acp.package-list.sh
  - agent/scripts/acp.package-publish.sh
  - agent/scripts/acp.package-remove.sh
  - agent/scripts/acp.package-update.sh
  - agent/scripts/acp.package-validate.sh
  - agent/scripts/acp.project-info.sh
  - agent/scripts/acp.project-update.sh
  - agent/scripts/acp.sessions.sh
  - agent/scripts/acp.uninstall.sh
  - agent/scripts/acp.version-check-for-updates.sh
  - agent/scripts/acp.version-check.sh
  - agent/scripts/acp.version-update.sh
tokens_est: 10000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Upgrade the 17 scripts using bare `set -e` to `set -euo pipefail` with an ERR trap, surfacing and fixing any latent unbound-variable or masked-pipeline bugs.

## Context

17 scripts use bare `set -e` (no `-u`, no `-o pipefail`, sometimes no ERR trap), violating `agent/skills/scripts.md` (audit-065 HIGH-065-004). Unbound-variable bugs silently succeed and pipeline failures are masked. The constraints.yml rule `never_use_set_e_without_trap` applies.

## Steps

1. For each script: change the header to `set -euo pipefail` and add `trap 'echo "[<name>] Error on line $LINENO" >&2; exit 1' ERR` per the scripts.md pattern.
2. Run each script's happy path; `-u` will surface unbound variables — fix each with proper defaults (`"${VAR:-}"`) or initialization.
3. Wrap intentional non-zero commands (grep that may not match, array ops) with `|| true` per scripts.md anti-patterns.
4. Run the full E2E suite (serial + `--parallel 4`) to catch regressions.
5. `shellcheck --severity=error` all 17 scripts.

## Expected Output

### Files Modified
- 17 scripts upgraded to `set -euo pipefail` + ERR trap

## Verification (double-verify)

- [ ] **Automated**: full E2E green after upgrade (serial + parallel); shellcheck error-clean
- [ ] **Manual**: `grep -L 'set -euo pipefail' agent/scripts/acp.*.sh` shows 0 bare `set -e` remaining
- [ ] No new unbound-variable failures in normal operation

## User-Observable Acceptance

- All 36 scripts use `set -euo pipefail`
- E2E suite remains green

## Addresses

audit-065 HIGH-065-004 (consolidated register H4)
