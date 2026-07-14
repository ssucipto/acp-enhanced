---
id: route-198
title: Safe install/update — tier helpers in acp.common.sh
task_type: architecture-design
milestone: M68
complexity: medium
executor: copilot
context_required:
  - design/safe-install-update-policy.md
  - reports/audit-080-version-update-overwrite-safety.md
  - scripts/acp.common.sh
files_affected:
  - agent/design/safe-install-update-policy.md
  - agent/scripts/acp.common.sh
  - agent/schemas/install-tier-registry.yaml
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-07-15
completed:
override_reason:
---

## Objective

Implement shared tier-aware copy helpers in `acp.common.sh` per design doc. Optional `install-tier-registry.yaml` for validate/docs.

## Acceptance criteria

- [ ] `acp_file_differs_from_upstream rel` compares SHA-256 local vs `$TEMP_DIR/rel`
- [ ] `acp_identity_is_customized` detects non-placeholder identity.yml
- [ ] `acp_copy_framework_file rel tier` enforces Tier A/B/C rules with logging
- [ ] `acp_merge_manifest_acp_core version` updates acp-core block only (Tier D)
- [ ] Design doc cross-references helper names

## Addresses

audit-080 F-080-01 (foundation); industry conffile/checksum patterns
