---
id: route-233
title: "M72 ShellCheck CI gate"
task_type: ci-cd-setup
milestone: M72
complexity: medium
executor: copilot
files_affected:
  - .github/workflows/ci.yaml
  - agent/scripts/
tokens_est: 4000
created: 2026-07-15
completed: 2026-07-15
---

## Objective

F-091-10: SHA-pinned shellcheck job at --severity=error over agent/scripts, scripts, e2e, tests; fix error-level findings.

## Tasks

task-244
