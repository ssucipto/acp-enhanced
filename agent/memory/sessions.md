# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [route-207, task-217, audit-084]
  done:
    - m63-amendment-deployed-v6-25-1
    - git-tag-v6-25-1-pushed
    - audit-084-carryovers-closed
  deferred:
    - fifoz-feedback-007-consumer-path → acp-version-update
  key_fact: "M63 amendment complete — v6.25.1 tagged and pushed; audit-084 deployment blockers closed."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [route-206, audit-083]
  done:
    - audit-083-m63-gaps-closed-v6-25-1
    - tier3-e2e-dynamic-loop-58-commands
    - validate-command-e2e-coverage-vitest
    - milestone-task-tracking-reconciled
  deferred:
    - fifoz-feedback-007-consumer-path → acp-version-update
  key_fact: "audit-083 closed SC-M63-01: tier3 E2E must loop all tier-3 docs — registry alone is insufficient for behavioral coverage."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [route-206]
  done:
    - m63-test-coverage-tier-2-3-shipped-v6-25-0
    - command-e2e-coverage-registry-70-commands
    - validate-command-e2e-coverage-ci-guard
    - tier2-tier3-parity-e2e-suites
  deferred:
    - fifoz-feedback-007-consumer-path → acp-version-update
  key_fact: "M63 ships validateCommandE2eCoverage() — 0 untested commands via registry; tier2/tier3 behavioral E2E complete CRIT-065-003 tier 2/3."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [housekeeping]
  done:
    - acp-validate-sync-update-commit-housekeeping
    - progress-yaml-next-steps-m68-notes-refreshed
    - recurring-tasks-marked-overdue-weekly-monthly
  deferred: []
  key_fact: "v6.24.1 clean — validate 0 errors; weekly/monthly integrity scans overdue since June."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [route-198, route-199, route-200, route-201, route-202, route-203, route-204, route-205]
  done:
    - m68-safe-install-update-policy-shipped-v6-24-0
    - tier-helpers-version-update-install-bootstrap-e2e-validate
    - audit-082-post-ship-gaps-doc-drift-install-agents-md-fixed
  deferred: []
  key_fact: "M68 audit-082 fully closed at v6.24.1 — bootstrap preserve E2E, carryovers re-verified @082, doc/install gaps fixed."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [route-190, route-191, route-192, route-193, route-194, route-195, route-196, route-197]
  done:
    - m67-cross-agent-handoff-protocol-shipped-v6-23-0
    - acp-handoff-v2-dual-mode-executor-cross-repo
    - acp-receive-command-wrappers-e2e-fixtures
    - active-handoff-schema-validate-ancestry-check
    - audit-079-housekeeping-milestone-gates-task-stamps-carryovers
  deferred:
    - fifoz-feedback-007-final-closure → consumer-acp-version-update
  key_fact: "M67 shipped v6.23.0 with handoff v2 dual mode + /acp-receive + resume bridge; audit-079 found tracking/discoverability shortcuts (unchecked gates, planned tasks, stale README) — all upstream items closed; FIFOZ must run /acp-version-update to retire local wiki workaround."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [validate-sync-update]
  done:
    - develop-branch-synced-47-commits-fast-forward
    - progress-yaml-191-duplicate-keys-removed-yaml-parse-restored
    - acp-validate-zero-errors-milestone-status-sync-m27-doc-created
    - acp-validate-ts-schema-mapping-and-array-type-fix
    - git-tag-v6-21-0-created-progress-tracking-refreshed-m63
    - readme-badges-updated-6-21-0-66-milestones
  deferred:
    - m63-test-coverage-tier-2-3 → route-tbd
    - github-branch-protection → manual-enable
  key_fact: "progress.yaml had 191 duplicate YAML keys (mostly duplicate completed_date in tasks section) causing js-yaml parse failure — validate used line-based fallback and missed deeper schema errors. After dedup, full YAML parse restored and cross-file validators became reliable again."

# === Compacted Block: 2026-06-15 (10 sessions) ===
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
  tasks_completed: 26

