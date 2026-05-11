---
id: route-029
title: M41b — Remove duplicate scripts/scripts-package.json (GAP-001)
task_type: documentation-sync
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/reports/audit-014-external-feedback-quality-and-improvement-plan.md
files_affected:
  - scripts/scripts-package.json
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Delete `scripts/scripts-package.json` — it is a duplicate of `scripts/package.json` with nearly identical content. Having two package files in the same directory creates confusion about which one is authoritative. Closes GAP-001 from audit-014.

## Acceptance Criteria

- [ ] Verify both files have same content (or `scripts-package.json` is a subset)
- [ ] Verify `scripts/package.json` has all required dependencies (`openai`, `gray-matter`, `js-yaml`, `ts-node`, `typescript`)
- [ ] `scripts/scripts-package.json` deleted
- [ ] No references to `scripts-package.json` remain in any documentation or scripts

## Implementation Notes

Before deleting, run:
```bash
diff scripts/package.json scripts/scripts-package.json
```
If there are differences, absorb any unique fields from `scripts-package.json` into `scripts/package.json` before deleting. Do NOT delete first and ask questions later.
