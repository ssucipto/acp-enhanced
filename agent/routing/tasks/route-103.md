---
id: route-103
title: "Backup instruction + safe install/update with user warning"
task_type: bash-script-fix
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/scripts/acp.install.sh
  - scripts/acp-bootstrap.sh
  - agent/scripts/acp.version-update.sh
files_affected:
  - agent/scripts/acp.install.sh
  - scripts/acp-bootstrap.sh
  - agent/scripts/acp.version-update.sh
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 103: Backup Instruction + Safe Install

## Objective

Add backup/restore guidance to install and update scripts. Before making changes,
inform users what will be overwritten and suggest backing up customized files.

## Context

Current scripts have "never overwrite" protections for user-state files (memory,
routing tasks, local patterns) but NO warning to users about what WILL be
overwritten (AGENTS.md, commands, scripts, core). Users with customizations
lose them without warning.

## Changes

### Add pre-install warning to all three scripts

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ACP Enhanced Install"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  This will overwrite:"
echo "    • AGENTS.md, CLAUDE.md, copilot-instructions.md"
echo "    • agent/commands/*.md (67 files)"
echo "    • agent/scripts/*.sh (29 files)"
echo "    • agent/core/*.yml, agent/skills/*.md, agent/wiki/*"
echo ""
echo "  This will PRESERVE:"
echo "    • agent/memory/* (sessions, lessons, decisions, patterns)"
echo "    • agent/design/*, agent/milestones/*, agent/patterns/local.*"
echo "    • agent/progress.yaml, agent/manifest.yaml"
echo "    • agent/preferences/, agent/configurables/"
echo ""
echo "  💡 Before installing, backup customized files:"
echo "    cp AGENTS.md AGENTS.md.bak"
echo "    cp -r agent/commands agent/commands.bak"
echo ""
read -p "  Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "  Aborted."
  exit 0
fi
```

### Add --yes flag to skip prompt

```bash
# Usage: ./install.sh --yes  (skip confirmation)
if [ "$1" != "--yes" ]; then
  # show prompt
fi
```

## Verification

- [ ] Install shows what will be overwritten vs preserved
- [ ] User prompted to confirm before changes
- [ ] --yes flag skips prompt for automation
- [ ] Backup guidance shown (cp commands)
- [ ] Update script also shows warning
