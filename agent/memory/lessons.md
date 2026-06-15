# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high
#
# Optional fields added in v6.8.0:

- date: 2026-06-15
  task_type: all
  mistake: "Autonomous mode (M61) took 4 shortcuts: route-172 tests were only return-type checks (not behavioral), tsc --noEmit never ran, Layer 1 token budget unverified, A3.5 full test suite never ran"
  correction: "After audit completion: always run the milestone sweep checklist literally — file existence check is not a substitute for running the test suite. Always write behavioral tests for filter/slice/cap functions, not just type checks. Always run tsc --noEmit on any TypeScript change. Always verify stated budget constraints with actual byte counts."
  priority: high

- date: 2026-06-15
  task_type: all
  mistake: "Autonomous mode (M61) took 6 additional shortcuts: (1) progress.yaml had no recent_work entry for M61+audit-075 completion — the session wasn't recorded in tracking; (2) next_steps stayed stale pointing to M61 instead of M62; (3) milestone-61 doc kept the original planning version v6.16.0 in success criteria instead of the actual shipped v6.20.9; (4) milestone verification gate (npm audit / Windows CI / secret scan) was never explicitly documented — tasks said 'done' but the gate checklist was blank; (5) .gitignore had a blanket `reports/` glob that also matched `agent/reports/`, forcing `-f` on every audit report commit; (6) .ts/.json files had no LF enforcement in .gitattributes despite being cross-platform build artifacts (tsc, vitest, npm)"
  correction: "Always write a recent_work entry in progress.yaml for every milestone completion and audit — they are the primary tracking record. Always update next_steps to reflect the next milestone, not the one just done. Always update the milestone doc's target version in the success criteria block to match the actual shipped version. Always replace 'TBD' verification gate checklists with actual pass/fail/⏳ results — don't leave them blank. If a .gitignore pattern blocks files that command docs say should be committed, whitelist the path explicitly. Add .ts and .json to .gitattributes LF enforcement when setting up TypeScript tooling."
  priority: high

- date: 2026-06-15
  task_type: all
  mistake: "Autonomous mode (M61) took 5 more shortcuts in Round 3: (1) None of the 7 version bumps (v6.20.3–v6.20.9) had git tags created — `git tag --list` was empty; (2) progress.yaml M61 master entry still used planning version v6.16.0 instead of shipped v6.20.9; (3) sessions.md M61 entry was frozen after Round 1, missing Round 2 fixes; (4) CHANGELOG v6.20.9 was frozen after Round 1, missing Round 2+3 fixes; (5) M62 target version mismatch — milestone doc/progress.yaml said v6.17.0 but next_steps said v6.21.0"
  correction: "Always create an annotated git tag as part of every version bump — it is the primary artifact connecting CHANGELOG to commit. If missed, create retroactive tags immediately. Keep progress.yaml master entries synced to actual shipped versions, not planning estimates. Expand sessions.md key_fact when post-entry fixes occur. Extend CHANGELOG entries for post-bump commits — do not leave them frozen. Ensure milestone doc, progress.yaml, and next_steps all agree on target version."
  priority: high
#   status: active       # Default if absent. active = load normally
#   status: archived     # Archived lessons are skipped by getFilteredLessons()
#   superseded_by: "constraints.yml:key"  # Reference to what now encodes this knowledge

- date: 2026-06-15
  scope: backend-bash
  task_type: audit
  lesson: |
    Taint-flow heuristics that only match direct sink calls (e.g. redirect(req.query))
    miss indirect flows (target = req.query.url; redirect(target)). Always add
    file-level fallbacks with sanitization negation (ALLOWED, path.resolve, isAllowedWebhook).
    Also: IG-49 file-level env+fetch heuristic must skip files with URL validation helpers.
  priority: high

- date: 2026-06-15
  scope: cross-cutting
  task_type: audit
  lesson: |
    When auditing a framework that splits tracked framework-data from
    gitignored instance-data, ALWAYS cross-check .gitignore (or run
    git check-ignore) before reporting a file as "missing". Audit-065
    flagged decisions.md and reports 052-064 as critical structural gaps;
    both are gitignored instance data (agent/.gitignore:5,34) that auto-create
    on first use. Second rule: ALWAYS open the source files you cite as code
    pointers — audit-065 cited acp-dispatch.ts:191 and package.json without
    reading them, missing a routing.yml data-loss bug (updateRoutingYml full
    overwrite) and an orphaned CI validator. A pointer without a read is a guess.
  priority: high

