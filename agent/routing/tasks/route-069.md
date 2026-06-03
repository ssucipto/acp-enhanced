---
id: route-069
title: End-to-end workflow integration test
task_type: e2e-test-write
milestone: M45
complexity: high
executor: deepseek-v4-pro
context_required: [tests/common.sh]
design_reference: [M45 Pre-Impl Gap Analysis](../reports/audit-034-m45-pre-impl-gap-analysis.md)
files_affected: [tests/acp.e2e-workflow.test.sh]
tokens_est: 6000
created: 2026-06-03
completed: 2026-06-03
depends_on: [route-063, route-064, route-065]
---

# End-to-End Workflow Integration Test

Create `tests/acp.e2e-workflow.test.sh` simulating a complete dev session:

1. **Init** — Read identity.yml and progress.yaml (light-mode protocol)
2. **Audit** — Verify /acp-audit finds a subject (file exists, command doc valid)
3. **Plan** — Verify route file creation creates valid frontmatter
4. **Commit** — Run /acp-commit protocol: session entry written, route_049 stamped
5. **Skills** — Verify @{testing} and @{crosscut} mention mapping resolves to existing files
6. **Cross-feature** — Verify light mode correctly skips skills (no taxonomy load) while full mode loads skills via catalog

All 6 steps are assertions against file state, not actual command execution.
