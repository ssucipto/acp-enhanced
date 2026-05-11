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
# When reading this file, access the `carryovers` list. Example:
#   carryovers:
#   - audit_id: 44
#     finding_id: P2-1
#     severity: high
#     file: agent/tasks/task-44-example.md
#     finding: Import path for auth module does not exist in codebase
#     status: pending
#     fix_applied_date: null
#     verified_in_audit: null
#     escalated_to: null
