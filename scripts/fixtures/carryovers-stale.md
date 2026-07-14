# Test fixture — stale pending carryover
carryovers:
  - audit_id: 999
    finding_id: FIXTURE-STALE
    severity: medium
    file: scripts/acp-validate.ts
    finding: "stale pattern test"
    fix_target: "scripts/acp-validate.ts: export function validateCarryoverFreshness"
    status: pending
