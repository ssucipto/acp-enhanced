---
id: task-008
title: Fix yaml-parser test hang at Group 7 edge cases
task_type: bash-script-fix
milestone: M26-audit
complexity: low
executor: deepseek-v4-flash
context_required:
  - tests/acp.yaml-parser.test.sh
  - agent/scripts/acp.yaml-parser.sh
files_affected:
  - tests/acp.yaml-parser.test.sh
tokens_est: 3500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
---

## Task: Fix yaml-parser test hang at Group 7 edge cases

## Problem

`tests/acp.yaml-parser.test.sh` hangs at Group 7 (Edge Cases). The test never
completes and exits with code 1. Symptoms:
- Groups 1–6 pass (visible output before hang)
- Group 7 starts, calls `yaml_parse` then `yaml_query ".nonexistent"` — likely hangs
- The test process must be killed externally

Root cause hypothesis: `yaml_query` with nonexistent/invalid paths may block waiting
for stdin or enter an infinite loop in `acp.yaml-parser.sh`. Needs investigation.

## Acceptance Criteria

- [ ] `tests/acp.yaml-parser.test.sh` completes without hanging
- [ ] All Groups 1–10 run to completion
- [ ] Test exits with code 0 (all passing) or non-zero with a summary (no silent hang)
- [ ] Fix is in the test OR the parser, whichever is the root cause
