---
id: route-231
title: "M72 wrapper strays + bootstrap dead-glob cleanup"
task_type: bash-script-fix
milestone: M72
complexity: low
executor: copilot
files_affected:
  - .github/prompts/
  - .opencode/commands/
  - scripts/acp-bootstrap.sh
tokens_est: 2500
created: 2026-07-15
completed: 2026-07-15
---

## Objective

F-091-04/06: delete 6 dot-named duplicate wrappers; fix bootstrap acp.*.md dead globs; regenerate + parity re-run.

## Tasks

task-242
