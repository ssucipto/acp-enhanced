---
id: route-114
title: "Fix BUG-045-02: Extract opencode generation from GENERATE_PROMPTS block"
task_type: bash-script-fix
milestone: M51
complexity: low
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
  - agent/reports/audit-045-bootstrap-step7-empty-dir-false-positive.md
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

# Route 114: Fix BUG-045-02 — Extract OpenCode from Prompts Block

## Objective

Move opencode/cursor command generation (step 6b) out of the `GENERATE_PROMPTS` block into an independent `GENERATE_OPENCODE` block so that opencode commands are generated even when prompts are skipped.

## Context

Lines 1301-1330 (opencode + cursor generation) are nested inside `if [ "$GENERATE_PROMPTS" = "true" ]` at line 701. `GENERATE_OPENCODE` defaults to `true` but is never independently checked. When users run bootstrap without `--generate-prompts`, `.opencode/commands/` and `.cursor/commands/` are never created.

## Changes

### `scripts/acp-bootstrap.sh`

**Before (structure):**
```bash
if [ "$GENERATE_PROMPTS" = "true" ]; then
  # ... prompt generation (lines 702-1300) ...
  # ... opencode generation (lines 1301-1330) ...
else
  echo "Skipping prompt files..."
fi
```

**After (structure):**
```bash
if [ "$GENERATE_PROMPTS" = "true" ]; then
  # ... prompt generation only ...
else
  echo "Skipping prompt files..."
fi

if [ "$GENERATE_OPENCODE" = "true" ]; then
  # ... opencode + cursor generation (moved here) ...
fi
```

The step numbering should also adjust:
- Step 6a: Prompt files (conditional on GENERATE_PROMPTS)
- Step 6b: OpenCode commands (conditional on GENERATE_OPENCODE)
- Step 7: Install agent/ (unchanged except for BUG-045-01 fix)

## Verification

- [ ] `GENERATE_PROMPTS=false` + `GENERATE_OPENCODE=true` → opencode commands generated
- [ ] `GENERATE_PROMPTS=true` + `GENERATE_OPENCODE=false` → prompts generated, no opencode
- [ ] Both true → both generated (existing behavior preserved)
- [ ] Both false → nothing generated
- [ ] `.opencode/commands/` contains acp-* files after bootstrap with defaults
