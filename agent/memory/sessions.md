# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

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

- date: 2026-05-09
  executor: copilot
  tasks: [route-013, M38]
  done:
    - investigated-feedback-001-tikrflow-3-sessions-context-overflow-knowledge-loss
    - created-audit-008-report-6-findings-5-decisions-R1-R4-adopted-R5-rejected
    - updated-AGENTS-md-CLAUDE-md-copilot-instructions-step4-gap-check-substep
    - added-mid-session-commit-triggers-7-triggers-proactive-WAL-approach
    - updated-constraints-yml-6-new-knowledge-preservation-rules
    - bumped-acp-commit-md-v1.0.0-to-v1.1.0-phase-boundary-frequency
    - prepended-acp-knowledge-gap-postmortem-to-lessons-md-priority-high
    - commit-4e00a90-fix-protocol-proactive-commit-triggers-feedback-001
  deferred: {}
  key_fact: |
    Context overflow is silent — sessions terminate without warning, and any work not
    written to disk at the moment of discovery is permanently lost. Fix: treat sessions.md
    like a WAL (write-ahead log). 7 trigger events require IMMEDIATE memory writes, not
    deferred end-of-session dumps. The >5-file commit trigger was immediately violated by
    the same commit that introduced it — caught and fixed in audit-009.

- date: 2026-05-06
  executor: copilot
  tasks: []
  done:
    - acp-status-read-only-display
    - answered-how-to-use-visualizer-launch-instructions
  deferred: {}
  key_fact: null

- date: 2026-05-06
  executor: copilot
  tasks: [task-141, task-142, task-143, task-144]
  done:
    - create-TaskList-tsx-task-rows-status-badge-hours
    - create-MilestoneTree-tsx-expand-collapse-hierarchy-expand-all-collapse-all
    - update-milestones-route-table-tree-tab-toggle
    - create-search-ts-fuse-js-index-threshold-0.35-milestone-task-weights
    - create-SearchBar-tsx-controlled-input
    - create-FilterBar-tsx-all-in-progress-completed-not-started-tabs
    - create-search-route-tsx-slash-search-q-results-page-grouped-milestones-tasks
    - wire-filter-bar-into-milestones-route-status-filter-composes-with-table-tree
    - create-NextSteps-tsx-blue-callout-next-steps-array
    - create-ProjectHeader-tsx-name-version-status-description
    - create-OverallProgress-tsx-milestone-completion-bar-counts
    - update-root-tsx-gray-900-sidebar-searchbar-header-outlet-layout
    - update-index-tsx-polished-home-page-replaces-raw-json
    - create-acp-visualize-md-command-doc-launch-tanstack-start-dashboard
    - update-agent-md-add-acp-visualize-to-workflow-commands
    - mark-M25-completed-100pct-8of8-tasks-2026-05-06
    - bump-version-6.4.8-to-6.4.12-four-increments
    - commit-e86406d-task-141-visualizer
    - commit-e913c3d-task-142-visualizer
    - commit-936ba37-task-143-visualizer
    - commit-42e13fd-task-141-acp-enhanced-tracking
    - commit-d4f13fe-task-142-acp-enhanced-tracking
    - commit-b67bc24-task-143-acp-enhanced-tracking
    - commit-7a99f46-task-144-and-M25-complete-acp-enhanced
  deferred: {}
  key_fact: |
    TanStack Start v1.167.64: `createAPIFileRoute` from `@tanstack/react-start/api`
    does NOT exist — that subpath has no export. Use `createServerFn` with
    `.inputValidator()` (NOT `.input()`). Import from root `@tanstack/react-start`.
    Pattern saved to patterns.md as `tanstack-start-v1-server-fn`.

