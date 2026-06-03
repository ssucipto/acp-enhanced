# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-06-04
  executor: copilot
  tasks_completed: [plan-047, audit-041, route-074, route-075, route-076, route-077, route-078, route-079, route-080, route-081, route-082, route-083, route-084, audit-042, acp-update]
  done:
    - m47-memory-integrity-v6-9-0-full-lifecycle
    - plan-feedback-review-16-of-20-findings-addressed
    - audit-041-pre-impl-readiness-10-findings-3-fixed-before-start
    - route-074-commit-step-2b-auto-sync-sessions-documents
    - route-075-commit-step-3b-auto-sync-patterns-documents
    - route-076-commit-step-6b-re-sync-after-compaction
    - route-077-pattern-sync-and-session-sync-repair-tools
    - route-078-validate-memory-yaml-lint-flag
    - route-079-version-update-guard-diff-preserve-force
    - route-080-yaml-quoting-directives-commit-and-update
    - route-081-schema-alignment-tasks-to-tasks-completed
    - route-082-dual-store-wiki-architecture-md
    - route-083-pattern-promotion-enforcement-step-3
    - route-084-command-onboarding-phase-guide
    - audit-042-post-impl-review-4-gaps-found-and-fixed
    - progress-yaml-synced-v6-9-0-47-milestones-66-commands
    - 6-git-commits-all-committed-to-mainline
  deferred:
    - "E2E tests for commit auto-sync → M48"
    - "Atomicity in sync operations → M48"
    - "F-05 registry schema lint → M48"
    - "CHANGELOG.md v6.9.0 update → M48"
  key_fact: |
    M47 (v6.9.0 Memory Integrity Release) completed end-to-end in a single session:
    /acp-plan → /acp-audit (pre-impl) → /acp-proceed --complete --yes (11 routes
    autonomous) → /acp-audit (post-impl) → /acp-update. The full ACP workflow was
    exercised: feedback-driven planning, pre-implementation audit with carryover
    tracking, autonomous milestone completion with per-task commits, post-implementation
    gap analysis, and progress synchronization. Core deliverable: /acp-commit now
    auto-syncs session and pattern documents from registries (steps 2b, 3b, 6b) with
    --no-sync escape hatch, idempotent design, and repair tools. Supporting work:
    --memory YAML validation, version-update guard (--diff/--preserve/--force),
    YAML quoting directives, schema alignment, dual-store wiki, pattern promotion
    enforcement, command onboarding. 6 git commits. 2 audit reports. 4 carryovers
    deferred to M48. Industry alignment: dual-store = Git checkout/DB checkpointing.

- date: 2026-06-03
  executor: copilot
  tasks: [audit-018, audit-019, audit-020, audit-021, audit-022, audit-023, audit-024, audit-025, audit-026, audit-027, audit-028, audit-029, audit-030, audit-031, audit-032, init-001, plan-044, route-047, route-048, route-052, route-053, route-054, route-055, route-056, route-057, route-058, route-059]
  done:
    - 15-audits-visualizer-repo-fixed-M44-100-percent
    - visualizer-remote-transferred-to-ssucipto
    - acp-visualize-command-updated-to-ssucipto-clone-url
    - ACP-agent-directory-added-to-visualizer-repo
    - README-visualizer-links-cleaned-all-ssucipto
    - bootstrap-syntax-bug-fixed-fi-else-ordering
    - 6-commits-pushed-today
    - 5-git-commits-all-pushed-to-mainline
  deferred:
    - F-004-dead-acp-core-manifest-sed → low
    - README-fully-synced-with-all-v6-8-2-features
    - M44-section-added-to-README-recent-enhancements