- date: 2026-06-08
  executor: copilot
  branch: develop
  tasks: [route-150, route-151, route-152, route-153, route-154, audit-059, audit-060, audit-061]
  done:
    - m57-autonomous-implementation-all-5-routes-completed
    - route-150-progress-yaml-recurring-tasks-block-5-default-tasks
    - route-150-progress-template-yaml-recurring-tasks-section
    - route-151-agents-md-step-4-5-synced-to-claude-copilot-instructions
    - route-152-constraints-yml-hooks-block-progress-schema-yaml-recurring-tasks
    - route-153-acp-validate-md-step-2d-recurring-tasks-validation
    - route-154-e2e-16-16-assertions-version-bump-6-12-1-changelog
    - audit-059-m57-m58-cross-milestone-audit-all-clean
    - audit-060-m57-pre-impl-readiness-all-findings-resolved
    - audit-061-m57-post-impl-verification-no-gaps
    - e2e-91-91-assertions-pass-49-review-26-integrity-16-recurring-tasks
    - version-consistency-8-files-all-6-12-1
    - 5-routes-stamped-completed-150-through-154
  deferred: []
  key_fact: "Even a small milestone (M57, ~3h, 5 routes) benefits from the same 3-round audit discipline as larger milestones. audit-059 (cross-milestone), audit-060 (pre-impl), and audit-061 (post-impl) collectively caught 0 new bugs — because the implementation followed the pre-established patterns from M55/M56. The discipline itself prevents bugs, not just catches them."


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
    bootstrap install fix. M55: /acp-review shipped (77 rules). M56: /acp-integrity v1.0
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

- date: 2026-06-15
  executor: copilot
  tasks: [route-185..189, audit-073, F-065-AUDIT]
  done:
    - m65-audit-followup-fix-11-subagent-findings
    - e2e-acp-validate-cross-layer-test-created
    - quarterly-deep-scan-gated-blocked
    - f-062-03-escalation-recorded
    - f-069-05-malformed-entry-repaired
    - version-canonicalized-v6-20-2
    - m54-progress-50-to-100-completed-date
    - route-185-verification-checkboxes-stamped
    - carryover-statuses-fixed-f-068-12-f-069-09-crit-065-001
    - cross-refs-added-acp-validate-md-steps-2e-2f
  deferred: []
  key_fact: "Cross-subagent audit catches what solo audit misses. My own audit-073 found 8 findings, but the F-065 subagent found 19 — including E2E test gaps and carryover status drift I missed."

- date: 2026-06-15
  executor: copilot
  tasks: [route-165, route-166]
  done:
    - m60-route-165-8-e2e-tests-created-all-passing
    - m60-route-166-integrity-rule-count-fixed-70-exact
    - m60-route-166-contributing-md-created
    - integrity-test-62-62-green
  deferred: []
  key_fact: "8 E2E test suites (init, proceed, plan, dispatch, commit, validate, audit, route) created in one milestone — each with structural+negative assertions following patterns/local.e2e-testing.md. CRLF line endings on Windows require tr -d '\r' conversion before bash execution."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-173, route-174, route-175, route-176, route-177, route-178, route-179]
  done:
    - m62-complete-7-routes-all-v6-21-0
    - route-173-pipefail-upgrade-17-scripts-set-euo-pipefail
    - route-174-command-doc-structural-conformance-steps-verification
    - route-175-memory-layer-schemas-7-files-enforced-in-acp-validate
    - route-176-audit-062-carryovers-f-062-01-through-05
    - route-177-low-severity-cleanups-l1-l4
    - route-178-cross-file-consistency-validators-7-checks
    - route-179-post-milestone-sweep-script-e2e-test
  deferred: []
  key_fact: "M62 completed in under 3 hours — all 7 routes shipped. 17 scripts upgraded to set -euo pipefail (0 bare remaining). 7 memory-layer schemas created + enforced. 5 audit-062 carryovers resolved (F-062-01..05). Post-M61 shortcut prevention deployed: 7 cross-file consistency validators in acp-validate.ts (40/40 tests) + acp.post-milestone-sweep.sh (6 gates). Pre-commit hook active — caught ACP rule changes on commits."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-m66-marker-backfill]
  done:
    - m66-marker-backfill-232-files-100pct-coverage
    - m66-design-markers-28-files-100pct
    - m66-task-markers-195-files-100pct
    - m66-pattern-markers-9-files-100pct
    - m66-created-backfill-script-acp-backfill-markers-py
    - m66-stripped-superseded-status-prose-fields
  deferred: []
  key_fact: "M66 completed: 100% @acp.meta.* marker coverage across 232 files (from 3.9%). The full traceability chain is now unlocked: meta-scan can inventory all files, acp-validate probes are no longer blind, and acp-sync traceability maps work on the entire codebase. Created scripts/acp-backfill-markers.py as a reusable tool for future marker work."
