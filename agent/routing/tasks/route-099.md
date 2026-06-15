---
id: route-099
title: "acp.install.sh: fix Windows Git Bash hang (while-true loop safety)"
task_type: bash-script-fix
milestone: M49
complexity: medium
executor: copilot
context_required:
  - agent/scripts/acp.install.sh
files_affected:
  - agent/scripts/acp.install.sh
tokens_est: 350
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 099: Fix acp.install.sh Windows Git Bash Hang

## Objective

Fix the infinite loop in `acp.install.sh` that hangs on Windows Git Bash during
`package.yaml` script dependency resolution (3 `while true` loops, lines 338-394).

## Context

Windows user reported install hanging for 5+ minutes at "Resolving script dependencies
from package.yaml...". Root cause: `yaml_query` on Windows Git Bash may never return
empty/null for out-of-range array indices, causing infinite `while true` loops.

## Changes

### 1. Add safety cap to all while-true loops

```bash
MAX_ITERATIONS=200
cmd_index=0
while true; do
  if [ "$cmd_index" -gt "$MAX_ITERATIONS" ]; then
    echo "ERROR: yaml_query loop exceeded $MAX_ITERATIONS iterations — aborting" >&2
    break
  fi
  ...
done
```

### 2. Add Windows detection + fallback

Before the yaml_query section, detect Windows and use copy-all path:

```bash
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
  echo "Windows detected — installing all scripts (skipping selective resolution)"
  find "$TEMP_DIR/agent/scripts" -maxdepth 1 -name "*.sh" -exec cp {} "$TARGET_DIR/agent/scripts/" \;
  echo "✓ Installed $(find "$TARGET_DIR/agent/scripts" -name '*.sh' | wc -l) scripts"
  # Skip to post-install verification
  return 0
fi
```

### 3. Add timeout wrapper

```bash
# If 'timeout' command is available, use it as additional safety
if command -v timeout &>/dev/null; then
  timeout 60 bash -c 'resolve_scripts_from_package_yaml' || {
    echo "WARN: package.yaml resolution timed out — falling back to copy-all mode"
    find "$TEMP_DIR/agent/scripts" -maxdepth 1 -name "*.sh" -exec cp {} "$TARGET_DIR/agent/scripts/" \;
  }
fi
```

## Verification

- [ ] Install completes on Windows Git Bash (no hang)
- [ ] Safety cap triggers at 200 iterations
- [ ] Windows detection skips yaml_query and uses copy-all
- [ ] macOS/Linux behavior unchanged
- [ ] All scripts installed (25+)