- date: 2026-06-03
  executor: copilot
  tasks: [route-063, route-064, route-065, route-066, route-067, route-068, route-069, route-070]
  done:
    - m45-test-package-8-routes-all-completed
    - tests-acp-light-mode-test-sh-10-assertions
    - tests-acp-at-mention-test-sh-10-assertions
    - tests-acp-parallel-test-sh-5-assertions
    - tests-acp-bootstrap-flags-test-sh-10-assertions
    - tests-acp-security-test-sh-8-assertions
    - tests-acp-runner-ci-test-sh-6-assertions
    - tests-acp-e2e-workflow-test-sh-8-assertions
    - tests-acp-smoke-test-sh-9-assertions-verified
    - tests-acp-performance-test-sh-4-assertions-verified
    - all-60-assertions-passing
    - gitignore-reports-added
    - route-files-stamped-completed
    - progress-yaml-m45-marked-completed
  deferred:
    - run-e2e-tests-sh-parallel-flag → M46
    - github-actions-ci-workflow-setup → infra-track
    - differences-table-updated-with-5-new-rows
    - update-command-corrected-to-acp-version-update
    - agent-layer-table-expanded-to-7-directories
    - 4-commits-all-pushed-to-mainline
    - R9-parallel-tasks-full-implementation
    - R8-observability-auto-population-on-commit
    - M44-100-percent-complete-10-routes-implemented
    - 20-gaps-found-and-fixed
    - CHANGELOG-updated-README-and-PRD-synced-44-milestones
    - 3-git-commits
  deferred:
    - F-004-dead-acp-core-manifest-sed → low
  key_fact: |
    12 audits, 100% M44, 20 gaps fixed in single session. Core insight: only
    10% of system surface area was used because users didn't know commands
    existed (→ post-command discoverability) and the context protocol was
    too heavy (→ light mode). Industry aligned with Anthropic 6 workflows,
    LangChain Interpreters, CrewAI memory, and LangSmith observability.
    No reusable code patterns — all work was protocol/documentation hygiene.
    - R9-parallelization-full-implementation-3-sub-tasks
    - 9-M44-routes-implemented-1-deferred
    - M44-64-percent-complete
  deferred:
    - route-048-observability-write-mechanism → P1 (design pending)
    - fixed-README-upstream-urls-banner-directory-tree-templates
    - fixed-PRD-status-skills-directory-tree
    - fixed-git-commit-git-init-command-docs-prefix-and-version
    - bumped-progress-yaml-6-6-0-to-6-8-2
    - synced-CLAUDE-md-from-copilot-instructions-md
    - committed-2-git-commits-docs-and-audit-fixes
  deferred:
    - F-004-dead-acp-core-manifest-sed → low
    - route-048-observability-write-mechanism → P1
    - route-050-R6-skills-at-mention-implementation → planned (053-055)
    - route-051-R9-parallelization-implementation → planned (056-058)
    - R3-R4-bash-script-flag-parsing → P1 (config done, script pending)
  key_fact: |
    Single-session transformation: 9 audits, 4 protocol files rewritten, 24
    command relationships mapped, 2 design docs, 10 M44 routes. Root causes
    found and fixed: 43/48 commands unused because users didn't know they
    existed (→ post-command discoverability), context protocol skipped 0/14
    times because it was too heavy (→ light mode), mode switching was one-way
    (→ two-way with recommendations), R2 dedup was an LLM-impossible "80%
    similar" (→ practical "read last 10, skip same topic"), R5 three-copy
    was going to break Claude Code (→ documented in pre-impl and fixed).
    Industry aligned with VS Code palette / npm tips / Anthropic simplicity.
    No reusable patterns — all work was documentation/correctness hygiene.
    - audit-023-second-round-mode-switching-gaps
    - fixed-GAP-001-reverse-switch-full-to-light
    - fixed-GAP-002-mode-tracking-current-field-in-routing-yml
    - fixed-GAP-003-auto-full-triggers-with-explicit-recommendation-logic
    - fixed-GAP-004-unified-output-formats-light-and-full-banners
    - fixed-GAP-005-added-est-tokens-to-light-banner
    - fixed-GAP-006-added-confirm-output-templates-to-routing-yml
    - fixed-GAP-007-R2-dedup-threshold-80-percent
    - fixed-GAP-008-R2-scope-inference-from-task-type
  deferred:
    - F-004-dead-acp-core-manifest-sed-in-version-update-sh → low
    - R3-team-size-flag → P1
    - R5-three-copy-redirects → P1
    - R8-observability-dashboard → P1
    - R4-optional-prompt-wrappers → P2
    - R6-skills-at-mention → P2
    - R9-parallelization → P2
    - R7-manifest-vs-progress-docs → P3
  key_fact: |
    6 audits completed (018–023). audit-023 caught 8 critical gaps in audit-022's
    R1/R2 implementation that would block real-world adoption: no reverse switching
    (full→light impossible), no mode tracking, auto-full triggers were passive YAML
    with no agent action, output formats were inconsistent between modes, and R2
    had no dedup threshold or scope inference. All gaps fixed in routing.yml +
    copilot-instructions.md + CLAUDE.md. Light mode is now a complete two-way
    protocol with mode awareness, recommendation, and consistent banners.
  deferred:
    - F-004-dead-acp-core-manifest-sed-in-version-update-sh → low
    - R3-team-size-flag → P1 (this week)
    - R5-three-copy-redirects → P1 (this week)
    - R8-observability-dashboard → P1 (this week)
    - R4-optional-prompt-wrappers → P2 (backlog)
    - R6-skills-at-mention → P2 (backlog)
    - R9-parallelization → P2 (backlog)
    - R7-manifest-vs-progress-docs → P3 (docs only)
  key_fact: |
    7 audits completed (018–024). v6.8.2 delivers: R1 light-mode protocol with
    two-way switching + mode recommendation, R2 auto-populate lessons from key_facts
    with scope + dedup, R3 post-command discoverability (24 command relationships
    surfacing related commands after each invocation). Root cause of 43/48 commands
    never used: users don't know what's available. Fix: agent now suggests related
    commands with "when to use" descriptions after each command, detects underused
    commands during repetitive work, and shows getting-started tips. Industry aligned
    with VS Code palette / npm tips / Rails scaffolds / Copilot chat patterns.
    v6.8.2. Key insight: only 10% of system surface area sees active use. Context
    loading protocol executed 0/14 times — agents skip it because ~800 tokens of
    mostly-stale context adds no value when conversation context exists. P0 fixes
    implemented: R1 light-mode protocol (identity + progress + recent sessions,
    ~200 tokens) added to routing.yml + copilot-instructions.md + CLAUDE.md. R2
    auto-populate lessons from key_facts added to /acp-commit protocol with scope
    inference + dedup. 7 remaining recommendations prioritized for phased rollout.

