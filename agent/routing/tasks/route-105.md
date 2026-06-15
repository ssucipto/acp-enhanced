---
id: route-105
title: "Install recovery path — /acp-install --repair mode"
task_type: command-doc-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.install.md
  - agent/scripts/acp.install.sh
files_affected:
  - agent/commands/acp.install.md
  - agent/scripts/acp.install.sh
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 105: Install Recovery Path (--repair)

## Objective

Add `--repair` mode to `/acp-install` that detects and fixes partial or broken
installs without a full reinstall.

## Context

Windows user ended up with a partial install (67 commands, 2 scripts, no manifest).
Manual recovery required cloning the repo and copying files. A `--repair` mode
automates this.

## Changes

### acp.install.sh — Add --repair flag

```bash
if [ "$1" = "--repair" ]; then
  echo "Repair mode: checking install integrity..."
  
  # Check and fix commands
  CMD_COUNT=$(find agent/commands -name 'acp.*.md' 2>/dev/null | wc -l)
  if [ "$CMD_COUNT" -lt 40 ]; then
    echo "  ⚠️ agent/commands/: $CMD_COUNT files — repairing..."
    # Copy missing commands from temp clone
  fi
  
  # Check and fix scripts
  SCRIPT_COUNT=$(find agent/scripts -name '*.sh' 2>/dev/null | wc -l)
  if [ "$SCRIPT_COUNT" -lt 20 ]; then
    echo "  ⚠️ agent/scripts/: $SCRIPT_COUNT files — repairing..."
    find "$TEMP_DIR/agent/scripts" -name '*.sh' -exec cp {} agent/scripts/ \;
  fi
  
  # Check and fix manifest
  if ! grep -q 'acp-core' agent/manifest.yaml 2>/dev/null; then
    echo "  ⚠️ agent/manifest.yaml: stub — repairing..."
    # Rewrite manifest
  fi
  
  # Run verification
  verify_install
  exit $?
fi
```

### acp.install.md — Document --repair

Add to command doc:
```
| `--repair` | Detect and fix partial/broken installs without full reinstall |
```

## Verification

- [ ] `--repair` detects missing commands
- [ ] `--repair` detects missing scripts
- [ ] `--repair` detects stub manifest
- [ ] Repairs fix each issue independently
- [ ] Post-repair verification passes
