# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-185, route-186, route-187, route-188, route-189]
  done:
    - m65-complete-5-routes
    - cross-layer-status-sync-12-milestone-docs
    - validate-filepointers-and-status-consistency-checks
    - m58-plan-correction-adr-11-12
    - adr-reconstruction-13-16
    - pipefail-meta-scan
    - quarterly-deep-scan-phase-2-active
    - f-062-03-promoted-to-m59
  deferred: []
  key_fact: "progress.yaml had systemic duplicate YAML keys causing js-yaml parse failures; validate.ts now uses line-based fallback. The cross-layer validator caught 12 stale milestone docs (9 fixed, M21/M42 left as legacy)."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [validate, sync]
  done:
    - validate-all-layers-pass-0-errors
    - sync-glossary-m58-phase-2-terms-added
  deferred:
    - design-marker-backfill → pending interactive prompt
  key_fact: "Glossary was missing 6 M58 Phase 2 terms (Integrity Scan, Phase 2, Confidence Ceiling, Taint Flow, Memory Poisoning, Self-Protection Protocol). Total terms: 42 → 48."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [audit-072, M58]
  tasks_completed: [audit-072]
  done:
    - audit-072-m58-post-impl-8-findings-all-fixed
    - taint-scan-ig-47-48-50-file-level-heuristics-indirect-flow
    - taint-manifest-max-confidence-ci-blocking-v1-1-0
    - e2e-integrity-v2-55-assertions-full-fixture-matrix
    - research-memory-poisoning-ux-doc-route-155
    - wiki-header-v2-0-0-phase-2-active
    - audit-carryovers-m58-bulk-fixed-verified-072
  deferred:
    - empirical-tpr-vs-eslint-descoped-literature-calibration → accepted
  key_fact: "Taint heuristics must use file-level flow analysis for indirect source→sink (target=req.query → redirect(target)); line-level patterns miss 50% of calibration fixtures."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-155, route-156, route-157, route-158, M58]
  tasks_completed: [route-156, route-157, route-158]
  done:
    - m58-phase-2-semantic-analysis-shipped-v6-20-0
    - route-156-wiki-cat-8-10-un-deferred-confidence-ceilings-acp-integrity-v2-0-0
    - route-157-acp-taint-scan-sh-memory-scan-sh-phase-2-prep-scripts
    - route-158-e2e-integrity-v2-26-assertions-ci-wired
    - phase2-self-protection-protocol-continue-not-self-halt
    - git-commit-d255929-v6-20-0
  deferred:
    - github-branch-protection-manual-enable → route-162
    - m65-tracking-reconciliation → route-185
  key_fact: "grep treats leading -- as flags — E2E assert_contains with needle '--phase2' silently fails. Use descriptive substring without leading dashes (e.g. 'Run Phase 2 semantic') or grep -F/--."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-179, route-180, route-181, route-182, route-183, route-184, audit-071, M64]
  tasks_completed: [route-179, route-180, route-181, route-182, route-183, route-184, audit-071]
  done:
    - m64-integrity-gateway-v1-1-routes-180-184-audit-071-fixes-v6-19-0-committed
    - audit-071-deep-dive-m59-m64-13-findings-11-fixed-1-open-1-accepted
    - e2e-exit-trap-fix-temp-fixture-dir-variable-collision-destroying-committed-fixtures
    - fixture-matrix-11-fixtures-4-script-backed-rules-manifest-yaml
    - manifest-hash-sh-output-removed-stderr-redirect
    - progress-yaml-description-updated-v6-19-0-reality
    - wiki-category-2-detection-column-restored
    - acp-integrity-md-bumped-v1-1-0
    - ci-integrity-e2e-plus-npm-test-wired-into-workflow
    - ig-emit-from-legacy-line-dead-branch-fixed
    - b20-scanner-specific-baselines-no-entropy-on-yaml-config
    - git-commit-v6-19-0-32-files-979-insertions-638-deletions
  deferred:
    - github-branch-protection-manual-enable → route-162
    - m65-tracking-reconciliation → route-185
  key_fact: "The E2E EXIT trap variable collision (FIXTURE_DIR reused across B1 temp dir and committed fixtures path) was the root cause of all intermittent fixture failures — trap deleted the entire fixtures/integrity/ directory on script exit. Fix: separate TEMP_FIXTURE_DIR + INTEGRITY_FIXTURE_DIR with trap cleared after B3."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-159, route-160, route-161, route-162, route-163, route-164, M59]
  tasks_completed: [route-159, route-160, route-161, route-162, route-163, route-164]
  done:
    - m59-shipped-v6-14-0-critical-fix-ci-integrity
    - route-159-updateRoutingYml-surgical-session-block-dispatch-regression-tests
    - route-160-package-yaml-15-missing-commands-ci-count-guard
    - route-161-acp-validate-in-ci-ci-validate-sh-real-checks
    - route-162-branch-protection-governance-docs-usage-md
    - route-163-openrouter-api-key-preflight-dispatch
    - route-164-version-header-check-validateVersionConsistency
    - changelog-6-14-0-progress-milestone-59-completed
  deferred:
    - github-branch-protection-manual-enable → route-162
    - m64-integrity-gateway-truth → route-179
    - git-commit-m59-v6-14-0 → user-request
  key_fact: "M59 closed silent correctness bugs (routing.yml overwrite, package.yaml gaps, CI no-op). C1 branch protection is documented but requires manual GitHub repo settings — code cannot enforce it. Next per ADR-10: M64 before M58 v2.0."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-155]
  tasks_completed: [route-155]
  done:
    - audit-070-m55-m58-gateway-deep-dive-16-findings-committed
    - m64-m65-remediation-plan-routes-179-189-coverage-matrix-committed
    - acp-validate-zero-errors-zero-warnings-69x3-parity-triple-sync
    - acp-sync-readme-prd-quickstart-counts-m52-m57-protocol-section
    - acp-update-progress-m54-50pct-m58-blocker-next-steps-trimmed
    - parity-wrappers-carryover-query-pattern-sync-session-sync-rule-file-audit
    - m54-milestone-doc-created-route-155-research-artifact-fixtures-drafted
  deferred:
    - git-commit-pending-local-work → user-request
    - m59-critical-ci-fixes → route-159
    - m64-integrity-gateway-truth → route-179
    - m65-tracking-reconciliation → route-185
  key_fact: "Audit-070 proved /acp-integrity v1.0 gives false assurance (~18/55 rules implemented, entropy scanner crashes on findings). M64 (gateway truth/test) must ship before M58 v2.0 semantic analysis — building Phase 2 on an untested v1 gateway would compound the problem."