- date: 2026-05-17
  executor: copilot
  tasks: [audit-018]
  done:
    - audit-018-readme-accuracy-vs-implementation
    - fixed-readme-seven-to-eight-steps-F-001
    - fixed-bootstrap-counter-1-7-to-1-8-all-six-echoes-F-002
    - added-M43-subsection-to-recent-protocol-enhancements-F-003
    - updated-section-header-v6.4-v6.8-to-v6.4-v6.8.1-F-003
    - rewrote-bootstrap-step-list-to-match-actual-script-F-004
    - generated-IP_REGISTER.md-via-ip-register-prompt
  deferred: []
  key_fact: |
    audit-018: README said "seven steps" but bootstrap has 8 ([8/8] = pre-commit hook, added M41).
    Script counters [1/7]–[6/7] were stale — updated to [1/8]–[6/8]. M43 (v6.8.1) was missing
    from "Recent Protocol Enhancements". All 5 findings fixed immediately — no pending carryovers.
    All previous audit carryovers remain at status:fixed (0 pending).

- date: 2026-05-13
  executor: copilot
  tasks: [plan(M43), route-043, route-044, route-045]
  done:
    - planned-M43-taxonomy-gap-fixes-routing-hygiene-3-routes-7d9c042
    - route-043-added-shell-scripting-to-taxonomy-yml-GAP-001-audit-017-75528d8
    - route-044-added-copilot-executor-note-to-ledger-md-R2-audit-017-8ccd849
    - route-045-command-doc-threshold-rule-rules-md-R3-audit-017-df4dac7
    - route-045-checkStaleness-moved-after-blocking-checks-acp-validate-ts-OBS-001-df4dac7
    - all-audit-carryovers-marked-fixed-0-pending
    - version-bumped-6.8.0-to-6.8.1
    - 4-commits-all-pushed-to-origin-mainline
  deferred: []
  key_fact: |
    GAP-001 (audit-017): shell-scripting task_type was used in route-005/011 but absent
    from taxonomy.yml — acp-dispatch.ts fell back to claude-sonnet (10-20x more expensive).
    Rule: add new task_types to taxonomy.yml IMMEDIATELY when first used in a route file.
    Threshold rule added to rules.md: command-doc-write when >20 net new lines or >50%
    rewritten; command-doc-update for smaller edits to existing command docs.

