# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high

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
