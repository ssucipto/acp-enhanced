---
id: route-101
title: "Generate .cursor/commands/ for Cursor IDE slash autocomplete"
task_type: bash-script-fix
milestone: M49
complexity: low
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
  - agent/scripts/acp.install.sh
files_affected:
  - scripts/acp-bootstrap.sh
  - agent/scripts/acp.install.sh
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 101: Cursor .cursor/commands/ Generation

## Objective

Generate `.cursor/commands/*.md` wrappers during bootstrap and install, enabling
`/acp-*` slash autocomplete in Cursor IDE.

## Context

Cursor uses `.cursor/commands/*.md` for `/` autocomplete — same format as opencode
wrappers. Bootstrap creates `.opencode/commands/` but never `.cursor/commands/`.
Currently 0 Cursor users get slash commands without manual copy.

## Changes

### acp-bootstrap.sh

After the opencode command generation step, add:

```bash
# Generate Cursor command wrappers (same format as opencode)
if [ -d ".opencode/commands" ]; then
  echo "Generating Cursor command wrappers..."
  mkdir -p .cursor/commands
  cp .opencode/commands/acp.*.md .cursor/commands/ 2>/dev/null || true
  CURSOR_COUNT=$(find .cursor/commands -name 'acp.*.md' | wc -l | tr -d ' ')
  echo "  ✓ $CURSOR_COUNT Cursor wrappers"
fi
```

### acp.install.sh

Same logic added to the install script's command copy section.

### acp.version-update.sh

Include Cursor wrappers in the update path so they stay current.

## Verification

- [ ] `.cursor/commands/` created with acp.*.md wrappers
- [ ] Cursor autocomplete shows /acp-* commands after reload
- [ ] Bootstrap, install, and update all generate Cursor wrappers
- [ ] Existing .cursor/commands/ not overwritten if already present (local.* preserved)
