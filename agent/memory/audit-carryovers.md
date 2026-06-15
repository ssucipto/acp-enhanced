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
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 62
    finding_id: F-062-02
    severity: medium
    file: agent/commands/acp.validate.md
    finding: "3 milestone verification checklist items unverified — disabled exclusion, frequency/trigger XOR, executor cross-validation"
    description: "Step 4.5 doesn't exclude disabled tasks. Schema doesn't enforce frequency/trigger mutual exclusivity. No executor validation against taxonomy.yml."
    fix_target: "Add disabled exclusion to Step 4.5. Add XOR constraint to progress.schema.yaml. Add executor cross-check to validate Step 2d."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 62
    finding_id: F-062-03
    severity: high
    file: agent/progress.yaml
    finding: "No automated next_due calculation — manual date updates prone to drift and human error"
    description: "After running a recurring task, the developer must manually update last_run and next_due. No auto-increment based on frequency."
    fix_target: "Implement acp.task-complete.sh helper or --complete flag that auto-sets last_run=today and next_due=today+frequency."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 62
    finding_id: F-062-04
    severity: medium
    file: agent/examples/pre-commit-hook.sh
    finding: "No reference git hook implementation for pre-commit-rule-audit trigger"
    description: "The on-commit trigger has no example .git/hooks/pre-commit script showing how to wire /acp-integrity --fast --ci."
    fix_target: "Create agent/examples/pre-commit-hook.sh with 5-line reference implementation."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 62
    finding_id: F-062-05
    severity: medium
    file: agent/progress.yaml
    finding: "No findings-to-task feedback loop — scan results not connected to recurring task status"
    description: "Weekly integrity scan could find same issue for months without automated tracking. No last_findings_count or deferred_findings field."
    fix_target: "Add last_findings_count field to recurring_tasks entries. Defer full findings DB integration to M58."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
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
    fix_target: "Create route in future milestone to add schema linting for memory registry entries"
    status: in-progress
    fix_applied_date: null
    verified_in_audit: null
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
    fix_target: "Create route for E2E tests covering commit auto-sync, repair tools, --memory validation"
    status: in-progress
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: "M48 routes 085-086"

  - audit_id: 41
    finding_id: GAP-041-08
    severity: medium
    file: agent/commands/acp.commit.md
    finding: "Atomicity not addressed in commit auto-sync design — multi-file sync lacks transaction boundaries"
    description: "If sync fails mid-operation, partial state possible. Idempotent design mitigates but doesn't prevent."
    fix_target: "Consider temp-file+atomic-rename or all-or-nothing approach during route-074/075 implementation"
    status: in-progress
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: "M48 route-087"

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
    status: pending
    fix_applied_date: null
    verified_in_audit: "066 (reclassified)"
    escalated_to: null

  - audit_id: 65
    finding_id: CRIT-065-002
    severity: critical
    file: GitHub repository settings
    finding: "No branch protection rules on mainline or develop — force-push and direct commits unblocked"
    fix_target: "Enable required status checks + PR review requirement on mainline; disable force-push"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 65
    finding_id: CRIT-065-003
    severity: critical
    file: e2e/
    finding: "46 of 71 commands (65%) have no E2E test — core commands /acp-init, /acp-proceed, /acp-plan, /acp-dispatch, /acp-commit, /acp-validate, /acp-audit, /acp-route all untested"
    fix_target: "Add E2E tests in three tiers: Tier 1 (8 core commands), Tier 2 (12 package/project), Tier 3 (16 memory/knowledge)"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 65
    finding_id: HIGH-065-004
    severity: high
    file: agent/scripts/ (17 files)
    finding: "17 scripts use bare 'set -e' not 'set -euo pipefail' — unbound variable bugs silently succeed; pipeline failures masked"
    fix_target: "Batch-upgrade acp.install.sh, acp.package-*.sh, acp.project-info.sh, acp.project-update.sh, acp.sessions.sh, acp.uninstall.sh, acp.version-*.sh"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 65
    finding_id: HIGH-065-005
    severity: high
    file: .github/workflows/
    finding: "No Windows CI runner — Windows is documented target platform but has no automated test coverage"
    fix_target: "Add windows-latest to e2e-tests.yaml matrix (ubuntu + macOS + Windows)"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 65
    finding_id: HIGH-065-006
    severity: high
    file: SECURITY.md
    finding: "No SECURITY.md / vulnerability disclosure process for open-source production tooling"
    fix_target: "Create SECURITY.md with private advisory process + scope definition"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  # ── AUDIT-066 FINDINGS — SECOND-ROUND DEEP GAPS 2026-06-15 ──────────────────

  - audit_id: 66
    finding_id: HIGH-066-001
    severity: high
    file: scripts/acp-dispatch.ts
    finding: "updateRoutingYml() overwrites entire core/routing.yml with a 4-line session stub — destroys context_modes + command_suggestions on every Persona B/C dispatch (tracked file = committed data loss)"
    fix_target: "Replace full-file writeFileSync with surgical session-block update (use yaml_set or targeted regex). Add regression test asserting context_modes survives dispatch."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 66
    finding_id: HIGH-066-005
    severity: high
    file: .github/workflows/ci.yaml
    finding: "acp-validate.ts never runs in CI — placeholder + frontmatter-field checks never execute; CI only runs ci-validate.sh"
    fix_target: "Add 'npx ts-node scripts/acp-validate.ts' as a CI step in ci.yaml validate job"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 66
    finding_id: HIGH-066-006
    severity: high
    file: scripts/ci-validate.sh
    finding: "ci-validate.sh frontmatter check is a no-op for command files — gates on head -1 grep '^---$' but command docs start with '# Command:' (inline bold markers, not --- YAML). No automated structural conformance check exists for command docs."
    fix_target: "Add command-doc structure validation (## Steps, ## Verification, **Namespace**: etc.) instead of gating on a --- line command files never have"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 66
    finding_id: MED-066-002
    severity: medium
    file: scripts/acp-dispatch.ts
    finding: "OPENROUTER_API_KEY non-null assertion (process.env.X!) — missing env var yields cryptic SDK error not a clear preflight message"
    fix_target: "Add preflight check: fail fast with clear message if OPENROUTER_API_KEY unset before client init"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 66
    finding_id: MED-066-003
    severity: medium
    file: scripts/
    finding: "No unit tests for TS tooling — scripts/*.test.ts = 0 files; acp-dispatch.ts and acp-validate.ts entirely untested (only Turing-complete code in repo)"
    fix_target: "Add vitest/jest + scripts/*.test.ts covering buildContext budget, getFilteredLessons, updateRoutingYml non-destructiveness"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 66
    finding_id: MED-066-007
    severity: medium
    file: agent/schemas/
    finding: "Only 5 schemas exist; no schema for milestone/session/lessons/decisions/clarification/feedback/audit-carryovers — memory layer is unvalidated. Also acp-validate.ts does not enforce the 5 schemas that do exist."
    fix_target: "Add memory-layer entity schemas + wire acp-validate.ts to enforce all schemas"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
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
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 67
    finding_id: MED-067-002
    severity: medium
    file: AGENTS.md
    finding: "AGENTS.md version header reads v6.10.0 while project is 6.12.1 — auto-loaded context file is 2 minors stale; three sync files not byte-identical (AGENTS.md has extra version header line)"
    fix_target: "Update AGENTS.md header to current version; add version-header check to /acp-validate Step 2c consistency check"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 67
    finding_id: MED-067-003
    severity: medium
    file: e2e/acp.integrity.test.sh
    finding: "Rule-count assertion uses grep -cE '^| IG-\\d+' but \\d is not a digit class in POSIX ERE (GNU grep -E) — matches literal 'd'; rule count miscomputed and non-portable"
    fix_target: "Replace \\d with [0-9] or use grep -P; verify >= 55 assertion actually computes correctly"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 67
    finding_id: MED-067-005
    severity: medium
    file: CONTRIBUTING.md
    finding: "No CONTRIBUTING.md despite being a public fork inviting contributions"
    fix_target: "Create CONTRIBUTING.md with branch model, test requirements, command-doc conventions"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 67
    finding_id: LOW-067-004
    severity: low
    file: agent/scripts/acp.git-provenance.sh
    finding: "Parses team_members with grep/while-read instead of YAML parser — violates scripts.md 'never parse YAML with grep' rule"
    fix_target: "Use yaml_get_array from acp.yaml-parser.sh to read team_members"
    status: pending
    fix_applied_date: null
    verified_in_audit: null
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
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 68
    finding_id: F-068-04
    severity: medium
    file: agent/benchmarks/fixtures/taint-flow/manifest.yaml
    finding: "Fixture manifest encodes severity but not the research-mandated max_confidence/CI policy; route-158 E2E built on severity alone could assert CRITICAL output, contradicting v2.0 'never CRITICAL in --ci' self-protection"
    description: "research-m58 mandates MEDIUM confidence ceiling and advisory-only taint findings. Severity (impact) != confidence (certainty)."
    fix_target: "Add max_confidence + ci_blocking per fixture aligned to the calibration matrix; update route-157/158 acceptance to assert no CRITICAL auto-fail on taint fixtures."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 68
    finding_id: F-068-07
    severity: medium
    file: agent/wiki/integrity-rules.md
    finding: "Neither integrity-rules.md nor acp.integrity.md reflect any v2.0 surface (still v1.0 / 'DEFERRED to v2.0'); wiki '55 v1.0 + 15 deferred' header going stale as M58 progresses"
    description: "Consistent with route-156 not_started, but doc surface unchanged despite M58 in_progress + fixtures shipped."
    fix_target: "Covered by route-156 (M58 doc/wiki/skill update); ensure header counts updated when v2.0 rules land."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 68
    finding_id: F-068-10
    severity: low
    file: agent/progress.yaml
    finding: "quarterly-deep-scan recurring task invokes unbuilt M58 capability (--rules taint-flow,memory); scheduled (next_due 2026-09-08) for a feature not yet implemented"
    fix_target: "Align quarterly-deep-scan activation with M58 delivery; gate or annotate until v2.0 ships."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 68
    finding_id: F-068-12
    severity: low
    file: agent/scripts/acp.meta-scan.sh
    finding: "Uses set -eu + ERR trap but not -o pipefail (partial case of audit-065 H4); not in route-173's 17-file list"
    fix_target: "Add acp.meta-scan.sh to route-173 pipefail scope, or upgrade its header to set -euo pipefail."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
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
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-02
    severity: high
    file: agent/routing/tasks/route-155.md
    finding: "route-155 completion desync — deliverables exist (research + 12 fixtures + manifest) and progress.yaml counts M58 1/4 done, but synced route-155.md completed: is empty"
    description: "Four tracking layers disagree on whether route-155 is done. Auto-stamp (/acp-commit protocol) never ran on the synced route file."
    fix_target: "Fill completed: on route-150..155; reconcile progress.yaml tasks_completed with route stamps."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-03
    severity: high
    file: agent/artifacts/research-m58-taint-flow-calibration.md
    finding: "route-155 scope under-delivery vs milestone-58 §7 — no 10 taint-flow CVEs, no TypeScript sample, no ESLint-security comparison, no empirical TPR (self-deferred to route-158), no memory-poisoning UX document — yet counted complete"
    description: "Research is solid literature calibration with JS fixtures but does not meet the milestone's empirical acceptance criteria."
    fix_target: "Either finish missing scope (empirical TPR vs ESLint, memory-poisoning UX doc) OR descope milestone-58 §7/§10 via ADR to the literature-calibration approach actually taken."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-04
    severity: high
    file: agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md
    finding: "Go/No-Go gate unsatisfiable as sequenced — §10 gates routes 156-158 on empirical taint TPR, but research measures no TPR ('measured in route-158') and route-158 is gated by the gate"
    description: "Circular dependency: the gate needs route-158's measurement; route-158 is blocked by the gate. The 'proceed' decision rests on literature estimates, not the mandated benchmark."
    fix_target: "Restructure the gate: move empirical TPR measurement into route-155/156 (before the gate), or accept literature ceilings explicitly via ADR and remove the empirical precondition."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-05
    severity: high
    file: agent/memory/audit-carryovers.md
    finding: "All 5 audit-062 (M57) carryovers still pending incl. F-062-03 (no automated next_due -> date drift) in a shipped feature; queued late in route-176/M62"
    description: "Reconfirms audit-068 F-068-03. M57's own audit findings remain open."
    fix_target: "Promote F-062-03 (auto next_due helper / --complete flag) to M59; keep F-062-01/02/04/05 in route-176."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-07
    severity: medium
    file: agent/benchmarks/fixtures/taint-flow/manifest.yaml
    finding: "Manifest encodes only severity, not max_confidence/ci_blocking — but milestone-58 §8 E2E (assertions 4-6,9) requires asserting confidence ceilings (<=MEDIUM, no HIGH except IG-61)"
    description: "route-158 ground truth cannot support the mandated confidence assertions as-is. (= audit-068 F-068-04.)"
    fix_target: "Add max_confidence + ci_blocking per fixture aligned to milestone-58 §4 confidence table; update route-158 acceptance."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-09
    severity: medium
    file: agent/progress.yaml
    finding: "M54 dangling milestone pointer — progress.yaml M54 -> milestone-54-ci-cd-gitflow.md does not exist even after sync; M54 status active/30% with tasks_total: 0"
    description: "Residual of audit-068 F-068-01, now scoped to M54 only. tasks_total: 0 with active/30% is itself inconsistent."
    fix_target: "Create milestone-54-ci-cd-gitflow.md or remove the pointer; fix tasks_total vs progress."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null

  - audit_id: 69
    finding_id: F-069-10
    severity: low
    file: agent/routing/tasks/route-157.md
    finding: "Script naming mismatch — research recommends acp.taint-heuristic.sh; route-157/milestone-58 call them acp.taint-scan.sh + acp.memory-scan.sh (none exist yet)"
    fix_target: "Reconcile to one canonical script name before route-157 implementation."
    status: pending
    fix_applied_date: null
    verified_in_audit: null
    escalated_to: null
