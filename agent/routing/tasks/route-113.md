---
id: route-113
title: "Fix BUG-045-01: Step 7 directory check → file count check"
task_type: bash-script-fix
milestone: M51
complexity: low
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
  - agent/reports/audit-045-bootstrap-step7-empty-dir-false-positive.md
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 100
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-06
override_reason:
---

# Route 113: Fix BUG-045-01 — Step 7 Directory Check

## Objective

Replace `[ -d "agent/commands" ] && [ -d "agent/scripts" ]` with a file count check using the same `find ... | wc -l` pattern already proven in the pre-flight check (lines 89-92).

## Context

Step 1 creates empty `agent/commands/` and `agent/scripts/` directories. Step 7 checks if these directories exist (they do — they're empty), reports "already present — skipping download", and the install is silently broken. The pre-flight check at lines 85-100 already uses the correct file-count logic.

## Changes

### `scripts/acp-bootstrap.sh` line ~1337

**Before:**
```bash
if [ -d "agent/commands" ] && [ -d "agent/scripts" ]; then
  echo -e "${GREEN}✓ agent/commands + agent/scripts already present — skipping download${NC}"
else
```

**After:**
```bash
_CMD_COUNT=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
_SCRIPT_COUNT=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$_CMD_COUNT" -ge 40 ] && [ "$_SCRIPT_COUNT" -ge 20 ]; then
  echo -e "${GREEN}✓ agent/commands + agent/scripts already present (${_CMD_COUNT} commands, ${_SCRIPT_COUNT} scripts) — skipping download${NC}"
else
  if [ "$_CMD_COUNT" -gt 0 ] || [ "$_SCRIPT_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Partial install detected (${_CMD_COUNT} commands, ${_SCRIPT_COUNT} scripts) — downloading full set${NC}"
  fi
```

## Verification

- [ ] Fresh `curl .../acp-bootstrap.sh | bash` produces 40+ commands
- [ ] Re-running bootstrap on already-installed project skips download
- [ ] Partial install triggers re-download (not skip)
- [ ] Pre-flight check logic unaffected (already uses file count)
