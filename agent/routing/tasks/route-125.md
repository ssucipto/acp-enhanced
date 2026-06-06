---
id: route-125
title: "Hook acp.cursor-commands-sync.sh into acp.install.sh + acp.version-update.sh"
task_type: bash-script-fix
milestone: M53
complexity: low
executor: copilot
context_required:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.version-update.sh
  - agent/scripts/acp.cursor-commands-sync.sh
  - agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md
files_affected:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.version-update.sh
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 125: Hook Cursor Sync into Install + Version Update

## Objective

Wire `acp.cursor-commands-sync.sh` into `acp.install.sh` and `acp.version-update.sh` so Cursor slash commands are auto-generated during install and regenerated on version update.

## Context

Per feedback-001 §3.2, the sync script should be called:
- After `.opencode/commands/` copy in `acp.install.sh`
- After opencode sync in `acp.version-update.sh`

The script already handles idempotency — running it multiple times overwrites existing wrappers with current `Purpose:` descriptions.

## Changes

### 1. `agent/scripts/acp.install.sh`

After the `.opencode/commands/` copy section, add:

```bash
# Generate Cursor slash commands (.cursor/commands/)
if [ -f "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh" ]; then
  echo "Generating Cursor slash commands..."
  chmod +x "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh"
  (cd "$TARGET_DIR" && bash agent/scripts/acp.cursor-commands-sync.sh)
fi
```

Update the install summary list to mention Cursor commands:
```
✓ cursor slash commands (.cursor/commands/) — N files
```

### 2. `agent/scripts/acp.version-update.sh`

After the opencode sync section, add:

```bash
# Regenerate Cursor slash commands
if [ -f "agent/scripts/acp.cursor-commands-sync.sh" ]; then
  echo "Regenerating Cursor slash commands..."
  bash agent/scripts/acp.cursor-commands-sync.sh
fi
```

## Verification

- [ ] Fresh `acp.install.sh` generates `.cursor/commands/` with wrappers
- [ ] `acp.version-update.sh` regenerates `.cursor/commands/`
- [ ] Install summary lists cursor command count
- [ ] Re-running sync is idempotent (no errors on re-run)
- [ ] User customizations in `agent/commands/` reflected in regenerated wrappers
