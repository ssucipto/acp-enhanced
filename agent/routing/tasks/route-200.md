---
id: route-200
title: acp.install.sh — tier preserve, manifest merge, Windows portability
task_type: bug-fix
milestone: M68
complexity: medium
executor: copilot
context_required:
  - design/safe-install-update-policy.md
  - scripts/acp.install.sh
files_affected:
  - agent/scripts/acp.install.sh
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed: 2026-07-15
override_reason:
---

## Objective

Apply tier policy to reinstall path. Replace `cat > agent/manifest.yaml` with Tier D merge. Replace `xargs` basename loops with portable while-read (Windows Git Bash).

## Acceptance criteria

- [ ] Reinstall on existing agent/ preserves customized core/wiki/routing Tier B files
- [ ] Third-party packages in manifest.yaml survive reinstall
- [ ] Manifest generation works without xargs on Git Bash
- [ ] `local.*` skills still excluded (regression from M29)

## Addresses

audit-080 F-080-06, F-080-07, F-080-11
