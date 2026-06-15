---
id: route-068
title: Smoke test + upgrade compatibility
task_type: e2e-test-write
milestone: M45
complexity: low
executor: deepseek-v4-flash
context_required: [tests/common.sh]
design_reference: [M45 Pre-Impl Gap Analysis](../reports/audit-034-m45-pre-impl-gap-analysis.md)
files_affected: [tests/acp.smoke.test.sh]
tokens_est: 2000
created: 2026-06-03
completed: 2026-06-03
depends_on: []
---

# Smoke Test + Upgrade Compatibility

Create `tests/acp.smoke.test.sh` — a <5s "is the system alive" sanity check:

1. agent/ directory exists with core subdirectories
2. AGENT.md has **Version**: field
3. agent/core/routing.yml is valid YAML and has session.executor
4. agent/core/identity.yml has version, fork_of, git_workflow (if present)
5. agent/progress.yaml has project.name and current_milestone
6. All existing route-001 through route-045 files parse correctly (compatibility)
