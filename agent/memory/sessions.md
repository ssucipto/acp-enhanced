# Session Memory
# Format: YAML blocks, last 3 loaded per session, auto-compacted at 15 entries
# DO NOT edit manually — updated by /acp-commit


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [task-348]
  done: [m89-pre-impl-stamp]
  deferred:
    - F-R006-01-js-yaml-cve → review-006
    - F-124-02-pr-mainline → maintainer
  key_fact: >
    audit-127 READY. M89 current_milestone. Next 349 wiki/audit/local.*
    then --pr-diff. F-R006 out.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [audit-127, plan-amend-m89-m91]
  done: [audit-127-pre-impl, amend-plans-d14-d18]
  deferred:
    - M89-coding → task-348
    - F-R006-01-js-yaml-cve → review-006
    - F-124-02-pr-mainline → maintainer
  key_fact: >
    audit-127 BLOCKED then plans amended (design 1.1.0 D14–D18). M89 READY
    for 349+. --diff and --pr-diff combinable. pr.yml not arrays. e2e-smoke
    ≠ /acp-smoke. F-127-13 ledger hole closed. F-R006 out.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [audit-126, plan-m89-m91]
  done: [audit-126-second-round, plan-waves-a-b-c]
  deferred:
    - F-125-01-pr-diff → M89
    - F-125-05-acp-smoke → M90
    - F-125-06-exec-host → M91
    - F-R006-01-js-yaml-cve → review-006
    - F-124-02-pr-mainline → maintainer
  key_fact: >
    --pr-diff must not collide with existing --diff. Do not copy FIFOZ smoke
    1.1.0 into AE v1. M89–M91 planned (6.35–6.37); proceed starts at task-348.
    current_milestone stays M88 until proceed.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [audit-125]
  done: [audit-125-fifoz-safeiq-feedback]
  deferred:
    - F-125-01-pr-diff → plan
    - F-125-02-cr-buckets → plan
    - F-125-05-acp-smoke → later-wave
    - F-125-06-exec-host → later-wave
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
    - F-124-02-pr-mainline → maintainer
  key_fact: >
    Safe-IQ 001+002 still fully open on 6.34.0 (--pr-diff, CR buckets, audit≠CR).
    FIFOZ 2026-08-14 command wave is shipped; remaining value is smoke + exec-host.
    Do not port Expo/Maestro/AimZero tests or visualizer bugs.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [audit-124]
  done: [audit-124-post-ship, changelog-mainline-accuracy, wiki-adr28, badge-88]
  deferred:
    - merge-develop-to-mainline → maintainer
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    M88 rewrite is sound on develop and tags. GitHub default clone is still
    mainline at 6.32.4. Completeness is a regular PR, not another force-push.
    F-R006 and fork caches stay separate.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [task-347]
  done: [v6340-bump, golden-tsv, annotated-tag]
  deferred:
    - pr-develop-to-mainline → maintainer
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    M88 closed as v6.34.0 after 346 proof. History rewrite already on origin.
    Regular push of develop + annotated tag (no second force-push). F-R006
    still pending. Forks/caches may retain old objects (F-119-09).


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [task-346]
  done: [fresh-clone-keep-purge-proof]
  deferred:
    - v6340-closure → task-347
    - F-122-04-reclone-daily → task-347
    - F-122-07-v6340-golden-tag → task-347
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    Full clone /tmp/acp-fresh-m88: develop dedd874 keepers+templates; PURGE
    paths have empty git log --all --full-history. v6.33.0 still has templates.
    Forks/caches may retain old objects. Daily .git is still unre-written —
    347 commits must be made on the rewritten clone, not this worktree.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [task-345]
  done: [filter-repo-paths-from-file, force-push-develop-mainline-tags]
  deferred:
    - fresh-clone-proof → task-346
    - F-122-04-no-reclone-until-347 → task-347
    - F-122-07-v6340-golden-tag → task-347
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    Operator confirmed force-push instance-docs develop mainline tags: yes.
    Rewrite clone /tmp/acp-rewrite-m88 (--no-local, 454 PURGE paths). Forks
    and GitHub caches may retain old objects (F-119-09). Do not reclone daily
    until 347. Do not force-push the daily worktree.


- date: 2026-08-28
  executor: cursor-grok
  branch: develop
  tasks: [audit-123]
  done: [audit-123-m88-gaps, cb-4-paths-from-file, cb-3b-git-init, agent-commit-adr28, install-root-gitignore, validate-templates]
  deferred:
    - filter-repo-force-push → task-345-operator-confirm
    - F-123-03-m87-phrase-not-consent → task-345
    - F-122-04-no-reclone-until-347 → task-347
    - F-122-07-v6340-golden-tag → task-347
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    audit-123: CB-4 must invert PURGE paths via --paths-from-file, never whole
    dirs (templates would vanish from tags). M87 phrase is not M88 consent.
    Type exactly force-push instance-docs develop mainline tags: yes.


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-335, task-336, task-337, task-338, task-339, task-340, task-341, task-342, task-343, task-344]
  done: [gate-backups, citation-map, gitignore-validator, dual-store-e2e, private-pack-dirs, tip-untrack, ci-rehearsal]
  deferred:
    - filter-repo-force-push → task-345-operator-confirm
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    GATE STAMP 20260827T231053. Tip is keepers-only (git rm --cached). CI rehearsal
    validate green. Halt until exact phrase force-push instance-docs develop
    mainline tags: yes. Do not reclone daily until 347. Do not reuse the M87 phrase.


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-332]
  done: [daily-reclone, v6330-bump, f-118-stamps]
  deferred:
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
    - merge-develop-to-mainline → maintainer
  key_fact: >
    Daily worktree .git replaced from origin/develop 344b84a (0 report bodies).
    Local reports restored from Phase 0 worktree backup. M87 closed as v6.33.0.
    F-R006-* still pending. Forks/caches may retain old objects (F-119-09).


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-330, task-331]
  done: [force-push-origin-rewrite, fresh-clone-history-proof]
  deferred:
    - reclone-daily-worktree → operator
    - F-118-01-stamp → task-332
    - F-R006-01-js-yaml-cve → review-006
  key_fact: >
    Operator confirmed `force-push develop mainline tags: yes`. Origin develop
    4a7cef3, mainline d83cddc, v6.32.4 reports=0 on a new clone. Forks and GitHub
    caches may retain objects (F-119-09). Re-clone the daily worktree before 332.


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-330]
  done: [audit-121-m87-impl-gaps, f-121-cookbook-no-local, f-121-wiki-redact, f-121-integrity-hashes]
  deferred:
    - force-push-develop-mainline-tags → task-330-operator-confirm
    - F-121-03-daily-history-dirty → task-331
    - F-118-01-history-rewrite → task-331
    - F-R006-01-js-yaml-cve → review-006
  key_fact: >
    audit-121 fixed on tip except F-121-03. Canonical rewrite clone is /tmp/acp-rewrite
    (--no-local). Readiness wording is not force-push consent. Type exactly
    `force-push develop mainline tags: yes`. Forks and GitHub caches may retain objects (F-119-09).


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-328, task-329, task-330]
  done: [tip-keepers-only, private-pack-script, local-filter-repo]
  deferred:
    - force-push-develop-mainline-tags → task-330-operator-confirm
    - F-118-01-history-rewrite → task-331
    - F-R006-01-js-yaml-cve → review-006
  key_fact: >
    Local filter-repo succeeded on a throwaway clone; origin was NOT force-pushed.
    /acp-proceed --yes is not consent. Type exactly `force-push develop mainline
    tags: yes` to publish. Forks and GitHub caches may retain objects (F-119-09).


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [task-333, task-334, task-323, task-322]
  done: [m87-phase-0-backups, citation-map]
  deferred:
    - F-118-01-history-rewrite → task-330
    - force-push-develop-mainline-tags → task-330-operator-confirm
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    Phase 0 restore-tested: worktree-20260827T202952, local git mirror HEAD
    1488312 then 6e47fd9, gpg archive acp-reports-feedback-20260827T203242.
    Passphrase is off-repo chmod 600. --yes is not force-push consent.


- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [audit-120, acp-plan, task-333, task-334]
  done: [m87-pre-impl-round2, backup-first-tasks]
  deferred:
    - F-118-01-history-rewrite → task-330
    - force-push-develop-mainline-tags → task-330-operator-confirm
    - F-R006-01-js-yaml-cve → review-006
  key_fact: >
    audit-120 READY after amend. First proceed is task-333 (rsync worktree),
    then 334 (local git mirror from pwd, not GitHub), then 323 (gpg). Do not
    start 322 until those restores pass. This machine has gpg not age.

- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [audit-119, acp-plan, M87]
  done: [m87-pre-impl-audit, m87-plan-amend-cookbook]
  deferred:
    - F-118-01-history-rewrite → task-330
    - force-push-develop-mainline-tags → task-330-operator-confirm
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    audit-119 READY after amend. Use design cookbook CB-1..CB-6. git rm must
    be --cached. filter-repo on a throwaway clone; force-push phrase is
    `force-push develop mainline tags: yes`. Do not commit audit-119.

- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [acp-plan, M87, task-322, ADR-27]
  done: [m87-privacy-purge-plan]
  deferred:
    - F-118-01-history-rewrite → task-330
    - force-push-develop-mainline → task-330-operator-confirm
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
  key_fact: >
    Maintainer overrode audit-118 Class A-in-git. ADR-27: public remotes contain
    zero agent/reports and agent/feedback bodies (keepers only). Secure removal
    is filter-repo plus operator-confirmed force-push of develop and mainline.
    HEAD git rm is not enough. Do not stamp F-118-01..03 until fresh-clone proof.

- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [audit-118]
  done: [audit-118-public-repo-privacy]
  deferred:
    - F-118-01-redact-coderabbit-raw → audit-118
    - F-118-02-untrack-fifoz-design-spec → audit-118
    - F-118-03-untrack-port-inbox → audit-118
    - F-118-04-d9-1-private-class → /acp-decide
    - F-R006-01-js-yaml-cve → review-006
  key_fact: >
    Superseded by ADR-27: do not keep Class A protocol audits in git on this
    public repo. Reports/feedback bodies are local-only; history rewrite required.

- date: 2026-08-27
  executor: cursor-grok
  branch: develop
  tasks: [acp-resume, weekly-code-review, weekly-integrity-scan, monthly-dependency-audit]
  done:
    - resumed-after-13-day-gap
    - stale-push-next-step-cleared
    - integrity-003-self-scan
    - review-006-weekly-self
    - monthly-dependency-audit-clean
  deferred:
    - F-R006-01-js-yaml-cve → review-006
    - F-R006-02-bootstrap-euo → review-006
    - F-R006-03-dispatch-any → review-006
    - ig17-scanner-allowlist → polish
    - adr-19-aikido → gated
  key_fact: >
    After M81/M86 ship, develop==mainline at v6.32.4 with no coding task in_progress.
    Overdue recurring scans are the next work. js-yaml GHSA-5p4m-2wfm-xmqj is SC-14
    (review), not IG-27–32 (monthly dependency-diff).

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [F2-09, integrity-002, D-002-01, D-002-02, D-002-03, D-002-04, D-002-05, D-002-06, D-002-07, D-002-08]
  done: [f2-09-quote-aware-hash-strip, integrity-002-self-scan, d002-polish-closed, adr19-stay-gated]
  deferred: [ig17-scanner-allowlist → polish, develop-push → ops]
  key_fact: "F2-09 strip_comments must keep # inside quotes; fast-path unquoted lines or yaml_parse query perf trips the 100ms unit budget."

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [acp-validate, acp-sync, acp-update, acp-commit]
  done: [validate-clean, readme-agent-sync-m81-m86, progress-recent-work, session-commit]
  deferred: [F2-09 → backlog, weekly-integrity → admin, D-002-01-08 → polish]
  key_fact: "README still advertised 70 commands / 36 scripts after M81+M86 — sync counts (72 cmds, 56 scripts, 81 milestones) with shipped features."

- date: 2026-08-14
  executor: cursor-composer
  tasks: [audit-117, review-005, F-117-01, F-117-02, F-117-03, F-117-04, F-117-05]
  done: [m81-post-ship-audit, findings-import-json-errors, e2e-efg, v6.32.1]
  deferred: [F2-09 → backlog, weekly-integrity → admin]
  key_fact: "findings-import must catch JSONDecodeError; never let set -e ERR trap hide the parser message."

- date: 2026-08-14
  executor: cursor-composer
  tasks: [task-270, task-271, task-272, task-273, task-274]
  done: [coderabbit-fixture, findings-import, coderabbit-template, review-wiring, coderabbit-e2e, v6.32.0-m81]
  deferred: [F2-09 → backlog, D-002-01-08 → polish, weekly-integrity → admin]
  key_fact: "M81 gate fixture mixes AE coderabbit --agent NDJSON with FIFOZ inventory; import is --input only (no --pr)."

- date: 2026-08-14
  executor: cursor-composer
  tasks: [audit-116, review-004, F-116-01, F-116-02, F-116-03, F-116-04, F-116-05, F-116-06, F-116-07]
  done: [m86-post-ship-audit, m86-review-004, shellcheck-sc1125-fix, e2e-matrix-skip-network, docs-domain-drift, v6.31.1]
  deferred: [F2-09 → backlog, D-002-01-08 → post-M86, weekly-integrity → admin, M81-fixture → M81]
  key_fact: "M86 --full shellcheck was self-breaking on SC1125 (em-dash in disable comment); e2e-matrix must use --skip-network like GH Actions."

- date: 2026-08-14
  executor: cursor-composer
  tasks: [task-305, task-306, task-308, task-309, task-310, task-311, task-312, task-313, task-314, task-315, task-316, task-317, task-318, task-319, task-320, task-321]
  done: [m86-ci-baseline, fg-contracts, acp-ci, acp-pr, upgrade-guard, review-scan-merge, v6.31.0-ship]
  deferred: [feedback-002-D-002-01-08 → post-M86, M81-coderabbit-fixture → M81, F2-09 → backlog]
  key_fact: "Default /acp-ci is --fast (excludes multi-minute e2e); upgrade-guard HARD-fails version-update when upstream-delta.yml present."

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [task-316, task-317, task-318]
  done:
    - task-316-review-scan-fifoz-m83-hunk-merge
    - task-317-rule-verification-discipline-pattern
    - task-318-feedback-002-residual-matrix
    - f-114-09-carryover-fixed
  deferred:
    - D-002-01..08-feedback-002-polish → post-M86
    - task-319-package-wrappers-manifest → /acp-proceed
    - weekly-review-integrity-overdue → admin
  key_fact: >
    feedback-008 precision merged into AE M83 review-scan without blind overwrite
    (8 take-FIFOZ + 1 hybrid); proxy≠invariant captured as pattern; feedback-002
    P0 closed with 8 explicit deferred IDs for FIFOZ response.

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [audit-115, acp-plan-M86-amend, task-307]
  done:
    - audit-115-m86-pre-impl-blocked-then-ready
    - amended-f3-01-through-f3-10-into-tasks-milestone-design
    - locked-p-ug-1-hard-fail-p-ci-1-p-path-1-p-val-1
    - added-missing-carryovers-f-114-07-08-11
    - task-307-complete-m86-in-progress
  deferred:
    - task-305-ci-baseline → /acp-proceed
    - task-306-fg-contracts → after-305
  key_fact: >
    audit-115 found the M86 plan would still allow fail-open shortcuts and a
    wrong scripts/ path, and could close without the review-scan merge. Amendments
    lock HARD upgrade-guard, agent/scripts/acp.ci-steps.sh, executed_steps
    validator work, and DAG edges 314←310, 319←316, 321←316+317. Coding starts
    at task-305, not 308.

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [acp-plan-M86, audit-114]
  done:
    - planned-m86-fifoz-field-feedback-port-17-tasks
    - wrote-design-and-adr-24-25-26
    - milestone-86-with-bindings-and-anti-shortcuts
    - progress-yaml-m86-planned-current-milestone-stays-m81
    - audited-fifoz-feedback-ingested-inbox-staged
  deferred:
    - implement-from-task-305 → /acp-proceed
    - m81-coderabbit-fixture → ops
  key_fact: >
    M86 plans the real FIFOZ deltas only (ADR-24/25/26): measure CI before
    tiering, abstract /acp-ci, /acp-pr must delegate gates, upgrade-guard for
    fork regression visibility, review-scan diff-merge — never re-port
    SHA-identical commands or paste Expo CI bodies. Pre-impl audit (307) gates
    coding. Target v6.31.0; current_milestone remains M81.