- date: 2026-06-07
  scope: backend-bash
  task_type: ci-cd-setup
  lesson: |
    YAML parser EXIT traps delete AST_FILE in subshells. Both
    init_ast() and the script-footer set 'trap cleanup_ast EXIT'.
    When yaml_query/yaml_set ran inside $(...) subshells, the
    subshell inherited the EXIT trap. On subshell exit, cleanup_ast
    deleted AST_FILE — in the parent process. All subsequent YAML
    operations failed with "No such file or directory". Fix: remove
    ALL EXIT traps. Cleanup happens in init_ast() before each new
    yaml_parse call. The final temp file leak is acceptable (OS
    cleans /tmp/). This was macOS-specific (bash subshell trap
    inheritance differs from GNU bash on Linux).
  priority: high

- date: 2026-06-07
  scope: testing
  task_type: ci-cd-setup
  lesson: |
    Shared fixture directories cause parallel E2E race conditions.
    Tests writing to tests/fixtures/* subdirs corrupt each other's
    data when run in parallel. Fix: use mktemp -d per test run,
    not hardcoded paths. Four tests had this issue.
  priority: high

- date: 2026-06-07
  scope: testing
  task_type: ci-cd-setup
  lesson: |
    $$ (parent PID) is NOT unique across parallel workers. All
    workers share the same parent PID. Tests using
    HOME="/tmp/acp-test-$$-$RANDOM" could collide when $RANDOM
    matched. Fix: use HOME="$(mktemp -d)/test-name" for truly
    unique isolation. Four tests needed this fix.
  priority: high

- date: 2026-06-07
  scope: testing
  task_type: ci-cd-setup
  lesson: |
    Generated files (manifest.yaml, node_modules/) missing in CI
    cause test failures. Add CI setup steps to generate them
    (cp template → manifest, npm install) before running E2E.
  priority: normal

- date: 2026-06-15
  scope: code-integrity
  task_type: audit-run
  lesson: "Audit-070 proved /acp-integrity v1.0 gives false assurance (~18/55 rules implemented, entropy scanner crashes on findings). Ship M64 gateway truth/test before M58 v2.0 semantic analysis — Phase 2 on an untested v1 gateway compounds false confidence."
  priority: high
  source: session-key-fact

  lesson: |
    Version bumps MUST update 8 files: AGENT.md, identity.yml, package.yaml,
    progress.yaml, CHANGELOG.md, README.md, PRD-MAIN.md, IP_REGISTER.md. No
    automated consistency check existed — 3 stale files found at 6.8.2 post-M48.
    Fix: added Step 2c Version Consistency Check to acp.validate.md v2.3.0.
    Hard requirements (AGENT, identity, package) fail on mismatch. Soft
    requirements (README, CHANGELOG, PRD, IP_REGISTER) warn. Rule: always
    run /acp-validate after version bumps.
  priority: high
  status: active

- date: 2026-05-09
  task_type: all
  status: archived
  superseded_by: "constraints.yml:context_overflow_commit_first"
  mistake: >
    Multiple sessions of knowledge (audit reports, ADRs, bug fix docs, patterns) were
    permanently lost when context window overflow terminated sessions before /acp-commit
    could be run. The TikrFlow project (feedback-001) lost 3 sessions of work:
    audit-40 (14 findings), audit-41 (19 findings), 6 ADRs, 8 patterns, and a Firestore
    index bug fix. Retroactive reconstruction took a full additional session with permanent
    nuance loss. Root cause: /acp-commit was framed as a passive end-of-session act, with
    no proactive triggers for mid-session knowledge events.
  correction: >
    ACP commits must be PROACTIVE, not reactive. Write session entries, lessons, and
    patterns at the moment of discovery — not at session end. Specific triggers:
      1. After every audit report is created → write session entry + lessons to .md files
      2. After every git commit with >5 files → treat as phase boundary → write session entry
      3. When a correction is given → write lesson IMMEDIATELY, acknowledge in response
      4. When a new pattern emerges → append to patterns.md before continuing
      5. When context window approaches capacity → write all pending ACP entries FIRST
    The /acp-commit command should be used to FINALIZE a session that already has most
    of its entries written, not as the sole moment of capture.
    Updated files: AGENTS.md + CLAUDE.md (Mid-Session Commit Triggers table + Step 4
    gap-check), constraints.yml (6 new knowledge-preservation rules),
    acp.commit.md v1.1.0. See audit-008 for full analysis.
  priority: high

- date: 2026-05-05
  task_type: upstream-sync
  mistake: >
    When writing task-155 (upstream feature parity matrix), the initial Implementation
    section only referenced the upstream CHANGELOG as the source of truth. This risks
    the executing agent assigning HAVE/PARTIAL/PORT/DEFER from high-level CHANGELOG
    summaries instead of reading actual command docs, script code, and milestone files.
    For macOS compat (task-156), the original step said "does it use bash 4+ features?"
    without mandating that the agent read and cite the actual script source.
  correction: >
    For any upstream sync task: read actual upstream source files first — in priority
    order: AGENT.md → agent/commands/*.md → agent/scripts/*.sh → agent/milestones/*.md
    → sampled agent/tasks/ → agent/design/*.md — then use CHANGELOG only as a
    cross-reference for version numbers. For macOS compat checks: read the actual script
    source and cite the specific bash 4+ construct (mapfile, readarray, declare -A, etc.)
    by line — never guess from feature names. See agent/skills/upstream-sync.md for
    the full encoded methodology.
  priority: high

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
    The agent/skills/commands.md canonical pattern used "@acp-foo" (dash) instead of
    "@acp.foo" (dot) in the directive block example — the wrong separator for the ACP
    dot-notation command naming convention.
  correction: >
    Commands always use dot notation: @namespace.command-name. Dash is never used
    between namespace and command name. Verified correct: @acp.init, @acp.proceed, etc.
    Skill file now corrected; check this whenever reading the commands skill.
    See agent/patterns/local.command-naming-convention.md for the full reference.
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

- date: 2026-05-11
  task_type: command-doc-update
  mistake: >
    During M39 acp-commit, routes 014-017 were force-added to git before their
    `completed:` field was stamped. The stamp step in /acp-commit auto-stamps
    routing task files, but the git add had already captured the unstamped state.
    Routes 018-021 (M40) were correctly stamped before commit.
  correction: >
    Always stamp `completed: [date]` in all route files BEFORE running `git add`.
    The correct order: (1) fill in `completed:` in each route-NNN.md, (2) git add -f,
    (3) git commit. Never add route files to staging before stamps are applied.
    Verify with: grep "^completed:" agent/routing/tasks/route-*.md before committing.
  priority: high

- date: 2026-05-11
  task_type: command-doc-update
  mistake: >
    When implementing acp.audit.md v1.1.0 --pre-impl mode (route-019), the
    "Phase Summary" table (finding counts per phase) was omitted from the report
    format template in Step 3b. The route-019 acceptance criteria explicitly required
    "--pre-impl report format adds 'Phase Summary' table (finding counts per phase)".
    This was only caught by the pre-push audit (#12).
  correction: >
    When implementing a command doc that specifies a report format, read ALL
    acceptance criteria line-by-line and verify each table/section mentioned is
    present in the implementation before closing the route. For --pre-impl mode:
    Phase Summary table must appear after Phase 4 and before Readiness Verdict.
  priority: normal

- date: 2026-05-11
  task_type: command-doc-update
  mistake: >
    acp.visualize.md was added to agent/commands/ but no corresponding
    .github/prompts/acp-visualize.prompt.md or .opencode/commands/acp-visualize.md
    was created. The command was therefore invisible to VS Code Copilot and opencode
    users. Caught during audit-013 milestone completion check.
  correction: >
    Every new command doc in agent/commands/*.md MUST have a matching prompt file
    in .github/prompts/ and .opencode/commands/. When creating a command file,
    immediately create both companion files as part of the same task. Verify with:
    diff <(ls agent/commands/*.md | grep -v template | ...) <(ls .github/prompts/...)
  priority: high
