---
id: route-018
title: M40 — Create agent/memory/audit-carryovers.md with schema and protocol
task_type: yaml-schema
milestone: M40
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/memory/
  - agent/feedback/feedback-003-pre-implementation-audit-protocol.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - agent/memory/audit-carryovers.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Create `agent/memory/audit-carryovers.md` — a new memory file dedicated to tracking pending
audit fixes between sessions. This is the missing memory layer between sessions.md (too
high-level) and lessons.md (general patterns). The file starts empty (just schema + header).

## Acceptance Criteria

- [ ] `agent/memory/audit-carryovers.md` created with YAML schema header (commented)
- [ ] Schema includes: `audit_id`, `finding_id`, `severity`, `file`, `finding`, `status`, `fix_applied_date`, `verified_in_audit`, `escalated_to`
- [ ] Valid values documented: `severity: critical|high|medium|low`, `status: pending|in-progress|fixed`
- [ ] Protocol section explains when to write entries (end of any audit producing actionable items)
- [ ] Protocol section explains when to remove entries (after fix is verified)
- [ ] File starts with zero entries (empty list) — no sample data

## Implementation Notes

```yaml
# Audit Carryover Tracking
# Pending fixes from prior audits that require follow-up action
# Written by: /acp-audit (end of any audit with actionable findings)
# Read by: Step 4.4 of context-loading protocol (session start)
# Update status to 'fixed' when fix is applied; remove entry after re-verified
#
# Protocol:
#   Write  → At end of /acp-audit, append each unresolved finding as status: pending
#   Check  → Step 4.4 reads this file; surfaces all pending items before work begins
#   Update → When fix applied, set status: fixed and fix_applied_date
#   Verify → Set verified_in_audit to the audit ID that confirmed the fix
#   Remove → Safe to delete entry once verified_in_audit is set
#
# Schema:
# - audit_id: [N]
#   finding_id: [e.g. P2-1]          # phase+number code from source audit
#   severity: [critical|high|medium|low]
#   file: [path/to/task-or-src-file]  # file containing the issue
#   finding: [one-line description of what needs to be fixed]
#   status: [pending|in-progress|fixed]
#   fix_applied_date: null            # YYYY-MM-DD when status → fixed
#   verified_in_audit: null           # audit ID that confirmed fix worked
#   escalated_to: null                # e.g. "011-C4" if re-discovered in next audit

carryovers: []
# NOTE: All entries are stored under the `carryovers:` key (not at root level).
# When reading this file, access `carryovers` list. Example:
#   carryovers:
#   - audit_id: 44
#     finding_id: P2-1
#     ...
```

## Dependency

Must be created before route-019 (acp.audit.md references it in Phase 3) and route-020
(AGENTS.md Step 4.4 references it).
