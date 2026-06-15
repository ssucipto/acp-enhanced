---
id: route-100
title: "acp-bootstrap.sh: detect and self-heal partial installs"
task_type: bash-script-fix
milestone: M49
complexity: medium
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 300
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 100: Bootstrap Partial-Install Self-Healing

## Objective

Replace the simple early-exit guard in `acp-bootstrap.sh` with a completeness
check that detects and auto-completes partial installs.

## Context

Current guard (line 78):
```bash
if [ -f "agent/core/identity.yml" ] && [ -f "AGENTS.md" ]; then
  echo "Already installed — exit"
```

If bootstrap creates the framework layer but fails before commands/scripts,
re-running exits immediately. User had 15 files with 0 commands.

## Changes

Replace early-exit with completeness check:

```bash
if [ -f "agent/core/identity.yml" ] && [ -f "AGENTS.md" ]; then
  CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
  SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$CMD_COUNT" -ge 40 ] && [ "$SCRIPT_COUNT" -ge 20 ]; then
    echo "ACP Enhanced is already installed ($CMD_COUNT commands, $SCRIPT_COUNT scripts)."
    echo "To reinstall, remove AGENTS.md and agent/ first."
    echo "To update: ./agent/scripts/acp.version-update.sh"
    exit 0
  else
    echo "⚠️  Partial install detected ($CMD_COUNT commands, $SCRIPT_COUNT scripts)."
    echo "Completing installation..."
    # Fall through to complete remaining steps
  fi
fi
```

## Verification

- [ ] Full install detected and skipped correctly
- [ ] Partial install (0 commands) auto-completes
- [ ] Partial install (missing scripts) auto-completes
- [ ] Re-run after completion exits cleanly
