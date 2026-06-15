---
id: route-102
title: "Post-install verification — check command/script counts"
task_type: bash-script-fix
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/scripts/acp.install.sh
  - scripts/acp-bootstrap.sh
files_affected:
  - agent/scripts/acp.install.sh
  - scripts/acp-bootstrap.sh
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 102: Post-Install Verification

## Objective

Add a `verify_install()` function to both bootstrap and install scripts that
checks command/script counts and reports failures.

## Context

The Windows user's install hung silently — no indication that scripts were
missing until manual inspection. A post-install check catches this immediately.

## Changes

### Add to both scripts

```bash
verify_install() {
  local errors=0
  local cmd_count=$(find agent/commands -maxdepth 1 -name "acp.*.md" 2>/dev/null | wc -l | tr -d ' ')
  local script_count=$(find agent/scripts -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Post-Install Verification"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [ "$cmd_count" -lt 40 ]; then
    echo "  ❌ agent/commands/: $cmd_count files (expected 40+)"
    errors=$((errors + 1))
  else
    echo "  ✅ agent/commands/: $cmd_count files"
  fi
  
  if [ "$script_count" -lt 20 ]; then
    echo "  ❌ agent/scripts/: $script_count files (expected 20+)"
    errors=$((errors + 1))
  else
    echo "  ✅ agent/scripts/: $script_count files"
  fi
  
  if [ -d ".opencode/commands" ]; then
    echo "  ✅ .opencode/commands/: present"
  else
    echo "  ⚠️ .opencode/commands/: missing"
  fi
  
  if [ "$errors" -gt 0 ]; then
    echo ""
    echo "  ⚠️  $errors check(s) failed. Run the install script again or"
    echo "  manually copy missing files from the ACP Enhanced repo."
    return 1
  fi
  
  echo "  ✅ All checks passed"
  return 0
}

# Call at end of install
verify_install
```

## Verification

- [ ] Successful install passes all checks
- [ ] Partial install (missing scripts) reports failures
- [ ] Verification runs at end of both bootstrap and install
- [ ] Exit code reflects verification result
