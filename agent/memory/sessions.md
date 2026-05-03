# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-05-03
  executor: Persona A (Copilot)
  tasks: [audit-001]
  done:
    - ran-acp-audit-full-task-and-bug-inventory
    - fixed-task-template-id-placeholder-bug-01
    - fixed-task-002-corrupted-title-bug-02
    - fixed-task-006-missing-completed-date-bug-03
    - fixed-awk-3arg-match-macos-incompatible-project-remove-bug-04
    - fixed-package-list-global-test-wrong-manifest-path-bug-05
    - wrote-audit-report-agent-reports-audit-001
    - pushed-3b528b5
  deferred:
    - git-commands-old-syntax-in-display-available-commands: BUG-06-needs-design-decision
    - preferences-tests-fail-under-e2e-runner: task-011
    - 10-remaining-e2e-failures: task-011
    - untracked-test-fixtures-gitignore: BUG-09-minor
  key_fact: |
    macOS ships BSD awk (POSIX only). Three-argument match($0, /regex/, arr) is a gawk
    extension — it fails silently with exit code 2 on macOS. Replace with two sub() calls
    on a key copy: `sub(/^  /, "", key); sub(/:.*/, "", key)`. Always use POSIX awk
    in any script expected to run on macOS. Added pattern: posix-awk-key-extraction.

- date: 2026-05-03
  executor: Persona A (Copilot)
  tasks: [task-007, task-008, task-009, task-010]
  done:
    - fix-display-available-commands-50-commands-7-categories
    - fix-yaml-parser-test-hang-group-7-set-e-root-cause
    - fix-set-preference-nested-yaml-round-trip-yaml-ast-cache-bug
    - fix-namespace-placeholders-and-scripts-path-prefix-command-docs
  deferred: {}
  key_fact: |
    AST cache bug found: yaml_get/yaml_get_nested/yaml_has_key/yaml_get_array only checked
    YAML_CURRENT_FILE match, not whether AST temp file still exists. A nested subshell can
    delete the temp file via cleanup_ast EXIT trap while parent sees stale YAML_CURRENT_FILE.
    Fixed with _ast_valid() helper checking both conditions. Also: scripts with set -euo pipefail
    must guard with BASH_SOURCE[0]==$0 to prevent polluting sourcing test shells.

- date: 2026-05-03
  executor: Persona A (Copilot)
  tasks: [task-001, task-002, task-003, task-004, task-005]
  done:
    - unify-command-syntax-at-acp-dot-to-slash-acp-hyphen-92-files
    - migrate-dot-agent-hidden-dir-into-agent-directory
    - update-install-update-scripts-acp-enhanced-context-layer
    - fix-e2e-test-assertions-update-skill-files-slash-notation
    - auto-migrate-legacy-dot-agent-on-install-or-update
  deferred: {}
  key_fact: |
    ACP Enhanced standardisation complete. @acp.X → /acp-X across 92 files (task-001).
    .agent/ hidden dir fully merged into agent/ (task-002). Install/update scripts now
    bootstrap agent/core/, skills/, wiki/, routing/, memory/ (task-003). Legacy .agent/
    projects auto-migrated on next install or update with create-if-absent semantics (task-005).
    @acp.meta.* namespace must remain unchanged — file annotation markers, not commands.

- date: 2026-05-01
  executor: Persona A (Copilot)
  tasks: [task-129, task-130, task-131, task-132]
  done:
    - M23-milestone-created
    - rebrand-AGENT-md-title-to-acp-enhanced
    - add-fork-and-maintained-by-metadata
    - add-acp-enhanced-whats-new-section-15-enhancements
    - rewrite-toc-14-to-24-entries
    - expand-core-commands-6-to-40-plus-10-categories
    - rename-what-is-acp-and-how-to-use-sections
    - bump-version-6.2.3-to-6.2.4
    - add-changelog-6.2.4-block
    - commit-and-push-c380f52
  deferred: {}
  key_fact: |
    AGENT.md was distributed as original-ACP docs; M23 rebranded it as ACP Enhanced fork.
    Key changes: 15-enhancement What's New table, ToC 14→24 entries, Core Commands 6→40+
    in 10 categories with (ACP Enhanced) labels. Always keep ToC in sync with body sections.
    Post-M23 audit found 6 gaps → planned as M24.

- date: 2026-05-01
  executor: Persona A (Copilot)
  tasks: [task-126, task-127, task-128]
  done:
    - M22-milestone-created
    - fix-AGENT-md-directory-tree-remove-ghost-add-7-missing-dirs
    - fix-AGENT-md-stale-acp-install-ref-to-package-install
    - fix-AGENT-md-unacp-install-to-acp-uninstall
    - add-bash-safety-anti-patterns-to-scripts-AGENTS-md
    - bump-version-6.2.2-to-6.2.3
    - add-changelog-6.2.3-block
    - update-progress-yaml-M21-complete-M22-complete
    - commit-and-push-52e05ee
  deferred: {}
  key_fact: |
    Fourth audit (documentation accuracy) found 3 fix categories:
    1. AGENT.md tree had ghost agent/files/ and was missing 7 real dirs (artifacts, benchmarks,
       clarifications, feedback, schemas, scripts, template files at agent/ root)
    2. AGENT.md had @acp.install stale ref (now @acp.package-install) and unacp.install.sh
       (should be acp.uninstall.sh)
    3. scripts/AGENTS.md bootstrap template was missing 2 bash-safety anti-patterns that existed
       in .github/copilot-instructions.md — always keep bootstrap template in sync with project instance

- date: 2026-05-01
  executor: Persona A (Copilot)
  tasks: [task-76, task-77, task-78, task-79, task-80]
  done:
    - M21-milestone-created
    - fix-9-unfilled-template-placeholders-in-pretend-context
    - fix-readme-curl-url-main-to-mainline
    - bump-version-6.2.1-to-6.2.2-in-3-files
    - add-7-missing-scripts-to-package-yaml
    - add-changelog-6.2.2-block
    - update-progress-yaml-M21
    - commit-and-push-d5a4f8d
  deferred: {}
  key_fact: |
    Third audit (functional readiness) found 5 critical categories:
    1. @{namespace}-{command-name} unfilled in 9 command pretend-context lines (template never filled in)
    2. README.md curl URL used main branch (doesn't exist) — onboarding 404 for all new users
    3. Version not bumped in 3 metadata files after M20
    4. 7 scripts in agent/scripts/ absent from package.yaml scripts section
    5. No [6.2.2] CHANGELOG block for M20 fixes
    Lesson: When creating commands from command.template.md, ALWAYS replace @{namespace}-{command-name}
    in BOTH the main directive line AND the pretend-context line.
    Rule for new milestones: check package.yaml scripts section matches ALL files in agent/scripts/


  deferred:
    - set_preference-flat-dot-write-still-unresolved: future-M21-candidate
    - blog-00001-acp-intro-hyphen-notation: out-of-scope-intentional
  key_fact: |
    Second audit found 5 bug categories missed by first audit:
    1. 9 directive headers with @acp- hyphen (LLM-critical: teaches wrong notation)
    2. 5 command files with @acp- in body text (examples, related, troubleshooting)
    3. AGENT.md tree comments with hyphen (#@acp-init etc.)
    4. 13 commands + 1 script absent from package.yaml (M6/M7/M15/M16 never synced)
    5. CHANGELOG missing post-M19 audit entry (afcf61d undocumented)
    Lesson: package.yaml must be updated at the END of every milestone that adds commands.
    agent/skills/commands.md @acp-foo example is intentional generic placeholder — do NOT change.

