---
id: route-032
title: M41b — Add AGENTS.md pre-commit sync hook to acp-bootstrap.sh (GAP-004)
task_type: bash-script-fix
milestone: M41
complexity: medium
executor: deepseek-v4-flash
context_required:
  - scripts/acp-bootstrap.sh
  - memory/patterns.md
  - wiki/architecture.md
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add a step to `scripts/acp-bootstrap.sh` that installs a `.git/hooks/pre-commit` hook. The hook automatically syncs `AGENTS.md` → `CLAUDE.md` and `.github/copilot-instructions.md` whenever `AGENTS.md` is staged for a commit. Without this, the three protocol files will drift over time as developers update `AGENTS.md` and forget to sync. Closes GAP-004 from audit-014.

## Acceptance Criteria

- [ ] `scripts/acp-bootstrap.sh` installs `.git/hooks/pre-commit` during setup (new Step 8 or within existing step)
- [ ] Hook content:
  ```bash
  #!/bin/bash
  # ACP: auto-sync AGENTS.md → CLAUDE.md + .github/copilot-instructions.md
  if git diff --cached --name-only | grep -q "^AGENTS\.md$"; then
    cp AGENTS.md CLAUDE.md
    cp AGENTS.md .github/copilot-instructions.md
    git add CLAUDE.md .github/copilot-instructions.md
    echo "[ACP] CLAUDE.md and copilot-instructions.md synced from AGENTS.md"
  fi
  ```
- [ ] Bootstrap script checks if `.git/hooks/pre-commit` already exists before writing:
  - If it exists and does NOT contain ACP sync block → appends the block (does not overwrite)
  - If it exists and ALREADY contains ACP sync block → skips silently
  - If it does not exist → creates new file with the hook
- [ ] Hook file set executable: `chmod +x .git/hooks/pre-commit`
- [ ] Bootstrap uses BSD-compatible bash (macOS safe — no GNU-only flags)
- [ ] `set -e` trap pattern followed if used (per lessons.md — never use `set -e` without trapping errors)

## Implementation Notes

Use the `local-star-exclusion-case-loop` pattern from `patterns.md` as style reference for the bash idioms. Read the full current `acp-bootstrap.sh` to find the correct insertion point — likely after the "Copy command docs" step and before the "Validate install" step. Test on macOS BSD bash 3.2.
