---
id: task-005
title: Auto-migrate legacy .agent/ on install/update
task_type: shell-scripting
milestone: none
complexity: low
executor: code
context_required:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.version-update.sh
files_affected:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.version-update.sh
tokens_est: 800
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed:
override_reason:
---

## Task: Auto-migrate legacy .agent/ on install/update

When ACP is installed or updated on a project that still has the legacy `.agent/`
hidden directory (ACP < 6.x layout), the scripts should detect it and automatically
migrate user-state files into the new `agent/` structure before proceeding.

## Acceptance Criteria

- Detection runs in `acp.install.sh` and `acp.version-update.sh`
- User-state files migrated with create-if-absent semantics (never overwrite):
  - `.agent/memory/*.md` → `agent/memory/`
  - `.agent/tasks/task-*.md` → `agent/routing/tasks/`
  - `.agent/routing/ledger.md` → `agent/routing/ledger.md`
- `.agent/` directory is removed after migration
- Static files in `.agent/` (core/, skills/, wiki/) are dropped — they are
  overwritten by the install/update anyway
- No migration = no output (silent no-op when `.agent/` absent)
- Migration block runs AFTER git clone (TEMP_DIR ready), BEFORE mkdir/copy phase

## Notes

- `acp.install.sh` uses `$TARGET_DIR` prefix for all paths
- `acp.version-update.sh` operates in current directory (no prefix)
- BSD macOS `mv` is safe for this operation (no delimiter issues)
