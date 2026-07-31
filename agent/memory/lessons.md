# Correction Log — Filtered by task_type before loading
# Populated automatically when developer says "log it" or "wrong, log this"
# Max 5 entries loaded per session, filtered to current task_type + priority:high
#
# Optional fields added in v6.8.0:

- date: 2026-07-24
  task_type: audit-run
  mistake: "M81 plan used 'Supersedes (partially) ADR-19' and speculative --pr/API import + invented carryover fields before a real findings fixture existed — would reopen a DO-NOT-re-open ADR and repeat F-098-04 speculative-vendor shortcuts."
  correction: "Narrowing an adoption gate is an ADR carve-out (ADR-21 pattern), never a supersede/reopen of a DO-NOT-re-open decision. Integration parsers must be fixture-first from sanitized live exports; match live carryover ledger shape; read recurring_tasks as the single command: string they actually are."
  priority: high
  trigger: plan-amend

- date: 2026-07-23
  task_type: audit-run
  mistake: "M78 closure (audit-098) declared '8 pre-existing E2E failures, zero regression' based on a FILE-LEVEL baseline comparison. audit-099 found this masked 2 NEW assertion-level failures I introduced: the v6.28.0 bump missed agent/progress.yaml's own version: field, so cross-file version checks in tests/acp.e2e-workflow + tests/acp.security failed — but the FILES were already failing at baseline for other reasons, so the file-level count stayed 8 and hid my regression. acp-validate.ts also passed because it never checks progress.yaml version."
  correction: "Regression comparison after a change MUST be assertion-level, not file-level — a test file already failing can silently absorb a new regression. When bumping a version, enumerate EVERY version-bearing field including agent/progress.yaml project.version (not just the acp-validate-checked set identity/AGENTS/CLAUDE/CHANGELOG/package), and close the loop by running the cross-file E2E version checks, not only acp-validate.ts. When a validator misses a real inconsistency an E2E catches, fix the validator too (add the missed field) so the gap can't recur."
  priority: high

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

