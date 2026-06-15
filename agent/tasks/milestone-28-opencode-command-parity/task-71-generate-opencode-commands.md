---
id: task-71
title: Generate .opencode/commands/ from .github/prompts/
task_type: scripting
milestone: M28
complexity: low
executor: copilot
context_required:
  - agent/core/identity.yml
  - agent/skills/scripts.md
files_affected:
  - .opencode/commands/ (58 new files)
  - agent/milestones/milestone-28-opencode-command-parity.md
tokens_est: 1500
tokens_actual: ~2800
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed: 2026-05-04
override_reason:
---

<!-- @acp.meta.task
topic: task, generate, opencodecommands, from, githubprompts
description: Generate .opencode/commands/ from .github/prompts/
milestone: M28
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Task: Generate .opencode/commands/ from .github/prompts/

Create the `.opencode/commands/` directory and populate it with 58 files — one for every `.github/prompts/*.prompt.md` file. Each opencode command file is a transformed copy of the Copilot prompt file:
- Strip `mode: agent` frontmatter field (VS Code-specific, not valid in opencode)
- Keep `description:` field unchanged
- Keep body content unchanged
- Output filename: strip `.prompt` suffix (`acp-init.prompt.md` → `acp-init.md`)

## Acceptance Criteria

- [x] `.opencode/commands/` directory exists
- [x] 58 files present (1:1 with `.github/prompts/`)
- [x] No file contains `mode: agent`
- [x] All files have `description:` in frontmatter
- [x] All files have `---` frontmatter delimiters

## Implementation Notes

Used a bash one-liner loop with `awk` to extract post-frontmatter body and `grep` to extract description. Tested against all 58 files — all pass E2E test (task-75).