- date: 2026-06-15
  executor: copilot
  branch: develop
  tasks: [route-150, route-151, route-152, route-153, route-154, audit-062, audit-063, audit-064, design-spec-features, design-spec-m55-m58, stakeholder-report]
  done:
    - m57-autonomous-implementation-all-5-routes-completed
    - route-150-progress-yaml-template-recurring-tasks
    - route-151-agents-md-step-4-5-triple-file-sync
    - route-152-constraints-yml-hooks-progress-schema
    - route-153-acp-validate-step-2d-recurring-validation
    - route-154-e2e-16-assertions-version-6-12-1-changelog
    - audit-062-m57-deep-dive-industry-standards-8-findings-5-carryovers
    - audit-063-design-spec-v1-review-12-findings-all-fixed-v2
    - audit-064-m55-m58-spine-v1-review-14-findings-all-fixed-v2
    - design-spec-acp-enhanced-features-v1-then-v2-after-audit-063
    - design-spec-m55-m58-command-ecosystem-v1-then-v2-after-audit-064
    - stakeholder-report-week-ending-2026-06-13-amber
    - status-snapshot-where-are-we
    - visualizer-configured-for-acp-enhanced-project
    - 3-spec-documents-2-audit-cycles-v1-v2-pattern-established
    - all-91-e2e-assertions-passing-across-review-integrity-recurring
  deferred:
    - m58-research-calibration → route-155
    - audit-062-carryovers → m59-remediation
    - m54-branch-protection → m54-completion
  key_fact: "The v1→v2 audit cycle pattern (create spec → audit → fix all findings → v2) caught 26 errors across two specs that would have shipped as authoritative documentation. Three CRITICAL numerical errors (M55: 54→77 rules, M56: broken subtotals, months: 11→5) were caught by line-by-line codebase cross-reference — the audit discipline prevented publication of incorrect metrics."

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
