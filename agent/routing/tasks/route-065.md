---
id: route-065
title: Bootstrap flags + observability tests
task_type: e2e-test-write
milestone: M45
complexity: low
executor: deepseek-v4-flash
context_required: [tests/common.sh, scripts/acp-bootstrap.sh]
design_reference: [Test Package Requirements](../reports/audit-033-test-package-requirements.md)
files_affected: [tests/acp.bootstrap-flags.test.sh, tests/acp.observability.test.sh]
tokens_est: 3000
created: 2026-06-03
completed: 2026-06-03
depends_on: []  # route-060 retired — cleared for D-002-08
---

# Bootstrap + Observability Tests

Create `tests/acp.bootstrap-flags.test.sh` verifying:

1. --team-size solo flag accepted
2. --team-size small flag accepted
3. --team-size team flag accepted
4. --generate-prompts flag accepted
5. Default (no flag) = small
6. Manifest scaffold block overrides flags

Create `tests/acp.observability.test.sh` verifying:

1. progress.yaml has observability: section
2. observability has this_week, by_executor, weekly_trend keys
3. this_week has: sessions, total_tokens_in, total_tokens_out, total_cost_usd, top_executor
4. Schema allows empty by_executor: {}