- date: 2026-05-05
  executor: copilot
  tasks: [task-156, task-157, task-158]
  done:
    - audit-3-PORT-items-from-parity-matrix-all-3-reclassified
    - saas-platform-PORT-to-HAVE-30-steps-confirmed-locally
    - acp-sync-pass-c-PORT-to-PARTIAL-old-D-ID-naming-gap
    - FR-DR-naming-PORT-to-PARTIAL-R-to-FR-D-to-DR-rename-gap
    - update-parity-matrix-PORT-3-to-0-HAVE-147-to-149-PARTIAL-13-to-15
    - add-section-13-compatibility-audit-with-verdict-table-and-safety-gate
    - update-section-11-PORT-action-items-to-reclassification-notes
    - commit-cbb9ec7-M29-task-156-port-compatibility-audit-0-PORT-items
    - create-agent-patterns-local-upstream-integration-runbook-67-lines
    - commit-0ed8c92-M29-task-157-upstream-integration-runbook
    - sync-agent-wiki-domain-yml-commands-count-51-to-58
    - add-6-missing-commands-commit-decide-memory-sync-route-cost-report-wiki-update
    - add-local-category-for-LOCAL-ONLY-commands
    - add-2-missing-e2e-suites-acp-drafts-acp-opencode-commands
    - commit-f68e732-M29-task-158-wiki-domain-sync-M29-COMPLETE
  deferred: {}
  key_fact: |
    Before classifying a parity item as PORT, ALWAYS verify locally first with
    `grep -r "keyword" agent/commands/ agent/scripts/`. All 3 PORT items in M29
    parity matrix were misclassified — the features already existed locally.
    The verify-before-classify rule is now codified in the upstream integration runbook
    (agent/patterns/local.upstream-integration-runbook.md Step 2 and Step 4).


  done:
    - fix-acp-install-sh-gitignore-drafts-bare-to-glob-add-gitkeep-touch-template-copy
    - fix-acp-bootstrap-sh-add-agent-drafts-mkdir-draft-template-copy
    - update-agent-md-directory-tree-add-drafts-entry
    - create-e2e-acp-drafts-test-sh-7-assertions-all-pass
    - mark-M30-completed-100pct-3of3-tasks
  deferred: {}
  key_fact: |
    acp.install.sh embedded .gitignore heredoc had bare `drafts/` (same bug as agent/.gitignore).
    Whenever install scripts write their own .gitignore blocks, those heredocs must also use
    `drafts/**` with `!` exceptions — not just the tracked agent/.gitignore file.
    Pattern: fix the source file AND all scripts that regenerate it.

