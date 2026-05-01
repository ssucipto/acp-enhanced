# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit

- date: 2026-05-01
  executor: architect
  tasks: [task-51, task-17]
  done:
    - pattern-reading-in-6-commands
    - pattern-create-command-verified
  deferred: {}
  key_fact: |
    All project tasks now complete (M1-M18 + M6). No remaining not_started tasks.
    Pattern reading steps: each command gets its own contextual step (2.75, 1.6, 1.5, 4.5, 2.6).
    task-17 (@acp.pattern-create) was already implemented as LLM directive — no script needed.


- date: 2026-05-01
  executor: Persona A (Copilot)
  tasks: [task-71, task-72, task-73, task-74, task-75]
  done:
    - M20-milestone-created
    - fix-9-directive-headers-hyphen-to-dot
    - fix-body-text-hyphen-refs-in-5-commands
    - fix-agent-md-directory-tree-comments
    - add-13-missing-commands-1-script-to-package-yaml
    - add-changelog-entry-for-afcf61d
    - update-progress-yaml-M20
    - commit-and-push-393d9e6
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