- date: 2026-08-14
  executor: cursor-composer
  branch: develop
  tasks: [audit-114]
  done:
    - audited-fifoz-agent-feedback-001-through-009-plus-port-guide
    - verified-implementations-against-ae-tree-sha-identical-vs-missing
    - ingested-new-feedback-into-agent-feedback
    - staged-portable-snapshots-in-fifoz-port-inbox
    - wrote-audit-114-and-f-114-carryovers
    - listed-acp-plan-preparation-for-m86
  deferred:
    - implement-acp-ci-pr-upgrade-guard → M86-/acp-plan
    - merge-review-scan-fifoz-delta → M86
  key_fact: >
    FIFOZ port guide's "six unreported commands" are a manifest-count false
    positive — integrity/review/carryover-query/rule-file-audit/session-sync/
    pattern-sync docs are byte-identical in ACP Enhanced. Real gaps: /acp-ci,
    /acp-pr (with CI gate delegation), upgrade-delta+guard (regression answer),
    and feedback-009 false-green bash/CI contracts. Do not blind-copy Expo CI
    bodies. Visualizer feedback-003/004 stay out of this repo.

- date: 2026-08-02
  executor: claude-sonnet
  branch: develop
  tasks: [ci-green-check]
  done:
    - fixed-preexisting-ci-only-flake-in-acp-project-workflow-test-sh
  deferred: []
  key_fact: >
    User asked to confirm CI green before pushing develop -> mainline. The
    F2-08 push (b53456d) still failed CI Checks — same e2e-smoke failure as
    the PRIOR commit (fa89446), so unrelated to F2-08. Root cause:
    acp.project-workflow.test.sh Test 4 asserts three consecutive
    acp.project-set.sh calls produce distinct last_accessed timestamps, but
    that field has 1-second resolution and the three switches (each just a
    fast bash script + yaml_parse/query) can complete within the same
    wall-clock second on a fast CI runner — passed locally 49/49 both before
    and after the real fix because local overhead happened to exceed 1s
    between switches, which is exactly why it's a flake and not caught
    locally. Fixed by adding `sleep 1` before switches 2 and 3 in the test
    (test-only change, no product code touched). Re-verified 49/49 locally.
    Note: M85 (just completed) made yaml_parse 3-4x faster, which plausibly
    made this pre-existing race easier to hit — worth remembering as a
    pattern: perf work can unmask latent timing assumptions in unrelated
    tests.

- date: 2026-08-02
  executor: claude-sonnet
  branch: develop
  tasks: [F2-08]
  done:
    - f2-08-dim-unbound-var-fixed-and-3-more-bugs-found-fixing-it
    - e2e-acp-package-install-list-18-of-18-passing-first-ever-green-run
  deferred: []
  key_fact: >
    F-113 carryover F2-08 (${DIM} unbound var, medium) looked like a one-line
    fix but e2e/acp.package-install-list.test.sh had literally never passed —
    each bug was masking the next one under it. Chain: (1) DIM never assigned
    in init_colors(), (2) SKIPPED_COUNT and INSTALLED_COUNT used via += but
    never initialized, (3) `for file in "${FILES_TO_PROCESS[@]}"` breaks under
    bash 3.2's (macOS default /bin/bash) set -u empty-array quirk, (4) the
    is_experimental=$(grep|grep|grep|grep -v|head) pipeline aborted the whole
    script under set -o pipefail whenever a file had NO experimental marker —
    the normal case — because grep legitimately exits 1 on no-match and
    pipefail propagates the *first* non-zero exit in the pipe, not just the
    last command's. Root cause this went undetected so long: this was the
    ONLY e2e test file for acp.package-install.sh, so no other suite ever
    exercised the plain (non-experimental) file path under set -u+pipefail.
    Fixed all 4; 18/18 assertions now pass (first-ever green run for this
    suite). F2-09 (quote-unaware comment stripping in acp.yaml-parser.sh)
    remains open, deliberately out of scope for this fix.

- date: 2026-08-02
  executor: claude-sonnet
  branch: develop
  tasks: [M85-phase3, task-304]
  done:
    - task-304-complete-a-110-04-05-07-stamped-fixed
    - m85-milestone-complete-8-of-8-tasks
    - 3-consecutive-green-e2e-runs-all-3-platforms-confirmed
    - fixed-3-real-bugs-in-task-300-own-equivalence-test
  deferred: []
  key_fact: >
    M85 is complete: 8/8 tasks, A-110-04 (coderabbit_active 58ms, was 646ms),
    A-110-05 (get_preference 45ms, was 854ms), and A-110-07 (macOS E2E flake,
    root cause was A-110-05) all stamped fixed in audit-carryovers.md.
    Closing task-304 required proof beyond a single green run — 3 CONSECUTIVE
    green E2E runs across all 3 platforms (not just macOS): 6559ae1/30707045524,
    def196d/30707352192, 7e95a2d/30707596784.
    Getting even the FIRST green run required fixing three real, unrelated bugs
    in task-300's own equivalence test (from the prior session) that blocked
    every E2E run regardless of A-110 status: (1) BSD `wc -l < file` (macOS,
    used by get_next_node_id) right-pads its count with leading spaces; GNU
    `wc` (Linux CI) doesn't — the golden fixture baked in macOS-only padding.
    (2) bash `read` treats tab as "IFS whitespace" REGARDLESS of custom IFS,
    so `IFS=$'\t' read -r a b c d e f <<< "$line"` collapses consecutive tabs
    (adjacent empty fields, which map/array AST nodes have) and silently
    shifts every field after the first empty one — this was a LATENT bug that
    happened to produce matching (wrong) output on both sides of the
    comparison locally, so it never surfaced until platform differences from
    fix (1) made the two wrong answers diverge from each other. Fixed by
    parameter-expansion splitting instead of `read`, mirroring
    _yaml_split_node's existing technique. (3) agent/integrity-manifest.yaml
    is rewritten in place by e2e/acp.integrity.test.sh running in the same
    parallel suite — a genuinely nondeterministic file, excluded rather than
    chased. Separately, windows-latest needed its own fixes: a path embedded
    inside a python3 -c string doesn't get Git Bash's automatic POSIX-to-
    Windows path translation (only whole command-line arguments do), and a
    <100ms perf assertion that was never validated against Windows CI's
    higher process-spawn overhead (raised to 250ms) — plus, even after both
    fixes, the equivalence suite still timed out at 180s under Windows'
    parallel-suite contention and was added to run-e2e-tests.sh's existing
    _acp_windows_skip_suite() list (same mechanism already used for
    acp.yaml-parser.test.sh and acp.preferences-validate.test.sh).
    Process lesson: a "passing" test that happens to be wrong on both sides
    of a comparison is a real risk in differential/equivalence testing —
    the bug here was caught only because a platform difference (macOS vs
    Linux wc padding) broke the coincidental cancellation. Worth deliberately
    injecting a known-bad value and confirming a differential test still
    catches it, not just trusting a clean run.
    current_milestone reverted to M81 (unchanged blocker: CodeRabbit fixture,
    ADR-22) — M85 was tracked as a parallel priority-4 item throughout.