- date: 2026-05-11
  executor: copilot
  tasks: [route-036, route-037, route-038, route-039, route-040, route-041, route-042]
  done:
    - dispatch-sigint-handler-and-order-fix
    - validate-sessions-memory-check
    - validate-agents-md-size-guard
    - validate-parity-diff-filenames
    - taxonomy-9-new-types-plus-last-updated
    - getSkillFile-crosscut-types-mapping
    - lessons-archive-mechanism-and-filter
    - staleness-check-taxonomy-and-models
    - final-review-moved-to-agent-design
    - m42-milestone-complete-6.8.0-released
  deferred: []
  key_fact: "validateSessionsMemory + validateAgentsMdSize + checkStaleness + improved runParityCheck added to acp-validate.ts; getSkillFile + getFilteredLessons improved in acp-dispatch.ts; 9 new taxonomy task types; FINAL-REVIEW.md moved to agent/design/acp-ux-review.md; all 9 audit-015 carryovers closed; version 6.7.0 -> 6.8.0"

- date: 2026-05-11
  executor: copilot
  tasks: [route-029, route-030, route-031, route-032, route-033, route-034, route-035]
  done:
    - completed-M41b-stabilisation-sprint-7-structural-gap-fixes
    - route-029-deleted-scripts-scripts-package-json-duplicate-GAP-001-bf92e15
    - route-030-added-QUICKSTART-link-to-README-hero-section-GAP-002-ecf5587
    - route-031-documented-git-workflow-branch-safety-README-QUICKSTART-GAP-003-b85393d
    - route-032-added-AGENTS-md-pre-commit-sync-hook-to-acp-bootstrap-sh-GAP-004-f3d5f17
    - route-033-added-Windows-WSL2-install-docs-to-README-QUICKSTART-GAP-005-d96f1d3
    - route-034-added-last-verified-2026-05-11-to-all-5-models-routing-config-yml-OBS-002-3c7083b
    - route-035-set-Persona-A-defaults-routing-yml-executor-copilot-model-github-copilot-OBS-004-263b3b2
    - M41-wrap-up-version-6.6.0-to-6.7.0-identity-package-AGENT-CHANGELOG-milestone-completed
    - M41-100-percent-14-of-14-tasks-all-routes-022-to-035-stamped
  deferred: []
  key_fact: |
    M41 Stabilisation Sprint COMPLETE (14/14, 6.7.0). Key patterns confirmed:
    acp-bootstrap.sh step 8 (8/8) installs pre-commit hook — idempotent (checks ACP marker before append).
    BSD-safe hook install: use `printf '%s\n' "$VAR" > file` (not heredoc with variable) to avoid
    quoting issues. routing.yml Persona A defaults: executor: copilot, model: github-copilot —
    acp-dispatch.ts overwrites at runtime for Persona B/C.
    QUICKSTART Step 0 is Windows/WSL2 setup (new pattern for platform-specific prerequisite steps).

- date: 2026-05-11
  executor: copilot
  tasks: [route-022, route-023, route-024, route-025, route-026, route-027, route-028]
  done:
    - completed-M41a-stabilisation-sprint-7-bug-fixes
    - route-022-fixed-sessions-md-yaml-orphaned-entry-missing-date-header-BUG-001
    - route-023-fixed-acp-dispatch-ts-HTTP-Referer-hardcoded-placeholder-BUG-002
    - route-024-created-acp-feedback-md-command-doc-v1.0.0-plus-companions-BUG-003a
    - route-025-created-acp-task-md-command-doc-v1.0.0-plus-companions-BUG-003b
    - route-026-created-acp-install-md-command-doc-v1.0.0-plus-companions-BUG-003c
    - route-027-created-acp-dispatch-md-command-doc-v1.0.0-plus-companions-BUG-003d
    - route-028-updated-domain-yml-count-58-to-63-BUG-004
    - M41-progress-0-to-7-tasks-50-percent-complete
  deferred:
    - M41b-routes-029-035-GAP-and-OBS-fixes → separate-acp-proceed-invocation
  key_fact: |
    4 missing command docs: acp.feedback, acp.task, acp.install, acp.dispatch (BUG-003a-d).
    acp.install.sh has NO --global/--local/--upgrade/--check flags — document actual script
    behaviour. domain.yml count was 58; actual verified count is 63 after M41a (61 acp.* + 2 git.*).
    Command doc trio pattern: every new command needs 3 files atomically: agent/commands/acp.{cmd}.md,
    .github/prompts/acp-{cmd}.prompt.md, .opencode/commands/acp-{cmd}.md.
    5 commits this session: b99ff1c, 4765a35, 9420f67, 3cb3573, 67a96cd, 0fb669d, 93bcf16.

