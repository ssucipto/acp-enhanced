# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

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
