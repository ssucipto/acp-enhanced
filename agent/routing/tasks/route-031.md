---
id: route-031
title: M41b — Document git_workflow branch safety in README + QUICKSTART (GAP-003)
task_type: documentation-sync
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - README.md
  - scripts/QUICKSTART.md
  - agent/core/identity.yml
  - agent/commands/acp.commit.md
files_affected:
  - README.md
  - scripts/QUICKSTART.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Make the `git_workflow:` branch safety feature (Step 1b) discoverable for new users. Currently it is fully implemented in `AGENTS.md`, `CLAUDE.md`, `architecture.md`, and `acp.commit.md` v1.2.0 — but `identity.yml` ships with the block commented out and there is no README section or QUICKSTART mention. The feature that prevents the most common AI coding mistake (committing to main) is invisible to new installers. Closes GAP-003 from audit-014.

## Acceptance Criteria

- [ ] `README.md`: new `## Branch Safety` section added (or placed in Install/Setup section)
  - Explains Step 1b: "At the start of each session, ACP checks your current branch against `git_workflow.default_working_branch`"
  - Shows the config block to add to `identity.yml`:
    ```yaml
    git_workflow:
      default_working_branch: mainline   # branch you commit to daily
      production_branch: main            # branch that deploys to prod
      branch_model: trunk                # trunk | gitflow-lite | github-flow
    ```
  - Notes: "If on production branch, ACP outputs a warning and stops — no accidental commits to main"
- [ ] `scripts/QUICKSTART.md`: new step (or note in Step 2 — Fill in identity) mentioning `git_workflow:` block
  - "Recommended: uncomment and configure `git_workflow:` in `agent/core/identity.yml` to enable branch safety checks"
- [ ] No changes to `identity.yml` itself (the commented block stays)

## Implementation Notes

Read the existing README "Recent Protocol Enhancements (v6.4–v6.6)" section (added in audit-013) which already documents M39 — the Branch Safety section should expand on this, not duplicate it. Place the `## Branch Safety` section near the install or identity setup documentation.