- date: 2026-05-05
  executor: copilot
  tasks: [task-159]
  done:
    - verify-task-159-all-4-checklist-items-pass
    - commit-1f73b24-fix-M30-agent-drafts-directory-live-bug
  deferred:
    - task-160: update install scripts to create agent/drafts/ on fresh install
    - task-161: update AGENT.md + e2e test for drafts convention
  key_fact: |
    bare `drafts/` in .gitignore excludes the entire directory including itself, blocking
    all `!exception` rules. Fix: use `drafts/**` (contents only) + explicit `!.gitkeep`
    and `!draft.template.md` — identical pattern to tasks/** and milestones/**.
    Verification gate: always run `git add <dir>/ && git status` then reset to confirm
    tracked files before committing a new directory with mixed tracked/ignored contents.

- date: 2026-05-05
  executor: copilot
  tasks: [task-184]
  done:
    - complete-audit-006-task-184-readiness-report-CLEAR-TO-RUN
    - implement-acp-install-sh-local-star-skill-exclusion-case-esac-loop
    - mark-task-184-completed-M29-progress-0pct-to-20pct-1of5-tasks
    - bump-version-6.4.1-to-6.4.2-patch
    - commit-a26d565-pushed-to-origin-mainline
  deferred: {}
  key_fact: |
    The local.* protection convention (project-local files never overwritten on upgrade)
    now covers all four install targets: memory/ (_create_if_absent), patterns/ (templates-only),
    index/ (find ! -name local.*), and skills/ (case loop, added this session).
    Safe upgrade guarantee: downstream projects can run acp.install.sh at any time without
    losing any project-local state — memory, routing tasks, patterns, index entries, or skills.

- date: 2026-05-06
  executor: copilot
  tasks: [audit-005]
  done:
    - fix-agent-path-bug-14-files-prompts-opencode-commands
    - fix-agent-tasks-routing-tasks-route-in-acp-route-and-acp-commit
    - fix-acp-dispatch-ts-AGENT_DIR-was-dotAgent-now-agent
    - update-AGENT-md-token-estimates-layer1-875t-layer2-475-660t-total-2550-3235t
    - update-readme-token-budget-2800-to-5000
    - update-readme-bootstrap-two-phases-to-seven-steps
    - update-readme-slash-commands-table-6-copilot-opencode-only-note
    - update-readme-comparison-table-add-fork-point-caveat
    - update-readme-any-other-agent-row-52-to-58-commands
    - create-6-missing-agent-commands-route-commit-decide-cost-report-memory-sync-wiki-update
    - verify-deepseek-v4-flash-available-0.14-0.28-exact-match
    - verify-deepseek-v4-pro-available-0.435-0.87-exact-match
    - committed-0f0b2ed-pushed-to-origin-mainline
  deferred: {}
  key_fact: |
    Original ACP has diverged to v7.x (active development). Comparison table claims about
    original ACP were accurate at fork point but upstream now has sessions, sync, validate,
    pattern-create, and other new commands. Added fork-point caveat to README. Also:
    agent/commands/ now has exactly 58 real command docs (matching 58 slash commands).
    The .agent/ vs agent/ path bug affected ALL 14 ACP Enhanced-layer command files
    AND acp-dispatch.ts — none of the enhanced-layer commands could have ever executed
    correctly before this fix.

# === Weekly Summary: 2026-05-01 – 2026-05-04 (10 sessions compacted 2026-05-05) ===
- date: 2026-05-01
  executor: Persona A (Copilot)
  compacted: true
  tasks: [task-76..80, task-126..132, task-001..005, task-007..012, task-148, task-146, task-151..154, audit-001, audit-002]
  summary: |
    Week of 2026-05-01 to 2026-05-04 — 10 sessions compressed.

    Milestones completed: M21, M22, M23 (AGENT.md completeness audit series)
    M21: Fixed 9 unfilled @{namespace}-{command-name} placeholders, README curl 404 (main→mainline),
         version 6.2.1→6.2.2, 7 missing scripts added to package.yaml, CHANGELOG 6.2.2.
    M22: Fixed AGENT.md directory tree (ghost removed, 7 missing dirs added), stale @acp.install
         ref, scripts/AGENTS.md bash anti-patterns, version 6.2.2→6.2.3, CHANGELOG 6.2.3.
    M23: Rebranded AGENT.md as ACP Enhanced fork — What's New table (15 items), ToC 14→24,
         Core Commands 6→40+ with (ACP Enhanced) labels, version 6.2.3→6.2.4, CHANGELOG 6.2.4.
    audit-001/002: posix-awk fix, @acp- hyphen notation fixes (9 headers + 5 body files),
         AGENT.md tree comments, package.yaml 13 missing commands, CHANGELOG post-M19 gap.
    task-001–005: @acp.X → /acp-X standardisation (92 files), .agent/ → agent/ migration,
         install/update bootstrap scripts, legacy .agent/ auto-migration on next install.
    task-007–010: yaml AST cache bug fixed (_ast_valid() helper), set -euo pipefail guard for
         sourced scripts (BASH_SOURCE[0]==$0 check).
    task-011–012: BSD date UTC fix (date -j -u flag on macOS), 50 .prompt.md files added to
         .github/prompts/ for VS Code Copilot slash command autocomplete.
    task-146/148: 203 files removed from tracking (gitignored as instance data), YAML completed:
         frontmatter established as sole task status indicator.
    task-151–154: yaml_query scalar array emit bug fixed, test path unified to tests/fixtures/
         (95/95 yaml-parser tests pass).
    Docs session: Glossary (42 terms, 7 categories), README AI tools/persona table, USAGE.md
         memory layer breakdown, v6.4.1 patch.

  key_facts_preserved:
    - "@acp.meta.* namespace must remain unchanged — file annotation markers, not commands"
    - "macOS BSD date UTC fix: date -j -u -f '%Y-%m-%dT%H:%M:%SZ' (add -u flag)"
    - ".prompt.md in .github/prompts/ required for VS Code Copilot slash command autocomplete"
    - "Instance data (tasks/, milestones/, memory/, progress.yaml) gitignored; patterns.md distributable"
    - "POSIX awk only on macOS — gawk 3-arg match() is an extension, use sub() instead"
    - "Always update package.yaml scripts section at END of any milestone that adds commands"
    - "Memory system is NOT hands-free — each layer requires a specific user action to populate it"
    - "yaml AST cache: _ast_valid() must check BOTH YAML_CURRENT_FILE match AND temp file exists"

- date: 2026-05-05
  executor: Persona A (Copilot)
  tasks: [task-176, task-177]
  done:
    - M34-command-naming-convention-complete
    - create-agent-patterns-local-command-naming-convention-md
    - add-naming-convention-callout-to-skills-commands-md
    - cross-reference-lessons-md-acp-foo-entry-to-pattern-doc
    - mark-progress-yaml-M34-complete
  deferred: {}
  key_fact: |
    Created canonical naming convention reference at agent/patterns/local.command-naming-convention.md.
    Triple-file architecture: agent/commands/acp.NAME.md (dot) + .github/prompts/acp-NAME.prompt.md
    (hyphen) + .opencode/commands/acp-NAME.md (hyphen). Invocation always /acp-NAME with hyphen.
    @acp-foo (dash after @) is NEVER valid — only @acp.foo (dot) in directive block examples.


- date: 2026-05-05
  executor: Persona A (Copilot)
  tasks: [task-185, task-186]
  done:
    - M37-audit-007-fixes-complete
    - fix-bare-agent-drafts-in-acp-project-create-md-line-292
    - git-rm-cached-lessons-md-decisions-md-untrack-gitignored-files
    - commit-a680d2a-fix-task-185
    - commit-9d60f41-chore-task-186
    - commit-1333313-mark-M37-complete
  deferred: {}
  key_fact: |
    install-script-gitignore-heredoc-sync pattern extends to COMMAND DOCS, not just install
    scripts. acp.project-create.md embeds a sample .gitignore for new projects — that embedded
    block also needed the agent/drafts/** fix (missed in M30). Rule: when fixing a gitignore
    pattern, grep agent/commands/ for embedded gitignore blocks too, not just agent/scripts/.
    git rm --cached removes files from git index without deleting on disk. Use to stop tracking
    files that were committed before a gitignore rule was applied.
