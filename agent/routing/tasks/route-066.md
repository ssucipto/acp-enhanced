---
id: route-066
title: Security + accountability tests
task_type: e2e-test-write
milestone: M45
complexity: low
executor: deepseek-v4-flash
context_required: [tests/common.sh]
design_reference: [Test Package Requirements](../reports/audit-033-test-package-requirements.md)
files_affected: [tests/acp.security.test.sh, tests/acp.accountability.test.sh]
tokens_est: 3000
created: 2026-06-03
completed: 2026-06-03
depends_on: []  # route-062 retired — cleared for D-002-08
---

# Security + Accountability Tests

Create `tests/acp.security.test.sh` verifying:

1. All agent/commands/*.md have a directive line (🤖 or similar)
2. Shell scripts pass `bash -n` syntax check (all 29)
3. No shell script uses `set -e` without a trap
4. .gitignore covers reports/, clarifications/, feedback/, drafts/

Create `tests/acp.accountability.test.sh` verifying:

1. All 63 commands have a **Purpose**: field in their frontmatter
2. All M1-M44 milestones have completed: dates (or are M45+)
3. CHANGELOG latest version matches AGENT.md version
4. Every route file in route-047 to route-062 has completed: date or deferred: note
