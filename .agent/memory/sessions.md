# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

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
    .agent/skills/commands.md @acp-foo example is intentional generic placeholder — do NOT change.

