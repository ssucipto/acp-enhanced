---
id: route-067
title: Cross-platform CI hardening + test infra improvements
task_type: bash-scripting
milestone: M45
complexity: medium
executor: deepseek-v4-pro
context_required: [.github/workflows/e2e-tests.yaml, run-e2e-tests.sh, tests/common.sh]
design_reference: [Test Package Requirements](../reports/audit-033-test-package-requirements.md)
files_affected: [.github/workflows/e2e-tests.yaml, run-e2e-tests.sh, tests/common.sh]
tokens_est: 5000
created: 2026-06-03
completed: 2026-06-03
depends_on: []
---

# Cross-Platform CI + Test Infra

Update runner and CI:

1. Add `md5sum` vs `md5` fallback (macOS/Linux portability)
2. Add `--verbose` flag to runner for detailed per-test output
3. Ensure CI workflow triggers on push to mainline AND any PR
4. Add test count summary (total assertions, pass rate) to runner output
5. Add `--list` flag to runner showing all discovered tests without running

New assertion helpers to add to tests/common.sh:
- `assert_gte` — assert greater-than-or-equal (for file counts)
- `assert_valid_yaml` — pipe content through yaml_parse
- `assert_syntax_ok` — run bash -n on a file
