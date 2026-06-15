---
id: task-72
title: Update acp-bootstrap.sh to generate .opencode/commands/
task_type: scripting
milestone: M28
complexity: low
executor: copilot
context_required:
  - agent/core/identity.yml
  - agent/skills/scripts.md
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 800
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed: 2026-05-04
override_reason:
---

<!-- @acp.meta.task
topic: task, update, acp-bootstrapsh, to, generate, opencodecommands
description: Update acp-bootstrap.sh to generate .opencode/commands/
milestone: M28
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Task: Update acp-bootstrap.sh to generate .opencode/commands/

Add a step `[6b/7]` to `scripts/acp-bootstrap.sh` that generates `.opencode/commands/` from the just-created `.github/prompts/` files. The generation runs immediately after the prompt files are created.

## Acceptance Criteria

- [x] `acp-bootstrap.sh` creates `.opencode/commands/` directory
- [x] Step outputs count of generated files
- [x] Step uses same transform logic as task-71 (strip mode:, keep description, keep content)
- [x] Summary section mentions opencode slash commands

## Implementation Notes

Inserted step `[6b/7]` between the existing steps 6 and 7. Used a `for` loop over `.github/prompts/*.prompt.md` with `awk`+`grep` transform. Added opencode note to summary echo block.
