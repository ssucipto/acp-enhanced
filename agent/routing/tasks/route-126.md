---
id: route-126
title: "Bootstrap step 6b: .cursor/commands/ generation + post-install verify"
task_type: bash-script-fix
milestone: M53
complexity: low
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
  - agent/scripts/acp.cursor-commands-sync.sh
  - agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 126: Bootstrap .cursor/commands/ + Post-Install Verify

## Objective

Add Cursor slash command generation to the bootstrap's step 6b (opencode generation) and update post-install verification to check `.cursor/commands/` count.

## Context

The bootstrap already generates `.opencode/commands/` in step 6b. Cursor commands should be generated alongside opencode commands for IDE parity. The post-install verification should report `.cursor/commands/` status (currently shows ⚠️ missing).

## Changes

### 1. `scripts/acp-bootstrap.sh` — Step 6b

After the opencode generation block (when `GENERATE_OPENCODE=true`), add Cursor generation:

```bash
# Generate Cursor slash commands (same as opencode, different target dir)
if [ -f "agent/scripts/acp.cursor-commands-sync.sh" ]; then
  echo -e "${YELLOW}Generating Cursor slash commands...${NC}"
  bash agent/scripts/acp.cursor-commands-sync.sh
fi
```

### 2. `scripts/acp-bootstrap.sh` — Post-install verification

Update the `.cursor/commands/` check from:
```bash
[ -d ".cursor/commands" ] && echo "✅" || echo "⚠️ missing"
```
To:
```bash
_CURSOR_COUNT=$(find .cursor/commands -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
_CMD_SOURCE_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" -o -name "git.*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$_CURSOR_COUNT" -ge "$_CMD_SOURCE_COUNT" ] 2>/dev/null; then
  echo -e "  ${GREEN}✅ .cursor/commands/: ${_CURSOR_COUNT} files${NC}"
else
  echo -e "  ${YELLOW}⚠️ .cursor/commands/: ${_CURSOR_COUNT} files (expected ≥${_CMD_SOURCE_COUNT})${NC}"
fi
```

## Verification

- [ ] Bootstrap with `GENERATE_OPENCODE=true` generates `.cursor/commands/`
- [ ] Post-install verification reports `.cursor/commands/` count (not just "missing")
- [ ] Cursor count ≥ command source count
- [ ] When sync script absent, graceful degradation (no crash)
- [ ] `.cursor/commands/` parity with `.opencode/commands/`
