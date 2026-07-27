# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-07-27
  executor: claude
  branch: develop
  tasks: []
  done:
    - audit-102-deterministic-review-gap-analysis
    - audit-103-measured-precision-recall-and-standards
    - m83-planned-17-tasks-6-phases
    - audit-104-pre-impl-readiness-with-amendments
    - f-104-01-through-07-amendments-applied
  deferred:
    - m83-implementation → handoff-cursor
    - m81-270-274 → coderabbit-fixture-gate
  key_fact: "/acp-review Phase 1 measured at ~8% recall / 0% precision on seeded fixtures; multi-path arg bug silently scanned only the last path, masking 2 HIGH findings in scripts/. EH-01 substring test 'try' not in body is disabled by retry/telemetry/entry. M83 (17 tasks) fixes correctness then precision then measures BEFORE expanding — phase 3 gated on 1b+1c. audit-104 found _index: array omission would silently drop new preference keys (no validator covers it)."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - f-m82-01-through-07-remediated
    - e2e-cross-layer-and-optionality-hardening
    - js-yaml-4-3-0-audit-clean
  deferred:
    - m81-270-274 → fixture-gate
    - coderabbit-workflows-cli-chunk → optional-rate-limit
  key_fact: "M82 findings F-M82-01..07 fixed: SCHEMAS_DIR+gh execFileSync, project-update tags loop, sweep token message, SH-01 allowlist, js-yaml 4.3.0; e2e CLI chunk done; workflows still rate-limited."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-275, task-276, task-277, task-278, task-279]
  done:
    - m82-local-thorough-review-campaign
    - review-002-coderabbit-cli-chunks
    - f-m82-01-through-07-carryovers
  deferred:
    - m82-e2e-workflows-cli-chunks → F-M82-06
    - m81-270-274 → fixture-gate
  key_fact: "M82 closed: Phase1+CodeRabbit CLI (2/4 chunks; rate-limited remainder). 7 carryovers F-M82-01..07. CLI does not satisfy ADR-22 M81 fixture. current_milestone remains M81."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-269]
  done:
    - task-269-adr22-policy-map-lite
    - acp-validate-clean
    - m81-status-synced-in-progress-1-of-6
    - changelog-unreleased-m81-wip
  deferred:
    - m81-270-274 → fixture-gate
    - aikido-m76-m77 → adr-19
  key_fact: "M81 halted after task-269: need tests/fixtures/coderabbit-findings-sample.json before 270+; ADR-22 carve-out live; F-101-01/04/07/08 fixed; pending F-101-02/03/05/06 for import/wiring tasks."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-269, task-270, task-271, task-272, task-273, task-274]
  done:
    - audit-101-f101-findings-folded-into-m81-plan
    - task-269-ungated-for-adr22
    - m81-ready-for-implementation-after-fixture
  deferred:
    - m81-270-274 → fixture-gate
    - aikido-m76-m77 → adr-19
  key_fact: "M81 plan amended per audit-101: ADR-22 carve-out (not supersede); task-269 ungated; findings-import v1 is --input fixture only; weekly-code-review is single command:/optional wrapper; Phase 1 never deferred to CodeRabbit."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - audit-101-m81-pre-impl-readiness
    - f-101-01-through-08-carryovers-written
  deferred:
    - m81-plan-amend-f101 → before-acp-proceed
    - m81-gate-artifact-findings-fixture → consumer-export
    - aikido-m74-m77 → deferred-cost
  key_fact: "M81 READY WITH AMENDMENTS (audit-101): carve ADR-22 out of ADR-19 (never supersede); fixture-first --input import only; weekly-code-review is a single command string; Phase 1 rules never defer to CodeRabbit; ungate task-269 for ADR writing."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - acp-validate-clean-post-m80
    - acp-sync-handoff-completed-progress-notes-refreshed
  deferred:
    - m74-m77-coderabbit-pr-check → adr-19-gate
  key_fact: "ADR-19 gates M74–M77 integration milestones (not tool install) until CodeRabbit + Aikido run on a Rygan repo with 2+ weeks of real findings; M78 optionality foundation shipped separately per ADR-21."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-265, task-266, task-268]
  done:
    - m80-e2e-debt-remediation-shipped-v6-28-2
    - f-m78-01-closed-68-68-e2e-suite
    - audit-100-carryovers-f-100-01-through-05-settled
    - test-side-fixes-workflow-cross-layer-validate-ts
    - behavior-reconcile-version-package-info-project-update-sweep
  deferred:
    - m74-m77-coderabbit-pr-check → adr-19-gate
    - crit-065-002-merge-pr3 → mainline
  key_fact: "F-M78-01 closed with honest code-vs-test triage (no blind greening): validate-cross-layer needed conditional package.yaml copy + milestone awk; validate-ts needed isolated 5-surface parity dirs; version-check-for-updates needed ${1:-} under set -u; project-update needed current_tags init before ADD_TAGS block."

