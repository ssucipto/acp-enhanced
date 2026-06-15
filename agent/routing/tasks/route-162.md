---
id: route-162
title: Enable branch protection on mainline + develop
task_type: ci-cd-setup
milestone: M59
complexity: low
executor: copilot
context_required:
  - core/identity.yml
files_affected:
  - docs/USAGE.md
tokens_est: 2000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Enable GitHub branch protection on `mainline` (production) and `develop` (default working) so direct/force pushes are blocked and CI status checks are required before merge.

## Context

`identity.yml` defines a gitflow-lite workflow but no enforcement exists — a single force-push could corrupt production history. Found in audit-065 (CRIT-065-002). This is a repository-settings change (not code), so the route documents the required settings and records confirmation.

## Steps

1. In GitHub repo settings → Branches → add rules for `mainline` and `develop`:
   - Require a pull request before merging (≥1 review for `mainline`).
   - Require status checks to pass: the `CI Checks` jobs (validate, shellcheck, e2e-smoke).
   - Require branches up to date before merging.
   - Disallow force pushes and deletions on `mainline`.
2. Document the enabled rules in `docs/USAGE.md` (governance section) so the policy is discoverable.
3. Record confirmation (settings link / screenshot reference) in the route completion note.

## Expected Output

### Files Modified
- `docs/USAGE.md` — governance/branch-protection section

### External
- GitHub branch protection rules enabled (mainline + develop)

## Verification (double-verify)

- [ ] **Automated**: a test push directly to `mainline` is rejected (or PR-without-checks is blocked)
- [ ] **Manual**: settings page shows both rules active; documented in USAGE.md

## User-Observable Acceptance

- Attempting `git push origin mainline` directly is rejected by the remote
- PRs cannot merge until CI is green

## Addresses

audit-065 CRIT-065-002 (consolidated register C1)
