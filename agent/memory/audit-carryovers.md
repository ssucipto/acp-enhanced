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
  # ── AUDIT-062 FINDINGS — M57 DEEP DIVE (2026-06-08) ─────────────────────────
  - audit_id: 62
    finding_id: F-062-01
    severity: medium
    file: agent/core/constraints.yml
    finding: "Hooks block format diverged from milestone plan — 2 of 3 planned hooks dropped (pre_commit_integrity_phase1, ci_npm_ignore_scripts)"
    description: "Milestone plan specified 3 boolean hooks; implementation uses task_id array binding. Better architecture but missing 2 hooks. Document as ADR."
    fix_target: "Create ADR documenting format change. Add ci_npm_ignore_scripts hook if CI enforces it."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "078"
    escalated_to: null
  - audit_id: 62
    finding_id: F-062-02
    severity: medium
    file: agent/commands/acp.validate.md
    finding: "3 milestone verification checklist items unverified — disabled exclusion, frequency/trigger XOR, executor cross-validation"
    description: "Step 4.5 doesn't exclude disabled tasks. Schema doesn't enforce frequency/trigger mutual exclusivity. No executor validation against taxonomy.yml."
    fix_target: "Add disabled exclusion to Step 4.5. Add XOR constraint to progress.schema.yaml. Add executor cross-check to validate Step 2d."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "078"
    escalated_to: null
  - audit_id: 62
    finding_id: F-062-03
    severity: high
    file: agent/progress.yaml
    finding: "No automated next_due calculation — manual date updates prone to drift and human error"
    description: "After running a recurring task, the developer must manually update last_run and next_due. No auto-increment based on frequency."
    fix_target: "Implement acp.task-complete.sh helper or --complete flag that auto-sets last_run=today and next_due=today+frequency."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "078"
    escalated_to: "M59 post-completion follow-up route (route-188 per audit-073). Automated next_due calculation deferred to M62 route-176 per audit-072 escalation. last_findings_count added (F-062-05)."
  - audit_id: 62
    finding_id: F-062-04
    severity: medium
    file: agent/examples/pre-commit-hook.sh
    finding: "No reference git hook implementation for pre-commit-rule-audit trigger"
    description: "The on-commit trigger has no example .git/hooks/pre-commit script showing how to wire /acp-integrity --fast --ci."
    fix_target: "Create agent/examples/pre-commit-hook.sh with 5-line reference implementation."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "078"
    escalated_to: null
  - audit_id: 62
    finding_id: F-062-05
    severity: medium
    file: agent/progress.yaml
    finding: "No findings-to-task feedback loop — scan results not connected to recurring task status"
    description: "Weekly integrity scan could find same issue for months without automated tracking. No last_findings_count or deferred_findings field."
    fix_target: "Add last_findings_count field to recurring_tasks entries. Defer full findings DB integration to M58."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "078"
    escalated_to: null

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
      priority:high lessons load for every task type, forever. TikrFlow overflow lesson
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
    status: fixed
    fix_applied_date: 2026-05-12
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

  # ── AUDIT-041 FINDINGS (M47 Pre-Implementation) ──────────────────────────────
  - audit_id: 41
    finding_id: GAP-041-04
    severity: low
    file: agent/routing/tasks/route-078.md
    finding: "Feedback-001 F-05 not covered — registry schema lint (require date: and name:; warn on unquoted colons)"
    description: "F-05 from feedback-001 recommends schema-level linting of patterns.md and sessions.md entries beyond YAML syntax validation. route-078 covers YAML parsing but not field-level schema enforcement. Candidate for M48."
    fix_target: "validateMemoryFieldLint() in acp-validate.ts --memory"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: "M48 route-088"
  - audit_id: 41
    finding_id: GAP-041-06
    severity: medium
    file: "[no specific file]"
    finding: "No CHANGELOG update route in M47 — v6.9.0 release needs release notes"
    description: "M47 targets v6.9.0 but no route covers CHANGELOG.md update."
    fix_target: "Add CHANGELOG.md update to M47 completion criteria or create route-085"
    status: fixed
    fix_applied_date: 2026-06-04
    verified_in_audit: null
    escalated_to: null
  - audit_id: 41
    finding_id: GAP-041-07
    severity: medium
    file: "[no specific file]"
    finding: "No E2E test route in M47 — commit auto-sync, repair tools, validation are testable"
    description: "Routes 074-078 produce user-facing features. Industry standard requires tests."
    fix_target: "command-e2e-coverage.yaml registers commit-sync + repair-tools suites"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: "M48 routes 085-086"
  - audit_id: 41
    finding_id: GAP-041-08
    severity: medium
    file: agent/commands/acp.commit.md
    finding: "Atomicity not addressed in commit auto-sync design — multi-file sync lacks transaction boundaries"
    description: "If sync fails mid-operation, partial state possible. Idempotent design mitigates but doesn't prevent."
    fix_target: "acp.atomic-write.sh temp-file + rename helper; wire into pattern-sync/session-sync/commit docs"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  # ── AUDIT-044 FINDINGS — POST-IMPLEMENTATION ENHANCEMENTS ─────────────
  - audit_id: 44
    finding_id: G-044-03
    severity: low
    file: agent/index/acp.core.yaml
    finding: "No index entry for new /acp-design-spec command — reduces contextual discoverability"
    description: "The key-file index system maps commands to design docs. Adding an entry in agent/index/acp.core.yaml lets agents discover the command during acp.plan / acp.design-create / acp.proceed context loading."
    fix_target: "Add acp.design-spec entry to agent/index/acp.core.yaml with weight 0.7, kind: command, applies: acp.design-spec, acp.proceed"
    status: fixed
    fix_applied_date: 2026-06-07
    verified_in_audit: "052"
    escalated_to: null
  - audit_id: 44
    finding_id: G-044-06
    severity: low
    file: agent/wiki/domain.yml
    finding: "No domain.yml entry for design-spec command taxonomy"
    description: "The wiki domain.yml tracks the command taxonomy. New commands should be registered for /acp-wiki-update consistency and cross-reference integrity."
    fix_target: "Add design-spec entry to agent/wiki/domain.yml commands section"
    status: fixed
    fix_applied_date: 2026-06-07
    verified_in_audit: "052"
    escalated_to: null
  - audit_id: 44
    finding_id: G-044-07
    severity: low
    file: README.md
    finding: "No README.md mention of /acp-design-spec — new user-facing command not listed"
    description: "README lists recent enhancements and command categories. M50 adds a significant new command (19-section interface specs, Mermaid diagrams, industry standards) that deserves a mention."
    fix_target: "Add /acp-design-spec to README recent enhancements or command listing section"
    status: fixed
    fix_applied_date: 2026-06-07
    verified_in_audit: "052"
    escalated_to: null
  - audit_id: 44
    finding_id: DEFER-044-01
    severity: low
    file: agent/milestones/milestone-50-design-spec-command.md
    finding: "P3 items deferred without follow-up tracking — Visualizer preset and exemplar"
    description: "Visualizer design-spec document type preset and abbreviated exemplar in agent/examples/ are deferred to later milestone but no carryover or future-milestone task exists."
    fix_target: "Create a follow-up task or add to next milestone's deferred list. Include in M50 session commit deferred: field."
    status: fixed
    fix_applied_date: 2026-06-07
    verified_in_audit: "052"
    escalated_to: null

  # ── AUDIT-045 FINDINGS — BOOTSTRAP INSTALL FAILURE ──────────────────
  - audit_id: 45
    finding_id: BUG-045-01
    severity: critical
    file: scripts/acp-bootstrap.sh
    finding: "Step 7 checks directory existence instead of file count — empty dirs from step 1 cause download skip"
    description: "Step 1 creates empty agent/commands/ and agent/scripts/ directories. Step 7 checks [ -d agent/commands ] && [ -d agent/scripts ] — directory exists (true) even when empty, so the install download is always skipped on fresh installs. Every new user gets 0 command files and 0 script files."
    fix_target: "Replace directory check with file count check using find ... | wc -l pattern (same as pre-flight check at line 89)"
    status: fixed
    fix_applied_date: 2026-06-06
    verified_in_audit: "046"
    escalated_to: null
  - audit_id: 45
    finding_id: BUG-045-02
    severity: high
    file: scripts/acp-bootstrap.sh
    finding: "OpenCode command generation nested inside GENERATE_PROMPTS block — skipped when prompts not generated"
    description: "Step 6b (opencode/cursor command generation) is inside if [ GENERATE_PROMPTS = true ]. GENERATE_OPENCODE defaults to true but is never independently checked. When prompts are skipped, .opencode/commands/ and .cursor/commands/ are never created."
    fix_target: "Extract opencode generation into separate if [ GENERATE_OPENCODE = true ] block independent of GENERATE_PROMPTS"
    status: fixed
    fix_applied_date: 2026-06-06
    verified_in_audit: "046"
    escalated_to: null
  - audit_id: 45
    finding_id: BUG-045-03
    severity: medium
    file: scripts/acp-bootstrap.sh
    finding: "Post-install verification detects failures but exits 0 — no auto-repair or fix command"
    description: "Verification correctly shows 0 files (red X) but bootstrap exits 0 and says Done. User sees failure but gets no remediation path."
    fix_target: "Exit non-zero on verification failure; print remediation command (re-run bootstrap or curl acp.install.sh)"
    status: fixed
    fix_applied_date: 2026-06-06
    verified_in_audit: "065"
    escalated_to: null

  # ── AUDIT-065 FINDINGS — COMPREHENSIVE GAP ANALYSIS 2026-06-15 ──────────────
  - audit_id: 65
    finding_id: CRIT-065-001
    severity: medium  # DOWNGRADED by audit-066: decisions.md is gitignored instance data (.gitignore:34), not missing storage
    file: agent/memory/decisions.md
    finding: "This framework-dev project never ran /acp-decide — its own 57-milestone ADR history is uncaptured (file auto-creates on first use; storage is NOT missing)"
    fix_target: "Run /acp-decide to capture this project's key ADRs; reconstruct 6 from wiki/patterns/commit history. De-prioritized vs code bugs per audit-066."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "073"
    verified_in_audit: "066 (reclassified)"
    escalated_to: null
  - audit_id: 65
    finding_id: CRIT-065-002
    severity: critical
    file: GitHub repository settings
    finding: "No branch protection rules on mainline or develop — force-push and direct commits unblocked"
    fix_target: "Deferred — GitHub Free tier (private repo); manual merge discipline on develop→mainline until upgrade or public repo rules. Script acp.branch-protection-setup.sh ready when available. mainline merged from develop 2026-07-15 (v6.27.1)."
    status: deferred
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-097-deferred
    escalated_to: null
  - audit_id: 65
    finding_id: CRIT-065-003
    severity: critical
    file: e2e/
    finding: "46 of 71 commands (65%) have no E2E test — core commands /acp-init, /acp-proceed, /acp-plan, /acp-dispatch, /acp-commit, /acp-validate, /acp-audit, /acp-route all untested"
    fix_target: "Add E2E tests in three tiers: Tier 1 (8 core commands), Tier 2 (12 package/project), Tier 3 (16 memory/knowledge)"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "074"
    escalated_to: null
  - audit_id: 65
    finding_id: HIGH-065-004
    severity: high
    file: agent/scripts/ (17 files)
    finding: "17 scripts use bare 'set -e' not 'set -euo pipefail' — unbound variable bugs silently succeed; pipeline failures masked"
    fix_target: "Batch-upgrade acp.install.sh, acp.package-*.sh, acp.project-info.sh, acp.project-update.sh, acp.sessions.sh, acp.uninstall.sh, acp.version-*.sh"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 65
    finding_id: HIGH-065-005
    severity: high
    file: .github/workflows/
    finding: "No Windows CI runner — Windows is documented target platform but has no automated test coverage"
    fix_target: "Add windows-latest to e2e-tests.yaml matrix (ubuntu + macOS + Windows)"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 65
    finding_id: HIGH-065-006
    severity: high
    file: SECURITY.md
    finding: "No SECURITY.md / vulnerability disclosure process for open-source production tooling"
    fix_target: "Create SECURITY.md with private advisory process + scope definition"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null

  # ── AUDIT-066 FINDINGS — SECOND-ROUND DEEP GAPS 2026-06-15 ──────────────────
  - audit_id: 66
    finding_id: HIGH-066-001
    severity: high
    file: scripts/acp-dispatch.ts
    finding: "updateRoutingYml() overwrites entire core/routing.yml with a 4-line session stub — destroys context_modes + command_suggestions on every Persona B/C dispatch (tracked file = committed data loss)"
    fix_target: "Replace full-file writeFileSync with surgical session-block update (use yaml_set or targeted regex). Add regression test asserting context_modes survives dispatch."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 66
    finding_id: HIGH-066-005
    severity: high
    file: .github/workflows/ci.yaml
    finding: "acp-validate.ts never runs in CI — placeholder + frontmatter-field checks never execute; CI only runs ci-validate.sh"
    fix_target: "Add 'npx ts-node scripts/acp-validate.ts' as a CI step in ci.yaml validate job"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 66
    finding_id: HIGH-066-006
    severity: high
    file: scripts/ci-validate.sh
    finding: "ci-validate.sh frontmatter check is a no-op for command files — gates on head -1 grep '^---$' but command docs start with '# Command:' (inline bold markers, not --- YAML). No automated structural conformance check exists for command docs."
    fix_target: "Add command-doc structure validation (## Steps, ## Verification, **Namespace**: etc.) instead of gating on a --- line command files never have"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 66
    finding_id: MED-066-002
    severity: medium
    file: scripts/acp-dispatch.ts
    finding: "OPENROUTER_API_KEY non-null assertion (process.env.X!) — missing env var yields cryptic SDK error not a clear preflight message"
    fix_target: "Add preflight check: fail fast with clear message if OPENROUTER_API_KEY unset before client init"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 66
    finding_id: MED-066-003
    severity: medium
    file: scripts/
    finding: "No unit tests for TS tooling — scripts/*.test.ts = 0 files; acp-dispatch.ts and acp-validate.ts entirely untested (only Turing-complete code in repo)"
    fix_target: "Add vitest/jest + scripts/*.test.ts covering buildContext budget, getFilteredLessons, updateRoutingYml non-destructiveness"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 66
    finding_id: MED-066-007
    severity: medium
    file: agent/schemas/
    finding: "Only 5 schemas exist; no schema for milestone/session/lessons/decisions/clarification/feedback/audit-carryovers — memory layer is unvalidated. Also acp-validate.ts does not enforce the 5 schemas that do exist."
    fix_target: "patterns.schema.yaml + SCHEMA_DATA_MAP + runSchemaEnforcement() for all memory arrays"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  # ── AUDIT-067 FINDINGS — COMPLETE CONSOLIDATED AUDIT 2026-06-15 ─────────────
  # NOTE: audit-067 Part B is the canonical deduplicated backlog. Entries below
  # are NEW findings only; prior 065/066 entries remain authoritative above.
  - audit_id: 67
    finding_id: HIGH-067-001
    severity: high
    file: package.yaml
    finding: "13 command docs absent from package.yaml — /acp-package-install would ship a broken framework missing acp.commit, acp.decide, acp.dispatch, acp.route, acp.task, acp.feedback, acp.visualize, acp.wiki-update, acp.carryover-query, acp.cost-report, acp.memory-sync, acp.pattern-sync, acp.session-sync"
    fix_target: "Add the 13 commands to package.yaml; add CI guard asserting package.yaml command count == command file count"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 67
    finding_id: MED-067-002
    severity: medium
    file: AGENTS.md
    finding: "AGENTS.md version header reads v6.10.0 while project is 6.12.1 — auto-loaded context file is 2 minors stale; three sync files not byte-identical (AGENTS.md has extra version header line)"
    fix_target: "Update AGENTS.md header to current version; add version-header check to /acp-validate Step 2c consistency check"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 67
    finding_id: MED-067-003
    severity: medium
    file: e2e/acp.integrity.test.sh
    finding: "Rule-count assertion uses grep -cE '^| IG-\\d+' but \\d is not a digit class in POSIX ERE (GNU grep -E) — matches literal 'd'; rule count miscomputed and non-portable"
    fix_target: "Replace \\d with [0-9] or use grep -P; verify >= 55 assertion actually computes correctly"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "074"
    escalated_to: null
  - audit_id: 67
    finding_id: MED-067-005
    severity: medium
    file: CONTRIBUTING.md
    finding: "No CONTRIBUTING.md despite being a public fork inviting contributions"
    fix_target: "Create CONTRIBUTING.md with branch model, test requirements, command-doc conventions"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "074"
    escalated_to: null
  - audit_id: 67
    finding_id: LOW-067-004
    severity: low
    file: agent/scripts/acp.git-provenance.sh
    finding: "Parses team_members with grep/while-read instead of YAML parser — violates scripts.md 'never parse YAML with grep' rule"
    fix_target: "Use yaml_get_array from acp.yaml-parser.sh to read team_members"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null

  # ── AUDIT-068 FINDINGS — M57 & M58 IMPLEMENTATION DEEP DIVE (2026-06-15) ─────
  # Note: M57's own findings F-062-01..05 remain pending (mapped to route-176/M62);
  # not re-listed here. Below are NEW findings only. See audit-068 report for full detail.
  - audit_id: 68
    finding_id: F-068-01
    severity: high
    file: agent/progress.yaml
    finding: "M54-M57 milestone artifact files missing; progress.yaml file: pointers dangle (e.g. M57 -> milestone-57-recurring-tasks-scheduler.md does not exist)"
    description: "GITIGNORE ARTIFACT — milestone-55/56/57/58 were tracked on origin all along; local gitignore hid them. Resolved 2026-06-15 by merging origin/develop (commit 90239d9). Residual: only M54 (milestone-54-ci-cd-gitflow.md) genuinely missing — see F-069-09."
    fix_target: "Resolved by sync. Residual M54 dangling pointer tracked as F-069-09."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "069"
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-02
    severity: high
    file: agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md
    finding: "M58 marked in_progress (25%) but routes 156/157/158 never expanded into route files; no acp.taint-heuristic.sh exists — claimed capability not runnable"
    description: "GITIGNORE ARTIFACT (route files) — routes 155-158 were tracked on origin; resolved 2026-06-15 by sync (commit 90239d9). The real residual is that route-157 scripts (acp.taint-scan.sh/acp.memory-scan.sh) remain unimplemented (route-157 not started) and route-155 under-delivered — see F-069-03/F-069-10."
    fix_target: "Route-file gap resolved by sync. Script implementation + route-155 scope tracked as F-069-03/F-069-10."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "069"
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-03
    severity: high
    file: agent/memory/audit-carryovers.md
    finding: "M57 shipped with HIGH carryover F-062-03 (no automated next_due -> manual date drift) still pending; currently queued late in route-176/M62"
    description: "A HIGH correctness gap lives in a shipped feature (recurring scheduler). Consider promoting F-062-03 out of M62 into the M59 critical track."
    fix_target: "Promote F-062-03 (auto next_due helper / --complete flag) to M59; keep F-062-01/02/04/05 in route-176."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-04
    severity: medium
    file: agent/benchmarks/fixtures/taint-flow/manifest.yaml
    finding: "Fixture manifest encodes severity but not the research-mandated max_confidence/CI policy; route-158 E2E built on severity alone could assert CRITICAL output, contradicting v2.0 'never CRITICAL in --ci' self-protection"
    description: "research-m58 mandates MEDIUM confidence ceiling and advisory-only taint findings. Severity (impact) != confidence (certainty)."
    fix_target: "Add max_confidence + ci_blocking per fixture aligned to the calibration matrix; update route-157/158 acceptance to assert no CRITICAL auto-fail on taint fixtures."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-07
    severity: medium
    file: agent/wiki/integrity-rules.md
    finding: "Neither integrity-rules.md nor acp.integrity.md reflect any v2.0 surface (still v1.0 / 'DEFERRED to v2.0'); wiki '55 v1.0 + 15 deferred' header going stale as M58 progresses"
    description: "Consistent with route-156 not_started, but doc surface unchanged despite M58 in_progress + fixtures shipped."
    fix_target: "Covered by route-156 (M58 doc/wiki/skill update); ensure header counts updated when v2.0 rules land."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-10
    severity: low
    file: agent/progress.yaml
    finding: "quarterly-deep-scan recurring task invokes unbuilt M58 capability (--rules taint-flow,memory); scheduled (next_due 2026-09-08) for a feature not yet implemented"
    fix_target: "Align quarterly-deep-scan activation with M58 delivery; gate or annotate until v2.0 ships."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 68
    finding_id: F-068-12
    severity: low
    file: agent/scripts/acp.meta-scan.sh
    finding: "Uses set -eu + ERR trap but not -o pipefail (partial case of audit-065 H4); not in route-173's 17-file list"
    fix_target: "Add acp.meta-scan.sh to route-173 pipefail scope, or upgrade its header to set -euo pipefail."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "073"
    verified_in_audit: audit-093
    escalated_to: null

  # ── AUDIT-069 FINDINGS — M57 & M58 POST-SYNC RE-AUDIT (2026-06-15) ───────────
  # Performed after merging origin/develop (commit 90239d9) which un-gitignored
  # milestones/tasks/routing/memory. Supersedes audit-068 F-068-01/02 (now fixed).
  # See agent/reports/audit-069-m57-m58-post-sync-reaudit.md for full detail.
  - audit_id: 69
    finding_id: F-069-01
    severity: high
    file: agent/milestones/milestone-57-recurring-tasks-scheduler.md
    finding: "Status desync — milestone-57.md & milestone-58.md say 'Status: planned / Started: —', contradicting progress.yaml (M57 completed 100% / M58 in_progress 25%) and git history"
    description: "Synced planning docs are pre-completion versions. A reader of the milestone file would conclude work never started. Single-source-of-truth violation introduced by the sync."
    fix_target: "Re-stamp milestone-57 -> completed, milestone-58 -> in_progress; add /acp-validate check flagging milestone/route status that disagrees with progress.yaml."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 69
    finding_id: F-069-02
    severity: high
    file: agent/routing/tasks/route-155.md
    finding: "route-155 completion desync — deliverables exist (research + 12 fixtures + manifest) and progress.yaml counts M58 1/4 done, but synced route-155.md completed: is empty"
    description: "Four tracking layers disagree on whether route-155 is done. Auto-stamp (/acp-commit protocol) never ran on the synced route file."
    fix_target: "Fill completed: on route-150..155; reconcile progress.yaml tasks_completed with route stamps."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 69
    finding_id: F-069-03
    severity: high
    file: agent/artifacts/research-m58-taint-flow-calibration.md
    finding: "route-155 scope under-delivery vs milestone-58 §7 — no 10 taint-flow CVEs, no TypeScript sample, no ESLint-security comparison, no empirical TPR (self-deferred to route-158), no memory-poisoning UX document — yet counted complete"
    description: "Research is solid literature calibration with JS fixtures but does not meet the milestone's empirical acceptance criteria."
    fix_target: "Either finish missing scope (empirical TPR vs ESLint, memory-poisoning UX doc) OR descope milestone-58 §7/§10 via ADR to the literature-calibration approach actually taken."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 69
    finding_id: F-069-04
    severity: high
    file: agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md
    finding: "Go/No-Go gate unsatisfiable as sequenced — §10 gates routes 156-158 on empirical taint TPR, but research measures no TPR ('measured in route-158') and route-158 is gated by the gate"
    description: "Circular dependency: the gate needs route-158's measurement; route-158 is blocked by the gate. The 'proceed' decision rests on literature estimates, not the mandated benchmark."
    fix_target: "Restructure the gate: move empirical TPR measurement into route-155/156 (before the gate), or accept literature ceilings explicitly via ADR and remove the empirical precondition."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 69
    finding_id: F-069-05
    severity: high
    file: agent/memory/audit-carryovers.md
    finding: "All 5 audit-062 (M57) carryovers still pending incl. F-062-03 (no automated next_due -> date drift) in a shipped feature; queued late in route-176/M62"
    description: "Reconfirms audit-068 F-068-03. M57's own audit findings remain open."
    fix_target: "Promote F-062-03 (auto next_due helper / --complete flag) to M59; keep F-062-01/02/04/05 in route-176."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: "M59 post-completion follow-up route (route-188 per audit-073). F-062-03 promoted."
  - audit_id: 69
    finding_id: F-069-09
    severity: medium
    file: agent/progress.yaml
    finding: "M54 dangling milestone pointer — progress.yaml M54 -> milestone-54-ci-cd-gitflow.md does not exist even after sync; M54 status active/30% with tasks_total: 0"
    description: "Residual of audit-068 F-068-01, now scoped to M54 only. tasks_total: 0 with active/30% is itself inconsistent."
    fix_target: "Create milestone-54-ci-cd-gitflow.md or remove the pointer; fix tasks_total vs progress."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "073"
    fix_applied_date: null
    verified_in_audit: audit-093
    escalated_to: null
  - audit_id: 69
    finding_id: F-069-10
    severity: low
    file: agent/routing/tasks/route-157.md
    finding: "Script naming mismatch — research recommends acp.taint-heuristic.sh; route-157/milestone-58 call them acp.taint-scan.sh + acp.memory-scan.sh (none exist yet)"
    fix_target: "Reconcile to one canonical script name before route-157 implementation."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null

  # ── AUDIT-072 FINDINGS — M58 POST-IMPL VERIFICATION (2026-06-15) ─────────────
  - audit_id: 72
    finding_id: F-072-01
    severity: high
    file: agent/wiki/integrity-rules.md
    finding: "Wiki header still says 'Deferred v2.0: 15 rules' after M58 un-deferred Cat 8/10"
    fix_target: "Update header to v2.0.0 with Phase 2 active and 70 total rules."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 72
    finding_id: F-072-02
    severity: high
    file: agent/scripts/acp.taint-scan.py
    finding: "Taint heuristics missed IG-47/48/50 on calibration fixtures (3/6 vulnerable fixtures returned clean)"
    fix_target: "Add file-level flow heuristics for indirect source→sink patterns; IG-50 LOW confidence."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null
  - audit_id: 72
    finding_id: F-072-03
    severity: medium
    file: e2e/acp.integrity-v2.test.sh
    finding: "E2E v2 only tested IG-45 fixture — not full 6-rule taint matrix"
    fix_target: "Add B13-B16: manifest fields, full matrix, --ci non-blocking, IG-50 LOW."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "072"
    escalated_to: null

  # ── AUDIT-070 FINDINGS — M55–M58 GATEWAY DEEP DIVE (2026-06-15) ──────────────
  - audit_id: 70
    finding_id: F-070-01
    severity: high
    file: agent/scripts/acp.entropy-scan.sh
    finding: "Entropy scanner crashes (exit 3) on every positive finding — set -e + output=$(...) where python uses sys.exit(findings) as data channel"
    description: "Under set -euo pipefail with ERR trap, the failing command substitution (python exits non-zero when findings>0) fires the trap and exits 3 before findings are printed. Scanner only works when it finds nothing; IG-17/IG-18 detection is non-functional."
    fix_target: "Stop using process exit code as count. Guard substitution (|| true / set +e) and parse count from stdout. Add true-positive E2E fixture."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: 071
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-02
    severity: high
    file: agent/scripts/acp.network-whitelist-validate.sh
    finding: "Claimed rule coverage >> implemented — ~18 of 55 v1.0 rules real. CRITICAL exfiltration (IG-07–13) and persistence (IG-21–26) categories have NO detection; IG-04/IG-05 also absent"
    description: "Command doc/wiki/skill/milestone present these as script-backed; the network script implements only IG-01,02,03,06. 18+ mostly-CRITICAL malicious-code rules silently pass — false assurance for a security gate."
    fix_target: "Implement the rules or relabel as 'documented, not enforced'; ship an accurate coverage matrix; gate --ci accordingly."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-03
    severity: high
    file: e2e/acp.integrity.test.sh
    finding: "Integrity E2E never exercises detection logic — B1 doesn't invoke the scanner; B2/B3 only test clean-file exit-0; B4 baseline only greps AGENTS.md; 4 scripts only bash -n syntax-checked"
    description: "The non-negotiable false-positive baseline promised in M56 §8 (assert_finding_count CRITICAL/HIGH 0 by running the gate) does not exist. F-070-01/02/06 all pass CI green."
    fix_target: "Add per-rule fixture matrix (true+/true- per script-backed rule) that runs real scripts and asserts rule ID + exit code; add the real clean-codebase baseline. Reuse M58 benchmarks/fixtures pattern."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: 071
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-04
    severity: high
    file: agent/scripts/acp.unicode-scan.sh
    finding: "O(lines × 16 codepoints × 2) python3 spawns — up to 32 interpreter starts per line; unusable as pre-commit/CI gate on real repos"
    fix_target: "Single python3 pass per file (or per tree) scanning the full codepoint set and emitting all findings with line/col."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: 071
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-05
    severity: medium
    file: agent/skills/code-integrity.md
    finding: "No script honors the documented output contract — skill defines findings: YAML with severity+confidence; scripts emit ad-hoc, mutually inconsistent text with no severity/confidence"
    fix_target: "Standardize on [SEVERITY] file:line ruleID — message (M55 format) and/or --json across all six scripts."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: 071
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-06
    severity: medium
    file: agent/scripts/acp.dependency-diff.sh
    finding: "--ci severity semantics contradict spec — doc says exit 1 on CRITICAL/HIGH only; scripts exit 1 on ANY finding. MEDIUM (IG-30/31) and IG-28 'postinstall present' break CI on normal projects"
    fix_target: "Scripts must emit severity; --ci filters to CRITICAL/HIGH only."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-07
    severity: medium
    file: agent/skills/code-integrity.md
    finding: "Skill 'Rules Covered' table overstates 4/6 scripts (git-prov claims IG-34/35 not impl, omits IG-36; dep-diff claims IG-29/32 not impl; network claims IG-05 not impl; unicode claims IG-16 homoglyphs not impl)"
    fix_target: "Align coverage tables (skill + script headers) to actual implementation."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-08
    severity: medium
    file: agent/scripts/acp.dependency-diff.sh
    finding: "Typosquatting is substring match over ~60 hardcoded packages, not Levenshtein 1–2 from top-1000 as claimed; misses real squats. IG-29 (shadow deps — the script's namesake) and IG-32 not implemented"
    fix_target: "Implement real Levenshtein (python helper); implement IG-29 by diffing imports/package.json vs lockfile; or descope honestly."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-09
    severity: medium
    file: agent/scripts/acp.network-whitelist-validate.sh
    finding: "YAML parsed with grep/sed across gateway — whitelist loader grabs ANY '- ' list item (not scoped to approved_hosts:), fail-open; same in git-provenance + manifest verify. Violates scripts.md (LOW-067-004 class)"
    fix_target: "Use agent/scripts/acp.yaml-parser.sh; scope extraction to the correct key."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-10
    severity: medium
    file: agent/scripts/acp.dependency-diff.sh
    finding: "IG-31 stale-lockfile uses file mtime — unreliable in git checkouts/CI (clone resets mtimes to checkout time)"
    fix_target: "Use git log -1 --format=%ct -- <file> for both files."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-11
    severity: medium
    file: agent/scripts/acp.git-provenance.sh
    finding: "IG-37 provenance is a no-op out of the box — identity.yml ships team_members: [] so author verification is silently skipped for every commit"
    fix_target: "Emit explicit IG-37 SKIPPED warning when team_members empty; document first-run setup."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-12
    severity: medium
    file: agent/scripts/acp.manifest-hash.sh
    finding: "IG-41 (new files in agent/core/ not in manifest) structurally undetectable — manifest tracks hardcoded 7-file list, never enumerates directory. --generate prints to stdout (not the file) while --verify reads the file"
    fix_target: "Glob tracked directories at generate time; have --generate write agent/manifest.yaml (with --stdout opt-out)."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-13
    severity: low
    file: agent/scripts/acp.unicode-scan.sh
    finding: "Mis-attributes rule IDs (JSON hardcodes IG-14 for all hidden-char hits; human output omits rule ID). Comment-detector ERE '/\\\\*' won't match real /* block comments"
    fix_target: "Map codepoint class → correct rule (IG-14/15/16); fix comment regex."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-14
    severity: low
    file: e2e/acp.integrity.test.sh
    finding: "Rule-count assertion uses grep -cE '^\\| IG-\\d+' — \\d is literal in ERE → count 0, [ 0 -ge 55 ] fails (masked by || echo 0). Same class as F-067-003"
    fix_target: "Use grep -cE '^\\| IG-[0-9]+'."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-15
    severity: low
    file: agent/scripts/acp.manifest-hash.sh
    finding: "Portability — shasum -a 256 only (many Linux CI images have sha256sum not shasum); unicode/entropy hard-require python3 and silently degrade to exit-2 warning if absent"
    fix_target: "Fall back to sha256sum/openssl dgst; document python3 requirement / make absence a hard error in --ci."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null
  - audit_id: 70
    finding_id: F-070-16
    severity: low
    file: agent/skills/code-integrity.md
    finding: "Token-budget inconsistency — skill header says ≤800 tokens; M56 deliverable + checklist specified ≤500"
    fix_target: "Pick one budget; update M56 checklist to match."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null

  # ── AUDIT-071 FINDINGS — M59/M64 POST-IMPL (2026-06-15) ─────────────────────
  - audit_id: 71
    finding_id: F-071-01
    severity: high
    file: agent/core/identity.yml
    finding: "v6.19.0 / M64 completion tracked locally but uncommitted — version drift vs git HEAD c7a1a9b"
    description: "M64 routes 180–184, fixtures, CI wiring, and doc truth pass exist in working tree at v6.19.0 but are not in git history. Operators see completed milestone in progress.yaml while HEAD is v6.14.1."
    fix_target: "Commit v6.19.0 bundle: scripts, fixtures, E2E, CI, wiki, progress, CHANGELOG."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: 071
    escalated_to: null

  # ── AUDIT-073 FINDINGS — M65 POST-IMPL VERIFICATION (2026-06-15) ─────────────
  - audit_id: 73
    finding_id: F-073-04
    severity: low
    file: agent/progress.yaml
    finding: "191 duplicate YAML mapping keys (started:, completed_date:) across task entries cause js-yaml parse failure; validate.ts fallback loader works but hides the symptom"
    description: "Systemic duplication from accumulated session writes. The fallback loader masks the issue but the underlying YAML is still corrupt. Fix requires a dedup script."
    fix_target: "Create acp.dedup-progress.sh or a one-time cleanup that deduplicates started:/completed_date: fields on task entries, keeping the most recent value. Deferred to M70 tech-debt track."
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-086
    escalated_to: null

  # ── AUDIT-075 FINDINGS — M61 POST-IMPL DEEP DIVE (2026-06-15) ─────────────────
  # All findings were discovered and fixed in the same audit cycle. Listed
  # for historical traceability; status: fixed with fix_applied_date set.
  - audit_id: 75
    finding_id: F-075-001
    severity: high
    file: SECURITY.md
    finding: "YOUR_ORG placeholder in GitHub Security Advisories URL — link broken for external researchers"
    fix_target: "Replace YOUR_ORG with ssucipto per identity.yml repo field"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 75
    finding_id: F-075-002
    severity: medium
    file: SECURITY.md
    finding: "Version footer stale — says 6.20.2, project is 6.20.7"
    fix_target: "Update version footer to match current project version"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 75
    finding_id: F-075-003
    severity: low
    file: SECURITY.md
    finding: "Fallback contact underspecified — no encryption-key path, email-only for sensitive reports"
    fix_target: "Add keyserver reference and note about encrypted email"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 75
    finding_id: F-075-004
    severity: high
    file: .github/workflows/ci.yaml
    finding: "Trufflehog uses unpinned trufflesecurity/trufflehog@main — violates IG-67 pinned-SHA requirement"
    fix_target: "Pin to commit SHA 84a2b33c9f891494db6ebe02f2a55b19cdf38f25 with version comment"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 75
    finding_id: F-075-005
    severity: medium
    file: .github/workflows/e2e-tests.yaml
    finding: "Windows CI added without conditional test-skipping mechanism for non-portable suites (task spec item #4 not implemented)"
    fix_target: "Add documented protocol comment for Windows suite authors"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 75
    finding_id: F-075-006
    severity: low
    file: .github/dependabot.yml
    finding: "open-pull-requests-limit set for npm (5) but not github-actions (unlimited by default)"
    fix_target: "Add open-pull-requests-limit: 5 to github-actions block"
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "075"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-001
    severity: high
    file: CHANGELOG.md
    finding: "v6.21.0 entry appears AFTER v6.20.9. Reverse chronological order violated — newest release should be first entry."
    fix_target: "Move ## [6.21.0] entry before ## [6.20.9]."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-002
    severity: medium
    file: agent/milestones/milestone-62-quality-hardening-schema-carryovers.md
    finding: "**Status**: planned — never updated to completed. Milestone fully shipped (7/7 routes, v6.21.0 tagged)."
    fix_target: "Change Status to completed, set completion date to 2026-06-15."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-003
    severity: medium
    file: agent/milestones/milestone-62-quality-hardening-schema-carryovers.md
    finding: "Verification gate has 4 aspirational bullets with no pass/fail markers (no ✅/❌/⏳)."
    fix_target: "Populate verification gate with actual pass/fail results."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-004
    severity: medium
    file: agent/progress.yaml
    finding: "monthly-dependency-audit missing last_findings_count — F-062-05 only added to 3 of 4 recurring_tasks."
    fix_target: "Add last_findings_count: 0 to monthly-dependency-audit."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-005
    severity: low
    file: agent/scripts/acp.yaml-validate.sh
    finding: "Standalone executable script with no set -e or set -euo pipefail."
    fix_target: "Add set -euo pipefail + ERR trap."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-006
    severity: low
    file: agent/scripts/acp.package-search.sh
    finding: "Has # set -e commented out with subshell rationale. Should use conventional pattern."
    fix_target: "Add set -euo pipefail or document as standard exclusion."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null
  - audit_id: 76
    finding_id: F-076-007
    severity: low
    file: agent/scripts/acp.post-milestone-sweep.sh
    finding: "Created with CRLF on Windows. Pre-commit hook (same commit) couldn't catch it — new-file race condition."
    fix_target: "Verify .gitattributes prevents recurrence. Test on clean checkout."
    status: fixed
    fix_applied_date: 2026-06-15
    verified_in_audit: "076"
    escalated_to: null

  # ── AUDIT-077 FINDINGS — CROSS-AGENT HANDOFF (M67) ───────────────────────────
  # Field evidence: FIFOZ audit-245, feedback-007. Planned: M67 routes 190–197.
  # Post-ship verification: audit-079 (2026-07-15)
  - audit_id: 77
    finding_id: H1
    severity: high
    file: agent/commands/acp.handoff.md
    finding: "Command forbids implementation steps; executor handoffs require task sequence, ADRs, guardrails"
    description: "acp.handoff.md L125/L247 explicit ban conflicts with FIFOZ M51 exemplar. Multi-executor same-repo workflow blocked by spec."
    fix_target: "acp.handoff.md v2 --mode executor with mandatory §4 template (route-190)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-190
  - audit_id: 77
    finding_id: H2
    severity: high
    file: agent/commands/
    finding: "No /acp-receive command; incoming agent has no structured protocol"
    fix_target: "Create acp.receive.md + wrappers (route-191)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-191
  - audit_id: 77
    finding_id: H3
    severity: high
    file: agent/commands/acp.handoff.md
    finding: "/acp-commit not enforced before handoff despite routing.yml suggestion"
    fix_target: "Outgoing ritual in handoff v2 command text (route-190)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-190
  - audit_id: 77
    finding_id: H4
    severity: medium
    file: agent/commands/
    finding: "No git commit pin freshness check on receive"
    fix_target: "/acp-receive step 3 git drift warning (route-191, route-195 E2E)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-191
  - audit_id: 77
    finding_id: H5
    severity: medium
    file: agent/reports/
    finding: "Ad-hoc handoff filename conventions (4 patterns across 9 FIFOZ handoffs)"
    fix_target: "Standardize handoff-{to}-{scope}-{date}.md in command (route-190)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-190
  - audit_id: 77
    finding_id: H6
    severity: medium
    file: agent/wiki/cross-agent-handoff.md
    finding: "No return-handoff template (implement → planning agent)"
    fix_target: "Template § Return handoff + wiki (route-190, route-194)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-194
  - audit_id: 77
    finding_id: H7
    severity: medium
    file: agent/commands/acp.handoff.md
    finding: "Self-contained-without-source conflicts with same-repo executor handoffs"
    fix_target: "Mode split: executor assumes same repo; cross-repo retains v1 rule (route-190)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-190
  - audit_id: 77
    finding_id: H8
    severity: low
    file: agent/progress.yaml
    finding: "Handoff usage undercounted in audits; no discoverability pointer"
    fix_target: "active_handoff field + wiki (route-193)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-193
  - audit_id: 77
    finding_id: H9
    severity: low
    file: agent/schemas/progress.schema.yaml
    finding: "No active_handoff pointer in progress.yaml schema"
    fix_target: "Schema extension + validate (route-193)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-193
  - audit_id: 77
    finding_id: H10
    severity: low
    file: agent/reports/
    finding: "Cross-repo handoffs mixed in same filename family without target-repo field"
    fix_target: "--mode cross-repo + optional target-repo frontmatter P2 (route-194)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-194
  - audit_id: 77
    finding_id: U1
    severity: medium
    file: agent/commands/acp.resume.md
    finding: "acp-resume chains init+proceed but never loads handoff files"
    fix_target: "Optional handoff path → receive protocol (route-192)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-192
  - audit_id: 77
    finding_id: U2
    severity: low
    file: agent/
    finding: "No formal proposals/feedback intake path until audit-077"
    fix_target: "CONTRIBUTING.md intake section (route-196)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-196
  - audit_id: 77
    finding_id: U3
    severity: low
    file: agent/wiki/
    finding: "No cross-agent handoff wiki until audit-077 (draft only)"
    fix_target: "Finalize wiki on M67 ship (route-193)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-193

  # ── AUDIT-078 FINDINGS — M67 PRE-IMPL (2026-07-15) ───────────────────────────
  - audit_id: 78
    finding_id: P-078-01
    severity: medium
    file: agent/wiki/domain.yml
    finding: "domain.yml entries corrupt at L33-37 — acp.feedback has duplicate category/purpose; acp.handoff purpose merged without command key"
    description: "Adding acp.receive on top of corrupt entries will propagate bad taxonomy. Must repair acp.feedback and add explicit acp.handoff entry before M67 ship."
    fix_target: "route-196: split L33-37 into proper acp.feedback and acp.handoff entries; add acp.receive entry; update count to 70 acp commands"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: M67 route-196

  # ── AUDIT-079 FINDINGS — M67 POST-SHIP GAPS (2026-07-15) ─────────────────────
  # Housekeeping closed in same session (audit-079 follow-up).
  - audit_id: 79
    finding_id: F-079-01
    severity: medium
    file: agent/milestones/milestone-67-cross-agent-handoff-protocol.md
    finding: "Milestone status completed but verification gates L88-108 all unchecked"
    fix_target: "Mark verification gates pass; align milestone doc with shipped state"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-02
    severity: medium
    file: agent/tasks/milestone-67-cross-agent-handoff-protocol/
    finding: "task-195..202 still status planned while routes 190-197 completed"
    fix_target: "Stamp all 8 task docs completed 2026-07-15"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-03
    severity: medium
    file: agent/memory/sessions.md
    finding: "No sessions.md entry for M67 v6.23.0 ship"
    fix_target: "Write session entry via /acp-commit"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-04
    severity: medium
    file: agent/feedback/feedback-007-cross-agent-handoff-protocol.md
    finding: "feedback-007 section 6 acceptance criteria still unchecked"
    fix_target: "Check acceptance boxes; document FIFOZ acp-version-update path"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-05
    severity: low
    file: README.md
    finding: "README omits /acp-receive and cross-agent-handoff wiki"
    fix_target: "Add receive to workflow list; link cross-agent-handoff.md"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-06
    severity: low
    file: .github/prompts/acp-handoff.prompt.md
    finding: "Handoff wrapper description still v1 cross-context not v2 dual mode"
    fix_target: "Update handoff wrapper descriptions on all 3 surfaces"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-07
    severity: low
    file: agent/wiki/domain.yml
    finding: "e2e_suites catalog missing acp.handoff and acp.receive tests"
    fix_target: "Add both suites to domain.yml test_suites"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-08
    severity: low
    file: agent/progress.yaml
    finding: "notes still claim 69 commands after M67"
    fix_target: "Update progress.yaml notes to 70 commands"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null
  - audit_id: 79
    finding_id: F-079-11
    severity: low
    file: package.yaml
    finding: "HIGH-067-001 still pending but 0/70 acp commands missing from package.yaml"
    fix_target: "Re-verify HIGH-067-001; mark fixed if confirmed"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: "079"
    escalated_to: null

  # ── AUDIT-080 FINDINGS — VERSION-UPDATE OVERWRITE SAFETY (2026-07-15) ────────
  # Field report: FIFOZ /acp-version-update overwrote identity.yml. route-079 doc-only.
  - audit_id: 80
    finding_id: F-080-01
    severity: critical
    file: agent/scripts/acp.version-update.sh
    finding: "route-079 guards (--diff, --preserve-project-core, --force) documented and marked complete but script has zero argument parsing"
    fix_target: "Implement route-079 in acp.version-update.sh; reopen route-079 until E2E passes"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-02
    severity: critical
    file: agent/scripts/acp.version-update.sh
    finding: "cp agent/core/*.yml blindly overwrites identity.yml on every version-update"
    fix_target: "Tier B policy: never overwrite identity.yml without --force; hash-diff vs upstream default"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-03
    severity: high
    file: agent/scripts/acp.version-update.sh
    finding: "agent/wiki/domain.yml and all wiki markdown overwritten on version-update"
    fix_target: "Add wiki paths to preserve-project-core tier; skip if modified"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-04
    severity: high
    file: agent/scripts/acp.version-update.sh
    finding: "routing taxonomy.yml, rules.md, config.yml overwritten on version-update"
    fix_target: "Tier B preserve for consumer-customized routing config"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-05
    severity: high
    file: scripts/acp-bootstrap.sh
    finding: "bootstrap re-run overwrites constraints.yml, routing.yml, wiki, taxonomy (only identity is create-if-absent)"
    fix_target: "create-if-absent for all Tier B bootstrap stubs"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-06
    severity: high
    file: agent/scripts/acp.install.sh
    finding: "acp.install.sh always cat > agent/manifest.yaml destroying third-party package entries on reinstall"
    fix_target: "Merge acp-core block only; preserve existing packages: keys"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-07
    severity: high
    file: agent/scripts/acp.install.sh
    finding: "acp.install.sh overwrites agent/core/*.yml on existing agent/ directory"
    fix_target: "Tier B preserve on reinstall; match version-update policy"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-08
    severity: medium
    file: CHANGELOG.md
    finding: "CHANGELOG v6.9.0 claims version-update core file protection shipped but script unchanged"
    fix_target: "Reconcile CHANGELOG after script fix; note doc-only gap in audit-080"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-10
    severity: medium
    file: e2e/acp.version.test.sh
    finding: "No behavioral E2E asserting project files preserved on version-update"
    fix_target: "Add e2e/acp.version-update-preserve.test.sh with customized identity.yml fixture"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-11
    severity: medium
    file: agent/scripts/acp.install.sh
    finding: "xargs in manifest generation fails on Windows Git Bash (sysconf error)"
    fix_target: "Replace xargs basename loops with portable while-read loop"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-09
    severity: medium
    file: agent/scripts/acp.version-update.sh
    finding: "Script entry check requires AGENT.md only; ACP Enhanced standard is AGENTS.md"
    fix_target: "Accept AGENTS.md OR AGENT.md; triple-sync AGENTS→CLAUDE+copilot on update (route-199)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 80
    finding_id: F-080-12
    severity: low
    file: agent/commands/acp.version-update.md
    finding: "Command doc lists domain.yml under agent/core/ — actual path is agent/wiki/domain.yml"
    fix_target: "Fix path in acp.version-update.md (route-203)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null

  # ── AUDIT-081 PRE-IMPL GAPS — M68 (2026-07-15) ───────────────────────────────
  - audit_id: 81
    finding_id: P-081-01
    severity: medium
    file: agent/scripts/acp.version-update.sh
    finding: "version-update L153 copies all agent/commands/*.*.md — overwrites third-party/custom command namespaces (Tier A)"
    fix_target: "route-199: copy only acp.*.md and git.*.md; skip other namespaces per design Tier A"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 81
    finding_id: P-081-02
    severity: medium
    file: agent/scripts/acp.version-update.sh
    finding: "version-update L193 blind-copies all skills; install skips local.* — update must match"
    fix_target: "route-199: skip local.*.md skills on update (Tier B); add E2E regression"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 81
    finding_id: P-081-03
    severity: medium
    file: e2e/acp.version-update-preserve.test.sh
    finding: "E2E preserve test needs offline upstream fixture — domain.yml says no network for version-update in CI"
    fix_target: "route-202: use ACP_UPSTREAM_ROOT=PROJECT_ROOT or copied fixture; no live git clone in CI"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null
  - audit_id: 82
    finding_id: F-082-09
    severity: low
    file: e2e/acp.bootstrap-preserve.test.sh
    finding: "No E2E for bootstrap re-run preserving customized Tier B files"
    fix_target: "Add e2e/acp.bootstrap-preserve.test.sh — re-run bootstrap with customized identity.yml"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 082
    escalated_to: null

  # ── AUDIT-083 FINDINGS — M63 POST-SHIP (2026-07-15) ─────────────────────────
  - audit_id: 83
    finding_id: F-083-01
    severity: high
    file: e2e/acp.tier3-memory-knowledge.test.sh
    finding: "Tier-3 E2E asserted only 26 of 58 commands while registry claimed full coverage"
    description: "Static hand-picked command list gave false confidence; registry mapped all tier-3 slugs to one suite."
    fix_target: "Dynamic loop over all non-tier-2 acp.*.md docs; meta-assertion TIER3_COUNT=58"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 083
    escalated_to: null
  - audit_id: 83
    finding_id: F-083-02
    severity: medium
    file: agent/milestones/milestone-63-test-coverage-tier2-3.md
    finding: "Success criteria referenced CHANGELOG v6.18.0 instead of v6.25.0"
    fix_target: "Update success criteria and add verification gates"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 083
    escalated_to: null
  - audit_id: 83
    finding_id: F-083-03
    severity: medium
    file: agent/tasks/milestone-63-test-coverage-tier2-3/
    finding: "No M63 task tracking doc while route-206 marked complete"
    fix_target: "Create task-211-route-206-coverage.md"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 083
    escalated_to: null
  - audit_id: 83
    finding_id: F-083-04
    severity: medium
    file: scripts/acp-validate.test.ts
    finding: "No vitest unit test for validateCommandE2eCoverage"
    fix_target: "Add options param (repoRoot/commandsDir) + fixture + 3 vitest cases"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 083
    escalated_to: null
  - audit_id: 83
    finding_id: F-083-06
    severity: low
    file: e2e/acp.tier2-workflow.test.sh
    finding: "Agent Directive check case-sensitive — acp.proceed uses CRITICAL AGENT DIRECTIVE"
    fix_target: "Use grep -qi for case-insensitive directive check in tier2/tier3 suites"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 083
    escalated_to: null

  # ── AUDIT-084 FINDINGS — M63 PRE-DEPLOYMENT (2026-07-15) ────────────────────
  - audit_id: 84
    finding_id: F-084-01
    severity: high
    file: agent/tasks/milestone-63-test-coverage-tier2-3/task-217-audit-083-release-closure.md
    finding: "v6.25.1 git tag missing — validate fails, task-217 step 5 incomplete"
    description: "identity.yml and CHANGELOG at 6.25.1 but only v6.25.0 tag exists on HEAD commit a84b00a."
    fix_target: "git tag -a v6.25.1 -m 'M63 audit-083 closure' HEAD; re-run acp-validate"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 084
    escalated_to: null
  - audit_id: 84
    finding_id: F-084-02
    severity: high
    file: agent/progress.yaml
    finding: "develop branch not pushed — v6.25.0/v6.25.1 commits local only"
    description: "c0baf78 and a84b00a ahead of origin/develop. Remote consumers cannot receive M63 amendment."
    fix_target: "git push origin develop && git push origin v6.25.0 v6.25.1"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 084
    escalated_to: null
  - audit_id: 84
    finding_id: F-084-03
    severity: medium
    file: agent/tasks/milestone-63-test-coverage-tier2-3/task-217-audit-083-release-closure.md
    finding: "task-217 marked completed while git tag step remains undone"
    fix_target: "Complete tag step; update verification checklist; stamp after F-084-01 fixed"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 084
    escalated_to: null
  - audit_id: 84
    finding_id: F-084-04
    severity: medium
    file: agent/progress.yaml
    finding: "recent_work stale tier3 assertion count (96 vs 259)"
    fix_target: "Update recent_work M63 entry: tier3 259 assertions post audit-083"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: 084
    escalated_to: null

  # ── REVIEW-001 FINDINGS — CODE REVIEW (2026-07-15) ───────────────────────────
  - audit_id: review-001
    finding_id: CR-001
    severity: critical
    file: scripts/package.json
    finding: "vitest ^1.6.0 — npm audit CRITICAL GHSA-5xrq (UI server arbitrary file RCE)"
    description: "Dev dependency; CI uses vitest run not UI — still violates SC-14 gate."
    fix_target: "Upgrade vitest to >=3.2.6; npm audit fix in scripts/"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: review-001-remediation
    escalated_to: null
  - audit_id: review-001
    finding_id: CR-002
    severity: high
    file: scripts/package.json
    finding: "Transitive vite <=6.4.2 — GHSA-fx2h high path traversal"
    fix_target: "Upgrade vitest/vite via npm audit fix; re-run scripts npm test"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: review-001-remediation
    escalated_to: null
  - audit_id: review-001
    finding_id: CR-003
    severity: high
    file: scripts/acp-validate.ts
    finding: "Widespread any in YAML parsers — loadYaml<any>, Record<string, any>"
    fix_target: "Add typed interfaces for taxonomy/config/progress YAML structures"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: review-001-remediation
    escalated_to: null
  - audit_id: review-001
    finding_id: CR-004
    severity: high
    file: scripts/acp-dispatch.ts
    finding: "catch (err: any) at line 294 — should use unknown"
    fix_target: "catch (err: unknown) with instanceof Error guard"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: review-001-remediation
    escalated_to: null
  - audit_id: review-001
    finding_id: CR-005
    severity: high
    file: agent/scripts/acp.package-search.sh
    finding: "Missing set -euo pipefail + trap ERR (SH-01 violation)"
    fix_target: "Refactor subshell loop or add ERR trap; align with route-173 pipefail standard"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: review-001-remediation
    escalated_to: null

  # ── INTEGRITY-001 FINDINGS — SELF SCAN (2026-07-15) ──────────────────────────
  - audit_id: integrity-001
    finding_id: INT-001
    severity: high
    file: agent/manifest.yaml
    finding: "IG-42 — manifest.yaml lacks files: sha256 block; 88 framework paths fail --verify"
    fix_target: "Run acp.manifest-hash.sh --generate to populate files: SHA registry (or split integrity manifest)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: integrity-001-remediation
    escalated_to: null
  - audit_id: integrity-001
    finding_id: INT-002
    severity: high
    file: agent/scripts/acp.git-provenance.sh
    finding: "IG-37 — BSD sed \\s in team_members parser fails on macOS; false unknown-author alerts"
    fix_target: "Replace sed 's/^\\s*-' with '[[:space:]]' POSIX class or yaml_get for team_members"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: integrity-001-remediation
    escalated_to: null

  # ── AUDIT-085 FINDINGS — ACP-REVIEW SELF-COVERAGE (2026-07-15) ─────────────
  - audit_id: audit-085
    finding_id: F-085-01
    severity: high
    file: agent/commands/acp.review.md
    finding: "Default path src/ misses ACP Enhanced codebase — no src/ directory exists"
    fix_target: "Add --self flag (scripts/, agent/scripts/, agent/commands/) or change ACP default path"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-085-remediation
    escalated_to: null
  - audit_id: audit-085
    finding_id: F-085-05
    severity: medium
    file: agent/commands/acp.review.md
    finding: "Rule ID collision — AP-01/02/03 used for API rules and Appendix A ACP rules"
    fix_target: "Rename Appendix A AP-* to ACP-01/02/03; update E2E and skill references"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-085-remediation
    escalated_to: null
  - audit_id: audit-085
    finding_id: F-085-06
    severity: medium
    file: README.md
    finding: "Rule count inconsistent — command doc says 54, README/domain.yml claim 77"
    fix_target: "Reconcile to 64 distinct definitions (54+10 appendix); update README, domain.yml, sessions.md"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-085-remediation
    escalated_to: null
  - audit_id: audit-085
    finding_id: F-085-07
    severity: medium
    file: e2e/acp.review.test.sh
    finding: "E2E does not execute /acp-review — only greps command doc against fixtures (M55 G-004 partial)"
    fix_target: "Add behavioral test: run review on fixture dir with --ci or script-backed rule scanner"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-085-remediation
    escalated_to: null

  # ── AUDIT-086 FINDINGS — CARRYOVER SECOND ROUND (2026-07-15) ───────────────

  - audit_id: audit-086
    finding_id: F-086-02
    severity: medium
    file: agent/feedback/feedback-007-cross-agent-handoff-protocol.md
    finding: "FIFOZ consumer path — /acp-version-update on downstream project not verified"
    fix_target: "Run /acp-version-update on FIFOZ when consumer repo access available"
    status: pending
    fix_applied_date: null
    verified_in_audit: audit-088-deferred
    escalated_to: null

  - audit_id: audit-086
    finding_id: F-086-03
    severity: medium
    file: agent/commands/acp.review.md
    finding: "/acp-review Phase 1 scanner covers 4/64 rules — not a standalone CI gate"
    fix_target: "Two-phase gate policy + 8-rule acp.review-scan.sh"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: null

  - audit_id: audit-086
    finding_id: F-086-04
    severity: low
    file: agent/memory/audit-carryovers.md
    finding: "Carryover registry drift — 21 entries stale 30+ days before audit-086 hygiene"
    fix_target: "validateCarryoverFreshness() in acp-validate.ts + vitest fixture"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  # ── AUDIT-087 FINDINGS — M70 PRE-IMPL READINESS (2026-07-15) ───────────────

  - audit_id: audit-087
    finding_id: F-087-01
    severity: high
    file: agent/tasks/milestone-70-tech-debt-gate-hardening/task-225.md
    finding: "task-225 references non-existent review rule IDs API-01 and CQ-01 — blocks scanner expansion"
    fix_target: "Amend task-225 to AP-01, SC-01 (or NC-01); verify against acp.review.md before /acp-proceed"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: null

  - audit_id: audit-087
    finding_id: F-087-02
    severity: high
    file: agent/tasks/milestone-70-tech-debt-gate-hardening/task-221.md
    finding: "task-221 scope duplicates shipped memory schemas — 4 schemas + runSchemaEnforcement() already exist"
    fix_target: "Rescope task-221 to patterns.schema.yaml, vitest fixtures, CI fail-on-error enforcement"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: null

  - audit_id: audit-087
    finding_id: F-087-05
    severity: medium
    file: agent/routing/tasks/route-208.md
    finding: "All 11 M70 routes have empty files_affected[] — operational incompleteness before implementation"
    fix_target: "Populate files_affected on route-208..219 before /acp-proceed"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  - audit_id: audit-087
    finding_id: F-087-06
    severity: medium
    file: agent/routing/tasks/route-162.md
    finding: "route-162 (M59 branch protection) overlaps task-219; completed field never stamped"
    fix_target: "Reconcile: stamp route-162 when task-219 completes; reference in task-219 acceptance"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-088
    escalated_to: null

  # ── AUDIT-089 FINDINGS — M70 IMPLEMENTATION GAPS (2026-07-15) ───────────────

  - audit_id: audit-089
    finding_id: F-089-01
    severity: high
    file: agent/tasks/milestone-70-tech-debt-gate-hardening/
    finding: "All 12 M70 task files still status: planned while progress.yaml marks completed — tracking drift"
    fix_target: "Stamp status: completed and completed: 2026-07-15 on task-219..230 frontmatter"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  - audit_id: audit-089
    finding_id: F-089-04
    severity: high
    file: agent/core/identity.yml
    finding: "M70 implementation uncommitted; v6.26.0 bumped in files but no git commit or tag"
    fix_target: "/git-commit M70 + git tag -a v6.26.0"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  - audit_id: audit-089
    finding_id: F-089-06
    severity: medium
    file: agent/wiki/domain.yml
    finding: "domain.yml documents 4 review-scan rules — M70 shipped 8"
    fix_target: "Update domain.yml acp.review-scan.sh entry to 8-rule list"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  - audit_id: audit-089
    finding_id: F-089-07
    severity: medium
    file: agent/routing/tasks/route-208.md
    finding: "M70 routes 208–219 still have empty files_affected[] after implementation"
    fix_target: "Populate files_affected on all M70 route files"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  - audit_id: audit-089
    finding_id: F-089-10
    severity: medium
    file: package.yaml
    finding: "acp.atomic-write.sh and acp.branch-protection-setup.sh not in package.yaml"
    fix_target: "Add new M70 scripts to package.yaml for install parity"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-090
    escalated_to: null

  # ── AUDIT-091 FINDINGS — WHOLE-SYSTEM GAPS & STANDARDS (2026-07-15) ────────

  - audit_id: audit-091
    finding_id: F-091-01
    severity: high
    file: .github/copilot-instructions.md
    finding: "copilot-instructions.md stale at v6.24.0 (two releases behind); pre-commit AGENTS.md sync hook not installed in this repo; validator size-only guard masked the drift"
    fix_target: "Re-copy AGENTS.md to copilot-instructions.md; install pre-commit sync hook in framework repo; change validator instruction-file check from byte-size to content hash"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-02
    severity: high
    file: package.yaml
    finding: "package.yaml version 6.21.1 vs canonical 6.26.0; acp.validate.md Step 2c documents package.yaml as hard requirement but acp-validate.ts never checks it; acp.cursor-commands-sync.sh, acp.claude-commands-sync.sh, acp.post-milestone-sweep.sh unregistered in package.yaml and integrity-manifest.yaml"
    fix_target: "Bump package.yaml to 6.26.0; implement package.yaml version check in acp-validate.ts; register the 3 missing scripts in package.yaml and integrity-manifest.yaml"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-03
    severity: medium
    file: scripts/acp-validate.ts
    finding: "Validator is cwd-sensitive with no repo-root detection; documented invocation in acp.validate.md Step 11.6 '(cd scripts && npx ts-node acp-validate.ts)' yields vacuous all-green run including 'Parity: 0 commands x 3 surfaces — all matched'"
    fix_target: "Add repo-root detection (walk up to agent/ or fail loudly); make parity check hard-fail on 0 commands found; fix Step 11.6 invocation text to 'npx tsx scripts/acp-validate.ts' from root"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-04
    severity: medium
    file: .github/prompts/
    finding: "6 stale dot-named duplicate wrappers (acp.carryover-query, acp.pattern-sync, acp.session-sync in both .github/prompts/ and .opencode/commands/) coexist with hyphen-named twins; invisible to parity check due to startsWith('acp-') filter; show as duplicates in slash pickers"
    fix_target: "Delete the 6 dot-named files; extend parity check to detect dot-named strays"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-05
    severity: medium
    file: scripts/acp-validate.ts
    finding: "Wrapper parity check covers 3 of 5 surfaces — .cursor/commands/ and .claude/commands/ unchecked (pre-noted in ADR-18); progress.yaml summary line and lessons.md companion-file lesson still name only prompts+opencode(+cursor)"
    fix_target: "Extend runParityCheck() to 5 surfaces; update progress.yaml summary line and the high-priority lessons.md entry to name all 4 wrapper directories"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-06
    severity: medium
    file: scripts/acp-bootstrap.sh
    finding: "Cursor/Claude wrapper copy loops (lines ~1330, ~1342) glob '.opencode/commands/acp.*.md' but opencode files are hyphen-named — dead code printing misleading '0 generated' success; on fresh bootstrap sync scripts do not exist yet at that step"
    fix_target: "Fix glob to acp-*.md or remove copy loops in favor of invoking sync scripts after agent/ install step 7"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-10
    severity: low
    file: .github/workflows/ci.yaml
    finding: "No ShellCheck lint gate in CI for a bash-first project (47 scripts in agent/scripts/)"
    fix_target: "Add shellcheck job to ci.yaml (SHA-pinned action), triage initial findings"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-07
    severity: low
    file: agent/commands/acp.validate.md
    finding: "Step 11.6 doc claims sessions entries require tasks_completed; enforced session.schema.yaml requires only date/executor/done and real entries use tasks:"
    fix_target: "Align Step 11.6 text with session.schema.yaml required_fields"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-14
    severity: high
    file: agent/.gitignore
    finding: "agent/.gitignore reports/ rule overrides root !agent/reports/ whitelist — new reports silently excluded from version control; audit-078..090 (incl. M71 closure evidence) untracked; validator gitignore check inspects tracked paths only so it passes"
    fix_target: "Remove/whitelist reports/ in agent/.gitignore; git add untracked reports; extend validator gitignore check to probe new-file addability in protocol dirs (task-240 fix + task-241 enforcement)"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  # ── AUDIT-092 FINDINGS — M72 PRE-IMPL READINESS (2026-07-15) ────────────────

  - audit_id: audit-092
    finding_id: F-092-01
    severity: medium
    file: agent/integrity-manifest.yaml
    finding: "No M72 task regenerates the SHA-256 integrity manifest despite M72 rewriting manifest-covered files (.cursor/commands wrappers etc.) — /acp-integrity --diff and weekly-integrity-scan will raise tamper false-alarms post-M72"
    fix_target: "PLAN FIXED (amendment 2026-07-15, design D10 + guardrail 10): manifest regen added to task-242 step 5, task-243 step 7, task-247 gate 2b (closure refused while /acp-integrity --diff dirty). Runtime effect verified at audit-093"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-092
    finding_id: F-092-02
    severity: medium
    file: agent/tasks/milestone-72-validation-truth-drift-hardening/task-247-m72-closure-ship.md
    finding: "M72 plan reserves 'audit-092' for closure audit but pre-impl audit took #092 per numbering protocol (M70 precedent) — 15 stale references across task-247, route-236, milestone doc, progress.yaml, carryover fix_targets"
    fix_target: "FIXED by plan amendment 2026-07-15 (not deferred to task-245): all 16 closure references renumbered audit-092 → audit-093 across task-246/247, route-236, milestone doc, design doc, progress.yaml; grep confirms 0 stale. Verified at audit-093"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-092
    finding_id: F-092-03
    severity: medium
    file: agent/.gitignore
    finding: "F-091-14 scope extension: 61 untracked reports (88 on disk / 27 tracked) and feedback/ 25 untracked (28/3) incl. feedback-007 cited by carryover F-086-02; clarifications/ ignore is INTENTIONAL (acp.plan.md Step 10) and must survive the fix"
    fix_target: "PLAN FIXED (amendment 2026-07-15, design D9): policy decided — track reports/ + feedback/, keep clarifications/drafts/preferences local-only; task-240 steps/verification updated (surgical whitelist, check-ignore probes both ways), task-241 addability probe covers feedback/. Runtime gitignore fix lands in task-240; verified at audit-093"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-092
    finding_id: F-092-04
    severity: low
    file: agent/tasks/milestone-72-validation-truth-drift-hardening/task-244-shellcheck-ci.md
    finding: "task-244 missing shellcheck install prerequisite (not installed locally); task-240 text misnames package.yaml script entry fields (says name+version+description; actual shape is name+description+type)"
    fix_target: "FIXED by plan amendment 2026-07-15: task-244 Prerequisites section added (brew install shellcheck); task-240 step 4 corrected to name+description+type. Verified at audit-093"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  # ── AUDIT-091 HYGIENE — task-245 (2026-07-15) ─────────────────────────────

  - audit_id: audit-091
    finding_id: F-091-08
    severity: low
    file: agent/memory/sessions.md
    finding: "sessions.md had 17 entries; protocol threshold >15 requires compaction"
    fix_target: "Compact oldest 10 into weekly-summary block"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-09
    severity: low
    file: agent/progress.yaml
    finding: "monthly-dependency-audit overdue since 2026-07-08"
    fix_target: "Run acp.dependency-diff.sh; refresh recurring_tasks dates"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  - audit_id: audit-091
    finding_id: F-091-13
    severity: info
    file: git
    finding: "Uncommitted Claude-integration work post v6.26.0"
    fix_target: "feat(claude) commit 2b92528"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-095
    escalated_to: null

  # ── AUDIT-094 FINDINGS — M72 IMPLEMENTATION GAPS (2026-07-15) ───────────────

  - audit_id: audit-094
    finding_id: F-094-01
    severity: critical
    file: agent/memory/audit-carryovers.md
    finding: "replace_all on verified_in_audit:null→audit-093 corrupted 19 historical carryover entries (audit-015/016/041) with false audit-093 verification pointers"
    fix_target: "Restore verified_in_audit from pre-07ab4d5 git history for non-M72 entries; add acp-validate guard against bulk verified_in_audit overwrite"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-02
    severity: critical
    file: agent/reports/audit-093-m72-closure.md
    finding: "audit-093 was self-certification by implementing agent — no independent re-verify with seeded negative probes (audit-088 precedent)"
    fix_target: "Run audit-095 independent closure with documented negative probes; do not treat audit-093 as authoritative"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-03
    severity: high
    file: agent/progress.yaml
    finding: "task-246 marked completed while CRIT-065-002 pending, no PR, task file status:planned"
    fix_target: "Set task-246 status deferred/blocked in progress.yaml; document admin blocker; do not stamp CRIT-065-002 fixed"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-04
    severity: high
    file: agent/scripts/acp.post-milestone-sweep.sh
    finding: "task-247 required post-milestone-sweep at closure; live run 2/6 pass (tsc import.meta CJS, token budget, gitattributes parse)"
    fix_target: "Fix tsc/sweep gates or document exclusions; re-run sweep to 6/6 before next release"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-05
    severity: medium
    file: agent/tasks/milestone-72-validation-truth-drift-hardening/
    finding: "task-243/244/246/247 frontmatter status:planned drifts from progress.yaml completed"
    fix_target: "Sync task YAML frontmatter completed: dates with progress.yaml or revert progress status"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-06
    severity: medium
    file: package.yaml
    finding: "14 agent/scripts/*.sh on disk not registered in package.yaml contents.scripts (D4 WARN-only)"
    fix_target: "Register all on-disk scripts; ratchet validateScriptRegistration to ERROR"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null

  - audit_id: audit-094
    finding_id: F-094-07
    severity: medium
    file: agent/milestones/milestone-72-validation-truth-drift-hardening.md
    finding: "All 11 milestone verification gate checkboxes remain unchecked despite milestone completed"
    fix_target: "Check gates with evidence or amend milestone status to reflect honest deferrals"
    status: fixed
    fix_applied_date: 2026-07-15
    verified_in_audit: audit-096
    escalated_to: null
