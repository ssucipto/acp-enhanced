---
id: route-199
title: acp.version-update.sh — implement route-079 for real
task_type: bug-fix
milestone: M68
complexity: high
executor: copilot
context_required:
  - design/safe-install-update-policy.md
  - commands/acp.version-update.md
  - routing/tasks/route-079.md
  - scripts/acp.version-update.sh
files_affected:
  - agent/scripts/acp.version-update.sh
  - agent/commands/acp.version-update.md
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Replace blind `cp` blocks in `acp.version-update.sh` with tier-aware helpers. Implement `--diff`, `--preserve-project-core`, `--force`, `--yes`. Accept `AGENTS.md` OR `AGENT.md`. Copy `agent/schemas/` (Tier C). Triple-sync AGENTS → CLAUDE + copilot-instructions.

## Acceptance criteria

- [ ] All route-079 verification items pass in shell
- [ ] No `cp "$TEMP_DIR/agent/core/"*.yml` glob remain
- [ ] Default update preserves customized identity.yml
- [ ] `--diff` exits without writes
- [ ] Manifest uses Tier D merge only (fix F-004 class sed issues)
- [ ] Copy only `acp.*.md` / `git.*.md` commands — preserve third-party namespaces (P-081-01)
- [ ] Skip `local.*.md` skills on update — match install.sh behavior (P-081-02)
- [ ] `export TEMP_DIR` before tier helper calls (P-081-08)

## Addresses

audit-080 F-080-01, F-080-02, F-080-03, F-080-04, F-080-09; P-081-01, P-081-02, P-081-08; route-079 (reopened)
