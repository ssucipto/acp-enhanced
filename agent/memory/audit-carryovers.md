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

carryovers:
  - audit_id: 14
    finding_id: BUG-001
    severity: critical
    file: agent/memory/sessions.md
    finding: Malformed YAML entry at line ~151 — executor block missing - date header; corrupts getLastNSessions() in acp-dispatch.ts
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-002
    severity: critical
    file: scripts/acp-dispatch.ts
    finding: HTTP-Referer hardcoded as placeholder "https://github.com/your-handle/your-repo" — should read from identity.yml homepage field
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003a
    severity: high
    file: agent/commands/acp.feedback.md
    finding: Missing command doc for /acp-feedback — feedback loop has no invocable command
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003b
    severity: high
    file: agent/commands/acp.task.md
    finding: Missing command doc for /acp-task — routing task creation has no command surface
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003c
    severity: high
    file: agent/commands/acp.install.md
    finding: Missing command doc for /acp-install — acp.install.sh has no agent-invocable companion
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003d
    severity: high
    file: agent/commands/acp.dispatch.md
    finding: Missing command doc for /acp-dispatch — Persona B/C users cannot invoke dispatch from inside IDE
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-004
    severity: medium
    file: agent/wiki/domain.yml
    finding: domain.yml commands.count is 58 but actual command count is 59 (will be 63 after BUG-003 fixes)
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-001
    severity: low
    file: scripts/scripts-package.json
    finding: Duplicate of scripts/package.json — should be deleted
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-002
    severity: medium
    file: README.md
    finding: scripts/QUICKSTART.md exists but is not linked from root README — new users cannot find the 3-4hr setup guide
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-003
    severity: medium
    file: README.md
    finding: git_workflow feature (Step 1b branch safety) is undiscoverable — not mentioned in README or QUICKSTART
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-004
    severity: medium
    file: scripts/acp-bootstrap.sh
    finding: No pre-commit hook for AGENTS.md→CLAUDE.md→copilot-instructions.md sync — manual copies will drift
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-005
    severity: low
    file: README.md
    finding: No Windows/WSL install path documented — TypeScript tooling works on Windows but shell scripts require WSL2
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null
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