- date: 2026-05-11
  executor: copilot
  tasks: [route-014, route-015, route-016, route-017, route-018, route-019, route-020, route-021]
  done:
    - completed-M39-git-branch-awareness-4-routes-version-6.4.13-to-6.5.0
    - route-014-optional-git-workflow-commented-block-in-identity-yml
    - route-015-step-1b-git-branch-safety-check-added-to-agents-claude-copilot-instructions
    - route-016-acp-commit-md-v1.2.0-step-0-branch-guard-branch-field-in-sessions-schema
    - route-017-milestone-39-created-wiki-architecture-domain-updated
    - completed-M40-pre-impl-audit-protocol-4-routes-version-6.5.0-to-6.6.0
    - route-018-audit-carryovers-md-created-new-memory-layer-carryovers-key-schema
    - route-019-acp-audit-md-v1.1.0-pre-impl-flag-4-phases-step-3b-carryover-write-all-modes
    - route-020-step-4.4-audit-carryovers-check-added-to-all-3-protocol-files
    - route-021-quality-gate-comment-task-template-milestone-40-created-wiki-updated
    - bumped-version-6.4.13-to-6.5.0-then-6.6.0-across-identity-agent-md-package-yaml-changelog
    - 2-git-commits-f677583-M39-413d27d-M40
  deferred: {}
  key_fact: |
    force-add is required for gitignored instance files in this repo (milestones/, routing/tasks/,
    progress.yaml, memory/). This repo is the ACP development repo and tracks these as examples —
    but agent/.gitignore excludes them by default for consumer projects. Always use `git add -f`
    for these paths when committing in acp-enhanced itself. Pattern: same `created: YYYY-MM-DD`
    appears in all route files, so stamp `completed:` by appending the date to that line.

- date: 2026-05-11
  executor: copilot
  tasks: [audit-011]
  done:
    - read-all-8-route-files-014-through-021
    - cross-referenced-against-identity-yml-agents-md-progress-yaml-milestone-format
    - found-6-gaps-3-high-3-medium-low-across-routes-015-017-018-019-020-021
    - created-audit-011-report-6-findings-9-recommended-fixes
    - applied-all-9-fixes-to-route-files-directly
  deferred: {}
  key_fact: |
    3 high gaps in routes pre-implementation: (1) route-017 title referenced deferred acp-bootstrap.sh
    work — title corrected; (2) route-017 milestone task list omitted route-017 itself; (3) route-019
    acceptance criteria said "Steps 0-5 unchanged" but Step 4 IS changed (carryover write added to all
    modes). Also: both wrap-up routes (017 + 021) omitted wiki file updates — same gap pattern that
    created audit-009 compliance fixes. All 9 fixes applied before implementation begins.

- date: 2026-05-11
  executor: copilot
  tasks: [audit-010]
  done:
    - read-feedback-002-git-branch-awareness-5-recommendations
    - read-feedback-003-pre-implementation-audit-protocol-4-recommendations
    - verified-no-implementations-exist-in-acp-enhanced-for-either-feedback
    - created-audit-010-report-9-findings-2-milestone-plan-M39-M40
  deferred:
    - implement-M39-git-branch-awareness → not-yet-routed
    - implement-M40-pre-impl-audit-enhancement → not-yet-routed
  key_fact: |
    feedback-002: ACP context-loading (Steps 1-6) has no git branch check, identity.yml
    has no git_workflow field, acp.commit.md has no branch guard. All 3 are high severity.
    feedback-003: acp.audit.md has single mode (no --pre-impl), no audit-carryovers.md
    exists (pending fixes are silently lost), task template has no verification quality gate.
    M39 (branch awareness, 4 tasks, ~45min) and M40 (pre-impl audit, 4 tasks, ~1hr) defined.

