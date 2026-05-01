# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high

- date: 2026-05-01
  task_type: command-doc-writing
  mistake: >
    When creating command files from command.template.md, the @{namespace}-{command-name}
    placeholder in the pretend-context line (line 4) was never replaced with the actual
    command name in 9 command files (acp.plan, acp.proceed, acp.package-create, etc.).
    The main directive line (line 3) was correctly filled in, but not line 4.
  correction: >
    When authoring or reviewing a command file, check BOTH line 3 (main directive)
    AND line 4 (pretend-context) for template placeholders. Both must have the actual
    command name (e.g. @acp.plan), not @{namespace}-{command-name}.
  priority: high

- date: 2026-05-01
  task_type: shell-scripting
  mistake: >
    M19 fixed yaml_get API misuse in acp.preferences.sh (read path) but did NOT fix
    set_preference() write path — it still writes flat-dot keys (e.g. "  plan.draft.create_mode: val")
    which yaml_get cannot traverse. Also, the production preference files (acp.default.yaml,
    preset files) were left in flat-dot format; only test fixtures were migrated to nested YAML.
  correction: >
    Added _flat_dot_get() fallback to get_preference, get_preference_source, and
    get_preference_with_preset so BOTH flat-dot and nested YAML preference files work.
    Future task (M20 candidate): rewrite set_preference() to write nested YAML so
    round-trip set→get works with yaml_get alone.
  priority: high

- date: 2026-05-01
  task_type: shell-scripting
  mistake: >
    When fixing yaml_query → yaml_get in acp.preferences.sh (M19), only migrated
    test FIXTURE files to nested YAML. Did not migrate production preference files
    in agent/preferences/ (acp.default.yaml and 3 preset files). Both must be in sync.
  correction: >
    Always update BOTH test fixtures AND production data files when changing YAML format
    expectations. Production pref files are at agent/preferences/<ns>.*.yaml — check them
    every time the yaml_get path traversal semantics change.
  priority: high

- date: 2026-05-01
  task_type: command-doc-writing
  mistake: >
    The .agent/skills/commands.md canonical pattern used "@acp-foo" (dash) instead of
    "@acp.foo" (dot) in the directive block example — the wrong separator for the ACP
    dot-notation command naming convention.
  correction: >
    Commands always use dot notation: @namespace.command-name. Dash is never used
    between namespace and command name. Verified correct: @acp.init, @acp.proceed, etc.
    Skill file now corrected; check this whenever reading the commands skill.
  priority: high

- date: 2026-05-01
  task_type: e2e-test-write
  mistake: >
    37 out of 52 commands have no E2E test file. The constraint says every command
    needs an E2E test. Many are pure-LLM commands with no script binding (so
    automated testing is hard), but 8 commands with real script bindings
    (package-create, package-install, package-publish, package-validate,
    preferences-create/set/show/validate) also lack E2E coverage.
  correction: >
    When creating a command that has a Scripts: binding, immediately create an
    e2e/<command-name>.test.sh as part of the same task. Pure-LLM commands
    (Scripts: None) should at minimum have a smoke test that checks the command
    doc is well-formed and the directive header is correct.
  priority: normal
