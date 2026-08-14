---
id: route-063
title: Light-mode protocol functional tests
task_type: e2e-test-write
milestone: M45
complexity: medium
executor: deepseek-v4-flash
context_required: [tests/common.sh, agent/core/routing.yml]
design_reference: [Test Package Requirements](../reports/audit-033-test-package-requirements.md)
files_affected: [tests/acp.light-mode.test.sh]
tokens_est: 4000
created: 2026-06-03
completed: 2026-06-03
depends_on: []  # route-060 retired — cleared for D-002-08
---

# Light-mode Protocol Tests

Create `tests/acp.light-mode.test.sh` verifying:

1. routing.yml has `context_modes` with light and full sections
2. Light mode has correct steps: load_identity, load_progress, load_recent, confirm
3. Full mode has correct steps: load_core, load_taxonomy, load_skill, load_memory, load_reference, confirm
4. budget_limit_tokens set for both modes
5. recommend_full_for list includes architecture-design, adr-write, milestone-create
6. recommend_light_for list includes bug-fix, docs-update, audit-run
7. auto_full_triggers includes acp.init, first_session
8. confirm_output templates have correct variable placeholders
9. mode_selection.default is light
10. Command_suggestions acp-audit maps to 3 related commands