- date: 2026-07-24
  executor: claude-opus-4-8
  branch: develop
  tasks: [task-255, task-256, task-257, task-258, task-259, task-260, task-261, task-262, task-263, task-264]
  done:
    - m78-coderabbit-optionality-foundation-shipped-v6-28-0
    - m79-closure-integrity-remediation-shipped-v6-28-1
    - audit-099-caught-own-version-regression-honest-correction
    - audit-100-m80-preimpl-5-findings-folded
    - m80-planned-3-tasks-after-task-267-removed
  deferred:
    - m80-implementation → cursor-executor-handoff (tasks 265,266,268)
    - m74-m77-coderabbit-pr-check → adr-19-gate
    - crit-065-002-merge-pr3 → mainline
  key_fact: "Regression comparison MUST be assertion-level, not file-level — audit-098 declared M78 'zero regression' by file-count but audit-099 found the v6.28.0 bump missed agent/progress.yaml's version: field, adding 2 assertion failures inside already-failing test files. Fix incl. a validator gap: acp-validate.ts now checks progress.yaml version (it caught a YAML corruption I introduced mid-fix). M80 = 7 pre-existing E2E failures (root-caused audit-099) + F-100-03 auto-sync trap (copilot-instructions.md regenerated from AGENTS.md)."

- date: 2026-07-23
  executor: claude-opus-4-8
  branch: develop
  tasks: []
  done:
    - audit-097-optional-coderabbit-distributed-framework-lens
    - plan-m78-optionality-foundation-6-tasks-255-260
    - adr-21-coderabbit-optionality-carved-out-of-adr-19-gate
    - adr-20-backfill-hooks-task_id-array-format
    - audit-098-preimpl-7-findings-folded-into-m78
  deferred:
    - m78-implementation → acp-proceed-complete (this session, next)
    - m74-m77-pr-check-findings-import → adr-19-adoption-gate
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "acp.preferences.sh sources acp.common.sh, so optional-tool detection helpers that call get_preference must live in a dedicated script (acp.coderabbit.sh) sourcing preferences.sh — never in common.sh (circular source). Caught in pre-impl audit-098 before any code was written. Also: ADR-19 gates CodeRabbit *integration* (PR-check/findings-import); the *optionality foundation* (toggle+detection+docs) is a separate non-gated concern (ADR-21)."

- date: 2026-07-17
  executor: copilot
  branch: develop
  tasks: []
  done:
    - validate-all-clean-v6-27-2
    - agent-md-legacy-version-sync
    - adr-19-m74-gate-documented
  deferred:
    - m74-plan → adr-19-adoption-gate
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "AGENT.md legacy header was 15 minors stale (6.12.1) while AGENTS.md/identity were 6.27.2 — hard validators only check AGENTS.md, not AGENT.md."

- date: 2026-07-17
  executor: copilot
  branch: develop
  tasks: []
  done:
    - validate-sync-update-chain-clean
    - readme-badge-drift-fixed-v6-27-2
    - research-direction-docs-on-develop
  deferred:
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "README version badge was soft drift (6.21.1) invisible to hard validators — acp-validate.ts only checks AGENTS/identity/package/CHANGELOG, not README shields.io URL."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-248, task-249, task-250, task-251, task-252, task-253, task-254]
  done:
    - m73-autonomous-complete-v6-27-1
    - carryover-integrity-restored-audit-095-closure
    - manifest-scripts-tracked-validate-clean
  deferred:
    - crit-065-002-branch-protection → github-admin
    - f-086-02-fifoz-consumer → task-239
  key_fact: M73 v6.27.1 closed audit-094 gaps; integrity-manifest now tracks agent/scripts; validate 0 errors (branch protection warn only).

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-240, task-241, task-242, task-243, task-244, task-246, task-247]
  done:
    - m72-autonomous-complete-audit-093
    - validator-hardening-5-surface-parity
    - v6-27-0-tagged
  deferred:
    - crit-065-002-branch-protection → admin-ops
  key_fact: M72 shipped v6.27.0 with ROOT-anchored validator; CRIT-065-002 remains pending (gh api 404).

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-245]
  done:
    - claude-integration-committed-adr-18-2b92528
    - sessions-compaction-f-091-08
    - monthly-dependency-audit-refreshed-f-091-09
    - task-245-hygiene-phase-complete
  deferred:
    - m72-validator-tasks → task-240-241
    - crit-065-002-branch-protection → task-246
  key_fact: "task-245 guardrail #9 satisfied — Claude tree committed (2b92528) before validator edits; acp.dependency-diff.sh 0 findings; sessions compacted to ≤8 entries."

