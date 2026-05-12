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
#   finding_id: [e.g. BUG-001]       # finding code from source audit
#   severity: [critical|high|medium|low]
#   file: [path/to/file]             # primary file containing the issue
#   finding: [one-line description of what needs to be fixed]
#   description: [fuller description — added in audit-015 schema enrichment]
#   fix_target: [what specifically to change]
#   status: [pending|in-progress|fixed]
#   fix_applied_date: null            # YYYY-MM-DD when status → fixed
#   verified_in_audit: null           # audit ID that confirmed fix worked
#   escalated_to: null                # e.g. "011-C4" if re-discovered in next audit

carryovers:
  # ── AUDIT-014 FINDINGS — ALL FIXED IN M41 (routes 022–035, v6.7.0) ──────────

  - audit_id: 14
    finding_id: BUG-001
    severity: critical
    file: agent/memory/sessions.md
    finding: Malformed YAML entry missing - date header; corrupts getLastNSessions()
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-002
    severity: high
    file: scripts/acp-dispatch.ts
    finding: HTTP-Referer hardcoded placeholder — should read from identity.yml
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003a
    severity: high
    file: agent/commands/acp.feedback.md
    finding: Missing command doc for /acp-feedback
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003b
    severity: high
    file: agent/commands/acp.task.md
    finding: Missing command doc for /acp-task
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003c
    severity: high
    file: agent/commands/acp.install.md
    finding: Missing command doc for /acp-install
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-003d
    severity: high
    file: agent/commands/acp.dispatch.md
    finding: Missing command doc for /acp-dispatch
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: BUG-004
    severity: medium
    file: agent/wiki/domain.yml
    finding: domain.yml commands.count was 58; actual verified count is 63
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-001
    severity: low
    file: scripts/scripts-package.json
    finding: Duplicate of scripts/package.json — deleted
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-002
    severity: medium
    file: README.md
    finding: QUICKSTART.md not linked from README — new users cannot find the setup guide
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-003
    severity: medium
    file: README.md
    finding: git_workflow feature (Step 1b) undiscoverable — not in README or QUICKSTART
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-004
    severity: medium
    file: scripts/acp-bootstrap.sh
    finding: No pre-commit hook for AGENTS.md→CLAUDE.md sync — manual copies will drift
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  - audit_id: 14
    finding_id: GAP-005
    severity: low
    file: README.md
    finding: No Windows/WSL install path documented
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: "015"
    escalated_to: null

  # ── AUDIT-015 FINDINGS — OPEN (from external final audit, verified vs v6.7.0) ─

  - audit_id: 15
    finding_id: BUG-003
    severity: high
    file: scripts/acp-dispatch.ts
    finding: updateRoutingYml() called BEFORE API stream (line 208) — stale executor state on failure or SIGINT
    description: >
      If API call fails or SIGINT received, routing.yml shows intended executor/model
      with no work done. Also: SIGINT during streaming loses the ledger row — tokens
      billed but not recorded.
    fix_target: Move updateRoutingYml() to after appendLedger(); add SIGINT handler to flush partial ledger
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: MEMORY-002
    severity: high
    file: scripts/acp-validate.ts
    finding: acp-validate.ts has no sessions.md YAML structure check
    description: >
      Malformed sessions.md entries go undetected across full milestones.
      BUG-001 was present for one full milestone without detection.
    fix_target: Add validateSessionsMemory() function to no-args validate path
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: VALIDATE-001
    severity: high
    file: scripts/acp-validate.ts
    finding: No AGENTS.md byte-size check — accidental bloat silently breaks tool auto-load limits
    description: >
      AGENTS.md is 11,043 bytes (safe). But no guard exists. If content from AGENT.md
      (90,368 bytes) is accidentally merged, it silently exceeds tool auto-load limits.
    fix_target: Add validateAgentsMdSize() to acp-validate.ts + agents_md_rules to constraints.yml
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: ROUTING-001
    severity: high
    file: agent/routing/taxonomy.yml
    finding: 9 common task types missing from taxonomy.yml — dispatch falls back to wrong executor
    description: >
      Missing: wiki-update, memory-write, changelog-update, progress-update, adr-write,
      audit-run, milestone-create, route-create, upstream-parity-check. Sessions data
      confirms these occur regularly across M29–M40.
    fix_target: Add 9 entries to taxonomy.yml with correct executor, context_required, tokens_est, skill
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: MEMORY-001
    severity: medium
    file: agent/memory/lessons.md
    finding: lessons.md has no expiry/archive mechanism — superseded lessons load on every dispatch call forever
    description: >
      priority:high lessons load for every task type, forever. consumer-project overflow lesson
      is redundant — its fix is codified in constraints.yml as context_overflow_commit_first.
    fix_target: Add status/superseded_by fields; update getFilteredLessons() to skip status:archived
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: ROUTING-002
    severity: medium
    file: scripts/acp-dispatch.ts
    finding: getSkillFile() has no explicit mapping for 7 of the 9 new task types — silent crosscut fallthrough
    description: After ROUTING-001 taxonomy entries are added, getSkillFile() needs explicit mapping so fallback is intentional.
    fix_target: Add explicit crosscutTypes array in getSkillFile() after ROUTING-001 is done
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: ROUTING-003
    severity: low
    file: agent/routing/taxonomy.yml
    finding: taxonomy.yml has no parseable last_updated date field; acp-validate.ts staleness check not implemented
    description: config.yml last_verified was added (route-034) but taxonomy.yml header has comment-only date, no YAML field.
    fix_target: Add last_updated: field to taxonomy.yml header; add checkStaleness() to acp-validate.ts
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: VALIDATE-002
    severity: low
    file: scripts/acp-validate.ts
    finding: Parity check shows count mismatch only — does not show which specific files are missing
    description: At 63 commands, count-only output is unhelpful. Developer must manually diff directories.
    fix_target: Compute symmetric difference in runParityCheck() and print missing filenames
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  - audit_id: 15
    finding_id: STRUCT-003
    severity: low
    file: scripts/FINAL-REVIEW.md
    finding: FINAL-REVIEW.md has useful UX analysis but is outside agent/ tree — never loaded by context protocol
    fix_target: Move to agent/design/acp-ux-review.md; add to domain.yml design entries
    status: fixed
    fix_applied_date: 2026-05-11
    verified_in_audit: null
    escalated_to: null

  # ── AUDIT-016 FINDINGS ──────────────────────────────────────────────────────

  - audit_id: 16
    finding_id: OBS-001
    severity: low
    file: scripts/acp-validate.ts
    finding: checkStaleness() runs before validateAgentsMdSize() and validateSessionsMemory() in the no-args main block — informational output appears before blocking checks
    description: Cosmetic ordering issue. Users see staleness warnings intermixed before blocking validation results. Low priority but confusing when staleness warns while validate ultimately exits 0.
    fix_target: Move checkStaleness() call to after validateAgentsMdSize() and validateSessionsMemory() in the no-args main block (acp-validate.ts ~line 503-509)
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  # ── AUDIT-017 FINDINGS ──────────────────────────────────────────────────────

  - audit_id: 17
    finding_id: GAP-001
    severity: high
    file: agent/routing/taxonomy.yml
    finding: task_type shell-scripting used in route-005 and route-011 but not registered in taxonomy.yml — dispatcher falls back to claude-sonnet (most expensive)
    description: Two routes use task_type shell-scripting which has no executor mapping in taxonomy.yml. acp-dispatch.ts falls back to config.yml default_model (claude-sonnet) — 10-20x more expensive than the correct deepseek-v4-flash executor.
    fix_target: Add shell-scripting entry to taxonomy.yml aliasing to bash-script-fix (deepseek-v4-flash, tokens_est 4000), or update route-005 task_type to bash-script-create and route-011 to bash-script-fix
    status: fixed
    fix_applied_date: 2026-05-12
    verified_in_audit: null
    escalated_to: null
