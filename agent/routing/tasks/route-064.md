---
id: route-064
title: @-mention + parallel task schema tests
task_type: e2e-test-write
milestone: M45
complexity: medium
executor: deepseek-v4-flash
context_required: [tests/common.sh, agent/routing/taxonomy.yml]
design_reference: [Test Package Requirements](../reports/audit-033-test-package-requirements.md)
files_affected: [tests/acp.at-mention.test.sh, tests/acp.parallel.test.sh]
tokens_est: 4000
created: 2026-06-03
completed: 2026-06-03
depends_on: []  # route-060 retired — cleared for D-002-08
---

# @-mention + Parallel Schema Tests

Create `tests/acp.at-mention.test.sh` verifying:

1. skills_catalog has exactly 7 entries
2. Each entry has: name, mention (@{name}), file, description, triggers
3. Every mention maps to an existing file in agent/skills/
4. Each trigger task_type exists in task_types
5. upstream-sync skill has upstream-parity-check as trigger

Create `tests/acp.parallel.test.sh` verifying:
1. task_type: parallel exists with sub_task_default_executor
2. task_type: orchestrator-workers exists
3. task.schema.yaml has correct fields: id, title, executor, depends_on
4. depends_on is optional with default []
