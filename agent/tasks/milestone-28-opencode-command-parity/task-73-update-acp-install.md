---
id: task-73
title: Update acp.install.sh to copy .opencode/commands/
task_type: scripting
milestone: M28
complexity: low
executor: copilot
context_required:
  - agent/core/identity.yml
  - agent/skills/scripts.md
files_affected:
  - agent/scripts/acp.install.sh
tokens_est: 500
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed: 2026-05-04
override_reason:
---

<!-- @acp.meta.task
topic: task, update, acpinstallsh, to, copy, opencodecommands
description: Update acp.install.sh to copy .opencode/commands/
milestone: M28
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Task: Update acp.install.sh to copy .opencode/commands/

When `acp.install.sh` installs ACP from a fresh repo clone (`$TEMP_DIR`), it should also copy `.opencode/commands/` to the target project. Since the files are committed to the repo (per ADR-6), they are present in `$TEMP_DIR` after git clone.

## Acceptance Criteria

- [x] `acp.install.sh` copies `$TEMP_DIR/.opencode/commands/*.md` to `$TARGET_DIR/.opencode/commands/`
- [x] Directory is created with `mkdir -p` if absent
- [x] Copy is guarded with `[ -d "$TEMP_DIR/.opencode/commands" ]` to be safe if absent

## Implementation Notes

Added copy block in the "ACP Enhanced context layer" section, immediately after the `agent/wiki` copy block. Used `|| true` to handle edge cases gracefully.
