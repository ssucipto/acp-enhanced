---
id: route-115
title: "Fix BUG-045-03: Exit non-zero on verification failure + remediation message"
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

# Route 115: Fix BUG-045-03 — Verification Exit Code + Remediation

## Objective

After post-install verification fails, exit with code 1 and print a clear remediation command so users know how to fix a broken install.

## Context

The post-install verification (lines 1425-1445) correctly counts files and shows ❌ on failure, but bootstrap always exits 0 and prints "Done. ACP Enhanced is ready." Users see the failure in output but get no fix path.

## Changes

### `scripts/acp-bootstrap.sh` lines ~1425-1445

After the verification output block, add:

```bash
# Check if verification passed
_VERIFY_FAILED=false
if [ "$_CMD_COUNT" -lt 40 ]; then
  _VERIFY_FAILED=true
fi
if [ "$_SCRIPT_COUNT" -lt 20 ]; then
  _VERIFY_FAILED=true
fi

if [ "$_VERIFY_FAILED" = "true" ]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}  ⚠️  INSTALL INCOMPLETE${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "  The bootstrap completed but agent/ files are missing."
  echo "  This is a known bug (audit-045). To fix:"
  echo ""
  echo "    curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/agent/scripts/acp.install.sh | bash"
  echo ""
  echo "  Or re-run bootstrap after the fix is released:"
  echo "    curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/scripts/acp-bootstrap.sh | bash"
  echo ""
  exit 1
fi
```

## Verification

- [ ] Fresh install with BUG-045-01 present → verification fails → exits 1
- [ ] Working install (40+ commands, 20+ scripts) → exits 0
- [ ] Remediation message includes the `curl ... acp.install.sh` command
- [ ] Message references audit-045 for traceability