- date: 2026-07-15
  executor: claude-code
  branch: develop
  tasks: [audit-091, plan-m72, audit-092, plan-m72-amendment]
  done:
    - audit-091-whole-system-gaps-standards-14-findings
    - m72-milestone-planned-design-8-tasks-8-routes-committed
    - audit-092-pre-impl-m72-readiness-ready-with-4-amendments
    - discovered-f-091-14-agent-reports-gitignore-blackhole-mid-report-commit
    - m72-amended-per-audit-092-d9-d10-guardrails-10-11-closure-renumbered-093
    - f-092-01-02-03-04-carryovers-stamped-fixed-plan-level-audit-093-verifies
  deferred:
    - m72-validator-implementation → task-240-247
    - crit-065-002-branch-protection → task-246
    - f-086-02-fifoz-consumer → task-239
  key_fact: "F-091-14: agent/.gitignore bare reports/ blocked 61 audit reports from git; sessions prepend protocol violation fixed; task-245 hygiene unblocks M72 validator work."
  commits: [1a1dc70 "plan(M72)", 57c0464 "audit(092)", ad29c3c "plan(M72) amend", 2b92528 "feat(claude)"]

# === Compacted Block: 2026-07-15 (10 sessions) ===
- type: weekly-summary
  week: 2026-07-15
  key_facts:
    - "M71 remediation shipped v6.26.0 — memory schema enforcement, 8-rule review scanner, atomic-write (audit-090)."
    - "audit-086 stamped 21 stale carryovers; acp.recurring-complete.sh added."
    - "v6.25.2 review/integrity remediation — acp.review-scan.sh Phase 1, integrity-manifest split."
    - "M63 amendment v6.25.1 — tier3 E2E dynamic loop; audit-083/084 closed."
    - "M68 safe install/update v6.24.1; M67 handoff v6.23.0."
    - "progress.yaml 191 duplicate YAML keys fixed — js-yaml parse restored."
  tasks_completed: [task-231..238, audit-086, review-001, route-207, route-206, route-198..205, route-190..197, validate-sync-update]

# === Compacted Block: 2026-06-08 – 2026-06-15 (6 sessions) ===
- type: weekly-summary
  week: 2026-06-15
  key_facts:
    - "M61 autonomous completion shipped as v6.20.7. Audit-075 found 6 issues including YOUR_ORG placeholder (HIGH), stale version footer (MEDIUM), unpinned trufflehog violating IG-67 (HIGH). Post-audit: 15 shortcuts caught across 3 rounds (E2E smoke-only tests, tsc never ran, no recent_work entries, stale versions). All fixed."
    - "Four maintenance commands (audit-074, validate, sync, update) found 7 items: missing CHANGELOG, stale milestone statuses, 3 carryovers not fixed. All resolved."
    - "M65 completed: progress.yaml had systemic duplicate YAML keys causing js-yaml parse failures; validate.ts now uses line-based fallback. Cross-layer validator caught 12 stale milestone docs."
    - "Glossary was missing 6 M58 Phase 2 terms. Validated: 48/48 terms."
    - "Taint heuristics must use file-level flow analysis for indirect source-to-sink — line-level patterns miss 50% of calibration fixtures."
    - "grep treats leading -- as flags — E2E assert_contains with needle '--phase2' silently fails. Use descriptive substring without leading dashes."
    - "M64 (integrity gateway v1.1): E2E EXIT trap variable collision (FIXTURE_DIR reused) destroyed committed fixtures. Fix: separate TEMP_FIXTURE_DIR + INTEGRITY_FIXTURE_DIR with trap cleared after B3."
    - "M59 closed silent correctness bugs: routing.yml overwrite, package.yaml gaps, CI no-op. 6 routes shipped as v6.14.0."
    - "Audit-070 proved /acp-integrity v1.0 gives false assurance (~18/55 rules implemented, entropy scanner crashes). M64 (gateway truth/test) must ship before M58 v2.0."
    - "M57: v1-to-v2 audit cycle pattern caught 26 errors across two specs. Discipline: audit AGAINST live codebase, not the spec itself."
    - "M57 autonomous implementation (5 routes, route-150..154): recurring_tasks block shipped in progress.yaml + schema; 91/91 E2E assertions. Even a small milestone benefits from the same 3-round audit discipline (059 cross-milestone, 060 pre-impl, 061 post-impl) as larger ones — 0 new bugs found because implementation followed pre-established M55/M56 patterns. Discipline prevents bugs, not just catches them."
    - "M60 (route-165/166): 8 E2E test suites created in one milestone (init/proceed/plan/dispatch/commit/validate/audit/route); integrity rule count fixed to exact 70; CONTRIBUTING.md created. CRLF line endings on Windows require tr -d '\\r' before bash execution."
    - "M62 (7 routes): 17 scripts upgraded to set -euo pipefail (0 bare remaining); 7 memory-layer schemas enforced; 5 audit-062 carryovers resolved; 7 cross-file consistency validators + post-milestone-sweep script deployed as post-M61 shortcut prevention. Pre-commit hook caught ACP rule changes on commit."
    - "M66 marker backfill: 100% @acp.meta.* coverage across 232 files (from 3.9%) via scripts/acp-backfill-markers.py — unlocked meta-scan inventory, validate probes, and acp-sync traceability maps repo-wide."
    - "audit-073 (M65 followup): cross-subagent audit catches what solo audit misses — a subagent found 19 findings vs my own 8, including E2E gaps and carryover status drift."
  tasks_completed: 34


