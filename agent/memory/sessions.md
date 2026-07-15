# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

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
    - f-086-02-consumer-project-consumer → task-239
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
    - f-086-02-consumer-project-consumer → task-239
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