- date: 2026-08-01
  executor: claude-sonnet
  branch: develop
  tasks: [M85-phase2, task-300, task-301, task-302, task-303]
  done:
    - task-300-parser-equivalence-complete
    - golden-fixture-regression-test-74-of-74-files-verified
    - discovered-add_child-sed-i-o-n-squared-cost-outside-m85-scope
    - task-301-pref-resolver-complete
    - acp.pref-resolve.py-stdlib-only-28-of-28-tests-pass-41ms-median
    - task-302-wired-fast-path-with-bash-fallback
    - coderabbit-helpers-memoised-active-646ms-to-65ms
    - task-303-wall-clock-perf-gate-450ms-budget-median-of-5
  deferred:
    - task-304 -> next-session
  key_fact: >
    task-300 could not be implemented as literally specified (re-run the pre-M85
    parser against every tracked YAML file on every CI invocation) — measured
    directly, dumping the whole repo's AST with the pre-M85 parser did not finish
    in 5 minutes. Root cause: add_child rewrites the entire growing AST_FILE with
    sed -i on every child appended, in BOTH the old and current parser, untouched
    by M85's field-access optimisation — O(n^2) in node count. agent/progress.yaml
    (9,480 lines / 7,880 nodes) alone takes ~100s to parse even with the CURRENT
    optimised parser. Solution: captured the pre-M85 parser's AST output ONCE into
    a committed golden fixture (tests/fixtures/yaml-parser-equivalence/pre-m85-ast.golden.tsv,
    74 files, 964K), and the committed test now only ever runs the current (fast)
    parser, diffing against that fixture — 73 files / 79s in the *.test.sh CI
    suite, agent/progress.yaml covered separately by
    tests/acp.yaml-parser-equivalence-large.sh (not *.test.sh, same
    not-in-the-fast-suite convention as acp.yaml-parser-perf.sh). Result: 74/74
    files verified, 56 divergences found and all individually confirmed
    attributable to the F-112-01 `|` fix — including an unanticipated case,
    agent/index/*.yaml files using `description: |` YAML block-scalar syntax
    (unsupported by this parser, so the literal value IS "|"), which shifted the
    old cut-based field boundaries the same way a `|` mid-string does. Zero
    unexpected divergences.
    task-301 also complete this session: acp.pref-resolve.py is a line-for-line
    stdlib-only reimplementation of yaml_parse/yaml_query and get_preference
    precedence (no PyYAML — confirmed absent in this environment). 28/28 new
    tests pass — every real preference key agrees with bash exactly (value AND
    exit code), a synthetic 4-layer fixture proves project > workspace > user >
    configurables precedence, the configurables `.default` suffix quirk (F2-02)
    is verified against a sibling `description` field so a naive uniform lookup
    would be caught, flat-dot fallback reproduced including its
    strip-all-whitespace-not-just-edges behaviour. Median 41-46ms vs the 854ms
    bash baseline, well under the <100ms target. Process note: acp.preferences.sh
    reassigns the global SCRIPT_DIR var unconditionally when sourced — a test
    script using that same variable name for its own paths will have them
    silently overwritten; use a different variable name when sourcing it
    alongside other path computation.
    task-302 also complete: get_preference now tries the task-301 resolver
    first (_pref_fast_path_available, mirrors node_scan_modules_available),
    falling back to the original bash walk — left fully intact — on
    resolver absence or an unexpected exit code. Verified byte-identical
    across 7 keys with python3 truly unresolvable (a minimal PATH excluding
    it, not just an empty PATH — macOS ships a python3 stub in /usr/bin that
    a naive PATH swap won't hide). _coderabbit_enabled and config_path are
    now memoised per-process (matches _ACP_GITLEAKS_PREF_CACHE); confirmed
    safe against yaml_set staleness because nothing in the codebase calls
    set_preference and coderabbit_active in the same process.
    e2e/coderabbit-optionality 13/13 in ~0.9s (was paying 646ms+ per call);
    coderabbit_active median ~65ms (target <200ms); preferences-validate
    19/19 in 26s, unchanged.
    task-303 also complete: acp.review-measure.sh --ci now times a
    single-file corpus scan (median of 5) and fails when it exceeds
    --perf-budget-ms (default 450, ~4.4x headroom over audit-110's measured
    103ms isolated figure). This directly closes the audit-110 blind spot —
    the recall/precision corpus gate scored 100%/100% throughout an 18x
    scanner slowdown because correctness gates can't see performance
    regressions. Verified: fails at an artificially low budget (10ms) with a
    message naming the budget/observed/audit-110; passes at the real budget
    with headroom (300-360ms measured, full subprocess path incl. bash
    startup, higher than the isolated 103ms parser figure but still well
    under 450ms); never fails without --ci. Documented in acp.review.md
    beside the existing corpus table; ci.yaml step renamed, no new step
    needed (the existing --ci invocation already runs it). task-304 is
    next, unblocked.

- date: 2026-07-31
  executor: claude-opus
  branch: develop
  tasks: [M85-phase1, task-297, task-299, task-298, plan-amend]
  done:
    - m85-phase-1-complete-3-of-8
    - parser-1498-to-320-forks-yaml_parse-3.5x
    - f-112-01-fixed-root-cause-f2-06-duplicate-create_node
    - task-298-array-cache-rejected-on-evidence
    - a-110-07-fixed-at-root-159s-to-28s
    - phase-2-re-scoped-against-measured-numbers
  deferred:
    - task-300-304 -> next-session
    - f2-08-dim-unbound -> outside-m85
    - f2-09-hash-in-quoted-value -> outside-m85
  key_fact: >
    M85 Phase 1 landed: 1498 -> 320 forks per parse (79%), yaml_parse 3384 -> 966ms
    on the fixture and 1369 -> 360ms on the real preference file. The win came
    entirely from replacing cut/grep/awk/sed with bash parameter expansion —
    byte-identical at every step, verified by diffing AST files across 30 tracked
    YAML files. F-112-01 (values containing `|` truncated) is fixed; the root cause
    was NOT what audit-112 recorded — create_node was DEFINED TWICE and bash kept
    the non-escaping definition (F2-06). task-298's array cache was REJECTED on
    evidence: it targeted ~19 of 635 forks (3%) for a staleness hazard across 10
    mutation sites, so the same safe technique went to the bigger targets instead.
    Side effect: preferences-validate 159s -> 28s, fixing A-110-07 at the root.
    Re-measured afterwards: the <150ms yaml_parse criterion is NOT reachable in
    pure bash (remaining wc/sed -i forks need state that cannot cross the $( )
    boundaries create_node is invoked through), so it was amended to the measured
    floor; and Phase 2 is CONFIRMED still needed because get_preference is 854ms.
    Process failure worth remembering: two turns reported progress.yaml notes as
    updated when the .replace() had silently no-opped — assert every scripted edit.

- date: 2026-07-30
  executor: claude-opus
  branch: develop
  tasks: [audit-113, plan-m85-amend-r2]
  done:
    - audit-113-round2-on-own-amendments
    - task-305-merged-into-299-circular-dep-removed
    - task-301-layer-model-corrected-configurables
    - noise-derived-measurements-corrected-across-docs
    - a-110-04-downgraded-to-medium
  deferred: []
  key_fact: >
    Round 2 pre-impl audited round 1's OWN amendments and found 5 findings, all
    defects in my round-1 output. (1) The task-305 I added was CIRCULAR: task-299
    declared depends_on:[task-305] while task-305 step 3 said the reader fix was
    "unblocked by task-299's splitter" — an implementer would have written the
    reader twice, the exact failure the split claimed to prevent. Merged into one
    atomic task. (2) task-301 specified a 4-layer model naming _pref_default_file,
    which does not exist; the real 4th layer is _pref_configurables_file and reads
    a DIFFERENT key shape (${ns}.${path}.default) — a uniform resolver would
    return empty where bash returns a value. (3) Several figures were single
    samples taken while E2E sweeps ran: "get_preference_or 5.5s vs strict 13.8s"
    was structurally impossible (the former is a 5-line wrapper CALLING the
    latter — 1521ms vs 1545ms measured), and "coderabbit_active 21.5s" was wrong
    by 15x (actual 1439ms, one preference call since it short-circuits when
    disabled). Those wrong numbers had propagated into the milestone doc, a
    carryover, and two audit reports as fact. What survived: yaml_parse 1369ms
    (mean/7 vs 1370ms recorded) and the ~900-fork count — a count cannot be
    skewed by load. Rule adopted: any perf figure entering a planning doc must be
    a mean over >=5 runs on an idle machine, and read the function before
    recording its cost.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [m84-backfill, audit-112, plan-m85-amend]
  done:
    - m84-milestone-record-backfilled
    - audit-112-pre-impl-m85-ready-with-3-amendments
    - f-112-01-pipe-truncation-found-in-live-ast-writers
    - m85-amended-task-305-added-297-299-300-revised
  deferred: []
  key_fact: >
    /acp-audit --pre-impl M85 Phase 2 found a HIGH correctness bug inside the very
    functions M85 was about to rewrite: the live AST writers
    (acp.yaml-parser.sh:444,:484) emit records with NO escaping, so any YAML value
    containing `|` is silently truncated — `piped: "a|b|c"` returns `"a`. 19 files
    source this parser including acp.install.sh and acp.package-install.sh.
    Worse, add_node() IS the only function that escapes `|` and has ZERO call
    sites — dead code — so task-299 had told the implementer to read it as the
    encoding authority, which would have produced false confidence. Worst of all,
    task-300's "byte-identical output" gate would have PERMANENTLY ENSHRINED the
    bug, because the corrected behaviour differs from the old truncated output.
    Three amendments applied: task-305 added (fix writer+reader together, before
    task-299), task-300 equivalence scoped modulo the pipe fix, task-297 fixture
    must contain a pipe value so the fix shows as a diff not a claim.
    Lesson: a pre-impl audit earns its keep on the cross-reference phase — the
    plan's every number was right and it was still about to cement a bug.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [plan-m85]
  done:
    - m85-planned-8-tasks-3-phases
    - parser-fork-cost-quantified-900-forks-per-parse
  deferred:
    - m84-milestone-record-missing -> flagged-to-maintainer
  key_fact: >
    M85 planned from audit-110/111. Quantified the defect before planning:
    parsing a 106-line file spawns ~1,428 traced subprocesses (~900 real forks —
    tr 270, cut 264, sed 233), because get_node() does `sed -n Np` per node
    (yaml-parser.sh:78) and get_field() pipes to cut per field (:84, 39 such
    sites). Reading one field of one node costs two forks; 19 files source this
    parser. Maintainer chose BOTH the bash-native parser rewrite and a python3
    preference fast path, plus a wall-clock corpus gate. Phase 2 is gated on
    task-300 proving byte-identical output first. Also found: M84 shipped in
    v6.29.1/6.29.2 and is referenced in prose but has NO milestone entry in
    progress.yaml — numbering gap, left for the maintainer to decide.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [audit-111]
  done:
    - readiness-verified-for-mainline-merge
    - a-110-06-retracted-as-false-positive
    - a-110-04-risk-framing-corrected
  deferred:
    - a-110-04-05-07 -> preference-layer-work
  key_fact: >
    Readiness check found my own audit-110 finding A-110-06 was FALSE:
    acp.review-scan.sh never sourced acp.coderabbit.sh — `grep -l` had matched a
    case pattern in is_sh_allowlisted()'s SH-01 allowlist. Retracted, and
    A-110-04's risk downgraded (coderabbit_active is unreachable from the
    scanner). Third substring-vs-structure error in three audits. Merge decision:
    mainline baseline is macOS+Windows RED; develop is macOS red only, so the
    merge strictly improves CI — Windows goes red->green for the first time. The
    remaining macOS failure is one suite (preferences-validate, 159s vs a 180s
    limit) tracked as A-110-07, root-caused to A-110-05, and not caused by these
    commits.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [audit-110]
  done:
    - windows-timeout-root-caused-to-preference-ordering
    - gitleaks-dupehound-availability-short-circuit-plus-memoisation
    - windows-600s-timeout-band-aid-reverted
  deferred:
    - coderabbit-21s-memoisation -> A-110-04
    - get_preference-13.8s-profile -> A-110-05
    - unused-coderabbit-source -> A-110-06
  key_fact: >
    The Windows E2E timeout was never a Windows problem or a hang. Every scanner
    invocation spent ~3s asking whether two optional analyzers were ENABLED
    before checking whether they were INSTALLED — gitleaks_active() and
    dupehound_active() each resolved a ~1.5s preference first, then ran a
    microsecond `command -v`. When the tool is absent the answer is "inactive"
    for every preference value, so the expensive call could never change it.
    Reordering took a single-file scan 2.95s -> 0.16s (18x) and
    acp.review.test.sh 66s -> 3s (22x); the 600s Windows timeout added hours
    earlier was then reverted as a symptom fix. The tell was sys=1.78s of a 2.95s
    run — high system time means process/filesystem churn, not computation.
    Why nobody noticed: the corpus gate measures recall/precision, never time, so
    a scanner 18x slower than necessary still scores 100%/100%.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [audit-110, validate-sync-update-commit]
  done:
    - adr-20-hook-binding-violation-found-and-enforced
    - three-dangling-precommit-hooks-resolved
    - validate-step-2g-documented
    - progress-recent-work-and-next-steps-updated
  deferred:
    - marker-coverage-24-percent-repo-wide → out-of-scope-m66-rescope
  key_fact: >
    /acp-validate passed clean, but a manual ADR-20 cross-check found 3 of 4
    `hooks.pre_commit` task_ids in constraints.yml resolved to nothing —
    pre-commit-integrity-phase1, ci-npm-ignore-scripts and post-milestone-sweep
    were never added to recurring_tasks. ADR-20 explicitly says validation "can
    enforce that every hook task_id resolves to a real recurring_task"; nothing
    ever did, so the hooks silently fired nothing since M62. Added the 3 registry
    entries plus validateHookTaskBindings(). Lesson: an ADR that describes an
    enforcement mechanism is not enforcement — grep for the check before trusting
    the decision. Also measured: @acp.meta marker coverage is 277/1171 (~24%)
    repo-wide, not the "100% across 232 files repo-wide" sessions.md claims —
    M66 covered entity docs only (scripts 2/51, commands 0/73, reports 0/115).

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [audit-108-remediation]
  done:
    - progress-yaml-strict-parse-gate-restored
    - sc2046-eliminated-across-review-and-integrity-suites
    - suppressed-write-audit-mutating-class-now-empty
    - package-update-remove-flag-made-literal-and-symmetric
  deferred: []
  key_fact: >
    loadProgressSafe() caught js-yaml's duplicate-key exception, printed a
    WARNING, and fell back to line-based parsing — so the original 191-key
    progress.yaml incident would recur with a green CI exit code. A resilience
    fallback that swallows the error it was built for is not resilience, it is a
    disabled check; the fallback now stays for other checks but a strict-parse
    gate fails the run. Audited all 70 `2>/dev/null || true` sites in
    agent/scripts: the mutating-write class (the A-108-07 class) is now empty —
    the rest are read-only probes, optional copies, or idempotent chmod.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [audit-108, G-107-02, G-107-07, G-107-08]
  done:
    - audit-108-today-work-gap-analysis-and-review
    - all-three-audit-107-carryovers-closed
    - memory-duplicate-key-gate-shipped-with-unit-tests
    - four-preexisting-memory-corruptions-repaired
    - corpus-fixtures-tracked-fresh-clone-verified
    - package-update-sed-newline-replaced-with-awk
  deferred:
    - integrity-test-sc2046-findings -> pre-existing-out-of-scope
  key_fact: >
    Building the G-107-02 duplicate-key validator immediately exposed FOUR real
    pre-existing memory corruptions that every prior validation had passed: a
    lessons.md entry where the audit-070 lesson was silently shadowed by a
    version-bump lesson that lost its `- date:` header, and three
    audit-carryovers entries with duplicate stamp keys — one where
    `fix_applied_date: null` overrode a real date while `status: fixed`.
    YAML last-wins makes this class invisible: every key-presence check passes
    and the entry count absorbs the merge. The validator must FAIL, not warn.
    Second lesson: my first implementation of that validator was itself wrong,
    splitting on `- date:` and false-positiving on sessions.md's legitimate
    `- type: weekly-summary` compaction blocks — split on any list marker.

- date: 2026-07-28
  executor: claude-opus
  branch: develop
  tasks: [F-107-01, F-107-02, F-107-03, F-107-04]
  done:
    - upstream-port-of-coderabbit-pr13-findings
    - positional-args-fix-across-8-scanners
    - sc15-lockfile-tracking-check-repaired
    - json-array-formatting-desed-portable-helper
    - baseline-capture-moved-after-inline-suppression
    - regression-tests-b34-b37-added
  deferred:
    - executor-default-change → rejected-upstream-see-key_fact
  key_fact: >
    CodeRabbit findings on a DOWNSTREAM consumer repo (PR #13) were real upstream
    bugs in ACP's own v6.29.2 scripts — 3 of 4 ported back here; the 4th
    (task.schema.yaml executor default deepseek-v4-flash → composer-2.5) was
    correctly REJECTED upstream: composer-2.5 appears nowhere in
    routing/taxonomy.yml, so that fix encodes the consumer's model policy and
    belongs in the consumer's overrides, not in the framework default.
    Finding #1 was materially worse upstream than reported: 6 of 8 scanners
    aborted on a bare no-argument invocation (verified by e2e B26, which fails
    on exactly those 6 at HEAD). 59 review-scan E2E assertions
    passed throughout because every one passed an explicit path.

- date: 2026-07-28
  executor: cursor
  branch: develop
  tasks: [audit-106, release-prep-v6.29.2]
  done:
    - validate-sync-update-release-prep
    - prd-main-domain-progress-version-sync
    - mainline-pr-readiness-confirmed
  deferred:
    - m81-implementation → coderabbit-fixture-gate
  key_fact: "v6.29.2 ready for develop→mainline PR: M83+M84 shipped, zero pending carryovers, validate clean after tag."

- date: 2026-07-28
  executor: cursor
  branch: develop
  tasks: [audit-106, M84, F-105-01, F-106-01, F-105-02, F-101-02, F-101-03, F-101-05, F-101-06]
  done:
    - audit-106-m84-remediation-committed
    - v6-29-2-patch
    - rule-override-preload-all-emitters
    - e2e-b32-b33-override-paths
    - review-doc-scanner-limitations-coderabbit-augmentation
    - all-actionable-carryovers-closed
  deferred:
    - m81-implementation → coderabbit-fixture-gate
  key_fact: "audit-106 closed M84 shortcuts: ig_parse_common_args + manifest-hash preload overrides; B32/B33 E2E; PyYAML stderr warning; F-101 doc-level carryovers fixed. M81 script implementation still blocked on real fixture."

- date: 2026-07-27
  executor: cursor
  branch: develop
  tasks: [task-283, task-284, task-285, task-286, task-287, task-288, task-289, task-290, task-291, task-292, task-293, task-294, task-295, task-296]
  done:
    - m83-complete-17-of-17-tasks
    - v6-29-0-shipped
    - tier-c-rules-expansion-38-deterministic
    - gitleaks-dupehound-optional-helpers
    - review-corpus-100-percent-recall-precision
    - adr-23-local-analyzer-carve-out
  deferred:
    - m81-270-274 → coderabbit-fixture-gate
  key_fact: "M83 COMPLETE: /acp-review scanner from ~8% recall to measured 100% on 30-case corpus; ~38 deterministic rules; optional gitleaks/dupehound/shellcheck; baseline+inline suppression. v6.29.0 shipped. current_milestone remains M81 (fixture gate)."

- date: 2026-07-27
  executor: cursor
  branch: develop
  tasks: [task-280, task-281, task-282]
  done:
    - m83-phase1-scanner-scope-and-executing-e2e
    - m83-phase1b-lexing-and-eh01-token-match
    - f-102-01-02-03-08-fixed
    - f-103-01-02-fixed
    - f-104-03-04-06-07-fixed
    - review-scan-fixtures-committed
  deferred:
    - m83-283-284 → finish-phase-1b-1c-before-phase-3
    - m81-270-274 → coderabbit-fixture-gate
  key_fact: "Phase 1+1b.282: TARGETS[]/--self/.mjs + executing E2E (28 asserts); lexing via acp.review-scan-ts.py (SC-01 comment-only so secrets still match); EH-01 uses \\btry\\b. Next: task-283 then 284 measure. Do not start Phase 3 until 283+284 land."

- date: 2026-07-27
  executor: claude
  branch: develop
  tasks: []
  done:
    - audit-102-deterministic-review-gap-analysis
    - audit-103-measured-precision-recall-and-standards
    - m83-planned-17-tasks-6-phases
    - audit-104-pre-impl-readiness-with-amendments
    - f-104-01-through-07-amendments-applied
  deferred:
    - m83-implementation → handoff-cursor
    - m81-270-274 → coderabbit-fixture-gate
  key_fact: "/acp-review Phase 1 measured at ~8% recall / 0% precision on seeded fixtures; multi-path arg bug silently scanned only the last path, masking 2 HIGH findings in scripts/. EH-01 substring test 'try' not in body is disabled by retry/telemetry/entry. M83 (17 tasks) fixes correctness then precision then measures BEFORE expanding — phase 3 gated on 1b+1c. audit-104 found _index: array omission would silently drop new preference keys (no validator covers it)."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - f-m82-01-through-07-remediated
    - e2e-cross-layer-and-optionality-hardening
    - js-yaml-4-3-0-audit-clean
  deferred:
    - m81-270-274 → fixture-gate
    - coderabbit-workflows-cli-chunk → optional-rate-limit
  key_fact: "M82 findings F-M82-01..07 fixed: SCHEMAS_DIR+gh execFileSync, project-update tags loop, sweep token message, SH-01 allowlist, js-yaml 4.3.0; e2e CLI chunk done; workflows still rate-limited."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-275, task-276, task-277, task-278, task-279]
  done:
    - m82-local-thorough-review-campaign
    - review-002-coderabbit-cli-chunks
    - f-m82-01-through-07-carryovers
  deferred:
    - m82-e2e-workflows-cli-chunks → F-M82-06
    - m81-270-274 → fixture-gate
  key_fact: "M82 closed: Phase1+CodeRabbit CLI (2/4 chunks; rate-limited remainder). 7 carryovers F-M82-01..07. CLI does not satisfy ADR-22 M81 fixture. current_milestone remains M81."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-269]
  done:
    - task-269-adr22-policy-map-lite
    - acp-validate-clean
    - m81-status-synced-in-progress-1-of-6
    - changelog-unreleased-m81-wip
  deferred:
    - m81-270-274 → fixture-gate
    - aikido-m76-m77 → adr-19
  key_fact: "M81 halted after task-269: need tests/fixtures/coderabbit-findings-sample.json before 270+; ADR-22 carve-out live; F-101-01/04/07/08 fixed; pending F-101-02/03/05/06 for import/wiring tasks."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-269, task-270, task-271, task-272, task-273, task-274]
  done:
    - audit-101-f101-findings-folded-into-m81-plan
    - task-269-ungated-for-adr22
    - m81-ready-for-implementation-after-fixture
  deferred:
    - m81-270-274 → fixture-gate
    - aikido-m76-m77 → adr-19
  key_fact: "M81 plan amended per audit-101: ADR-22 carve-out (not supersede); task-269 ungated; findings-import v1 is --input fixture only; weekly-code-review is single command:/optional wrapper; Phase 1 never deferred to CodeRabbit."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - audit-101-m81-pre-impl-readiness
    - f-101-01-through-08-carryovers-written
  deferred:
    - m81-plan-amend-f101 → before-acp-proceed
    - m81-gate-artifact-findings-fixture → consumer-export
    - aikido-m74-m77 → deferred-cost
  key_fact: "M81 READY WITH AMENDMENTS (audit-101): carve ADR-22 out of ADR-19 (never supersede); fixture-first --input import only; weekly-code-review is a single command string; Phase 1 rules never defer to CodeRabbit; ungate task-269 for ADR writing."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: []
  done:
    - acp-validate-clean-post-m80
    - acp-sync-handoff-completed-progress-notes-refreshed
  deferred:
    - m74-m77-coderabbit-pr-check → adr-19-gate
  key_fact: "ADR-19 gates M74–M77 integration milestones (not tool install) until CodeRabbit + Aikido run on a Rygan repo with 2+ weeks of real findings; M78 optionality foundation shipped separately per ADR-21."

- date: 2026-07-24
  executor: cursor
  branch: develop
  tasks: [task-265, task-266, task-268]
  done:
    - m80-e2e-debt-remediation-shipped-v6-28-2
    - f-m78-01-closed-68-68-e2e-suite
    - audit-100-carryovers-f-100-01-through-05-settled
    - test-side-fixes-workflow-cross-layer-validate-ts
    - behavior-reconcile-version-package-info-project-update-sweep
  deferred:
    - m74-m77-coderabbit-pr-check → adr-19-gate
    - crit-065-002-merge-pr3 → mainline
  key_fact: "F-M78-01 closed with honest code-vs-test triage (no blind greening): validate-cross-layer needed conditional package.yaml copy + milestone awk; validate-ts needed isolated 5-surface parity dirs; version-check-for-updates needed ${1:-} under set -u; project-update needed current_tags init before ADD_TAGS block."

- date: 2026-07-24
  executor: claude-opus-4-8
  branch: develop
  tasks: [task-255, task-256, task-257, task-258, task-259, task-260, task-261, task-262, task-263, task-264]
  done:
    - m78-coderabbit-optionality-foundation-shipped-v6-28-0
    - m79-closure-integrity-remediation-shipped-v6-28-1
    - audit-099-caught-own-version-regression-honest-correction
    - audit-100-m80-preimpl-5-findings-folded
    - m80-planned-3-tasks-after-task-267-removed
  deferred:
    - m80-implementation → cursor-executor-handoff (tasks 265,266,268)
    - m74-m77-coderabbit-pr-check → adr-19-gate
    - crit-065-002-merge-pr3 → mainline
  key_fact: "Regression comparison MUST be assertion-level, not file-level — audit-098 declared M78 'zero regression' by file-count but audit-099 found the v6.28.0 bump missed agent/progress.yaml's version: field, adding 2 assertion failures inside already-failing test files. Fix incl. a validator gap: acp-validate.ts now checks progress.yaml version (it caught a YAML corruption I introduced mid-fix). M80 = 7 pre-existing E2E failures (root-caused audit-099) + F-100-03 auto-sync trap (copilot-instructions.md regenerated from AGENTS.md)."

- date: 2026-07-23
  executor: claude-opus-4-8
  branch: develop
  tasks: []
  done:
    - audit-097-optional-coderabbit-distributed-framework-lens
    - plan-m78-optionality-foundation-6-tasks-255-260
    - adr-21-coderabbit-optionality-carved-out-of-adr-19-gate
    - adr-20-backfill-hooks-task_id-array-format
    - audit-098-preimpl-7-findings-folded-into-m78
  deferred:
    - m78-implementation → acp-proceed-complete (this session, next)
    - m74-m77-pr-check-findings-import → adr-19-adoption-gate
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "acp.preferences.sh sources acp.common.sh, so optional-tool detection helpers that call get_preference must live in a dedicated script (acp.coderabbit.sh) sourcing preferences.sh — never in common.sh (circular source). Caught in pre-impl audit-098 before any code was written. Also: ADR-19 gates CodeRabbit *integration* (PR-check/findings-import); the *optionality foundation* (toggle+detection+docs) is a separate non-gated concern (ADR-21)."

- date: 2026-07-17
  executor: copilot
  branch: develop
  tasks: []
  done:
    - validate-all-clean-v6-27-2
    - agent-md-legacy-version-sync
    - adr-19-m74-gate-documented
  deferred:
    - m74-plan → adr-19-adoption-gate
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "AGENT.md legacy header was 15 minors stale (6.12.1) while AGENTS.md/identity were 6.27.2 — hard validators only check AGENTS.md, not AGENT.md."

- date: 2026-07-17
  executor: copilot
  branch: develop
  tasks: []
  done:
    - validate-sync-update-chain-clean
    - readme-badge-drift-fixed-v6-27-2
    - research-direction-docs-on-develop
  deferred:
    - crit-065-002-merge-pr3 → mainline
    - f-086-02-fifoz-consumer → task-239
  key_fact: "README version badge was soft drift (6.21.1) invisible to hard validators — acp-validate.ts only checks AGENTS/identity/package/CHANGELOG, not README shields.io URL."

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-248, task-249, task-250, task-251, task-252, task-253, task-254]
  done:
    - m73-autonomous-complete-v6-27-1
    - carryover-integrity-restored-audit-095-closure
    - manifest-scripts-tracked-validate-clean
  deferred:
    - crit-065-002-branch-protection → github-admin
    - f-086-02-fifoz-consumer → task-239
  key_fact: M73 v6.27.1 closed audit-094 gaps; integrity-manifest now tracks agent/scripts; validate 0 errors (branch protection warn only).

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-240, task-241, task-242, task-243, task-244, task-246, task-247]
  done:
    - m72-autonomous-complete-audit-093
    - validator-hardening-5-surface-parity
    - v6-27-0-tagged
  deferred:
    - crit-065-002-branch-protection → admin-ops
  key_fact: M72 shipped v6.27.0 with ROOT-anchored validator; CRIT-065-002 remains pending (gh api 404).

- date: 2026-07-15
  executor: copilot
  branch: develop
  tasks: [task-245]
  done:
    - claude-integration-committed-adr-18-2b92528
    - sessions-compaction-f-091-08
    - monthly-dependency-audit-refreshed-f-091-09
    - task-245-hygiene-phase-complete
  deferred:
    - m72-validator-tasks → task-240-241
    - crit-065-002-branch-protection → task-246
  key_fact: "task-245 guardrail #9 satisfied — Claude tree committed (2b92528) before validator edits; acp.dependency-diff.sh 0 findings; sessions compacted to ≤8 entries."

- date: 2026-07-15
  executor: claude-code
  branch: develop
  tasks: [audit-091, plan-m72, audit-092, plan-m72-amendment]
  done:
    - audit-091-whole-system-gaps-standards-14-findings
    - m72-milestone-planned-design-8-tasks-8-routes-committed
    - audit-092-pre-impl-m72-readiness-ready-with-4-amendments
    - discovered-f-091-14-agent-reports-gitignore-blackhole-mid-report-commit
    - m72-amended-per-audit-092-d9-d10-guardrails-10-11-closure-renumbered-093
    - f-092-01-02-03-04-carryovers-stamped-fixed-plan-level-audit-093-verifies
  deferred:
    - m72-validator-implementation → task-240-247
    - crit-065-002-branch-protection → task-246
    - f-086-02-fifoz-consumer → task-239
  key_fact: "F-091-14: agent/.gitignore bare reports/ blocked 61 audit reports from git; sessions prepend protocol violation fixed; task-245 hygiene unblocks M72 validator work."
  commits: [1a1dc70 "plan(M72)", 57c0464 "audit(092)", ad29c3c "plan(M72) amend", 2b92528 "feat(claude)"]

# === Compacted Block: 2026-07-15 (10 sessions) ===
- type: weekly-summary
  week: 2026-07-15
  key_facts:
    - "M71 remediation shipped v6.26.0 — memory schema enforcement, 8-rule review scanner, atomic-write (audit-090)."
    - "audit-086 stamped 21 stale carryovers; acp.recurring-complete.sh added."
    - "v6.25.2 review/integrity remediation — acp.review-scan.sh Phase 1, integrity-manifest split."
    - "M63 amendment v6.25.1 — tier3 E2E dynamic loop; audit-083/084 closed."
    - "M68 safe install/update v6.24.1; M67 handoff v6.23.0."
    - "progress.yaml 191 duplicate YAML keys fixed — js-yaml parse restored."
  tasks_completed: [task-231..238, audit-086, review-001, route-207, route-206, route-198..205, route-190..197, validate-sync-update]

# === Compacted Block: 2026-06-08 – 2026-06-15 (6 sessions) ===
- type: weekly-summary
  week: 2026-06-15
  key_facts:
    - "M61 autonomous completion shipped as v6.20.7. Audit-075 found 6 issues including YOUR_ORG placeholder (HIGH), stale version footer (MEDIUM), unpinned trufflehog violating IG-67 (HIGH). Post-audit: 15 shortcuts caught across 3 rounds (E2E smoke-only tests, tsc never ran, no recent_work entries, stale versions). All fixed."
    - "Four maintenance commands (audit-074, validate, sync, update) found 7 items: missing CHANGELOG, stale milestone statuses, 3 carryovers not fixed. All resolved."
    - "M65 completed: progress.yaml had systemic duplicate YAML keys causing js-yaml parse failures; validate.ts now uses line-based fallback. Cross-layer validator caught 12 stale milestone docs."
    - "Glossary was missing 6 M58 Phase 2 terms. Validated: 48/48 terms."
    - "Taint heuristics must use file-level flow analysis for indirect source-to-sink — line-level patterns miss 50% of calibration fixtures."
    - "grep treats leading -- as flags — E2E assert_contains with needle '--phase2' silently fails. Use descriptive substring without leading dashes."
    - "M64 (integrity gateway v1.1): E2E EXIT trap variable collision (FIXTURE_DIR reused) destroyed committed fixtures. Fix: separate TEMP_FIXTURE_DIR + INTEGRITY_FIXTURE_DIR with trap cleared after B3."
    - "M59 closed silent correctness bugs: routing.yml overwrite, package.yaml gaps, CI no-op. 6 routes shipped as v6.14.0."
    - "Audit-070 proved /acp-integrity v1.0 gives false assurance (~18/55 rules implemented, entropy scanner crashes). M64 (gateway truth/test) must ship before M58 v2.0."
    - "M57: v1-to-v2 audit cycle pattern caught 26 errors across two specs. Discipline: audit AGAINST live codebase, not the spec itself."
    - "M57 autonomous implementation (5 routes, route-150..154): recurring_tasks block shipped in progress.yaml + schema; 91/91 E2E assertions. Even a small milestone benefits from the same 3-round audit discipline (059 cross-milestone, 060 pre-impl, 061 post-impl) as larger ones — 0 new bugs found because implementation followed pre-established M55/M56 patterns. Discipline prevents bugs, not just catches them."
    - "M60 (route-165/166): 8 E2E test suites created in one milestone (init/proceed/plan/dispatch/commit/validate/audit/route); integrity rule count fixed to exact 70; CONTRIBUTING.md created. CRLF line endings on Windows require tr -d '\\r' before bash execution."
    - "M62 (7 routes): 17 scripts upgraded to set -euo pipefail (0 bare remaining); 7 memory-layer schemas enforced; 5 audit-062 carryovers resolved; 7 cross-file consistency validators + post-milestone-sweep script deployed as post-M61 shortcut prevention. Pre-commit hook caught ACP rule changes on commit."
    - "M66 marker backfill: 100% @acp.meta.* coverage across 232 files (from 3.9%) via scripts/acp-backfill-markers.py — unlocked meta-scan inventory, validate probes, and acp-sync traceability maps repo-wide."
    - "audit-073 (M65 followup): cross-subagent audit catches what solo audit misses — a subagent found 19 findings vs my own 8, including E2E gaps and carryover status drift."
  tasks_completed: 34


# === Compacted Block: 2026-02-16 – 2026-06-08 (20 sessions) ===
- date: 2026-06-08
  executor: copilot
  compacted: true
  tasks: [route-131..158, audit-018..061, M39..M57, design-specs, stakeholder-reports]
  done:
    - compacted-block-see-summary
  summary: |
    Feb 16 – Jun 8, 2026 (20 sessions compacted 2026-06-15):

    Feb–Mar: M1–M18 — ACP foundation. Commands infrastructure, package management system
    (install, list, info, search, update, remove, validate, publish), package development
    system (YAML schema, namespace utilities, entity creation), global package installation,
    project registry (7 management commands), preferences system (8 tasks, 13 bugs fixed),
    template source files, benchmark suite (8 tasks + LLM evaluator), sessions system,
    cross-platform CI (macOS + Linux), key file index, clarification capture, design
    reference, artifact commands, index semantic entry types.

    Mar–Apr: M24–M38 — Protocol hardening. AGENTS.md completeness, preferences bug fix
    sprint (CRITICAL yaml_query misuse), three-persona deployment model, distribution
    readiness fixes, opencode command parity, upstream integration audit, drafts convention
    fix, E2E test coverage, AGENT.md protocol docs, pluggable driver system, command naming
    convention, acp-validate.ts enhancement, gitignore completeness, protocol knowledge
    preservation (WAL pattern), git branch awareness (Step 1b safety check).

    May: M39–M48 — Audit-driven improvements. Pre-implementation audit protocol (--pre-impl
    4-phase mode), taxonomy gap fixes, dispatch integrity + validation hardening, feedback
    integration rounds (001–005). Memory integrity release: commit auto-sync, repair tools,
    memory YAML validation. Carryover resolution + workflow hardening.

    Jun 1–8: M49–M57 — Command ecosystem spine. Dogfooding resolution (Windows + Cursor),
    install fixes, design-spec command (arc42/C4/IEEE/ISO), stakeholder report command,
    bootstrap install fix. M55: /acp-review shipped (64 rules). M56: /acp-integrity v1.0
    shipped (55 rules, 6 bash scripts, LLM/Script Boundary Rule). M57: Recurring tasks
    scheduler shipped (5 tasks, Step 4.5 protocol, pre-commit hooks).

    Audits conducted: 018–061 (44 audits across all milestones). Key architectural decisions:
    command-doc-as-spec (M55), LLM/Script Boundary Rule (M56), WAL proactive memory writes
    (M38), confidence ceiling model (M58 planned), cadence-only scheduler (M57).
  key_facts_preserved:
    - "Run /acp-sync after every milestone — 3 core E2E suites were missing from domain.yml"
    - "Three rounds of pre-impl audit catch gaps invisible in planning — never skip"
    - "Post-impl audit catches bugs pre-impl audit can't — shell injection, trap ERR, counters"
    - "v1→v2 spec audit cycle: write spec → audit → fix ALL → publish v2 — caught 26 errors"
    - "Command doc IS the spec — separate spec files create version drift (audit-052)"
    - "Deterministic tasks use bash scripts, not LLM reasoning — 100% accuracy at $0 cost"
    - "Context overflow is silent — write sessions.md at moment of discovery (WAL pattern)"
    - "Never use set -e without trap ERR in bash scripts"
    - "Never write bash that breaks on macOS (BSD sed, date differences)"
    - "Python subprocess calls must use os.environ — never string-interpolate variables"