# === Compacted Block: 2026-02-16 – 2026-06-08 (20 sessions) ===
- date: 2026-06-08
  executor: copilot
  compacted: true
  tasks: [route-131..158, audit-018..061, M39..M57, design-specs, stakeholder-reports]
  done:
    - compacted-block-see-summary
  summary: |
    Feb 16 – Jun 8, 2026 (20 sessions compacted 2026-06-15):

    Feb–Mar: M1–M18 — ACP foundation. Commands infrastructure, package management system
    (install, list, info, search, update, remove, validate, publish), package development
    system (YAML schema, namespace utilities, entity creation), global package installation,
    project registry (7 management commands), preferences system (8 tasks, 13 bugs fixed),
    template source files, benchmark suite (8 tasks + LLM evaluator), sessions system,
    cross-platform CI (macOS + Linux), key file index, clarification capture, design
    reference, artifact commands, index semantic entry types.

    Mar–Apr: M24–M38 — Protocol hardening. AGENTS.md completeness, preferences bug fix
    sprint (CRITICAL yaml_query misuse), three-persona deployment model, distribution
    readiness fixes, opencode command parity, upstream integration audit, drafts convention
    fix, E2E test coverage, AGENT.md protocol docs, pluggable driver system, command naming
    convention, acp-validate.ts enhancement, gitignore completeness, protocol knowledge
    preservation (WAL pattern), git branch awareness (Step 1b safety check).

    May: M39–M48 — Audit-driven improvements. Pre-implementation audit protocol (--pre-impl
    4-phase mode), taxonomy gap fixes, dispatch integrity + validation hardening, feedback
    integration rounds (001–005). Memory integrity release: commit auto-sync, repair tools,
    memory YAML validation. Carryover resolution + workflow hardening.

    Jun 1–8: M49–M57 — Command ecosystem spine. Dogfooding resolution (Windows + Cursor),
    install fixes, design-spec command (arc42/C4/IEEE/ISO), stakeholder report command,
    bootstrap install fix. M55: /acp-review shipped (64 rules). M56: /acp-integrity v1.0
    shipped (55 rules, 6 bash scripts, LLM/Script Boundary Rule). M57: Recurring tasks
    scheduler shipped (5 tasks, Step 4.5 protocol, pre-commit hooks).

    Audits conducted: 018–061 (44 audits across all milestones). Key architectural decisions:
    command-doc-as-spec (M55), LLM/Script Boundary Rule (M56), WAL proactive memory writes
    (M38), confidence ceiling model (M58 planned), cadence-only scheduler (M57).
  key_facts_preserved:
    - "Run /acp-sync after every milestone — 3 core E2E suites were missing from domain.yml"
    - "Three rounds of pre-impl audit catch gaps invisible in planning — never skip"
    - "Post-impl audit catches bugs pre-impl audit can't — shell injection, trap ERR, counters"
    - "v1→v2 spec audit cycle: write spec → audit → fix ALL → publish v2 — caught 26 errors"
    - "Command doc IS the spec — separate spec files create version drift (audit-052)"
    - "Deterministic tasks use bash scripts, not LLM reasoning — 100% accuracy at $0 cost"
    - "Context overflow is silent — write sessions.md at moment of discovery (WAL pattern)"
    - "Never use set -e without trap ERR in bash scripts"
    - "Never write bash that breaks on macOS (BSD sed, date differences)"
    - "Python subprocess calls must use os.environ — never string-interpolate variables"