# Restored 2026-07-28 (audit-108): this entry had lost its `- date:` header and
# was merged into the audit-070 lesson above, where YAML last-wins silently
# shadowed that lesson. Date inherited from the block it was merged into.
- date: 2026-06-15
  task_type: version-bump
  scope: cross-cutting
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
    Every new command doc in agent/commands/*.md MUST have matching wrapper files in
    all four surfaces: .github/prompts/acp-{name}.prompt.md, .opencode/commands/acp-{name}.md,
    .cursor/commands/acp-{name}.md, .claude/commands/acp-{name}.md (run acp.cursor-commands-sync.sh
    and acp.claude-commands-sync.sh after edits). git.* commands need cursor + claude only.
    Verify with: npx tsx scripts/acp-validate.ts (parity check).
  priority: high

- date: 2026-07-15
  task_type: memory-write
  mistake: >
    New agent/memory/sessions.md entries were appended near the tail of the file
    (after existing compacted blocks) instead of prepended to the top, as
    acp.commit.md Step 2 requires ("Prepend a YAML entry"). This left the file in
    non-chronological order — a 2026-07-15 entry sat below 2026-06-15 entries —
    and wasn't caught until the next /acp-commit inspected the full file (audit-091
    session). Also surfaced: agent/.gitignore's bare `reports/` rule (not `reports/**`
    + `!agent/reports/`) silently overrides the root .gitignore whitelist — 61 of 88
    audit reports were never version-controlled, undetected because the validator's
    gitignore-conflict check only inspects already-tracked paths, never probes
    addability of new files in protocol directories.
  correction: >
    Always prepend new sessions.md entries immediately after the header comment
    block (top of file), never append near existing entries or compacted blocks.
    Separately: when fixing a gitignore bare-dir bug for one directory, grep the
    WHOLE file for other bare `dir/` rules sitting above a `!whitelist` line —
    they silently block it too (see patterns.md: install-script-gitignore-heredoc-sync,
    extended 2026-07-15 with the agent/.gitignore reports/ instance).
  priority: high

- date: 2026-07-28
  task_type: bug-fix
  mistake: >
    Four bugs shipped in v6.29.2 framework scripts, all found downstream by
    CodeRabbit on a consumer repo's PR (#13) rather than by ACP's own review or
    E2E suites. (1) Eight scanners restored positional args with
    `set -- "${IG_REMAINING_ARGS[@]:-}"`; for an EMPTY array that expands to one
    empty-string argument, not zero, so `$1=""` reached the target loop. Six of
    eight scanners were therefore completely broken when invoked with no path
    argument, exiting 2 with "Error:  not found" — a total-failure bug that 59
    passing review-scan E2E assertions never caught, because every test passed an
    explicit path. (2) SC-15's lockfile-tracking check had `return 0` on BOTH
    branches, making the entire `git ls-files` half dead code: an untracked
    lockfile passed silently. (3) JSON output was assembled with
    `sed 's/},{/},\n{/g'` — BSD sed (macOS before Darwin 25) emits a literal `n`,
    AND on every platform the pattern also matches `},{` occurring inside a
    finding message, injecting a raw newline into a JSON string literal and
    producing invalid JSON. (4) `ig_emit_finding` called `ig_baseline_add_entry`
    BEFORE the inline-suppression check, so findings silenced by an
    `acp-review-ignore` comment still entered a `--write-baseline` baseline;
    deleting the comment later would not re-surface them.
  correction: >
    Never restore positionals with `"${arr[@]:-}"` — guard on
    `${#arr[@]} -gt 0` and use a bare `set --` otherwise. Never assemble or
    reformat JSON with sed; parse it (python3) so delimiter sequences inside
    string values cannot be matched. Order suppression checks BEFORE baseline
    capture — a baseline must record only findings that are still active, or
    suppression becomes permanent and invisible. When a rule has an early
    `return 0` on every branch, the check above it is dead code: assert the
    NEGATIVE case in tests (untracked lockfile MUST fire), not just the positive.
    Above all: every scanner E2E suite must include a no-argument invocation case
    — "runs with default target" is the single most common real-world invocation
    and was untested for all eight scanners.
  priority: high

- date: 2026-07-28
  task_type: memory-write
  scope: cross-cutting
  mistake: >
    Duplicate YAML keys inside a memory entry are invisible to every check the
    repo had. An edit that deletes the FOLLOWING entry's `- date:` header merges
    two entries; `entry.includes("done:")` still passes, the entry count absorbs
    the merge, and YAML last-wins silently shadows the earlier entry's values.
    audit-108 shipped a detector and it immediately found FOUR pre-existing
    corruptions that had survived every prior /acp-validate run: a lessons.md
    entry where the audit-070 "false assurance" lesson was shadowed by a
    version-bump lesson, and three audit-carryovers entries with duplicate stamp
    keys — including one where `fix_applied_date: null` overrode a real date
    while `status: fixed`. Related failure: the first version of the detector
    itself was wrong, splitting entries on `- date:` and false-positiving on
    sessions.md's legitimate `- type: weekly-summary` compaction blocks.
  correction: >
    Treat a duplicate key as a hard failure, never a warning — silent shadowing
    is how memory actually gets lost (this is the second incident after the
    191-key progress.yaml failure). When splitting a YAML list into entries,
    split on ANY list marker (`^- [a-z_]+:`) rather than a known first key: a
    file may legitimately contain more than one entry shape. After appending to
    any memory file, verify the diff shows insertions and ZERO deletions —
    deletions mean a neighbouring entry's header was consumed.
  priority: high

- date: 2026-07-28
  task_type: audit-run
  scope: tooling
  mistake: >
    Scanning the carryover ledger with an unanchored regex
    (`re.search(r'status:\s*(\S+)', block)`) reported two false pending items.
    It matched `status:pending` occurring inside a finding's PROSE — F-099-03's
    own description reads "…remain status:pending — carryover-ledger integrity
    failure" — rather than the entry's `status:` key. Key-anchored parsing
    (`^    status:\s*(\S+)$` with re.M) gives the correct count: 0 pending.
    This is the second false positive of the same class in two audits; the first
    was the duplicate-key validator splitting sessions.md on `- date:` and
    folding legitimate `- type: weekly-summary` blocks into the prior entry.
  correction: >
    When parsing structured YAML-ish memory files, always anchor on the key at
    its exact indentation and never match bare substrings against block text —
    these files quote other entries' field names in their own prose constantly.
    Corollary for verification harnesses: do not wrap greps containing `${...}`
    or `\$` in `eval`, which expands them before grep sees them and produces
    false ❌ results. Four checks in audit-109 failed this way and had to be
    re-verified directly.
  priority: high

- date: 2026-07-28
  task_type: audit-run
  scope: cross-cutting
  mistake: >
    ADR-20 states that `hooks.<phase>[].task_id` MUST resolve to a
    `recurring_tasks[].id` and that "validation (acp-validate) can enforce that
    every hook task_id resolves to a real recurring_task". Nobody ever wrote that
    check, so 3 of 4 pre_commit hooks (pre-commit-integrity-phase1,
    ci-npm-ignore-scripts, post-milestone-sweep) pointed at ids that were never
    created — the hooks silently fired nothing from M62 until audit-110, while
    /acp-validate reported a fully clean run.
  correction: >
    An ADR that DESCRIBES an enforcement mechanism is not enforcement. When an
    ADR says a validator "can" or "will" check something, grep the validator for
    the check before treating the decision as in force; if absent, implement it
    in the same change that discovers the gap. Corollary: a clean validator run
    proves only that the implemented checks passed — it never proves the
    documented invariants hold. Cross-check ADR consequences against code
    periodically.
  priority: high

- date: 2026-07-28
  task_type: bug-fix
  scope: performance
  mistake: >
    Raised the Windows E2E per-test timeout from 180s to 600s to "fix" a suite
    that kept timing out, without first asking why a 72-assertion suite needed
    more than three minutes. It still timed out at 600s. The real cause was that
    gitleaks_active() and dupehound_active() each resolved a ~1.5s preference
    BEFORE the microsecond `command -v` availability check, so every scanner
    invocation on every platform paid ~3s for two questions whose answers could
    not change the outcome when the tools were absent. Reordering gave 18x on a
    single scan and 22x on the suite; the timeout bump was pure symptom-masking
    and would have permanently hidden the defect.
  correction: >
    Never raise a timeout before root-causing what consumes it — a timeout bump
    deletes the only signal you have. Order guard clauses cheapest-first:
    `command -v` before any preference/config/network lookup, and confirm the
    expensive call cannot change the result (here, absent tool => inactive for
    every preference value, so the reorder was provably equivalent — verified
    across all 6 states). Diagnostic: high `sys` time relative to `user` in
    /usr/bin/time -p means process/filesystem churn, not computation — profile
    subprocess calls, not algorithms. Finally, correctness gates cannot see
    performance regressions: the corpus scored 100%/100% throughout while the
    scanner was 18x slower than necessary. Add a wall-clock assertion if speed
    matters.
  priority: high

- date: 2026-07-28
  task_type: audit-run
  scope: tooling
  mistake: >
    Filed carryover A-110-06 claiming acp.review-scan.sh sources
    acp.coderabbit.sh without using it. It never sourced it. `grep -l
    acp.coderabbit.sh` matched line 485 — a CASE PATTERN inside
    is_sh_allowlisted()'s SH-01 exclusion list. The scanner sources exactly three
    files. This is the THIRD instance of the same class in three audits: the
    duplicate-key validator splitting sessions.md on `- date:` and folding
    `- type: weekly-summary` blocks into the prior entry; the carryover ledger
    scan matching `status:pending` inside a finding's prose; and now a source
    check matching a case pattern.
  correction: >
    `grep -l <filename>` answers "is this string present", never "is this file
    used". For structural questions use a structural pattern anchored to the
    construct — `^\s*(source|\.)\s+` for imports, `^    status:` for a YAML key
    at its indent, `^- ` for a list item. Before filing any finding whose claim
    is structural ("X sources Y", "X is unused", "N entries pending"), re-verify
    with an anchored pattern and read the matched line in context. A wrong
    finding in the carryover ledger is worse than no finding: it sends the next
    session to fix something that was never broken.
  priority: high

- date: 2026-07-30
  task_type: audit-run
  scope: measurement
  mistake: >
    Recorded single-sample performance measurements as facts in planning
    documents while full E2E sweeps were running on the same machine. Three
    figures were wrong: "get_preference strict 13.8s vs get_preference_or 5.5s"
    (actual 1521ms vs 1545ms — and structurally impossible, since
    get_preference_or is a 5-line wrapper that CALLS get_preference), and
    "coderabbit_active 21.5s" (actual 1439ms, wrong by ~15x, and its claimed
    13.8+5.5 decomposition was invented by the noise — the function
    short-circuits when CodeRabbit is disabled and makes ONE preference call).
    Those numbers propagated into a milestone doc, a carryover ledger entry, and
    two audit reports, and one of them was used to file a carryover as HIGH.
  correction: >
    Any performance figure that enters a planning document, carryover, or report
    must be a mean over >=5 runs on an otherwise idle machine — never a single
    sample, and never taken while other suites are running. Read the function
    before recording its cost: a wrapper cannot be slower than what it wraps, and
    that was disprovable from five lines of source. Prefer load-independent
    metrics where they exist — the ~900-fork count survived scrutiny unchanged
    while every timing around it drifted, because a count cannot be skewed by
    machine load. When correcting a propagated figure, fix every document it
    reached and annotate the original rather than silently rewriting it.
  priority: high

- date: 2026-07-31
  task_type: memory-write
  scope: tooling
  mistake: >
    Used python `t.replace(old, new, 1)` to amend the M85 notes block in
    progress.yaml across two separate turns without asserting the anchor matched.
    Both replacements silently no-opped — the anchor text had already drifted —
    and both times I reported "progress.yaml notes updated" to the user. The
    stale text (coderabbit_active 21.5s, get_preference ~2.2s) survived in the
    tracking file while I believed it had been corrected. A third attempt using a
    greedy regex with a lookahead also failed to match, again silently.
  correction: >
    Every scripted edit to a tracked file must assert its anchor matched
    (`assert t.count(old) == 1`) before writing, and must verify the result
    afterwards by grepping for a string unique to the NEW text. `.replace()` and
    `re.sub()` both return the input unchanged when nothing matches, so an
    unasserted edit is indistinguishable from a successful one — and the commit
    message then documents work that did not happen. Prefer a short unique anchor
    over a long multi-line block, since long blocks drift. Never report a file as
    updated without reading back evidence of the new content.
  priority: high