- date: 2026-05-09
  executor: copilot
  tasks: [audit-009]
  done:
    - created-audit-009-report-6-findings-all-fixed
    - created-route-013-retroactive-route-for-audit-008-work
    - created-milestone-38-protocol-knowledge-preservation
    - wrote-sessions-md-entry-for-2026-05-09-audit-008-session
    - updated-changelog-md-6.4.13-entry-proactive-commit-triggers
    - updated-progress-yaml-version-6.4.13-current-milestone-M38-complete
    - updated-agent-md-add-acp-commit-to-workflow-proactive-session-memory-note
    - updated-wiki-architecture-md-session-memory-write-protocol-section
    - updated-wiki-domain-yml-session-memory-protocol-section
    - bumped-version-6.4.12-to-6.4.13-AGENT-md-identity-yml-package-yaml
  deferred: {}
  key_fact: |
    When audit-008 was executed, 6 ACP process compliance gaps were created: no route file,
    no sessions.md entry, stale progress.yaml, no CHANGELOG entry, AGENT.md not updated,
    wiki not updated. All 6 were retroactively fixed in audit-009. Key pattern: even work
    that fixes process gaps can itself violate process — always run /acp-route BEFORE
    starting and /acp-commit IMMEDIATELY after each >5-file commit.

# === Weekly Summary: 2026-05-01 – 2026-05-09 (10 sessions compacted 2026-05-13) ===
- date: 2026-05-01
  executor: Persona A (Copilot)
  compacted: true
  tasks: [task-76..80, task-126..132, task-001..005, task-007..012, task-146, task-148, task-151..154,
          audit-001, audit-002, task-156, task-157, task-158, task-159, task-176, task-177,
          task-184, task-185, task-186, audit-005, route-013, M38]
  summary: |
    Week of 2026-05-01 to 2026-05-04 (original compaction 2026-05-05):
    M21-M23 completions (AGENT.md audit series). audit-001/002 fixes. task-001-012: @acp.X→/acp-X
    standardisation (92 files), .agent/→agent/ migration, install/update scripts, yaml AST cache bug
    (_ast_valid() helper), BSD date UTC fix (date -j -u on macOS), 50 .prompt.md files added.
    task-146/148: 203 files untracked, YAML frontmatter as sole task status indicator.
    task-151-154: yaml_query scalar array bug fixed, 95/95 yaml-parser tests pass.

    2026-05-05 — M29 (task-156-158): Parity matrix audit — all 3 PORT items were misclassified;
    features already existed locally. Upstream integration runbook created. wiki/domain.yml synced.
    2026-05-05 — M30 (task-159): Fixed acp.install.sh gitignore heredoc (bare drafts/→drafts/**).
    Fix source file AND all scripts that regenerate it.
    2026-05-05 — M34 (task-176-177): Canonical naming convention — triple-file architecture
    (agent/commands/acp.NAME.md + .github/prompts/acp-NAME.prompt.md + .opencode/commands/acp-NAME.md).
    2026-05-05 — M37 (task-185-186): Audit-007 fixes — gitignore heredoc pattern extends to command
    docs (acp.project-create.md). git rm --cached removes tracked gitignored files.
    2026-05-05 — audit-006/task-184: local.* protection covers all 4 install targets
    (memory/, patterns/ [templates-only], index/, skills/).
    2026-05-06 — audit-005: .agent/→agent/ path bug fixed (14 files + acp-dispatch.ts). Original ACP
    diverged to v7.x. 58 real command docs in agent/commands/.
    2026-05-06 — M25/task-141-144: TanStack visualizer complete. createAPIFileRoute does NOT exist in
    v1.167.64 — use createServerFn with .inputValidator().
    2026-05-09 — M38/route-013: Context overflow is silent. sessions.md treated as WAL.
    7 trigger events require IMMEDIATE memory writes. audit-008 findings + proactive commit protocol.
  key_facts_preserved:
    - "Verify locally before PORT classification: grep -r keyword agent/commands/ agent/scripts/"
    - "Triple-file command architecture: acp.NAME.md (dot) + acp-NAME.prompt.md + acp-NAME.md (hyphen)"
    - "Gitignore heredoc pattern extends to command docs — grep agent/commands/ when fixing gitignore"
    - "local.* protection covers all 4 install targets: memory/, patterns/, index/, skills/"
    - "TanStack Start v1: createServerFn with .inputValidator() — createAPIFileRoute does NOT exist"
    - ".agent/ vs agent/ path bug fixed in audit-005 — 58 command docs in agent/commands/"
    - "macOS BSD date UTC fix: date -j -u -f '%Y-%m-%dT%H:%M:%SZ' (add -u flag)"
    - "Context overflow is silent — write sessions.md at moment of discovery, not end of session"
    - "POSIX awk only on macOS — gawk 3-arg match() is an extension, use sub() instead"
    - "Always update package.yaml scripts section at END of any milestone that adds commands"
