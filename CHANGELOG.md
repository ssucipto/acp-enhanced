# Changelog

All notable changes to the Agent Context Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added (M81 — in progress, not shipped)
- **ADR-22** — CodeRabbit-only M81 carved out of ADR-19’s Aikido-coupled gate (task-269).
- **Policy map lite** — `agent/wiki/coderabbit-policy-map-lite.md` (Phase 1 never deferred to CodeRabbit).
- Wiki/config/research roadmap points to M81/ADR-22 for CodeRabbit consumers; Aikido/M76/M77 stay ADR-19-gated.

### Notes
- Tasks 270–274 blocked until `tests/fixtures/coderabbit-findings-sample.json` (sanitized real export) exists. Planned ship: **v6.30.0** (M81; v6.29.0 taken by M83).

---

## [6.29.1] — 2026-07-28

### Added (M84 hotfix — F-105-01)
- **`review.rule_overrides` preferences** — per-rule `enabled: false` and `severity` overrides in `agent/preferences/acp.default.yaml`, loaded by `acp.review-rule-overrides.py` and applied in `acp.integrity-output.sh` for `/acp-review` and `/acp-integrity`.
- **Legacy adoption guide** — `agent/wiki/review-legacy-adoption.md` documents the baseline → tighten workflow for existing codebases.

### Fixed
- **Scanner stdin safety** — rule-override loading no longer steals lines from nested `while read` loops (inline suppression regression).

---

## [6.29.0] — 2026-07-27

### Added (M83 — Deterministic Local Review Engine)
- **Scanner execution coverage** — `e2e/acp.review-scan.test.sh` expanded to 29 behavioral checks covering multi-path scope, `--self`, `.mjs`/`.cjs`, SH-03 delegation, baseline suppression, inline suppression, dupehound wiring, and shared entropy reuse.
- **Measured corpus + harness** — `tests/fixtures/review-corpus/`, `tests/fixtures/review-scan/`, and `agent/scripts/acp.review-measure.sh` publish reproducible recall/precision for the shipped deterministic review surface.
- **Optional local analyzer helpers** — `agent/scripts/acp.gitleaks.sh` and `agent/scripts/acp.dupehound.sh` implement the ADR-23 three-gate pattern for SC-01 and CH-05 without making either tool a hard dependency.
- **M83 validation report** — `agent/reports/review-003-m83-scanner-validation.md` records the closure evidence for the scanner, fixtures, and carryover ledger.

### Changed
- **`/acp-review` documentation** — reconciled ruleset ownership, OWASP Top 10:2025 coverage, A08 ownership via `/acp-integrity`, and the shipped Phase 1/1b/1c automation counts.
- **Reference model** — `agent/wiki/domain.yml` now reflects the shipped review scanner helpers/suites and updated behavioral coverage.

### Fixed
- **F-102-01..08 and F-103-01..10** — all 18 M83 carryovers are now fixed with regression fixtures or doc assertions.
- **False-positive controls (F-103-09)** — `agent/scripts/acp.integrity-output.sh` now supports `--baseline`, `--write-baseline`, inline `acp-review-ignore` comments with required reasons, and suppression summaries in text/JSON output.
- **OWASP alignment (F-103-08)** — corrected the secrets/injection mapping and documented all 10 OWASP 2025 categories, with A08 explicitly owned by `/acp-integrity`.
- **Scanner precision/recall gaps** — M83 closes the measured comment/string lexing, EH-01 token matching, TS-01/TS-02/NC-01 recall, SC-01 prefix/entropy reuse, shellcheck SH-03, and default fixture-exclusion findings.

### Notes
- **Milestone shipped**: M83 is complete at **17/17 tasks** and released as **v6.29.0**. `current_milestone` in `agent/progress.yaml` remains **M81** because the CodeRabbit fixture gate is intentionally separate work.

---

## [6.28.2] — 2026-07-24

### Fixed (M80 — E2E suite debt remediation)
- **7 pre-existing E2E failures (F-M78-01)** — full suite **68/68** green (`run-e2e-tests.sh --skip-network`).
- **Test-side (task-265)**: e2e-workflow light-mode regex; validate-cross-layer conditional `package.yaml` copy; validate-ts 5-surface parity fixtures.
- **Behavior (task-266)**: `acp.version-check-for-updates.sh` `${1:-}` fix (exit 2 without AGENT.md); `acp.project-update.sh` unbound `current_tags`; `acp.package-info.sh` empty-line count bug; `acp.post-milestone-sweep.sh` executable bit in git index.
- **audit-100 carryovers F-100-01..05** — verified at closure.

---

## [6.28.1] — 2026-07-23

### Fixed (M79 — M78 Closure-Integrity Remediation, audit-099)
- **Version regression** — the v6.28.0 bump missed `agent/progress.yaml`'s own `version:` field (still 6.27.2), caught by cross-file E2E version checks but not `acp-validate.ts` (F-099-01). Now consistent.
- **Validator gap** — `acp-validate.ts validateVersionConsistency()` now includes `agent/progress.yaml project.version` so a future bump can't skip it; +2 vitest cases (F-099-02). This immediately caught a progress.yaml corruption during remediation.
- **Carryover ledger** — F-098-01..07 + F-097-01 (implemented in M78 but left `pending`) marked `fixed`/`verified_in_audit: audit-099` (F-099-03).
- **Subdirectory detection** — `coderabbit_available`/`coderabbit_active` now anchor config detection AND preference resolution to the git repo root, so detection works from any subdirectory (F-099-05).
- **Doc reconcile** — milestone-78 Build Order corrected to `acp.coderabbit.sh`; task-259 pointer reconciled to README (F-099-04, F-099-06).

### Notes
- ~6 genuinely pre-existing E2E failures (F-M78-01) remain deferred with root causes documented in audit-099 — not M78/M79 shortcuts.

---

## [6.28.0] — 2026-07-23

### Added (M78 — CodeRabbit Optionality Foundation)
- **Optional CodeRabbit integration** — `integrations.coderabbit.{enabled,config_path}` preferences (both OFF/inert by default). ACP stays fully functional without CodeRabbit (audit-097, ADR-21).
- **Detection helpers** — `agent/scripts/acp.coderabbit.sh` (`coderabbit_available` / `coderabbit_active` / hint); config-file detection only, sources preferences (not common.sh — avoids circular source, audit-098 F-098-01).
- **Pattern** — `agent/patterns/local.optional-external-tool.md`: three-gate contract (opt-in → detection → silent degradation) reusable for Aikido and future tools.
- **E2E** — `e2e/coderabbit-optionality.test.sh`: 4 states, 11 value assertions.
- **Docs** — `agent/wiki/coderabbit-integration.md` how-to guide + README pointer.

### Notes
- **GATED at ship time (ADR-19)**: full M74–M77 tool-integration track (CodeRabbit + Aikido). Later **ADR-22** carved CodeRabbit-only M81 out of that Aikido-coupled gate — see [Unreleased].
- **ADR-20** backfilled (hooks `task_id`-array format); **ADR-21** added (optionality carve-out).

---

## [6.27.2] — 2026-07-17

### Changed
- **README badges** — version 6.27.2; 73 milestones shipped (M74 next); 72 slash commands.
- **progress.yaml** — recent work for validate/sync chain; M74 roadmap in next_steps; research report pointers.
- **M73 milestone marker** — `@acp.meta.milestone status:` aligned to `completed`.

### Fixed
- **Version drift** — README shields.io badge was 6.21.1 while canonical identity/AGENTS was 6.27.1.

---

## [6.27.1] — 2026-07-15

### Fixed (M73 — Closure Honesty Remediation)
- **Carryover integrity** — restored 17 false `audit-093` stamps; `validateCarryoverAuditStamps()` guard (F-094-01).
- **Independent closure** — audit-095 with seeded negative probes supersedes audit-093 self-cert (F-094-02).
- **Tracking sync** — task-246 honestly deferred; M72 task frontmatter aligned (F-094-03/05).
- **D4 ratchet** — 13 scripts registered in `package.yaml`; unregistered script → ERROR (F-094-06/07).
- **Post-milestone-sweep** — 6/6 gates; tsc NodeNext; token budget + gitattributes gate fixes (F-094-04).

### Changed
- **`acp.post-milestone-sweep.sh`** — align token budget with constraints (5000 total); escape glob in gitattributes check.
- **M72 milestone gates** — checked with evidence; cwd gate amended for D1 module ROOT (F-094-10).

---

## [6.27.0] — 2026-07-15

### Added
- **M72** — Validation Truth & Drift Hardening (8 tasks, routes 229–236).
- **Validator D1–D5** — ROOT-anchored `acp-validate.ts`, instruction SHA-256 hash sync, `package.yaml` version check, 5-surface parity, dot-stray detection, protocol-dir addability (D9).
- **+8 vitests** — 36 validate tests (58 total in scripts/).
- **ShellCheck CI** — scoped error-severity gate for `agent/scripts`, `scripts`, `e2e`, `tests`.

### Changed
- **D9 evidence dirs** — `agent/reports/` + `agent/feedback/` tracked; 88 closure-evidence files added.
- **`acp-bootstrap.sh`** — cursor/claude sync after step 7; dead `acp.*.md` copy loops removed.
- **`acp.validate.md`** — Step 11.6/11.7 aligned with enforced reality.

### Fixed
- **F-091-01..14** (audit-093 re-verified); **F-092-01..04** plan amendments landed.

### Deferred (ops)
- **CRIT-065-002** — GitHub branch protection (`gh api` 404; requires repo admin).

---

## [6.26.0] — 2026-07-15

### Added
- **M70** — Tech Debt & Gate Hardening milestone (12 tasks, routes 208–219).
- **`acp.atomic-write.sh`** — temp-file + rename helper for commit sync atomicity (GAP-041-08).
- **`acp.branch-protection-setup.sh`** — GitHub branch protection automation (CRIT-065-002).
- **`patterns.schema.yaml`** — memory pattern entry schema + validate enforcement.
- **`validateMemoryFieldLint()`**, **`validateCarryoverFreshness()`**, **`validateIg35RouteDrift()`** in `acp-validate.ts`.
- **Review Phase 1 expansion** — 8 rules (EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01).
- **IG-35** — route `files_affected` drift check in `acp.git-provenance.sh`.

### Changed
- **`acp.review.md`** — two-phase gate policy (8 automated + 56 agent-required).
- **`command-e2e-coverage.yaml`** — registers `commit-sync` and `repair-tools` suites.
- **`acp.review-scan.sh`** — expanded from 4 to 8 deterministic rules.

### Fixed
- **MED-066-007**, **GAP-041-04**, **GAP-041-07**, **GAP-041-08**, **F-086-03**, **F-086-04**, **F-086-01** (IG-35).

### Deferred (ops)
- **CRIT-065-002** — GitHub branch protection requires repo admin (`acp.branch-protection-setup.sh`).
- **F-086-02** — FIFOZ `/acp-version-update` consumer verification (external project access).

---

## [6.25.3] — 2026-07-15

### Added
- **`acp.recurring-complete.sh`** — auto-advance `recurring_tasks.next_due` after weekly/monthly scans (F-068-03).
- **audit-086** — second-round carryover re-verification report and planning matrix.

### Changed
- **`acp.manifest-hash.sh`** — `--generate` writes to `integrity-manifest.yaml` by default.
- **`ci-validate.sh`** — missing `## Steps` / `## Verification` in command docs now FAIL (not warn).
- **`code-integrity.md`** — honest multi-script gateway coverage note (pattern-scan owns exfil/persistence).

### Fixed
- **audit-086** — stamped 21 stale carryovers as fixed (audit-065/066/070 items closed in M59–M64/v6.25.2).
- **F-086-01** — descoped IG-35 from `git-provenance.sh` header (not implemented).

---

## [6.25.2] — 2026-07-15

### Added
- **`acp.review-scan.sh`** — deterministic Phase 1 scanner for `/acp-review` (EH-02, SC-01, TS-01, SH-01).
- **`agent/integrity-manifest.yaml`** — SHA-256 manifest split from package `manifest.yaml` (INT-001).
- **`/acp-review --self`** — self-review recipe for ACP Enhanced framework code (audit-085 F-085-01).

### Changed
- **Rule count** — reconciled to 64 total (54 core + 10 Appendix A) across README, domain.yml, wrappers.
- **Appendix A IDs** — renamed AP-01/02/03 → ACP-01/02/03 in review command docs.

### Fixed
- **review-001** — vitest ^3.2.7 (0 npm audit CVEs); TypeScript strictness in `acp-validate.ts`; `err: unknown` in `acp-dispatch.ts`; `set -euo pipefail` in `acp.package-search.sh`.
- **integrity-001** — INT-001/002: integrity manifest verify via awk; macOS BSD `sed`/`mapfile` fixes in git-provenance and network-whitelist scripts.
- **audit-085** — F-085-01/05/06/07: Phase 1 scanner, `--self` flag, rule count, appendix naming.

### Security
- **npm audit** — scripts/ dev dependencies upgraded; 0 vulnerabilities.

---

## [6.25.1] — 2026-07-15

### Fixed
- **audit-083** — tier3 E2E now exercises all 58 tier-3 command docs (was static 26-command subset);
  case-insensitive Agent Directive checks; `validateCommandE2eCoverage()` accepts `repoRoot`/`commandsDir`
  options for vitest; milestone/task tracking reconciled.

### Added
- **Vitest** — `validateCommandE2eCoverage` unit tests + gap fixture YAML.
- **Task doc** — `task-211` for route-206 M63 coverage; tasks 212–218 for audit-083 remediation.

---

## [6.25.0] — 2026-07-15

### Added
- **M63 Test Coverage Tier 2 & 3** — `agent/schemas/command-e2e-coverage.yaml` maps all 70 `acp.*` commands.
- **`validateCommandE2eCoverage()`** — CI guard: 0 untested commands; fails on missing registry/suite.
- **E2E** — `acp.tier2-workflow.test.sh`, `acp.tier3-memory-knowledge.test.sh`,
  `acp.command-coverage-parity.test.sh`.

### Changed
- `acp-validate.ts` — command↔test parity scan wired into default validate run.

---

## [6.24.1] — 2026-07-15

### Added
- **E2E** — `e2e/acp.bootstrap-preserve.test.sh` (6 assertions) — bootstrap re-run preserves Tier B.
- **`agent/schemas/install-tier-registry.yaml`** — path registry for tier policy docs/validate.

### Fixed
- **audit-082** — `acp.install.sh` copies `AGENTS.md` (not stale `AGENT.md` only); tier-aware install banner;
  README/CONTRIBUTING consumer safety; `acp.version-update.md` steps reconciled to tier policy;
  milestone gates + task stamps; `--force` E2E (V13); carryovers re-verified @ audit-082.

---

## [6.24.0] — 2026-07-15

### Added
- **Safe install/update policy (M68)** — tier A/B/C/D file policy in `acp.common.sh`
  (`acp_copy_framework_file`, `acp_merge_manifest_acp_core`, `acp_install_manifest_acp_core`).
- **`/acp-version-update` route-079 for real** — `--diff`, `--preserve-project-core`,
  `--force`, `--yes`; accepts `AGENTS.md` or `AGENT.md`; offline `ACP_UPSTREAM_ROOT` for E2E.
- **E2E** — `e2e/acp.version-update-preserve.test.sh` (13 assertions incl. `--force`),
  `e2e/acp.install-preserve.test.sh` (manifest merge + tier B).
- **Validate guard** — `validateInstallUpdateSafety()` blocks blind `cp agent/core/*.yml`
  and `cat > manifest.yaml` regressions.

### Fixed
- **audit-080** — version-update no longer blind-overwrites `identity.yml`, wiki, routing;
  install preserves Tier B on reinstall; manifest merge retains third-party packages;
  bootstrap create-if-absent for Tier B stubs; Windows `xargs` replaced with `acp_list_basenames`.
- **v6.9.0 doc-only gap** — route-079 guards were documented in M47 but never implemented
  in shell until this release (SC-080-01).

### Changed
- `acp.version-update.md` v1.2.0 — single authoritative tier table (SC-080-05).
- Third-party command namespaces and `local.*` skills preserved on update (P-081-01/02).

---

## [6.23.1] — 2026-07-15

### Fixed
- **audit-079 housekeeping** — M67 post-ship gap closure: milestone verification
  gates checked, task-195..202 stamped completed, sessions.md entry, feedback-007
  §6 upstream acceptance, README/QUICKSTART 70-command counts, handoff wrapper
  v2 descriptions, domain.yml handoff/receive E2E catalog, audit carryovers
  re-verified @079, HIGH-067-001 marked fixed (0/70 commands missing).

---

## [6.23.0] — 2026-07-15

### Added
- **`/acp-handoff` v2.0.0** — dual mode: `--mode executor` (same-repo,
  implementation package with ADR locks, task sequence, git pin) and
  `--mode cross-repo` (v1 problem-only behaviour, default).
- **`/acp-receive`** — incoming handoff protocol: git drift warning, session
  gap check, assignment checklist, `--latest` resolution via `active_handoff`.
- **`active_handoff`** optional field in `progress.yaml` schema + validate rule.
- **E2E** — `e2e/acp.handoff.test.sh`, `e2e/acp.receive.test.sh` with M51-style
  fixtures under `agent/benchmarks/fixtures/handoff/`.
- **Wiki** — `agent/wiki/cross-agent-handoff.md` ritual documentation (M67).

### Changed
- **`/acp-resume` v1.1.0** — optional handoff path runs receive protocol before init.
- **`package.yaml`**, `domain.yml`, `agent/index/acp.core.yaml` — register
  `acp.receive` (70th command); repair corrupt domain.yml handoff/feedback entries.
- **CONTRIBUTING.md** — field feedback intake via `agent/proposals/` and
  `agent/feedback/`.

### Fixed
- **audit-077 / feedback-007** — cross-agent handoff protocol gaps H1–H10, U1–U3.
- **audit-078 P-078-01** — `domain.yml` corrupt acp.feedback/handoff entries.

---

## [6.21.1] — 2026-07-15

### Fixed
- **progress.yaml YAML integrity** — removed 191 duplicate task field keys
  (mostly duplicate `completed_date` entries) restoring full js-yaml parse.
- **Milestone status desync** — synced `**Status**` in M19, M24–M28, M47–M49
  milestone docs to match progress.yaml (`completed`).
- **Missing M27 milestone doc** — created
  `agent/milestones/milestone-27-distribution-readiness-fixes.md`.
- **acp-validate.ts** — removed incorrect `milestone.schema.yaml` →
  `progress.yaml` mapping; fixed `Array.isArray` type check for schema warnings.
- **Verification gates** — marked M59/M60/M63 industry-standard verification
  items with ✅/⏳ status prefixes.

### Changed
- **progress.yaml tracking** — `current_milestone` → M63; `next_steps` and
  `notes` refreshed after M66 completion.
- **README badges** — version 6.21.1; 66 milestones shipped, M63 next.
- **git tag** — retroactive `v6.21.0` tag on M66 release commit.

---

## [6.21.0] — 2026-06-15

### Added
- **route-178: Cross-file consistency validators** — 7 automated checks in
  `acp-validate.ts` (40/40 vitest): version consistency across identity.yml,
  AGENTS.md, CLAUDE.md, CHANGELOG.md; stale next_steps detection;
  milestone doc version drift; blank verification gate detection;
  missing git tags; .gitignore conflicts; .gitattributes coverage.
- **route-179: Post-milestone sweep script** — `acp.post-milestone-sweep.sh`
  with 6 automated gates (tsc, vitest, git tags, acp-validate, token budget,
  gitattributes) + E2E test. Triggered by constraints.yml hook.
- **route-175: Memory-layer schemas** — 7 new `agent/schemas/*.schema.yaml`
  files (milestone, session, lessons, decisions, clarification, feedback,
  audit-carryovers) enforced by `acp-validate.ts`.
- **route-174: Command doc structural conformance** — `## Steps` added to
  `acp.integrity.md` and `acp.review.md`; `## Verification` added to
  dispatch, feedback, install, task, and visualize commands.
- **route-176: Reference git hook** — `.git/hooks/pre-commit` with staged
  ACP file scanning, bash guard, and pass/fail output.
- **constraints.yml: test_quality_gate rule** — unit tests must assert
  behavior, not just types. `post_milestone_sweep` hook registered.

### Changed
- **route-173: Pipefail upgrade** — 17 scripts upgraded from bare `set -e`
  to `set -euo pipefail` + ERR trap. All 36 scripts now conform.
- **route-177: Low-severity cleanups** — network_whitelist.yml reviewed_by
  populated; L1-L4 resolved.

### Fixed
- **route-176: 5 audit-062 carryovers resolved** — F-062-01..05 all
  marked fixed: hooks restored, checklist verified, next_due automated,
  reference hook created, last_findings_count added.

---

## [6.20.9] — 2026-06-15

### Fixed
- **route-172 test depth**: `getFilteredLessons`/`getLastNSessions` upgraded from smoke tests (return type) to proper behavioral tests: exact task_type filtering, archived-entry skipping, priority:high cross-matching, 5-entry cap, N=1/2/3 session slicing, and empty-string fast path. 33 vitest tests (from 26). `tsc --noEmit` passes (added tsconfig.json). (audit-075 shortcut remediation)
- **route-171 budget check**: identity.yml Layer 1 token count verified (1,622 bytes ≈ 405 tokens, under 500 ceiling). team_members addition had negligible impact (+22 bytes, +5 tokens).
- **A3.5 final sweep**: vitest 33/33 green. E2E suite has 47/47 CRLF failures on WSL — pre-existing line-ending issue. .gitattributes LF enforcement (route-171) prevents future files from acquiring CRLF.
- **progress.yaml tracking**: Added full recent_work entry for M61 completion + audit-075 (6 routes, 6 findings, 3 carryovers). Updated next_steps from stale M61→M62. Refreshed notes to reflect all shipped milestones.
- **milestone-61 doc version**: Fixed stale v6.16.0 in success criteria → v6.20.9. Populated verification gate with actual pass/fail/⏳ results (npm audit clean, secret-scan active, vitest 33/33, Windows E2E ⏳ pending CRLF fix).
- **.gitignore whitelist**: Added `!agent/reports/` to allow audit reports to commit without `-f` (blanket `reports/` glob was catching `agent/reports/`).
- **.gitattributes TypeScript/JSON**: Added `*.ts` and `*.json` LF enforcement for cross-platform tooling (tsc, vitest, npm).
- **M61 progress.yaml master entry**: Updated name from planning version v6.16.0 to shipped v6.20.9, replaced planning notes with completion summary.
- **sessions.md M61 entry**: Expanded key_fact to cover all 15 shortcuts across 3 rounds.
- **M62 target version**: Updated milestone doc and progress.yaml from stale v6.17.0 → v6.21.0 to match next_steps.
- **Retroactive git tags**: Created annotated tags for v6.20.3 through v6.20.9 on corresponding commits.

---

## [6.20.8] — 2026-06-15

### Fixed
- **Audit-075 (M61 post-impl)**: 6 findings fixed — YOUR_ORG placeholder in SECURITY.md URL (HIGH), stale version footer (MEDIUM), fallback contact under-specification (LOW), unpinned trufflehog action → SHA-pinned per IG-67 (HIGH), Windows CI conditional-skip protocol comment (MEDIUM), missing open-pull-requests-limit on Dependabot github-actions (LOW). 3 carryovers (HIGH-065-005/006, MED-066-003) marked fixed and verified.

---

## [6.20.7] — 2026-06-15

### Added
- **TS unit test suite (vitest)**: 26 tests covering `acp-dispatch.ts` (budget enforcement, getSkillFile, getLastNSessions, getFilteredLessons, estimateTokens, updateRoutingYml) and `acp-validate.ts` (placeholder detection on lines 3-4, frontmatter field validation). Wired into CI. (route-172, M61)

### Changed
- **`acp-dispatch.ts`**: Exported `buildContext`, `getLastNSessions`, `getFilteredLessons`, `getSkillFile`, `estimateTokens` for testability (route-172, M61).
- **`acp-validate.ts`**: Exported `validatePlaceholders`, `validateFrontmatter`, `ValidationError`; added `isDirectExecution()` guard to prevent main() from running during test imports (route-172, M61).

---

## [6.20.6] — 2026-06-15

### Added
- **IG-37 active**: `team_members` populated in `identity.yml` enabling git author provenance verification via `acp.git-provenance.sh`. CRLF resilience added to grep-based parser (L4 migration deferred to route-177). (route-171, M61)

### Changed
- **`.gitattributes`**: Extended LF enforcement to `*.yml` and `*.yaml` for cross-platform bash-parser compatibility (route-171, M61).

---

## [6.20.5] — 2026-06-15

### Added
- **Dependabot**: Weekly npm (`/scripts`) and github-actions ecosystem updates (route-170, M61).
- **`scripts/package-lock.json`**: Pinned dependency tree committed to repo (audit-065 M7).
- **CI supply-chain job**: `npm audit --audit-level=high` (non-blocking) + trufflehog secret scan (blocking) (route-170, M61).

---

## [6.20.4] — 2026-06-15

### Added
- **CODEOWNERS**: Catch-all + fine-grained ownership rules for `scripts/`, `.github/workflows/`, and `agent/scripts/` (route-169, M61).
- **PR and issue templates**: `.github/pull_request_template.md` with E2E+validate+changelog checklist; `bug_report.md` and `feature_request.md` with structured fields (route-169, M61).

---

## [6.20.3] — 2026-06-15

### Added
- **SECURITY.md**: Vulnerability disclosure policy with private reporting via GitHub Security Advisories, supported versions table, in-scope/out-of-scope definitions, response targets, and coordinated disclosure policy. Linked from README.md and CONTRIBUTING.md. Addresses audit-065 HIGH-065-006 (route-168, M61).
- **Windows CI**: Added `windows-latest` runner to E2E test matrix with `shell: bash` default for cross-platform Git Bash compatibility. `.gitattributes` LF enforcement already in place (IG-42). (route-167, M61)

---

## [6.20.2] — 2026-06-15

### Added
- **Cross-layer status validation** (`scripts/acp-validate.ts`): New `validateStatusConsistency()` and `validateFilePointers()` checks run in all validate modes — catches milestone-doc vs progress.yaml desync and dangling file pointers (route-186, audit-069 F-069-01/F-069-09).
- **ADR-13**: LLM/Script boundary rule for `/acp-integrity` (deterministic → bash, semantic → LLM)
- **ADR-14**: Confidence ceiling policy for semantic security analysis (taint ≤ MEDIUM, injection/memory ≤ LOW)
- **ADR-15**: Command doc as spec — no separate specification files
- **ADR-16**: Gitflow-lite branching model (`develop` → `mainline`)
- **M60 — Tier 1 E2E test coverage**: 8 new E2E suites for core commands (init, proceed, plan, dispatch, commit, validate, audit, route) — all passing at 100% (route-165). Drops untested command ratio from 68% to ≤56%.
- **M60 — Integrity test hardening**: Rule-count assertion tightened from ≥55 to exact 70 (route-166, MED-067-003).
- **M60 — CONTRIBUTING.md**: New contributor guide with branch model, PR checks, command-doc conventions, and shell scripting conventions (route-166, MED-067-005).

### Fixed
- **Status desync across 12 milestone docs**: M44, M46, M50-M56, M65 milestone docs now agree with progress.yaml (route-185, audit-069 F-069-01)
- **M54 inconsistency**: `tasks_total: 1` with `status: completed`; branch protection tracked in M59 route-162
- **Progress.yaml description**: Updated from v6.19.0 to v6.20.1 with correct milestone status
- **`acp.meta-scan.sh` pipefail**: Added `-o pipefail` to `set -euo pipefail` header (route-188, F-068-12)
- **`quarterly-deep-scan` recurring task**: Description updated to reflect Phase 2 activation (M58 shipped)
- **F-062-03 carryover promoted**: automated `next_due` calculation tracked in M59 post-completion follow-up

### Changed
- **`acp-validate.ts` resilience**: Progress.yaml YAML parse failures (duplicate keys) now fall back to line-based parsing instead of crashing
- **M58 plan correction ADRs**: ADR-11 (route-155 scope descope) and ADR-12 (§10 non-circular gate) formalize the post-audit-072 plan

## [6.20.1] — 2026-06-15

### Fixed
- **Taint heuristics**: IG-47/48/50 missing on calibration fixtures — added file-level flow analysis for indirect source→sink (audit-072)
- **IG-49 false positive**: Skip safe files with URL validation helpers
- **IG-50 confidence ceiling**: Now reports `[LOW]` per milestone specification
- **Fixture manifest**: Added `max_confidence` + `ci_blocking` fields per fixture
- **Wiki header**: Updated to v2.0.0 — Phase 2 active, 70 total rules
- **Milestone-58**: Verification checklist completed; research gate descoped
- **Audit carryovers**: 9 M58-related items from audit-068/069 marked fixed

### Added
- **Memory poisoning UX research** (`agent/artifacts/research-memory-poisoning-ux.md`)
- **Glossary terms**: 6 M58 Phase 2 terms added (Integrity & Security section)
- **E2E coverage**: B13–B16 — full 6-rule taint matrix (55 assertions, +29)

### Changed
- **`quarterly-deep-scan`**: Description updated — M58 shipped, Phase 2 active

## [6.20.0] — 2026-06-15

### Added
- **M58 `/acp-integrity` v2.0 Phase 2** — semantic analysis (routes 156–158)
- `acp.taint-scan.sh` + `acp.taint-scan.py` — taint source/sink extraction + IG-45–50 heuristics
- `acp.memory-scan.sh` — memory vs `constraints.yml` prep for LLM semantic comparison
- E2E `e2e/acp.integrity-v2.test.sh` — 26 assertions (confidence ceilings, scripts, docs)

### Changed
- Wiki Cat 8/10 un-deferred with Max Confidence columns; command doc v2.0.0 with `--phase2`
- Skill `code-integrity.md` Phase 2 guidance + self-protection protocol
- Confidence ceiling model: Cat 8 MEDIUM max, Cat 9/10 LOW max (IG-61 HIGH script-backed)

---

## [6.19.0] — 2026-06-15

### Added
- **M64 Integrity Gateway v1.1** — truth & test milestone (routes 180–184 + route-179 from 6.14.1)
- `acp.integrity-output.sh` — uniform `[SEVERITY] file:line ruleID — msg` contract, `--json`, severity-aware `--ci`
- `acp.pattern-scan.sh` + `acp.pattern-scan.py` — exfiltration (IG-07–13) and persistence (IG-21–26) deterministic detection
- Integrity fixture matrix: `agent/benchmarks/fixtures/integrity/manifest.yaml` + true+/true- fixtures
- E2E B10–B22: scanner regression, fixture matrix, JSON output, false-positive baseline

### Fixed
- All 7 scanners emit uniform output; `--ci` exits 1 only on CRITICAL/HIGH (not MEDIUM)
- `acp.network-whitelist-validate.sh` — YAML whitelist load via parser validation
- `acp.dependency-diff.sh` — Levenshtein typosquat (IG-27), shadow deps (IG-29), git-date stale lock (IG-31)
- `acp.git-provenance.sh` — IG-37 explicit skip when `team_members` empty
- `acp.manifest-hash.sh` — directory enumeration, `--output`, `calculate_checksum` sha fallback
- E2E S3 — `IG-[0-9]+` grep (portable vs `\d`)

### Changed
- `/acp-integrity` maturity → v1.1; wiki/skill/command docs reconciled to script-backed coverage
- **ADR-10 gate cleared** — M58 v2.0 semantic work may proceed after M65 tracking reconciliation

---

## [6.14.1] — 2026-06-15

### Added
- **M64 route-179** (partial) — integrity scanner fixtures under `agent/benchmarks/fixtures/integrity/`
- E2E regression **B10–B14** in `acp.integrity.test.sh` (entropy crash, `--ci` gate, unicode detection, perf)

### Fixed
- **F-070-01** — `acp.entropy-scan.sh` no longer crashes on findings (`set -e` + non-zero Python exit); uses `ACP_FINDING_COUNT` marker
- **F-070-04** — `acp.unicode-scan.sh` single-pass scan (~4.7s for `agent/` vs ~42s per-file Python spawns)

### Changed
- M64 milestone tracking — route-179 complete, 1/6 routes in progress

---

## [6.14.0] — 2026-06-15

### Added
- **M59 Critical-Fix & CI Integrity** — six audit carryovers shipped (H1, H8, H2/H3, C1 docs, M9, M12)
- `scripts/acp-dispatch.test.ts` — regression tests for surgical `updateRoutingYml()` (preserves `context_modes`, `command_suggestions`)
- `validateVersionConsistency()` in `acp-validate.ts` — AGENTS.md header vs `identity.yml` drift check
- **15 missing commands** added to `package.yaml` (commit, decide, dispatch, route, task, feedback, visualize, wiki-update, carryover-query, cost-report, memory-sync, pattern-sync, session-sync, rule-file-audit, install)
- `docs/USAGE.md` — Git branch protection governance section (mainline + develop)

### Fixed
- **H1** — `updateRoutingYml()` no longer overwrites full `routing.yml`; updates `session:` block only
- **H8** — `package.yaml` command manifest parity with `agent/commands/acp.*.md`
- **H2/H3** — CI runs `acp-validate.ts` + `ci-validate.sh` with real command-doc structure checks and package count guard
- **M9** — `OPENROUTER_API_KEY` preflight in `acp-dispatch.ts` with clear error before API call

### Changed
- `.github/workflows/ci.yaml` — Node 20 setup, `npm install` in `scripts/`, `npx ts-node scripts/acp-validate.ts`
- Version bump **6.12.2 → 6.14.0** across identity, package, AGENTS/CLAUDE/copilot triple-sync, README badge

### Notes
- **C1 (route-162)** — branch protection documented in `docs/USAGE.md`; enable manually in GitHub repo settings (requires admin/`gh`)

---

## [6.12.2] — 2026-06-15

### Added
- **ADR-10** — M64 (integrity gateway truth/test) is a hard prerequisite before M58 v2.0 semantic analysis implementation
- Command parity wrappers for `/acp-carryover-query`, `/acp-pattern-sync`, `/acp-session-sync` (69×3 surfaces)
- `agent/commands/acp.rule-file-audit.md` — alias to `/acp-integrity --self --fast`
- `agent/milestones/milestone-54-ci-cd-gitflow.md` — CI/CD + GitFlow-lite milestone doc
- M58 research artifact and taint-flow fixture matrix (`agent/benchmarks/fixtures/taint-flow/`, 12 files)
- Session document auto-sync: `agent/sessions/2026-06-15-audit-remediation-docs-validation-sync.md`

### Fixed
- `acp-validate` — 0 errors, 0 warnings (frontmatter gaps, triple-file size under 12KB, sessions.md structure)
- `package.yaml` — quote `requires.acp` value (`">=3.13.0"`) to fix YAML parse error
- AGENTS.md / CLAUDE.md / copilot-instructions triple-sync (trimmed stale v6.10.0 header and oversized sections)

### Changed
- README, `scripts/PRD-MAIN.md`, `scripts/QUICKSTART.md` — doc sync to v6.12.x counts (69 commands, 9 skills, 36 scripts, M52–M57)
- `agent/progress.yaml` — M54 50%, M58 blocked on M64, next steps and blockers refreshed
- `agent/wiki/domain.yml` — last_verified annotation

---

## [6.12.1] — 2026-06-08

### Added (M57 — Recurring Tasks Scheduler + Pre-Commit Hook Framework)
- **Recurring Tasks Scheduler**: 5 default recurring tasks — weekly code review, weekly integrity scan, pre-commit rule audit, monthly dependency audit, quarterly deep scan
- `agent/progress.yaml` — `recurring_tasks:` block with cadence/trigger-based task scheduling
- `agent/progress.template.yaml` — recurring_tasks template section for new projects
- **AGENTS.md Step 4.5** — scheduled review due check at session start (surfaces overdue recurring tasks)
- Synced to `CLAUDE.md` and `.github/copilot-instructions.md`
- `agent/core/constraints.yml` — `hooks:` block with pre-commit hook binding
- `agent/schemas/progress.schema.yaml` — recurring_tasks field schema (id, command, frequency, trigger, executor, dates, status)
- `agent/commands/acp.validate.md` — Step 2d recurring tasks validation
- E2E test: `e2e/acp.recurring-tasks.test.sh` (16 assertions, 100% pass)
- Standards: NIST SP 800-53 SI-4, OWASP SAMM v2, ISO 27001 A.8.8

### Changed
- `agent/progress.yaml` — current_milestone: M57 → M58; project description updated to v6.12.1

---

## [6.12.0] — 2026-06-07

### Added (M56 — /acp-integrity v1.0 — AI Code Integrity & Malicious Code Detection)
- **`/acp-integrity` command**: 55-rule trustworthiness verification — detects hidden Unicode, exfiltration, supply chain risks, CI injection
- `agent/commands/acp.integrity.md` — full command doc with Agent Directive, LLM/Script Boundary Rule, Remediation Playbook, Standards References
- `agent/skills/code-integrity.md` — slim skill file (≤800 tokens) with script table + confidence ceilings
- `agent/wiki/integrity-rules.md` — full 70-rule catalogue (55 v1.0 + 15 deferred to v2.0)
- **6 bash scripts**: `acp.unicode-scan.sh`, `acp.entropy-scan.sh`, `acp.manifest-hash.sh`, `acp.network-whitelist-validate.sh`, `acp.git-provenance.sh`, `acp.dependency-diff.sh`
- `agent/core/network_whitelist.yml` — approved outbound domain whitelist schema
- `agent/core/identity.yml` — `team_members:` field for git provenance verification
- `acp-rule-file-audit` alias — 3-line wrappers → `acp-integrity --self --fast`
- E2E test: 26/26 assertions (structural + behavioral + false-positive baseline)
- LLM/Script Boundary Rule: deterministic tasks use bash scripts, not LLM reasoning
- [feedback-007](agent/feedback/feedback-007-acp-integrity-command-upstream-v2.md): `/acp-integrity` proposal accepted with scope reduction (Phase 1 only)
- [audit-053](agent/reports/audit-053-feedback-007-acp-integrity-suitability-analysis.md): suitability analysis — 4 CRITICAL gaps, scope reduction recommended
- [audit-054](agent/feedback/audit-054-second-round-acp-integrity-consolidated.md): Perplexity second-round — all findings confirmed, 2 extra scripts, consolidated v1.0 scope
- [audit-055](agent/reports/audit-055-m56-pre-implementation-gap-check.md): pre-impl gap check — 5 gaps + 2 inconsistencies, all fixed
- M57 + M58 stubs created for deferred features (recurring tasks, semantic analysis)
- Deferred to v2.0 (M58): taint flow (IG-45–50), semantic injection (IG-53/54/56/57), memory poisoning (IG-58–62)

### Changed
- `agent/routing/taxonomy.yml`: added `code-integrity-scan` task type + `@{code-integrity}` skill catalog entry
- `agent/core/routing.yml`: added acp-integrity command suggestions
- `package.yaml`: added acp.integrity.md entry with 6 scripts
- `agent/core/identity.yml`: added `team_members:` field

---

## [6.11.0] — 2026-06-07

### Added (M55 — /acp-review Code Quality & Security Review Command)
- **`/acp-review` command**: 54-rule standards enforcement covering TypeScript, OWASP Top 10:2025, OWASP MASVS v2.0, API conventions, naming, code health, and error handling
- `agent/commands/acp.review.md` — full command document with 7 rule categories, quality gates, executor selection, and output format spec
- `agent/skills/code-review.md` — compact skill file (copilot executor, Flash disqualified, OWASP→rule mapping)
- Appendix A: 10 ACP self-review rules (SH-01–SH-04, YM-01–YM-03, ACP-01–ACP-03) auto-activate when `agent/commands/` detected
- `--diff` flag: review only files changed since last commit (git diff integration)
- `--carryover` integration: writes HIGH+ findings to `agent/memory/audit-carryovers.md`
- `--ci` mode: compact output, exit 1 on CRITICAL/HIGH findings
- 4 task types in taxonomy: `code-review-full`, `code-review-targeted`, `code-review-security`, `code-review-ci`
- Skill catalog entry for `@{code-review}` @-mention invocation
- E2E test: 14 assertions (7 structural + 7 behavioral) in `e2e/acp.review.test.sh`
- [feedback-006](agent/feedback/feedback-006-acp-review-command-upstream-v3.md): `/acp-review` proposal accepted — ships full TypeScript-first ruleset (not scoped down)
- Mobile MASVS v2.0 rules (SC-19–SC-23) for React Native/Expo projects
- Executor selection: Composer 2.5 (preferred), DeepSeek V4 Pro, Kimi K2.6, Qwen3 235B; Flash/Flash-Max disqualified
- Cross-links added to `acp.audit.md`, `acp.validate.md`, `acp.repair-tools.md`, `acp.stakeholder-report.md`, `acp.design-spec.md`, `acp.pattern-create.md`, `acp.carryover-query.md`
- `agent/reports/audit-050-feedback-006-review-command-scope-analysis.md` — scope correction analysis
- `agent/reports/audit-051-m55-readiness-gap-analysis.md` — 13 findings, all resolved

### Changed
- `agent/routing/taxonomy.yml`: added 4 code-review task types + skill catalog entry
- `agent/core/routing.yml`: added acp-review, acp-carryover-query, acp-validate command suggestions
- `package.yaml`: added acp.review.md entry

---

## [6.10.0] — 2026-06-07

### Added (M53 — Cursor Slash Commands Bootstrap)
- **Cursor IDE slash-command parity**: `/acp-*` commands now available as native Cursor slash commands via `.cursor/commands/` auto-generation
- `agent/scripts/acp.cursor-commands-sync.sh` — generates Cursor wrappers from `agent/commands/` sources (dots→hyphens naming)
- Hooked into `acp.install.sh` and `acp.version-update.sh` for automatic regeneration
- Bootstrap step 6b generates `.cursor/commands/` alongside `.opencode/commands/`
- Post-install verification checks `.cursor/commands/` file count parity with source commands
- `.cursor/rules/acp-slash-commands.mdc` — always-on agent execution protocol
- `agent/wiki/cursor-integration.md` — Cursor integration guide
- `e2e/acp.cursor-commands-sync.test.sh` — 10-assertion test (naming, parity, content, idempotency)

### Fixed
- Pre-existing `@acp.` occurrences in `acp.visualize.md` replaced with `/acp-` (route-129 hotfix)
- Command-docs E2E test now 466/466 (was 465/466 with 1 `@acp.` failure)

---

## [6.9.5] — 2026-06-07

### New Commands (M52 — Stakeholder Report + Carryovers)
- **`/acp-stakeholder-report`** — Generate concise weekly/monthly stakeholder progress summaries with RAG health indicator, ≤300-word executive summary, decisions required, and 2–4 KPI metrics. v1.1.0 hardened by audit-071 from FIFOZ production use.

### Added
- Five-tier reporting model documented in README (status → stakeholder → report → design-spec → cost-report)
- `agent/templates/stakeholder-report.template.md` — 9-section output template
- `e2e/acp.stakeholder-report.test.sh` — 15-assertion smoke test
- `routing.yml` command_suggestions for acp-stakeholder-report
- `taxonomy.yml` stakeholder-report task_type
- Cross-links in acp.report.md (Example 3 updated), acp.cost-report.md, acp.status.md

### Fixed
- Audit-044 carryovers resolved: design-spec index entry (G-044-03), domain.yml entry (G-044-06), README mention (G-044-07), P3 deferred tracking (DEFER-044-01)
- Pre-existing `@acp.` occurrences in `acp.visualize.md` replaced with `/acp-` (CARRY-047-01)

---

## [6.9.4] — 2026-06-06

### Fixed (M51 — Bootstrap Install Fix)
- **BUG-045-01 (CRITICAL)**: Step 7 now checks file count (`find | wc -l`) instead of directory existence (`-d`). Empty dirs from step 1 no longer cause download skip. Every fresh `curl | bash` install was silently broken with 0 command files.
- **BUG-045-02 (HIGH)**: OpenCode command generation extracted from `GENERATE_PROMPTS` block. Now runs independently when `GENERATE_OPENCODE=true`. Graceful skip when no prompt files exist.
- **BUG-045-03 (MEDIUM)**: Post-install verification exits non-zero on failure with clear remediation command.
- **Bootstrap robustness**: `mkdir -p agent/drafts` before cp (was missing for small team-size scaffold).

### Added
- `e2e/acp.bootstrap.test.sh` — 8-assertion smoke test (fresh install in temp dir)

---

## [6.9.3] — 2026-06-06

### New Commands (M50 — Design-Spec Command Integration)
- **`/acp-design-spec`** — Generate Application Interface & Data-Flow Design Specifications from the live codebase. 19-section template based on arc42, C4 Model, IEEE 1016, and ISO 42010. Stack-agnostic with detection tables. Includes output template, E2E smoke test, and framework integration (routing.yml, taxonomy.yml).

### Added
- `agent/templates/` directory for output templates
- `agent/templates/design-spec.template.md` — 19-section spec template
- `e2e/acp.design-spec.test.sh` — 12-assertion smoke test (all passing)
- `routing.yml` command_suggestions for `acp-design-spec`
- `taxonomy.yml` `design-spec` task_type
- Cross-links in `acp.report.md` and `acp.design-create.md` Related Commands
- `package.yaml` entry for `acp.design-spec.md`

---

## [6.9.2] — 2026-06-06

### Added (M49 — Dogfooding + Install Resolution)
- **Triple-file parity check**: `/acp-validate` Step 11.7 warns on missing `.github/prompts/` and `.opencode/` wrappers (route-094)
- **AGENTS.md version line**: Protocol doc header now shows v6.9.2 for Copilot/Cursor/Claude (route-095)
- **`--validate` flag**: `/acp-commit --validate` runs validation before committing (route-096)
- **Windows + Cursor support**: `.cursor/commands/` auto-generated during bootstrap. Windows install docs with Git Bash recovery path (routes-101, 104)
- **Post-install verification**: Command/script counts checked at end of bootstrap and install (route-102)
- **Backup warning**: Install/update scripts now show overwrite vs preserve lists before making changes (route-103)
- **`--repair` mode**: `/acp-install --repair` detects and fixes partial/broken installs (route-105)
- **Instance Data wiki**: Documented `.gitignore` design rationale and framework dev mode (route-098)

### Fixed
- **Windows Git Bash hang**: 3 `while true` loops in `acp.install.sh` now have MAX_ITERATION safety caps (route-099)
- **Bootstrap partial-install**: Completeness check replaces simple early-exit; auto-completes partial installs (route-100)

### Source
- feedback-003 (dogfooding analysis — 5 pain points)
- install-windows-cursor-2026-06-06 (7 Windows/Cursor findings)

---

## [6.9.1] — 2026-06-04

### Added (M48 — Carryover Resolution & Workflow Hardening)
- **E2E tests for commit auto-sync**: `e2e/acp.commit-sync.test.sh` — 6 assertions verifying session/pattern document generation, idempotency, and --no-sync (route-085)
- **E2E tests for repair tools + --memory**: `e2e/acp.repair-tools.test.sh` — 6 assertions covering --dry-run, --all, session-sync, and bad YAML detection (route-086)
- **Atomicity in sync operations**: Temp-file + atomic rename pattern in `/acp-commit` steps 2b/3b preventing partial writes (route-087)
- **Registry schema lint**: `/acp-validate --memory` now warns on missing `date:`/`name:` fields and unquoted colons in scalar values (route-088)
- **Audit-first workflow wiki**: Documented in `agent/wiki/architecture.md` with pattern steps, when-to-use guidance, and production data (route-089)
- **`/acp-status --health`**: YAML lint + git drift + uncommitted progress check (route-090)
- **`/acp-index init`**: Bootstrap index from project patterns, commands, and designs (route-091)
- **`/acp-carryover-query`**: Search 5000+ line `audit-carryovers.md` by status, severity, audit, or keyword (route-092)
- **Triple-file parity**: `.github/prompts/` and `.opencode/` wrappers for carryover-query

### Changed
- `/acp-status` version bumped to 1.1.0
- `/acp-index` updated with `init` subcommand

### Fixed
- All 8 carryover items from M47 audit-041/042 resolved
- 3 pending carryovers marked in-progress with M48 route references
- GAP-041-06 (CHANGELOG) marked fixed

### Source
- M47 carryovers: GAP-041-04, GAP-041-07, GAP-041-08
- FIFOZ feedback-002: B-066-01, B-066-02, B-066-07, B-066-08

---

## [6.9.0] — 2026-06-04

### Added (M47 — Memory Integrity Release)
- **Commit-integrated document auto-sync**: `/acp-commit` now automatically generates `agent/sessions/{date}-{slug}.md` and `agent/patterns/{name}.md` from registries on every successful commit (steps 2b, 3b). Re-syncs affected documents after weekly compaction (step 6b). Idempotent design — re-running without registry changes does not rewrite files.
- **`--no-sync` flag** on `/acp-commit`: Skips auto-sync steps for debugging. Warns that document directories may drift from registries.
- **`/acp-pattern-sync`**: Manual repair tool — sync pattern documents from `agent/memory/patterns.md` registry. Supports `--dry-run`, `--all`, `--name <name>`.
- **`/acp-session-sync`**: Manual repair tool — sync session documents from `agent/memory/sessions.md` registry. Supports `--dry-run`, `--all`, `--date <YYYY-MM-DD>`.
- **`/acp-validate --memory`**: YAML-lint `agent/memory/patterns.md`, `agent/memory/sessions.md`, and `agent/progress.yaml`. Fails with line numbers on syntax errors. Complements existing Step 11.6 structural validation.
- **`/acp-version-update` guards**: `--diff` previews changes without applying. `--preserve-project-core` skips `identity.yml`, `domain.yml`, `taxonomy.yml`. `--force` skips confirmation prompts. Default behavior now warns before overwriting modified core files.
- **YAML quoting directives**: Agent directives in `/acp-commit` (steps 2, 6) and `/acp-update` (step 5) requiring quoted scalars when values contain `:` to prevent js-yaml parse failures.
- **Dual-store architecture wiki**: Documented registry-to-document sync model, repair paths, and YAML integrity in `agent/wiki/architecture.md`.
- **Pattern promotion enforcement**: `/acp-commit` step 3 now actively prompts when `key_fact` contains code patterns, architectural insights, or repeatable processes.
- **Command onboarding**: `/acp-init` now shows phase-aware command recommendations (new project, active milestone, post-milestone, maintenance).
- **ADR-9**: Dual-store architecture decision — registry as source of truth, documents as consumption layer, commit as sync trigger.

### Changed
- **Schema alignment**: `/acp-commit` session entry field `tasks:` renamed to `tasks_completed:` for consistency with visualizer expectations and weekly-summary blocks. `/acp-validate` Step 11.6 updated to match.
- `/acp-commit` version bumped to 1.3.0. `/acp-validate` version bumped to 2.2.0. `/acp-version-update` version bumped to 1.1.0.

### Fixed
- Stale `tasks:` references in `/acp-commit` step 5 and verification section (audit-042, GAP-042-01)
- Missing YAML quoting directive in `/acp-update` step 5 (audit-042, GAP-042-02)
- Triple-file parity: Added `.github/prompts/` and `.opencode/commands/` wrappers for new `pattern-sync` and `session-sync` commands (audit-042, GAP-042-03)
- `--diff` flag integrated into `/acp-version-update` steps — previously documented in arguments only (audit-042, GAP-042-04)
- `agent/core/identity.yml`, `domain.yml`, `taxonomy.yml` now protected from silent overwrite during version updates

### Source
- FIFOZ feedback-001 (pattern memory visualizer gaps)
- FIFOZ feedback-002 (next release review + audit-066 addendum)
- 42 audit reports (audit-001 through audit-042)

---

## [6.8.2] — 2026-06-03

### Added (M46)
- **Parallel test runner**: `run-e2e-tests.sh --parallel [N]` runs tests concurrently using native bash background subshells. No GNU parallel dependency. Auto-detects CPU count. CI workflows updated to use `--parallel 4`.
- `--help` flag on `run-e2e-tests.sh` documenting all options
- Argument validation: rejects invalid `--parallel` values, unknown flags show hint

### Changed
- Bootstrap safety: pre-flight checks for wrong directory, idempotency guard, cleanup on failure (audits 036-038)
- Update script F-004 dead sed fixed: `acp-core` manifest entry now created if missing
- README: update description corrected, safety warnings added to all install paths
- Visualizer companion: renamed to ACPEnhanced-Visual, updated install instructions

### Fixed
- `scripts/acp-bootstrap.sh`: Step progress counters corrected from `[1/7]`–`[6b/7]` → `[1/8]`–`[6b/8]` (audit-018)
- `README.md`: Bootstrap step count "seven steps" → "eight steps" (audit-018)
- `.gitignore`: Added `IP_REGISTER.md` (legal document, not for version control)
- `README.md`: Install/update curl commands corrected from `prmichaelsen/agent-context-protocol` → `ssucipto/acp-enhanced` (audit-019)
- `agent/commands/git.commit.md`: Version 1.0.0 → 2.0.0, `@git.commit` → `/git-commit` (audit-021)

### Added
- **Light-mode context protocol (R1)**: Two-way mode switching with recommendations. Light mode (~200 tokens) loads identity + progress + recent sessions. Full mode (~800 tokens) for `/acp-init` and architecture sessions. Config in `agent/core/routing.yml → context_modes`. (audit-022, audit-023)
- **Auto-populate lessons from key_facts (R2)**: `/acp-commit` Step 3b auto-migrates session key_facts to `lessons.md` with scope inference, priority detection, and dedup. (audit-022)
- **Command discoverability**: 24 `command_suggestions` entries in routing.yml. Post-command protocol surfaces 2–3 related commands with "when to use" descriptions. Underused-command detection. Getting-started check. (audit-024)
- **Skills → @-mention (R6)**: 7 skills invocable via `@{skill-name}` in chat. `skills_catalog` in taxonomy.yml. Context protocol Step 3 replaced. (audit-022, routes 053–055)
- **Parallel task support (R9)**: `task_type: parallel` and `orchestrator-workers` with DAG-based sub-tasks. A3.1 spawning in `/acp-proceed`. Sub-task schema at `agent/schemas/task.schema.yaml`. (audit-022, routes 056–058)
- **Bootstrap scaffold flags (R3/R4)**: `--team-size solo|small|team` and `--generate-prompts` flags. Manifest `scaffold` config block. (routes 046, 049, 059)
- **Observability dashboard (R8)**: Auto-populated `observability:` section in progress.yaml on `/acp-commit`. Per-executor breakdown, weekly trends. (route-048)
- **Three-copy architecture documented (R5)**: Sync headers on CLAUDE.md and copilot-instructions.md. Rationale documented in AGENT.md. (route-047)
- **Manifest-vs-progress docs (R7)**: "Core Project Files" table in AGENT.md. (route-052)
- `README.md`: shields.io banner (v6.8.2, production pattern, 44/44 milestones, 63 commands). Full ACP Enhanced directory tree. (audit-020)

### Changed
- `agent/progress.yaml`: Version 6.6.0 → 6.8.2. M44 added (100% complete). Recent work refreshed.
- `scripts/PRD-MAIN.md`: Status "Ready for Implementation" → "Implemented — 44 milestones complete"
- `agent/core/routing.yml`: context_modes, command_suggestions, mode_selection added
- `.github/copilot-instructions.md`: Light mode protocol, post-command discoverability, @-mention skills Step 3, observability Step 3c, R2 auto-lessons, variable population instructions

---

## [6.8.1] — 2026-05-12

### Fixed
- `agent/routing/taxonomy.yml`: Added `shell-scripting` entry (executor: deepseek-v4-flash, tokens_est: 4000) — prevents silent fallback to `claude-sonnet` for route-005 and route-011 which use this task type (M43, route-043, audit-017 GAP-001)
- `scripts/acp-validate.ts`: Moved `checkStaleness()` call to after `validateAgentsMdSize()` and `validateSessionsMemory()` in the no-args main block — informational staleness output now appears after blocking validation checks (M43, route-045, audit-016 OBS-001)

### Added
- `agent/routing/ledger.md`: Comment header explaining why `executor: copilot` rows always have blank token/cost data — copilot tasks run inside VS Code with no write-back to ledger; only acp-dispatch.ts tasks populate actuals (M43, route-044, audit-017 R2)
- `agent/routing/rules.md`: Threshold rule for `command-doc-write` vs `command-doc-update` — new protocol sections > 20 lines → write; corrections < 20 net new lines → update; rewriting > 50% → write (M43, route-045, audit-017 R3)

---

## [6.8.0] — 2026-05-11

### Fixed
- `scripts/acp-dispatch.ts`: `updateRoutingYml()` moved after `appendLedger()` — ledger entry now always written before routing.yml update even on partial runs (M42, route-036, BUG-003)
- `scripts/acp-dispatch.ts`: SIGINT handler added — ensures partial ledger row is flushed on Ctrl+C, prevents silent data loss on interrupted dispatches (M42, route-036, BUG-003)

### Added
- `validateSessionsMemory()` in `scripts/acp-validate.ts` — validates `sessions.md` entry structure (required keys, date format); integrated into no-args validate path (M42, route-037, MEMORY-002)
- `validateAgentsMdSize()` in `scripts/acp-validate.ts` — byte-size guard for AGENTS.md, CLAUDE.md, copilot-instructions.md against `agents_md_rules` thresholds in constraints.yml (M42, route-038, VALIDATE-001)
- `checkStaleness()` in `scripts/acp-validate.ts` — informational check: warns if `taxonomy.yml` is >90 days old or if any config.yml model `last_verified` is >180 days ago (M42, route-041, ROUTING-003)
- `agents_md_rules` block in `agent/core/constraints.yml` — defines `max_bytes: 15000`, `warn_at_bytes: 12000`, and `files_to_check` list for AGENTS.md size enforcement (M42, route-038, VALIDATE-001)
- 9 new task types in `agent/routing/taxonomy.yml` (`wiki-update`, `memory-write`, `changelog-update`, `progress-update`, `adr-write`, `audit-run`, `milestone-create`, `route-create`, `upstream-parity-check`); `last_updated: 2026-05-11` header field added (M42, route-039, ROUTING-001/002)
- `agent/design/acp-ux-review.md` — UX analysis document (moved from `scripts/FINAL-REVIEW.md`) (M42, route-042, STRUCT-003)

### Changed
- `runParityCheck()` in `scripts/acp-validate.ts` — rewritten from count-only to Set-based diff; now prints per-filename `❌` for each unmatched command doc or prompt file (M42, route-038, VALIDATE-002)
- `getSkillFile()` in `scripts/acp-dispatch.ts` — `crosscutTypes` list expanded with 9 new task types to match taxonomy additions (M42, route-039, ROUTING-002)
- `getFilteredLessons()` in `scripts/acp-dispatch.ts` — skips lessons with `status: archived`; `agent/memory/lessons.md` archive schema documented in header comment (M42, route-040, MEMORY-001)

### Moved
- `scripts/FINAL-REVIEW.md` → `agent/design/acp-ux-review.md` — UX analysis now inside `agent/` tree and discoverable by context-loading protocol (M42, route-042, STRUCT-003)

---

## [6.7.0] — 2026-05-11

### Added
- `agent/commands/acp.feedback.md` — new command doc for capturing structured feedback (M41a, route-024)
- `agent/commands/acp.task.md` — new command doc for creating/reading/updating routing task files (M41a, route-025)
- `agent/commands/acp.install.md` — new command doc for ACP installation (M41a, route-026)
- `agent/commands/acp.dispatch.md` — new command doc for Persona B/C dispatch flow (M41a, route-027)
- Companion prompt + opencode files for all 4 new commands (12 new files total)
- `scripts/acp-bootstrap.sh`: Step 8 — installs `.git/hooks/pre-commit` to auto-sync `AGENTS.md` → `CLAUDE.md` + `.github/copilot-instructions.md` on commit (M41b, route-032)
- `#### Windows (WSL2) Setup` subsection in `README.md` Requirements — WSL2 install command and native Windows TypeScript note (M41b, route-033)
- `Step 0 — Platform Setup` in `scripts/QUICKSTART.md` for Windows users (M41b, route-033)
- `last_verified: 2026-05-11` field in all 5 model entries in `agent/routing/config.yml` (M41b, route-034)
- `## Branch Safety` section in `README.md` explaining `git_workflow:` config and Step 1b (M41b, route-031)

### Fixed
- `agent/memory/sessions.md`: orphaned YAML block at line ~151 repaired (missing `- date:` header) (M41a, route-022)
- `scripts/acp-dispatch.ts`: replaced hardcoded `HTTP-Referer` placeholder with dynamic values from `identity.yml` (M41a, route-023)
- `agent/wiki/domain.yml`: command count corrected from 58 → 63 to match actual command files (M41a, route-028)
- `agent/core/routing.yml`: `executor: unset` / `model: unset` replaced with Persona A defaults (`copilot` / `github-copilot`) (M41b, route-035)
- `scripts/scripts-package.json`: deleted duplicate file (identical to `scripts/package.json`) (M41b, route-029)

### Docs
- `scripts/QUICKSTART.md`: Step 1 expanded with `git_workflow:` recommendation and example config (M41b, route-031)
- `README.md`: prominent QUICKSTART link added to Install and Quick Start sections (M41b, route-030)
- `agent/skills/typescript.md`: corrected reference from `scripts-package.json` → `scripts/package.json` (M41b, route-029)

---

## [6.6.0] — 2026-05-11

### Added
- `agent/memory/audit-carryovers.md` — new memory layer for tracking unresolved audit findings across sessions (M40, route-018)
- `/acp-audit --pre-impl` flag — 4-phase pre-implementation readiness mode: plan correctness, code cross-reference, carryover check, operational completeness (M40, route-019)
- Step 4.4 in AGENTS.md, CLAUDE.md, .github/copilot-instructions.md — audit-carryovers.md check at session start; surfaces pending findings with ⚠️ warning before any work begins (M40, route-020)
- Quality gate HTML comment in `agent/tasks/task-1-{title}.template.md` — enforces pre-write cross-reference of field names, enums, imports, HTTP methods before verification checklist items are written (M40, route-021)
- `agent/milestones/milestone-40-pre-impl-audit-protocol.md` — M40 milestone record

### Changed
- `agent/commands/acp.audit.md` — v1.0.0 → v1.1.0: added --pre-impl mode (Step 3b), carryover write in Step 4 for all modes, updated verification checklist
- `agent/wiki/architecture.md` — Pre-Implementation Audit Protocol section added
- `agent/wiki/domain.yml` — audit_carryovers memory layer entry added; --pre-impl flag documented

---

## [6.5.0] — 2026-05-11

### Added
- **Git Branch Awareness** (M39): Step 1b in context-loading protocol — warns if working
  on production branch (conditional on `git_workflow:` block in `identity.yml`)
- `git_workflow:` optional block added to `agent/core/identity.yml` with fields:
  `default_working_branch`, `production_branch`, `branch_model`
- Step 0 pre-commit branch guard in `acp.commit.md` (v1.2.0) — STOP if on production branch
- Optional `branch:` field in sessions.md entry schema

### Protocol
- ✅ **M39 Git Branch Awareness** — COMPLETE
  - route-014: `git_workflow:` block in `identity.yml`
  - route-015: Step 1b branch safety check in AGENTS.md/CLAUDE.md/copilot-instructions.md
  - route-016: `acp.commit.md` v1.2.0 — Step 0 guard + `branch:` in session schema
  - route-017: milestone-39 file, version bump, wiki updates

---

## [6.4.13] — 2026-05-09

### Added
- `agent/reports/audit-008-feedback-001-knowledge-preservation.md` — audit report on TikrFlow knowledge loss incident (3 sessions lost to context overflow); 6 findings, 5 decisions (R1–R4 adopted, R5 deferred)
- `agent/milestones/milestone-38-protocol-knowledge-preservation.md` — M38: feedback-001 protocol fixes milestone
- Mid-Session Commit Triggers section in `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` — 7 proactive memory-write triggers; WAL (write-ahead logging) approach to prevent knowledge loss

### Changed
- `agent/core/constraints.yml` — replaced `never_skip_acp_commit` with 6 granular knowledge-preservation rules: `write_lessons_at_discovery`, `write_session_at_phase_boundary`, `write_patterns_at_discovery`, `write_adr_at_decision`, `context_overflow_commit_first`, `validate_prior_session_at_start`
- `agent/commands/acp.commit.md` — v1.0.0 → v1.1.0: frequency changed to "every phase boundary AND session end"; added overflow risk warning; added proactive trigger event list
- `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` — Step 4 gap-check: new substep 2 (compare session date vs today, surface deferred items, note knowledge gaps from git commits post-dating last sessions.md entry)
- `agent/memory/lessons.md` — prepended high-priority `acp-knowledge-gap` postmortem (2026-05-09, task_type: all); documents 3-session TikrFlow loss, 5 correction points

### Protocol
- ✅ **M38 Protocol Knowledge Preservation** — COMPLETE
  - Proactive 7-trigger commit system: milestone phase done, audit creation, ADR, new pattern, correction, context overflow, >5-file commit
  - Commit `4e00a90` (2026-05-09)

---

## [6.4.12] — 2026-05-06

### Added
- `agent/commands/acp.visualize.md` — `@acp.visualize` command: launch TanStack Start dashboard for current project

### Changed
- `AGENT.md` — `@acp.visualize` added to Workflow commands section
- `agent/progress.yaml` — M25 complete: 87% → 100% (8/8 tasks); status: in_progress → completed

### Milestone
- ✅ **M25 ACP Progress Visualizer (P0 MVP)** — COMPLETE
  - task-137: Bootstrap + TanStack Start app
  - task-138: YAML parser + TypeScript data model
  - task-139: Server functions + file-watcher auto-refresh
  - task-140: Milestone table view (@tanstack/react-table)
  - task-141: Milestone tree view with expand/collapse
  - task-142: Fuse.js search + status filter
  - task-143: Dashboard shell (sidebar, ProjectHeader, OverallProgress, NextSteps)
  - task-144: @acp.visualize command

---

## [6.4.11] — 2026-05-06

### Added
- `src/components/ProjectHeader.tsx` (visualizer) — project name, version, status, description
- `src/components/OverallProgress.tsx` (visualizer) — milestone completion bar + counts
- `src/components/NextSteps.tsx` (visualizer) — blue callout for next_steps array

### Changed
- `src/routes/__root.tsx` (visualizer) — full sidebar layout (gray-900 sidebar + header SearchBar)
- `src/routes/index.tsx` (visualizer) — polished home page replacing raw JSON placeholder

### Agent
- `agent/progress.yaml` — M25: 75% → 87% (7/8 tasks)

---

## [6.4.10] — 2026-05-06

### Added
- `src/lib/search.ts` (visualizer) — Fuse.js index builder (threshold 0.35, milestone + task search)
- `src/components/SearchBar.tsx` (visualizer) — controlled text input
- `src/components/FilterBar.tsx` (visualizer) — All|In Progress|Completed|Not Started status filter
- `src/routes/search.tsx` (visualizer) — `/search?q=...` results page

### Changed
- `src/routes/milestones.tsx` (visualizer) — FilterBar wired; status filter composes with Table/Tree

### Agent
- `agent/progress.yaml` — M25: 62% → 75% (6/8 tasks)

---

## [6.4.9] — 2026-05-06

### Added
- `src/components/TaskList.tsx` (visualizer) — task rows with id, name, StatusBadge, estimated/actual hours
- `src/components/MilestoneTree.tsx` (visualizer) — expandable milestone → task hierarchy with Expand All/Collapse All
- `src/routes/milestones.tsx` (visualizer) — Table/Tree tab toggle

### Agent
- `agent/tasks/milestone-25-acp-progress-visualizer/task-141-milestone-tree-view.md` — completed
- `agent/progress.yaml` — M25: 50% → 62% (5/8 tasks)

---

## [6.4.8] — 2026-05-06

### Added
- `src/components/StatusBadge.tsx` (visualizer) — color-coded status badge (completed/in_progress/not_started)
- `src/components/ProgressBar.tsx` (visualizer) — proportional bar with % label
- `src/components/MilestoneTable.tsx` (visualizer) — sortable 9-column table using @tanstack/react-table
- `src/routes/milestones.tsx` (visualizer) — `/milestones` route with live data

### Agent
- `agent/tasks/milestone-25-acp-progress-visualizer/task-140-milestone-table-view.md` — completed
- `agent/progress.yaml` — M25: 37% → 50% (4/8 tasks)

---

## [6.4.7] — 2026-05-06

### Added
- `server/routes/api/progress.ts` (visualizer) — `fetchProgress()` server function reads + parses progress.yaml from filesystem
- `server/routes/api/watch.ts` (visualizer) — `fetchWatchToken()` returns file mtime for polling-based change detection
- `src/lib/data-source.ts` (visualizer) — `useProgressData()` hook with 2s polling auto-refresh
- `src/routes/index.tsx` (visualizer) — live JSON render via `useProgressData()` hook

### Agent
- `agent/tasks/milestone-25-acp-progress-visualizer/task-139-server-route-file-watcher.md` — completed
- `agent/progress.yaml` — M25: 25% → 37% (3/8 tasks)

---

## [6.4.6] — 2026-05-06

### Added
- `src/lib/types.ts` (visualizer) — ProgressData, ProjectMetadata, Milestone, Task, WorkEntry TypeScript interfaces
- `src/lib/yaml-loader.ts` (visualizer) — `parseProgressYaml()` normalises raw YAML → typed data (milestone id + task milestoneId injected)
- `src/lib/yaml-loader.test.ts` (visualizer) — 10 unit tests, all pass
- `test/fixtures/sample-progress.yaml` (visualizer) — representative test fixture

### Agent
- `agent/tasks/milestone-25-acp-progress-visualizer/task-138-yaml-parser-data-model.md` — completed
- `agent/progress.yaml` — M25: 13% → 25% (2/8 tasks)

---

## [6.4.5] — 2026-05-06

### Added
- `tests/acp.validate-ts.test.sh` — 13 assertions covering all M35 checks:
  - Placeholder detection: valid file clean, line 3+4 flagged, code-block excluded, numeric braces excluded
  - Frontmatter: missing Status warned, multiple missing fields produce multiple warnings
  - Parity: 7/7/7 in sync, 6/7 mismatch detected
  - Summary lines verified: all 3 check headers present in output
- `scripts/acp-validate.ts` — `ACP_COMMANDS_DIR`, `ACP_PROMPTS_DIR`, `ACP_OPENCODE_DIR` env var overrides for testability

### Agent
- `agent/tasks/milestone-35-acp-validate-ts-enhancement/task-180-validate-ts-e2e-tests.md` — completed
- `agent/progress.yaml` — M35: 67% → 100% (3/3 tasks), status: completed, current_milestone → M36

---

## [6.4.4] — 2026-05-06

### Added
- `scripts/acp-validate.ts` — `validateFrontmatter()`: checks every `agent/commands/*.md` for required inline bold markers (`**Namespace**:`, `**Version**:`, `**Status**:`, `**Scripts**:`); reports warnings for missing fields
- `scripts/acp-validate.ts` — `runFrontmatterScan()`: no-arg scan of all command files; reports "N files checked, M warnings"
- `scripts/acp-validate.ts` — `runParityCheck()`: triple-file parity check across `agent/commands/acp.*.md`, `.github/prompts/acp-*.prompt.md`, `.opencode/commands/acp-*.md`; reports counts and mismatches as warnings
- `scripts/acp-validate.ts` — no-arg entry point now runs all 3 checks: placeholder scan, frontmatter scan, parity check

### Agent
- `agent/tasks/milestone-35-acp-validate-ts-enhancement/task-179-header-format-validation.md` — completed
- `agent/progress.yaml` — M35: 33% → 67% (2/3 tasks)

---

## [6.4.3] — 2026-05-06

### Added
- `scripts/acp-validate.ts` — `validatePlaceholders()` function: scans lines 3–4 of every `agent/commands/*.md` for unresolved `{PLACEHOLDER}` patterns; excludes fenced code blocks; reports file path, line number, and placeholder name
- `scripts/acp-validate.ts` — `runPlaceholderScan()`: no-arg entry point; reports "N files checked, M errors found"; sets `process.exitCode = 1` when errors found

### Agent
- `agent/tasks/milestone-35-acp-validate-ts-enhancement/task-178-placeholder-detection.md` — completed
- `agent/progress.yaml` — M35: not_started → in_progress, 0% → 33% (1/3 tasks)
- `scripts/package.json` — dependencies installed via npm install

---

## [6.4.2] — 2026-05-05

### Fixed
- `agent/scripts/acp.install.sh` — protect `local.*` skill files from being silently overwritten on upgrade; extends the existing `local.*` convention (already applied to `agent/index/` and `agent/patterns/`) to `agent/skills/`; uses a `case … esac` loop (bash 3.2-safe, macOS-compatible)

### Agent
- `agent/tasks/milestone-29-upstream-integration-audit/task-184-install-skill-local-exclusion.md` — completed
- `agent/progress.yaml` — M29 progress: 0% → 20% (1/5 tasks done)

---

## [6.4.1] — 2026-05-04

### Added
- `agent/artifacts/glossary-1-core-terminology.md` — 42-term core terminology glossary covering all ACP Enhanced concepts (protocol, routing, personas, memory system, opencode integration, workflow terms) with alphabetical index
- `docs/USAGE.md` — new section "ACP Enhanced vs Original ACP — The Memory Layer Explained": per-component breakdown of what is automatic vs what requires user action, including sessions.md, lessons.md, ADRs, and patterns

### Changed
- `README.md` — new "AI Tools & Model Routing" section: persona comparison table, model selection table with exact costs, semi-automatic vs fully automatic routing flows, step-by-step OpenRouter + acp-dispatch.ts setup, daily opencode workflow
- `README.md` — "Differences from Original ACP" table expanded with opencode, preferences, project registry, and cost tracking rows; plain-language value statement added; link to USAGE.md for full automatic vs manual breakdown

---

## [6.4.0] — 2026-05-04

### M27 — Distribution Readiness

- `agent/scripts/acp.install.sh`: Added `.opencode/commands/` copy step so fresh installs via `acp.install.sh` receive opencode slash commands
- `scripts/acp-bootstrap.sh`: Step 6b added — generates `.opencode/commands/*.md` from `.github/prompts/*.prompt.md` during bootstrap
- `AGENT.md`: Updated "Command Invocation Styles" table — added opencode row, removed broken `@acp.*` notation

### M28 — opencode Command Parity

- `.opencode/commands/` (58 files): Full parity with `.github/prompts/` — every `/acp-*` command available in opencode TUI autocomplete
- `agent/scripts/acp.version-update.sh`: Added `.opencode/commands/` update step so existing projects receive new opencode commands on `/acp-version-update`
- `e2e/acp.opencode-commands.test.sh`: New E2E test enforcing 1:1 parity between Copilot and opencode command files (351 assertions across 5 suites: directory, file, content, count, body parity)
- `README.md`: Replaced broken `@acp.*` notation with accurate per-tool invocation table; added opencode to slash commands section; fixed `@git.commit` → `/git-commit`, `@git.init` → `/git-init`
- `CHANGELOG.md`: This entry

---

## [6.3.0] — 2026-05-04

### Added
- 50 new `.github/prompts/*.prompt.md` files registering all ACP commands as VS Code Copilot slash commands with autocomplete (`/acp-proceed`, `/acp-status`, `/acp-plan`, all package/project/preference commands, etc.)
- `git-init.prompt.md` slash command registration for git init workflow
- `scripts/acp-bootstrap.sh`: All 57 prompt file blocks added to section [6/7] so fresh installs receive full slash command autocomplete out of the box

### Internal
- `agent/routing/tasks/task-012.md`: Task tracking for bootstrap prompt coverage

---

## [6.2.5] — 2026-05-01

### M24 — AGENT.md Completeness

**AGENT.md — Added commands:**
- Core Commands: Added `@acp.resume` (Workflow), `@acp.update` (Version & Sync), `@acp.preferences-get` (Preferences), `@acp.projects-restore` (Project Registry)
- Core Commands: Added Git namespace section — `@git.commit`, `@git.init`

**AGENT.md — New section:**
- Three-Persona Deployment Model section: Persona A (Copilot Pro only), Persona B (multi-model DeepSeek via OpenRouter), Persona C (recommended combined). Includes Personas at a Glance table, "Which Persona Should I Use?" decision tree, three-layer context model token estimates, and cross-reference to `scripts/QUICKSTART.md`.

**AGENT.md — Conclusion and Sample Prompts:**
- Conclusion: updated from "Agent Directory Pattern transforms" to "ACP Enhanced transforms"
- Key Takeaways: added Package Ecosystem (item 8) and Token Efficiency ≥60% reduction (item 9)
- Sample Prompts: added legacy/modern note at top of section
- Added `@acp.*` equivalents for all 5 legacy trigger strings (Initialize, Proceed, Update, Check for updates, Uninstall)
- Added "ACP Enhanced Commands Quick Reference" sub-section with 5 daily-use commands

**Housekeeping:**
- M23 session memory written to `.agent/memory/sessions.md`
- Retroactively created `agent/milestones/milestone-17-artifact-commands-system.md`
- Version bumped to 6.2.5 in `AGENT.md`, `package.yaml`, `.agent/core/identity.yml`, `agent/progress.yaml`

---

## [6.2.4] - 2026-05-01 — M23 ACP Enhanced Identity

### Added

- **Title**: Renamed from "Agent Context Protocol (ACP)" to "Agent Context Protocol Enhanced (ACP Enhanced)" in `AGENT.md` header.

- **Metadata**: Added `Fork of` and `Maintained by` fields to the `AGENT.md` metadata block, pointing to upstream and this fork respectively.

- **ACP Enhanced — What's New section**: New table documenting all 15 capabilities that ACP Enhanced adds over the original `prmichaelsen/agent-context-protocol` (Context Loading Protocol, Package Management, Preferences System, Project Registry, Sessions System, Key File Index, Clarification Capture, Design Reference System, Artifact Commands, Metadata Markers, Specs System, Benchmark Suite, YAML Parser, Cross-platform CI, Index Semantic Entry Types). Also includes a "What the Original ACP Provides" subsection to clearly show the baseline.

- **Complete Table of Contents**: Expanded from 14 entries to 24 entries, covering all body sections previously unlisted: ACP Commands, ACP Preferences System, Global Package Discovery, Project Registry System, Sessions System, Experimental Features, Benchmark Suite, Template Source Files, Key File Index, Sample Prompts.

- **Expanded Core Commands list**: Replaced 6-command flat list with a categorized reference covering all 40+ ACP Enhanced commands across 10 categories (Workflow, Planning, Clarification, Artifacts, Package Management, Preferences, Project Registry, Sessions, Key File Index, Version & Sync). *(ACP Enhanced)* labels identify enhancements beyond the original ACP.

### Changed

- **"What is ACP?" → "What is ACP Enhanced?"**: Section renamed and body text updated to describe ACP Enhanced.
- **"How to Use the Agent Pattern" → "How to Use ACP Enhanced"**: Section renamed.
- **Overview paragraph**: Updated to introduce ACP Enhanced as a fork and extension.

---

## [6.2.3] - 2026-05-01 — M22 Documentation Accuracy Audit

### Fixed

- **FIX-A** (`AGENT.md` directory tree): Removed ghost `agent/files/` entry (directory does not exist on disk). Added 7 missing directories: `agent/artifacts/`, `agent/benchmarks/`, `agent/clarifications/`, `agent/feedback/`, `agent/schemas/`, `agent/scripts/`, and template files at `agent/` root level (`manifest.template.yaml`, `package.template.yaml`, `progress.template.yaml`, `projects.template.yaml`, `sessions.template.yaml`). Also added `AGENTS.md` at project root level. Restructured tree for logical grouping.

- **FIX-B** (`AGENT.md` stale references): Replaced stale `@acp.install` reference (no longer a command; the feature is now `@acp.package-install`, which has been shipped since M3). Fixed two occurrences of `unacp.install.sh` → `acp.uninstall.sh` (wrong script name in the "Uninstall Prompt" sample section).

- **FIX-C** (`scripts/AGENTS.md` bootstrap template): Added two bash-safety anti-patterns to the "Anti-Patterns (Never Do These)" section. These were already present in this project's own `.github/copilot-instructions.md` but missing from the bootstrap template distributed to new projects: `Never use set -e without trapping errors in bash scripts` and `Never write bash that breaks on macOS (BSD sed, date +%N differences)`.

---

## [6.2.2] - 2026-05-01 — M20 + M21 Consistency Cleanup and Functional Readiness

### Fixed

#### M20 — Notation Standardization (commit 393d9e6)

- **BUG-A** (9 command files): Fixed directive header pretend-context lines using `@acp-*` hyphen notation → dot notation. Files: `acp.audit`, `acp.clarification-address`, `acp.clarification-create`, `acp.handoff`, `acp.sessions`, `acp.spec`, `acp.version-check`, `acp.version-check-for-updates`, `acp.version-update`. LLMs reading these files were taught the wrong invocation notation.

- **BUG-B** (5 command files, ~26 occurrences): Fixed body-text `@acp-*` references in examples, related commands, tips, and troubleshooting sections. Files: `acp.init` (~11), `acp.status` (~8), `acp.handoff` (2), `acp.proceed` (1), `acp.spec` (6).

- **BUG-C**: Fixed `AGENT.md` directory tree comments — `# @acp-init`, `# @acp-proceed`, `# @acp-status` → dot notation.

- **BUG-D** (package.yaml): Added 13 missing commands and 1 missing script that were introduced in M6/M7/M15/M16 but never synced to `package.yaml`. Added: preferences system (5 commands), project registry extended (5 commands), `acp.design-reference`, `acp.clarification-capture`, `acp.clarification-create`, `acp.preferences.sh`.

- **BUG-E**: Added missing CHANGELOG entry for post-M19 audit fixes (commit `afcf61d`). Documents BUG-14 through BUG-19 including the CRITICAL `_flat_dot_get()` fallback fix.

#### M21 — Functional Readiness Audit

- **BUG-A** (9 command files): Fixed unfilled `@{namespace}-{command-name}` template placeholder in pretend-context directive lines. Files: `acp.package-create`, `acp.package-install`, `acp.proceed`, `acp.plan`, `acp.project-create`, `acp.report`, `acp.resume`, `acp.task-create`, `git.commit`. These files were created from the template but the placeholder was never replaced with the actual command name.

- **BUG-B** (CRITICAL — onboarding): Fixed `README.md` bootstrap `curl` URL — referenced `main` branch which does not exist; the repository uses `mainline`. Every new user attempting to follow the install instructions received a 404.

- **BUG-C** (3 files): Bumped version from `6.2.1` → `6.2.2` in `package.yaml`, `AGENT.md`, `.agent/core/identity.yml`.

- **BUG-D** (7 scripts): Added 7 missing scripts to `package.yaml` scripts section: `acp.project-info.sh`, `acp.project-remove.sh`, `acp.project-update.sh`, `acp.projects-restore.sh`, `acp.projects-sync.sh`, `acp.meta-scan.sh`, `acp.package-install-optimized.sh`.

---

## [6.2.1] - 2026-05-01 — M19 Preferences System Bug Fix

### Fixed

- **BUG-1**: Replaced all `yaml_query(file, path)` calls with `yaml_get(file, path)` in `acp.preferences.sh` — `yaml_query` takes only one argument; every preference resolution was broken
- **BUG-2**: Rewrote `generate_preferences` to enumerate preferences via `_index` array in configurables + indexed `yaml_get`; previously always emitted empty namespace block
- **BUG-3**: Replaced `yaml_get_array` + `grep -oP` option iteration with indexed `yaml_get` loop in `validate_preference`; previously always rejected valid string options
- **BUG-4**: Migrated all preference test fixtures from flat-dot keys to nested YAML format; `yaml_get` path traversal now resolves correctly
- **BUG-5**: Removed dead `indent_key` variable in `set_preference`; replaced sed-based value replacement with awk (injection-safe — no delimiter sensitivity)
- **BUG-6**: Replaced `bc`-based number range checks with bash integer arithmetic `(( value < min ))`; `bc` absent on Alpine and many CI environments
- **BUG-7**: Changed `acp.common.sh` shebang from `#!/bin/sh` to `#!/usr/bin/env bash`; file uses bash arrays and `${BASH_SOURCE[0]}`
- **BUG-8**: Added `trap 'cleanup_ast' EXIT` and `cleanup_ast` call inside `init_ast` in `acp.yaml-parser.sh`; temp files were leaking on unexpected exit
- **BUG-9**: Removed duplicate "Repository cloned" success message in `acp.package-install.sh`
- **BUG-10**: `get_preference_source` now returns exit 0 for the `"none"` case (valid non-error state)
- **BUG-11**: Documented `yaml_query` map/array colon-suffix behavior in function header comment
- **BUG-12**: `_yaml_sed_i` in `acp.yaml-parser.sh` now delegates to `_sed_i` when `acp.common.sh` is also loaded
- **BUG-13**: `AGENT.md` version corrected from `5.41.0` to `6.2.0` (prior session)

### Added

- `_index` array added to `agent/configurables/acp.configurables.yaml` listing all 8 preference ids — required by `generate_preferences`

### Post-M19 Audit Fixes (commit afcf61d)

- **BUG-14 (CRITICAL)**: Added `_flat_dot_get()` fallback to `acp.preferences.sh` (8 locations) — production preference files use flat-dot key format (`  plan.draft.create_mode: val`) but M19's `yaml_get` reader requires nested YAML; all preference reads were silently returning empty. Fallback allows both formats to work
- **BUG-15**: Removed stale duplicate footer from `agent/commands/acp.plan.md` — Version: 1.0.0 / Created: 2026-02-22 block contradicted the canonical Version: 2.0.0 header
- **BUG-16**: Fixed `.agent/core/identity.yml` version 6.2.0 → 6.2.1 (M19 bump was missed in this file)
- **BUG-17**: Fixed `@acp-init` → `@acp.init` in `agent/commands/acp.init.md` directive header
- **BUG-18**: Fixed `@acp-status` → `@acp.status` in `agent/commands/acp.status.md` directive header
- **BUG-19**: Fixed `@acp-index` → `@acp.index` in `agent/commands/acp.index.md` directive header

### Added (Post-M19 Audit)

- `docs/USAGE.md`: Comprehensive step-by-step day-to-day usage guide covering session lifecycle (`@acp.init` → `@acp.plan` → `@acp.proceed` → `@git.commit` → `/acp-commit`), preferences, packages, key file index, command quick-reference table, and troubleshooting

---

## ACP Enhanced Fork

This project is a fork of [Agent Context Protocol](https://github.com/prmichaelsen/agent-context-protocol)
by [@prmichaelsen](https://github.com/prmichaelsen). All original ACP content is preserved.

### Enhanced additions (on top of original ACP)

- **`.agent/` Framework Layer** — structured context management system for the AI agent:
  - `.agent/core/` — identity, constraints, token budget (loaded every session)
  - `.agent/skills/` — domain-specific guidance loaded one file per session
  - `.agent/routing/` — task taxonomy for classifying work and routing to skill files
  - `.agent/memory/` — tiered memory: session log, lessons learned, patterns, ADRs
  - `.agent/wiki/` — reference docs loaded section-by-section within token budget
- **Context Loading Protocol** — 6-step deterministic protocol in `AGENTS.md` / `.github/copilot-instructions.md` enforcing a 2,800-token budget
- **Correction Protocol** — automatic lesson capture to `.agent/memory/lessons.md` on every developer correction
- **Session Commit Protocol** (`/acp-commit`) — structured session summaries with auto-compaction
- **Task Routing** (`/acp-route`) — classifies tasks by type, selects executor and context files
- **ADR Command** (`/acp-decide`) — records architectural decisions with explicit DO NOT re-open guards
- **Bootstrap script** (`scripts/acp-bootstrap.sh`) — one-command setup of the full `.agent/` structure in a new project
- **`scripts/AGENTS.md`** — generic project template for the context loading protocol

---

## [6.2.0] - 2026-05-01

### Added
- **Preferences System** (`agent/scripts/acp.preferences.sh`): Multi-level preference configuration with 4-level precedence (Project > Workspace > User > Default). Functions: `get_preference`, `has_preference`, `get_preference_or`, `get_preference_source`, `generate_preferences`, `set_preference`, `validate_preference`, `get_preference_with_preset`, `load_preset`, `list_presets`.
- **Configurables** (`agent/configurables/acp.configurables.yaml`): 9 preferences across 5 categories — plan (draft.create_mode, batch.auto_confirm), task (create.granularity, create.auto_number), validation (auto_fix.enabled, strict_mode.enabled), output (verbosity.level), git (auto_commit.enabled).
- **Project-Level Defaults** (`agent/preferences/acp.default.yaml`): Project-level preference values for the ACP namespace.
- **Preference Commands**:
  - [`@acp.preferences-get`](agent/commands/acp.preferences-get.md) — Resolve and generate the effective preference set for a namespace
  - [`@acp.preferences-show`](agent/commands/acp.preferences-show.md) — Display effective preferences with source attribution (📁/💼/👤/⚙️)
  - [`@acp.preferences-set`](agent/commands/acp.preferences-set.md) — Set a preference value at a specified level with validation
  - [`@acp.preferences-create`](agent/commands/acp.preferences-create.md) — Create a preference file at user/workspace/project level
  - [`@acp.preferences-validate`](agent/commands/acp.preferences-validate.md) — Validate all preference files against configurables schemas
- **Preset System**: Three built-in workflow presets:
  - `acp.batch-planning` — contextual mode, auto-confirm, quiet output
  - `acp.interactive-planning` — guided mode, manual confirm, verbose output
  - `acp.rapid-prototyping` — contextual mode, auto-commit, minimal output
- **`--preset` flag** on `@acp.plan`: Load a named preference bundle for a single invocation. CLI overrides still beat presets.
- **`--presets` flag** on `@acp.preferences-show`: List available presets instead of showing preference values.
- **Package Preference Support**: Packages can now bundle configurables and preset preference files.
  - `agent/schemas/package.schema.yaml` — new `contents.configurables` and `contents.presets` fields
  - `agent/scripts/acp.package-install.sh` — copies `*.configurables.yaml` and preset `*.yaml` on install (non-destructive)
  - `agent/scripts/acp.package-create.sh` — scaffolds `agent/configurables/<pkg>.configurables.yaml` + `agent/preferences/<pkg>.default.yaml`
  - `agent/scripts/acp.package-validate.sh` — `validate_configurables()` checks YAML syntax, id dot-paths, and package.yaml listing
- **Test Suite** (`tests/acp.preferences.test.sh`, `tests/acp.preferences-validate.test.sh`, `tests/acp.preferences-preset.test.sh`, `e2e/acp.plan-with-preferences.test.sh`): 26+ tests covering precedence, validation, preset loading, and @acp.plan integration.

### Changed
- **`@acp.plan` v2.0.0**: Step 1 now invokes `@acp.preferences-get acp`, parses `--preset` and `--<pref.path>` CLI overrides, merges with precedence (CLI > preset > preferences), and stores the effective map. Step 4 Option A uses 3-level dispatch: override → preference → ask user.
- **`agent/scripts/acp.preferences.sh`** CLI: added `set`, `validate`, `load-preset`, `list-presets` subcommands.

### Technical Details
- Preferences are pure YAML; no external dependencies beyond the existing `acp.yaml-parser.sh`
- Namespace isolation: each package owns its own namespace (e.g., `acp`, `my-package`)
- Backward compatible: all commands skip gracefully if `@acp.preferences-get` is unavailable



### Added
- **D-IDs for designs** — designs now carry `D<N>` labels on atomic, addressable units (decisions, code snippets, schemas, interfaces, algorithms, formulas, key invariants, diagrams). This gives designs the same exact-reference surface that specs already have with `R<N>`. Tasks declare which design units they inline via `incorporates: D1, D3` in their task marker (mirroring `covers: R10, R11` for specs).
- **Marker schema additions**:
  - `decisions:` on design markers — records the D-ID range or list (e.g. `D1..D8` or `D1, D3, D7`)
  - `design:` + `incorporates:` on task markers — path to the referenced design, and the specific D-IDs the task inlines
- **`@acp.validate` Step 5.1 (Self-Containment Probes)** — three reading-comprehension checks run on every incomplete task (status `draft | in_progress | not_started`; completed tasks skipped). Validate is LLM-executed, so probes judge content, not regex fingerprints.
  - **Probe 1 (spec inlining)**: for each R-ID in task's `covers:`, confirm the R-ID's requirement text is reflected in the task body. Flag missing R-IDs with specific suggestions.
  - **Probe 2 (design inlining)**: for each D-ID in task's `incorporates:`, confirm the D-ID's atomic unit (code snippet, decision, schema, etc.) is in the task body. If the design has D-IDs but the task has no `incorporates:` field, soft-warn. Legacy designs without D-IDs get a holistic "does the task reflect substantive design content" check.
  - **Probe 3 (clarification inlining)**: for each clarification with `resolves:` pointing at this task and `resolved: true`, confirm the resolved decisions appear in the task body.
- **Validate Step 12 report** gains a "Self-Containment" section. All probe findings are **soft warnings** — overall status becomes "Passed with warnings" rather than "Failed" when only self-containment issues exist.
- **`@acp.sync` Step 1.4 Pass C** — backfill D-IDs in legacy designs. Scans each design for candidate atomic units (headings, fenced code blocks, tables, definition paragraphs), proposes D-ID labels for user approval. Never silent.

### Changed
- **`@acp.task-create` Step 5.5** — now records which D-IDs the task inlines. When extracting design content, the agent notes the specific `D<N>` IDs of the atomic units copied into the task body; Step 6 writes them into the task marker's `incorporates:` field.
- **`@acp.task-create` Step 6** — populates `design:` and `incorporates:` marker fields (both optional; omit when no design applies).
- **`@acp.design-create` Step 5** — during design generation, the agent labels atomic units with `D<N>` IDs and populates the marker's `decisions:` field with the resulting range/list.
- **Design template** — D-ID labeling guidance block at the top of the template with per-unit-type examples. Marker stub gains `decisions:` field.
- **Task template** — marker stub gains `design:` and `incorporates:` fields.
- **AGENT.md "Metadata Markers"** section gains a "D-IDs for designs" subsection with labeling conventions, numbering rules, and migration guidance. Field catalog updated.

### Motivation
v5.40.0 made markers authoritative but didn't enforce the Self-Contained Task Principle — a task could still claim `covers: R12` in its marker and ship without R12's text in the body. Validate probes close that loop. D-IDs extend the same rigor to designs: tasks that need a specific design decision or code snippet can now reference it by exact ID and validate confirms the inlining.

### Migration (for existing ACP projects)
1. Run `@acp.sync` once — Pass C proposes D-IDs for legacy designs; user approves per candidate.
2. Run `@acp.validate` — Probe findings appear as warnings for any incomplete task whose inlining drifted from its claims.
3. New designs created with `@acp.design-create` get D-IDs automatically.

## [5.40.0] - 2026-04-28

### Changed
- **Markers supersede prose frontmatter.** Templates no longer carry prose fields that duplicate marker fields. The marker is the single source of truth; prose no longer mirrors it.
- **Fields removed from templates** (now lived only in the marker):
  - `**Status**` — removed from spec, task, design, milestone, pattern, clarification, research, glossary, reference templates
  - `**Last Updated**` — removed from spec template (use marker `updated:`)
  - `**Last Verified**` — removed from research/glossary/reference templates (use marker `last_verified:`)
  - `**Confidence**` — removed from research/glossary/reference templates (use marker `confidence:`)
  - `**Milestone**` — not applicable; stayed in task template (as a link, not a status field)
  - `**Dependencies**` — removed from task, milestone templates (use marker `depends_on:`)
  - `**Applicable To**` — removed from pattern template (use marker `applies_to:`)
- **Fields kept in prose** (not duplicated by markers): `**Namespace**`, `**Version**`, `**Created**` (immutable), `**Design Reference**`, `**Estimated Time**`, `**Duration**`, `**Goal**`, `**Concept**`, `**Purpose**`, `**Category**`, `**Type**`, `**Sources**`, `**Total Terms**`.
- **Creation commands updated** (`acp.task-create`, `acp.clarification-create`) to NOT write `**Status**` prose fields. Example outputs no longer show `Status: ...` lines.
- **`acp.sync` Step 1.4** split into two passes: (A) add missing markers, (B) remove superseded prose frontmatter from files that already have markers. Both prompt per file with diff-like preview; never silently writes.
- **AGENT.md "Metadata Markers" section** adds a "Markers supersede prose frontmatter" subsection documenting the supersession table and authoritative sources (marker for document state, `progress.yaml` for task-lifecycle state).

### Motivation
v5.38.0 + v5.39.0 shipped markers alongside the existing prose frontmatter, leaving `status` (and a few other fields) duplicated. Duplication drifts — one place says "Active," the other says "Draft," and neither is obviously authoritative. v5.40.0 resolves this by making the marker the only source and removing the prose copies.

### Migration (for existing ACP projects)
Run `@acp.sync` once. Step 1.4 Pass A backfills missing markers; Pass B prompts to remove superseded prose fields per file. No silent rewrites. Users can approve, edit, or skip each change.

## [5.39.0] - 2026-04-28

### Changed
- **`@acp.task-create` Step 5.6** — now invokes `./agent/scripts/acp.meta-scan.sh --kind spec agent/specs/` to narrow candidate specs via marker `topic:` keywords, then opens only the 1-3 relevant specs to extract verbatim R<N> descriptions. Replaces "scan every spec file by filename and section content." Falls back to legacy filename scanning if no spec markers exist yet (warns user to backfill via `@acp.sync` Step 1.4).
- **`@acp.task-create` Step 6** — now explicitly populates the `@acp.meta.task` marker block fields (topic, description, milestone, spec, covers, depends_on, status, updated) at file creation, replacing the template's `{placeholder}` values. Report Success step confirms no placeholder text remains.
- **`@acp.spec` Step 6** — now populates the `@acp.meta.spec` marker block (topic, description, requirements range R1..R<N>, status, updated) at file creation.
- **`@acp.design-create` Step 5** — populates `@acp.meta.design` marker (topic, description, informs, depends_on, status, updated).
- **`@acp.pattern-create` Step 5** — populates `@acp.meta.pattern` marker (topic, description, applies_to, status, updated).
- **`@acp.clarification-create` Step 6** — populates `@acp.meta.clarification` marker (topic, resolves, resolved=false, status, updated).
- **`@acp.sync` new Step 1.3** — runs `./agent/scripts/acp.meta-scan.sh agent/` once and caches the marker inventory for the rest of the sync cycle. Steps 1.5, 1.6, 5, and 6 consume this cached stream instead of reading files repeatedly.
- **`@acp.sync` new Step 1.4 (Backfill)** — for files in marker-eligible directories without markers, proposes a marker derived from filename + headings and prompts user for confirmation. Never silently writes. User can accept, edit, skip, or skip-all-remaining.
- **`@acp.sync` Steps 1.5 / 1.6** — rewritten to drive off marker data: spec inventory comes from marker `requirements:` fields (expanding `R1..R30` range notation), task claims come from marker `covers:` fields, code implementation status from code marker `implements:` fields. One pass across all markers instead of N passes across N files.

### Added
- Marker-based cross-referencing now detects, during sync:
  - **Unclaimed requirements** (spec R<N> in no task's `covers:`) — planning gap
  - **Unimplemented claims** (task `covers: R<N>` marked `status: complete` but no code `implements: R<N>`) — completion drift
  - **Duplicated claims** (R<N> in multiple tasks' `covers:`) — flagged for review
  - **Stale markers** (`status: complete` but `updated:` > 6 months old) — possibly out-of-date

### Motivation
v5.38.0 shipped the marker system foundation. Without this wiring, the markers were interoperable-by-hand but not automatic. v5.39.0 makes the spec→task→code traceability chain run by itself: every new task automatically claims the right requirements, every sync cycle surfaces every gap.

### Out of scope (deferred)
- Frontmatter consolidation (duplicated `status` between marker and prose) — deferred.
- `acp.validate` task-inlining check — deferred, noted in memory.
- Retroactive marker population in ACP's own existing files — hand-curated as needed.

## [5.38.0] - 2026-04-28

### Added
- **Language-agnostic `@acp.meta.*` marker system** — documents (and optionally source code files) carry machine-readable metadata markers that let orchestrators map the repo in one awk pass instead of reading every file. Markers work in markdown, TypeScript, Python, Rust, SQL, shell, YAML — any file where comments can host two sentinels (`@acp.meta.<kind>` opening, `@acp.meta.end` closing).
- **Parser script** `agent/scripts/acp.meta-scan.sh` — single source of truth for marker discovery and parsing. Supports `--kind spec|task|code|...` filtering. Output is a flat `file:` / `kind:` / `key:` stream with `---` between blocks, consumable by downstream shell, another awk pass, or an LLM prompt.
- **Eight marker kinds**: `spec`, `task`, `design`, `milestone`, `pattern`, `clarification`, `artifact`, `code`. Each has a documented field catalog (required + optional) in AGENT.md.
- **`code` marker** — NEW. Source files can declare which spec requirements they implement via `implements: R10, R11`. Enables spec→task→code traceability in one awk pass: a task `covers:` an R-ID, a code file `implements:` it, an orchestrator grep correlates them without opening any file.
- **Template stubs** — every document template now includes a pre-filled `@acp.meta.*` marker block: spec, task, design, milestone, pattern, clarification, and all three artifact templates (research, glossary, reference).
- **AGENT.md "Metadata Markers" section** — documents sentinel syntax, per-language comment forms, field catalog per kind, and the parser script.

### Motivation
During Iris's M10 milestone, six sub-agents independently reported "done," but a post-hoc audit caught 8 integration bugs and a missing UX slice (character bubble attribution, help button). Spec requirement R20 (help system) was in the spec but no task claimed it — nothing flagged it until after shipping. Markers make that failure mode mechanical to detect: awk over the whole repo, diff task `covers:` against spec `requirements:`, surface gaps immediately.

### Planned (follow-up, not in this release)
- Creation commands (`@acp.task-create`, `@acp.spec`, `@acp.design-create`, etc.) auto-populating markers at file creation — partially wired; full integration deferred to 5.39.0.
- `@acp.sync` consuming the marker stream for cross-reference traceability (Steps 1.5 / 1.6 already describe the goal; consuming the script output wired in 5.39.0).
- Frontmatter consolidation — `status` and a few other fields now live in BOTH the marker block AND the prose frontmatter. Migration deferred to a later release.

## [5.37.0] - 2026-04-27

### Added
- **Task template** — new required `User-Observable Acceptance` section in every task. At least one acceptance criterion describing what a user can observe after task completion, or a justified `N/A —` line (≥10 chars of reason) for pure refactors/internal work. Feature tasks must not be N/A.
- **Task template** — new conditional `Spec Coverage` section. Populated automatically by `@acp.task-create` when a matching spec exists in `agent/specs/`. Lists the `R<N>` requirements this task claims, with each requirement's description copied verbatim from the spec so sub-agents have inline requirement text (no need to open the spec file).
- **`@acp.task-create` Step 5.6** — cross-references `agent/specs/` for matching specs. Extracts requirement IDs, behaviors, and test names scoped to the task topic.
- **`@acp.sync` Step 1.5 / 1.6** — reads `agent/specs/` and builds a traceability map: every `R<N>` → which tasks claim it → whether the claim is implemented in code. Steps 5 and 6 now surface unclaimed requirements (planning gaps), unimplemented claims (completion drift), and drifted implementations (code/spec mismatch).
- **AGENT.md** — new "Specs" core component section (#2), `agent/specs/` added to directory tree, `@acp.spec` mentioned in the new-project workflow.

### Changed
- **`@acp.proceed` Step 3.5 (Post-Completion Audit)** — substantially expanded from 5 bullet points to a 7-part mechanical audit: (A) re-read task doc, (B) file checks, (C) walk verification checklist with claim verification, (D) audit `User-Observable Acceptance`, (E) audit `Spec Coverage`, (F) produce traceability report, (G) decide with drift-remediation protocol. Orchestrator must not trust sub-agent "done" reports — every claim is mechanically verified.
- **Drift remediation protocol** — when Step 3.5 finds drift, the orchestrator must: (1) update the task document with a `## Drift Remediation` section listing every drifted item, (2) spawn a mandatory remediation sub-agent with verbatim drift list, (3) re-run Step 3.5 from scratch after the sub-agent reports done. No inline drift fixes; drift becomes a durable artifact in the task doc.
- **Self-Contained Task Principle** in `@acp.task-create` strengthened from advisory to mandatory: every snippet, requirement, interface, schema, example, and edge case relevant to a task MUST be inlined verbatim. Sub-agents do not read design docs, specs, or hunt for context — they read only the task file. Duplication is intentional and is the cost of sub-agent reliability.

## [5.36.0] - 2026-04-27

### Added
- **Phase 12: Interactive OQ Resolution** for `@acp.spec` — after spec generation, summarizes results, reports Open Questions and `undefined` Behavior Table rows, and offers interactive resolution session
- Concept block workflow: groups related OQs by shared invariant/pattern, orders by blast radius, presents with problem statement + options + recommendation
- Single-keystroke decision prompts (a/b/c/d) with freeform override support
- Line-by-line mode for per-item nuanced decisions (option d)
- Batch editing: moves OQs to Resolved, updates Behavior Table, adds tests, commits at session close
- `--resolve-oqs` flag to opt-in for `--from-*` modes
- `--no-interactive` flag to skip Phase 12 entirely
- Failure handling: detects contradictions, flags cross-block conflicts, supports `/revise <block>`

### Changed
- `@acp.spec` version 1.0.0 → 1.1.0 (new Phase 12)
- Phase 12 runs by default (unless `--no-interactive`), enabled for `-i`, opt-in for `--from-*`
- Package version 4.12.0 → 4.13.0
- Project version 6.1.0 → 6.2.0

### Rationale
- Based on proven scenecraft pattern: 13 blocks in 90 minutes closed ~110 OQs
- Provides guided path through Open Question resolution that was previously missing
- Clustering related OQs reduces cognitive load and ensures policy decisions close multiple OQs at once
- Blast radius ordering means early decisions cascade and close downstream OQs, reducing total work

## [5.35.0] - 2026-04-24

### Added
- **`-i` / `--interactive` flag** for `@acp.clarification-create` — one-question-at-a-time chat mode, distinct from the default chat-based mode that still generates a file
- Explicit "Interactive Mode" section documenting the transient-by-default behavior

### Changed
- `@acp.clarification-create` interactive mode is now **transient by default** — no file gets written unless the user explicitly asks ("save this as a clar", "write the file", "persist this"). Clarifications feed directly into the next command via chat context
- Step 5 (Generate Questions) now branches three ways: file-based (`--file`), chat-based (default, generates file), interactive (`-i`, no file unless requested)
- `@acp.clarification-create` version 1.1.0 → 1.2.0 (new mode)

### Rationale
- Pre-generating 20+ questions forces the user to context-switch through the whole document before any feedback loop. One-at-a-time lets the agent adapt — if an answer reveals a misunderstanding, the agent can correct course on the next question instead of committing everything to a file
- Most clarifications are transient (used once to reach alignment, then consumed by the next command), so default file-generation is wasted work

## [5.34.0] - 2026-04-24

### Added
- **`--stacked` flag** for `@acp.proceed` — completes an entire milestone using a chain of stacked worktrees. Task N's worktree branches from Task N-1's worktree, building up changes incrementally. Nothing merges to main until the user approves at the end, giving the user a single approval gate for the whole milestone
- Branch naming convention for stacked worktrees: `acp/stack/{milestone-slug}/task-{id}`
- Worktree directory convention: `.claude/worktrees/stack/{milestone-slug}/task-{id}/` (follows Claude Code's existing `<repo>/.claude/worktrees/` convention)
- Section A11 (Stacked Worktree Mode) in `@acp.proceed`: full workflow covering chain creation, per-task `@git.commit`, final merge approval prompt (`merge` / `diff` / `abort`), cleanup after merge, and halt-and-preserve on failure
- `--dag` / `--graph` future flags documented (parallel-within-stack using `@acp.plan` dependencies) — not yet implemented
- NLP matching for stacked mode: `stack`, `stacked`, `stack the milestone`, `chain worktrees` keywords
- Examples 8-9 in `@acp.proceed`: stacked mode, stacked + yolo

### Changed
- `@acp.proceed` version 2.0.0 → 2.1.0 (new execution mode)
- `--stacked` implies `--complete --worktrees` and is mutually exclusive with `--parallel` (stacked is inherently sequential)
- Final merge to main uses regular merge (preserves per-task atomic commits) — explicitly not squash
- Failure mid-stack halts execution and **preserves the entire worktree chain** so the user can inspect or resume

## [5.33.0] - 2026-04-23

### Changed
- `@acp.clarification-create` now instructs the agent to **default to a strong recommendation in yes/no form** on every question it can take a stance on. Old guidance said recommendations were optional and "do NOT force a recommendation when neither option is clearly better" — new guidance flips this: a confident recommendation the user rejects with one keystroke (`n`) is cheaper than a neutral question that forces them to write a sentence. Wishy-washy hedging is explicitly banned; if a rationale takes more than one clause, the question belongs in `@acp.clarification-address` for research instead.
- **Answer-effort principle** added to `@acp.clarification-create`: long clarifications are fine, but long *user replies* mean the questions were authored poorly. Goal is that the user can work through the whole document typing mostly just `y` / `n`, writing prose only where they want to override the recommendation.
- Multi-option per-item clarification format now requires an explicit `recommend: yes` / `recommend: no` on each bullet so users can accept or override each independently with a single keystroke.
- Prose-answer questions now explicitly reserved for genuinely open-ended fields (names, descriptions, free-text context); anything else should be re-framed as y/n with a recommendation.
- `@acp.clarification-create` version bumped 1.0.0 → 1.1.0 to reflect the behavior change.

## [5.32.0] - 2026-04-23

### Added
- **Behavior Table** section added to the `@acp.spec` default structure and `agent/specs/spec.template.md` — a scannable 4-column catalog (`#`, `Scenario`, `Expected Behavior`, `Tests`) that serves as the reviewer's primary proofing surface
- `` `undefined` `` convention (code-literal) for Behavior Table rows where the source artifacts did not resolve a scenario — surfaces ambiguity explicitly instead of silently guessing
- `OQ-N` Open Question identifiers, cross-referenced from Behavior Table rows via `→ [OQ-N](#open-questions)` links
- Behavior Table integrity rules: every test in the Tests section must appear in at least one row's `Tests` column (no orphan tests); every `undefined` row must have a matching Open Question (no orphan undefineds)
- Full worked example in the template showing 7 defined rows + 3 `undefined` rows for a login endpoint, demonstrating happy → bad → edge → undefined row-ordering convention

### Changed
- `@acp.spec` Core Principle now frames the Behavior Table as the reviewer's primary proofing surface and the Tests section as the executable proof of the contract
- Verification checklist in `@acp.spec` enforces Behavior Table presence, orphan-test prevention, and orphan-`undefined` prevention

## [5.31.0] - 2026-04-22

### Added
- `@acp.spec` command — generate a specification document from a clarification, design, draft, requirements doc, or interactive input (sources are mutually exclusive: `--from-clar`, `--from-design`, `--from-draft`, `--from-req`, `-i`/`--interactive`)
- `agent/specs/` directory convention for storing specification documents
- `agent/specs/spec.template.md` — spec template with Purpose, Source, Scope, Requirements, Interfaces/Data Shapes, Behavior, Acceptance Criteria, Tests (Base Cases + Edge Cases), Non-Goals, Open Questions, Key Design Decisions, Related Artifacts
- Tests section convention: language-agnostic `Given`/`When`/`Then` format with kebab-case test names, short-slug assertion identifiers, support for single-sentence or bulleted `Given`/`When`, and multiple assertions per test
- Comprehensive-coverage requirement for specs: all four dimensions (happy path, bad path, positive assertions, negative assertions) must be represented across Base + Edge Cases combined
- Concurrency-probe requirement in interactive spec mode: the agent must explicitly ask about mutex/locks, async operations, event queues, background workers, and transactions (each with their own hazard-class edge-case tests)
- Spec-as-proof principle documented in `@acp.spec`: the complete spec defines the end-system behavior exactly, enabling the user to proof scenarios before code is written and making TDD mechanical

### Changed
- `package.yaml` version 4.7.0 → 4.8.0 (new command added to `contents.commands`)
- `README.md` Entity Creation section lists `@acp.spec`

## [5.30.0] - 2026-03-21

### Added
- Step 0 (Display Command Header) added to all 46 command files — shows purpose, usage/args, and related commands on invocation
- Step 0 added to command.template.md as the default for new commands

### Changed
- @acp.plan steps renumbered (0→11) to accommodate new Step 0 header before existing Step 0 (Read Contextual Key Files)
- @acp.proceed --parallel no longer implies worktrees; --worktrees is now explicit opt-in
- @acp.proceed --turbo/--yolo no longer expand to --parallel

## [5.29.0] - 2026-03-20

### Added
- Index semantic entry types: `path: null` entries with `kind: note` (factual context) and `kind: directive` (behavioral instructions) in agent/index/*.yaml
- Inline entries use the `description` field as content, with same `weight`/`applies` filtering as file entries
- Display icons in init/proceed/plan: 📝 for notes, ⚡ for directives
- Validation rules for path/kind consistency in @acp.validate

### Changed
- Collapsed `requirements` kind into `design` (accepted as deprecated alias)
- Section header broadened from "Reading Key Files" to "Reading Key Files & Context"
- Updated kind enum from 4 values to 5: `pattern`, `command`, `design`, `note`, `directive`

## [5.28.9] - 2026-03-20

### Added
- `--noworktreemerge` / `--holdmerge` / `--safemerge` / `--safe` flag for @acp.proceed — gates worktree merges in parallel mode, prompting user before each merge to prevent concurrent merge collisions across multiple CLI instances
- Example 7 (Yolo with Safe Merge) in @acp.proceed documentation
- Directive header updated with `--safe` flag detection
- A10 section: Worktree Merge Gating behavior specification

## [5.28.8] - 2026-03-20

### Added
- GitHub Actions E2E CI workflow (`.github/workflows/e2e-tests.yaml`) — runs all E2E tests on ubuntu-latest and macos-latest on push to mainline and PRs
- M13 (Cross-Platform CI) complete: macOS test fixes, unified test runner, GitHub Actions workflow

## [5.28.7] - 2026-03-20

### Added
- Unified E2E test runner (`run-e2e-tests.sh`) — discovers and runs all `e2e/*.test.sh` suites with per-suite PASS/FAIL, output tail on failure, summary table, filter argument, and proper exit codes

## [5.28.6] - 2026-03-20

### Fixed
- Fix macOS compatibility in E2E tests: replace GNU `sed -i` with portable sed+mv pattern (2 files, 3 calls)
- Fix `date +%N` (unsupported on macOS) with `$RANDOM` for unique temp dirs (3 files)
- Fix exit code propagation: add `exit $?` after `print_test_summary` in 4 test files

## [5.28.5] - 2026-03-20

### Changed
- Harden `@acp.proceed` to aggressively set start/end timestamps and status transitions on both tasks AND milestones
- Step 1: mandatory milestone `status: in_progress` and `started` date when first task begins
- Step 4: mandatory milestone `completed` date and `status: completed` when last task finishes, auto-advance `current_milestone`
- Autonomous loop Steps 2 & 6: same mandatory status/timestamp updates applied to autonomous mode

## [5.28.4] - 2026-03-20

### Changed
- Add mandatory auto-commit step (Step 11) to `@acp.pattern-create` and `@acp.design-create` — agents commit created artifacts automatically after document creation
- Add `--no-commit` flag to `@acp.plan`, `@acp.pattern-create`, and `@acp.design-create` to optionally skip the auto-commit step
- Fix `@acp.plan` Step 9 to exclude clarification files from staging (clarifications are not committed)

## [5.28.3] - 2026-03-19

### Changed
- Migrate `priority` field from string enum (`critical`/`high`/`medium`/`low`) to numeric (0 = highest, ascending). Visualizers render as P0, P1, etc.
- Update schema, template, progress.yaml, visualizer design interfaces, benchmark seeds, and changelog

## [5.28.2] - 2026-03-19

### Fixed
- Add trailing double-spaces to all markdown frontmatter `**Key**: Value` lines for proper line break rendering (228 files)
- Rename `agent/artifacts.template.md/` directory to `agent/artifacts/` (was incorrectly using `.md` extension on a directory)
- Update all references to old `artifacts.template.md/` path across commands, tasks, design docs, and progress.yaml

## [5.28.1] - 2026-03-18

### Changed
- **`@acp.plan` Step 9 hardened** — auto-commit of planning artifacts is now marked MANDATORY with explicit warning directive. Agents must commit without asking and verify success before proceeding. Added enumerated file list for staging and commit message example.

## [5.23.0] - 2026-03-17

### Added
- **`@acp.clarification-address` depth modes** — added `--deep` (default) and `--shallow` flags to control research intensity. Deep mode includes web research, MCP tools, tradeoff analysis, and recommendations. Shallow mode provides codebase-only research without analysis, ideal for quick passes.
- **Interactive response lines** — every agent comment block now includes a blank `>` response line immediately after, allowing users to respond interactively to agent research, analysis, and recommendations.
- **Recommendation prompts** — when the agent provides a recommendation in `--deep` mode, the comment block ends with "Would you like to accept this recommendation? (yes/no)" to explicitly prompt user feedback.

### Changed
- **`@acp.clarification-address` version 2.0.0** — unified command now handles both quick research (via `--shallow`) and comprehensive analysis (via `--deep`). Agent responses are always written as HTML comment blocks and never modify `>` response lines.

### Removed
- **`@acp.clarifications-research` command** — deprecated and removed. Use `@acp.clarification-address --shallow` for equivalent functionality.

## [6.0.0] - 2026-03-16

### Breaking Changes
- **Milestones array → map** — `milestones:` in progress.yaml is now a map keyed by milestone ID (`M1:`, `M2:`, ...) instead of an array of objects with `- id: M1`. The `id:` field is removed from milestone entries (the key IS the ID).
- **Tasks keys normalized** — `tasks:` keys changed from `milestone_1`, `milestone_2`, etc. to `M1`, `M2`, etc. to match milestone IDs.
- **Progress keys normalized** — `progress:` per-milestone keys changed from `milestone_1` to `M1`, etc.

### Added
- **`agent/schemas/progress.schema.yaml`** — formal schema definition for progress.yaml files. Defines required fields, types, enums, and patterns for project metadata, milestones, tasks, and all optional sections.
- **`priority` field (required)** — milestones and tasks now require a numeric `priority:` field (0 = highest priority, ascending). Visualizers render as P0, P1, etc. Added to schema, templates, AGENT.md, command directives, and all existing data.

### Fixed
- **Duplicate `milestone_3` key** — task-50 (Package Search Default Topic Filter) was under a second `milestone_3:` block; merged into the canonical M3 section.

## [5.22.0] - 2026-03-15

### Added
- **`@acp.audit` command** — general-purpose deep-dive investigation command. Audits any subject (code, docs, features, directories) and produces a structured report at `agent/reports/audit-{N}-{subject}.md` with tables, code pointers, key decisions, and git history. Read-only — never modifies existing files. Supports CLI and natural language arguments with context inference.

## [5.21.0] - 2026-03-14

### Added
- **Milestone `file:` field in progress.yaml** — milestones now require a `file:` key mapping to their milestone document path (e.g. `file: agent/milestones/milestone-1-name.md`). Updated progress.template.yaml, AGENT.md schema, and `@acp.plan` Step 7 to enforce this for new projects.

## [5.20.0] - 2026-03-14

### Added
- **`--turbo` / `--yolo` combo flags for `@acp.proceed`** — shorthand for `--auto --this --parallel --yes`. Also formally adds `--this` (use task from chat context), `--parallel` (worktree sub-agents), and `--yes` (skip confirmation) as individual flags.

## [5.19.0] - 2026-03-14

### Added
- **Task `started` timestamp and auto-computed `actual_hours`** — tasks now track ISO 8601 `started` timestamps (auto-set on `in_progress` transition) and `actual_hours` (auto-computed from `started`/`completed_date` diff). Updated across `@acp.proceed`, `@acp.update`, `@acp.task-create`, `@acp.plan`, progress template, AGENT.md schema, and visualizer data model. Replaces manual "ask user for hours" prompt with automatic calculation.

## [5.18.4] - 2026-03-14

### Added
- **`@acp.init` lists ACP projects** — added Step 2.3 to list all registered projects from `~/.acp/projects.yaml` during init, showing name, type, description, and status. Skippable with `--skip projects`

## [5.18.3] - 2026-03-14

### Changed
- **`@acp.plan` auto-commits planning artifacts** — added Step 9 to invoke `@git.commit` after generating the planning report, so milestone/task/design documents and progress.yaml updates are committed automatically

## [5.18.2] - 2026-03-14

### Fixed
- **Install script fails to copy core scripts** — `acp.install.sh` used jq-style `yaml_query` syntax (`[]`, `select()`, `| pipes`) that the custom YAML parser doesn't support, causing script dependency resolution to silently fail and install zero scripts (e.g. `acp.install.sh`, `acp.version-update.sh`, `acp.version-check.sh`). Rewrote to use numeric index iteration matching the pattern in `acp.package-install.sh`.

## [5.18.1] - 2026-03-14

### Fixed
- **Bootstrap install missing bundled index files** — `acp.install.sh` only copied `*.template.yaml` from `agent/index/`, now also copies non-template, non-local index files (e.g. `acp.core.yaml`)
- **`acp.core.yaml` not declared in package.yaml** — added `contents.indices` section so the package install path bundles the core index file

## [5.18.0] - 2026-03-14

### Added
- **`acp.core.yaml` key file index** — bundled index of 12 core command directives shipped with ACP installs
  - Weighted entries for `acp.proceed` (0.9), `acp.init` (0.8), `acp.plan` (0.8), `acp.task-create` (0.8), and 8 more
  - Contextual `applies` fields so agents load relevant commands at the right time
  - Replaces per-project duplication of core command index entries

## [5.17.0] - 2026-03-14

### Added
- **`@acp.clarification-address` command** — address clarification responses with research, tradeoff analysis, and recommendations
  - Reads user responses on `>` lines and analyzes them for tradeoffs, ambiguity, and follow-up needs
  - Honors research directives (codebase via Glob/Grep/Read, web via WebSearch/WebFetch, MCP tools)
  - Presents tradeoff analyses with pro/con breakdowns and recommendations
  - Responds to user feedback in HTML comment blocks (`<!-- ... -->`)
  - Writes all agent responses as comment blocks (`<!-- [Agent] -->`, `<!-- [Agent — Researched] -->`, `<!-- [Agent Analysis] -->`)
  - Supports `--latest`, `--dry-run`, `--scope <path>` arguments
  - Complementary to `@acp.clarifications-research` (which only fills `> research this` lines)

### Changed
- **`@acp.clarification-create`** — updated to recommend comment-block feedback workflow
  - "Next steps" output now suggests using `<!-- ... -->` for follow-up questions
  - Added `@acp.clarification-address` and `@acp.clarifications-research` to Related Commands
  - Notes section documents comment-block workflow

## [5.16.0] - 2026-03-13

### Added
- **`@acp.handoff` command** — generate cross-context task handoff reports for transferring work to agents in different repositories or providers
  - Synthesizes handoff from chat conversation context (primary source)
  - Describes the problem and request without prescribing implementation steps
  - Supports `--to` / `--target` arguments for explicit target, or infers from conversation
  - Resolves project names against `~/.acp/projects.yaml`
  - Includes source project path/repo URL for back-reference
  - Uses absolute file paths (from `/`) for cross-project clarity
  - Prompts user to output to chat or save to `agent/reports/`
  - Freeform format shaped by each handoff's specific needs

## [5.15.1] - 2026-03-09

### Fixed
- **Install script missing bundled scripts** — `acp.install.sh` and `acp.uninstall.sh` were not referenced by any command in package.yaml, so the dependency-based installer skipped them
  - Added `acp.install.sh` to `acp.package-create` and `acp.project-create` command dependencies
  - Added `acp.uninstall.sh` to `acp.package-remove` command dependencies

## [5.15.0] - 2026-03-09

### Added
- **`@acp.clarifications-research` command** — research and fill in agent-delegated clarification items
  - Scans clarification docs for research delegation markers (`research this`, `agent: ...`, etc.)
  - Classifies response lines as empty, user-answer, or research-request
  - Explores codebase (Glob, Grep, Read) to answer delegated questions
  - Replaces trigger lines with `[Researched]`-prefixed answers with file references
  - Supports `--latest`, `--dry-run`, `--scope <path>` arguments
  - Never modifies user answers, empty lines, or clarification status

## [5.14.0] - 2026-03-09

### Added
- **`--quick` and `--skip` flags for @acp.init** — faster initialization for returning users
  - `--quick` / `-q`: skips version checks, source file review, and doc sync
  - `--skip <items>`: granular control over 8 individual steps (checks, sessions, docs, global, keys, files, sync, progress)
  - Step 9: usage tip shown when no flags used so users discover faster modes naturally
  - @acp.init bumped to v1.1.0

## [5.13.1] - 2026-03-06

### Changed
- **Yes/No question format preference in clarifications** (Task 110) — improved UX for answering clarification questions
  - Prefer Yes/No over "Option A or Option B?" — users answer "yes/no" instead of "the former/the latter"
  - Two options with recommendation: "We recommend X. Acceptable?" (yes/no)
  - Two options without recommendation: "Do you prefer X?" (yes/no) — no forced recommendations
  - Multi-option discrete format: each sub-option gets its own `>` response line for inline yes/no
  - Updated conflict resolution in @acp.clarification-capture to yes/no/custom format
- **Milestone 15 Complete** — all 5 tasks done (106-110)

## [5.13.0] - 2026-03-04

### Added
- **Duplicate awareness in @acp.clarification-create** (Task 109) — avoids generating duplicate questions
  - Step 1.5: Check Existing Clarifications for Overlap
  - Title-based heuristic: infer relevance from filenames, only load relevant clars
  - Visible output showing which clarifications checked/skipped
  - Cross-references existing answers to skip already-answered questions

### Changed
- **Milestone 15 Complete** — Clarification Capture System fully implemented
  - 4/4 tasks complete: directive, templates, integration, duplicate awareness

## [5.12.3] - 2026-03-04

### Changed
- **Integrated @acp.clarification-capture into create commands** (Task 108) — all 4 create commands now support context capture
  - Updated: design-create, task-create, pattern-create, command-create
  - Added Arguments section with --from-clar, --from-clars, --from-chat, --from-context
  - Added Step 2.7: Capture Clarification Context (references shared directive)
  - Generate steps updated to insert Key Design Decisions section when context available

## [5.12.2] - 2026-03-04

### Added
- **Key Design Decisions section in entity templates** (Task 107) — optional section for capturing clarification decisions
  - Added to: design.template.md, task template, pattern.template.md, command.template.md
  - Category-grouped tables with Decision/Choice/Rationale columns
  - Populated by @acp.clarification-capture or manually authored

## [5.12.1] - 2026-03-04

### Added
- **@acp.clarification-capture shared directive** (Task 106) — reusable directive for capturing clarification decisions into entity documents
  - 8-step capture flow: detect sources, read clars, warn partial, resolve conflicts, synthesize chat, generate section, update status, return
  - Full argument table: `--from-clar`, `--from-clars`, `--from-chat`, `--from-context`
  - Auto-detect mode (default): implicit `--from-context` when no flags specified
  - Conflict resolution UX: flag for user, accept "most recent wins"
  - Warning UX for uncaptured decisions in session

## [5.12.0] - 2026-03-04

### Added
- **Clarification Capture System** (M15) — prevent loss of design rationale from ephemeral clarifications
  - Design document: `agent/design/local.clarification-capture-system.md`
  - Shared directive `@acp.clarification-capture` for embedding decisions in entity docs
  - "Key Design Decisions" optional section for entity templates (category-grouped tables)
  - `--from-clar`, `--from-clars`, `--from-chat`, `--from-context` arguments for create commands
  - Auto-detect and warn when uncaptured clarifications exist in session
  - Conflict resolution flow (flag and ask user to resolve)
  - Duplicate awareness in `@acp.clarification-create`
  - Milestone 15 with 4 tasks (106-109)

## [5.10.2] - 2026-03-02

### Fixed
- **macOS compatibility** — all scripts now work on macOS (BSD sed and missing sha256sum)
  - Replace all `sed -i` calls with portable `_sed_i` / `_yaml_sed_i` wrappers (17 call sites across 7 files)
  - macOS BSD sed requires `sed -i ''` (explicit empty backup suffix); GNU sed does not
  - Add `shasum -a 256` fallback for macOS where `sha256sum` is unavailable
  - Fixes install script failure: `sed: invalid command code f` on macOS temp paths

## [5.10.1] - 2026-03-01

### Added
- **Deliverables Verification Gate** (Task 95) — mandatory verification before task completion
  - `@acp.proceed` Step 3.5: verify all expected files exist before marking task complete
  - `@acp.proceed` Step A3.5: milestone completion sweep after autonomous task loop
  - Autonomous loop Step 4: VERIFY DELIVERABLES in per-task loop (renumbered 4-8)
  - Updated single-task and autonomous verification checklists with file existence checks
  - AGENT.md: added "Documentation is a First-Class Deliverable" to Quality Best Practices

## [5.10.0] - 2026-03-01

### Added
- **Sessions System** (M12) — global session tracking for concurrent multi-project agent work
  - `acp.sessions.sh` — self-contained script with 6 subcommands (register, deregister, list, clean, heartbeat, count)
  - `@acp.sessions` command — dedicated session management with NLP argument support
  - `sessions.template.yaml` — template for `~/.acp/sessions.yaml`
  - Directive-level integration: `@acp.init` (register), `@acp.status` (count), `@acp.report` (deregister)
  - PPID-based stale detection with dead-PID cleanup and timeout removal
  - E2E test suite: 16 tests, 40 assertions, 100% pass rate
  - AGENT.md Sessions System documentation section
  - Advisory-only — no locking or coordination

## [5.9.2] - 2026-03-01

### Added
- Session registration step in `@acp.init` (Step 1.5 — register + show siblings)
- Session count display in `@acp.status` (Step 5.5 — "Sessions: N active")
- Session deregistration step in `@acp.report` (Step 10 — end session)
- All integration steps guarded with "if script exists" for graceful degradation

## [5.9.1] - 2026-03-01

### Added
- `acp.sessions.sh` — self-contained sessions infrastructure script (6 subcommands)
- `sessions.template.yaml` — template for `~/.acp/sessions.yaml`
- Session management: register, deregister, list, clean, heartbeat, count
- PPID-based stale detection with dead-PID cleanup and 2h timeout removal
- `--pid` flag on register for explicit PID control

## [5.9.0] - 2026-03-01

### Added
- `saas-platform` massive benchmark — 15-step expert-complexity dual-seed benchmark
  - 20 buggy Express/Node.js seed files (auth bypass, plaintext passwords, filter bugs, wrong status codes)
  - 32 ACP documentation overlay files (8 design docs, 5 patterns, 3 milestones, 15 tasks)
  - 30 step prompts (15 ACP + 15 baseline) covering analysis through security hardening
  - `verify_saas_platform()` verification function in runner/verify.sh

### Fixed
- Baseline task names missing in benchmark report chart (task vs tasks YAML field fallback)

## [5.8.0] - 2026-03-01

### Added
- `get_git_origin()` and `get_git_branch()` utility functions in `acp.common.sh`
- `git_origin` and `git_branch` fields auto-detected and stored in project registry
- `@acp.projects-restore` command — clone missing projects from stored git origins
- `acp.projects-restore.sh` script with `--dry-run` and `--install-acp` flags
- Git origin backfill pass in `@acp.projects-sync` for existing registered projects
- `--git-origin` and `--git-branch` flags on `@acp.project-update`
- Git origin display in `@acp.project-info` and `@acp.project-list` output

### Changed
- `register_project()` now accepts optional 5th/6th args for git_origin/git_branch with auto-detection fallback
- `@acp.projects-sync` detects and shows git origin during discovery, backfills missing origins
- Updated command docs: project-create, project-info, project-list, project-update, projects-sync

## [5.7.3] - 2026-03-01

### Added

**ACP-Initialized Project Benchmark** (Milestone 11 — Task 90):
- Dual-seed benchmark: seed-base (Express app, 9 files) + seed-acp (agent/ directory, 14 files)
- ACP mode gets pre-loaded designs, patterns, tasks, progress; baseline gets nothing
- Mode-specific step prompts: ACP prompts are 1 line each, baseline prompts are 15-44 lines each
- Runner enhanced: `seed_dir_acp` overlay, `skip_acp_install` config, `prompt_file_acp`/`prompt_file_baseline` support
- Verify function and GitHub Actions workflow choice added
- M11 complete (12/12 tasks)

## [5.7.2] - 2026-03-01

### Changed
- Add `--autonomous` flag alias to `@acp.proceed` command (equivalent to `--complete` and `--auto`)

## [5.7.1] - 2026-03-01

### Added

**Enterprise Task Manager Benchmark** (Milestone 11 — Task 89):
- Large-scope benchmark: 670+ line seed project (12 files) with 5 unlabeled bugs
- Circular dependencies, inconsistent patterns, missing auth on routes
- 10 step prompts: deep analysis, bug fixes, refactoring, 50+ tests, teams, activity feed, RBAC, security audit, migration docs
- Designed for 2-4 hour runtime per mode — punishes "dive in without planning"
- Verification function and GitHub Actions workflow choice added

**ACP-Initialized Project Benchmark Task** (Milestone 11 — Task 90):
- Task specification for dual-seed benchmark (planned, not yet implemented)
- Tests value of pre-existing ACP documentation vs no docs

## [5.7.0] - 2026-03-01

### Added

**Documentation & Historical Tracking — M11 Complete** (Milestone 11 — Task 86):
- Benchmark Suite section in AGENT.md (quick start, task table, architecture, key files)
- Benchmark section in README.md with quick-start commands
- Historical run comparison script (`compare-runs.sh`)
- Design document status updated to Implemented

**Milestone 11 Complete**: ACP Benchmark Suite — 10/10 tasks
- Full E2E benchmark system: ACP vs baseline comparison
- 6 benchmark tasks (simple → complex, including legacy refactor and event-driven pivot)
- LLM evaluator with 6-category rubric
- HTML dashboard with radar charts
- GitHub Actions on-demand workflow
- Historical tracking and documentation

## [5.6.3] - 2026-03-01

### Added

**GitHub Actions Workflow** (Milestone 11 — Task 85):
- On-demand benchmark workflow with `workflow_dispatch` trigger
- Configurable inputs: task selection, mode (acp/baseline/both), run count
- Report artifact upload with 90-day retention
- Job summary with YAML results
- Timeout controls: 90min per task, 2hr per job

## [5.6.2] - 2026-03-01

### Added

**Order Pipeline Benchmark** (Milestone 11 — Task 88):
- `order-pipeline` benchmark task: 7-step challenge with mid-stream sync-to-event-driven pivot
- Steps cover: catalog/inventory, cart/orders, state machine, tests, event-driven refactor, notifications+retry, integration+docs
- Verification function with event bus module detection (multiple naming conventions)

## [5.6.1] - 2026-03-01

### Added

**Legacy Refactor Benchmark** (Milestone 11 — Task 87):
- `legacy-refactor` benchmark task: 6-step refactoring challenge starting from messy seed app
- Seed application: working but poorly structured Express CRUD app with intentional bugs
- Seed directory support in run-single.sh (copies seed files + runs npm install before step 1)
- Verification function `verify_legacy_refactor()` in verify.sh

## [5.6.0] - 2026-03-01

### Added

**New Benchmark Tasks & Evaluator Fix** (Milestone 11 — Tasks 87, 88):
- Legacy Codebase Refactor benchmark (task-87): 6-step task starting from pre-built messy Express app, tests planning under constraints
- Event-Driven Order Pipeline benchmark (task-88): 7-step task with mid-stream sync-to-event-driven architectural pivot

### Fixed
- Evaluator JSON extraction now reads `.structured_output` (where `--json-schema` places data) instead of empty `.result` field

## [5.5.0] - 2026-02-28

### Added

**Report & Dashboard Enhancement** (Milestone 11 — Task 84):
- Improvement percentage column in metrics comparison tables (Markdown + HTML)
- Per-step breakdown tables showing step ID, phase, duration, tokens, turns
- Radar chart (Chart.js) for 6-dimension evaluation score visualization in HTML reports
- Evaluation scores written to summary.yaml per task/mode
- Checks row in verification tables
- serve-reports.sh index now shows eval scores, multi-task report links with task names

## [5.4.0] - 2026-02-28

### Added

**LLM Evaluator** (Milestone 11 — Task 83):
- `evaluator-prompt.md`: 6-category rubric (correctness, completeness, code style, documentation, architecture, testing) with scoring guidelines (1-10, MISS/MEETS/EXCEEDS)
- `evaluation-schema.json`: JSON schema for structured evaluator output
- Evaluator integration in `run-single.sh`: runs as separate Claude session after verification, saves per-category scores and rationales
- Evaluation tables in Markdown and HTML reports with color-coded scores and summaries

## [5.3.2] - 2026-02-28

### Added

- Benchmark runner injects `@acp.plan` directive (plan before building) into first step prompt in ACP mode
- Benchmark runner injects `@acp.proceed` directive (structured implementation) into subsequent step prompts in ACP mode
- Single-prompt benchmarks also receive plan directive in ACP mode

## [5.3.1] - 2026-02-28

### Fixed

- `run-single.sh`: grep commands now use `|| true` to prevent `set -euo pipefail` crashes when config fields are missing
- `run-single.sh`: timeout config parsing now matches both `timeout:` and `timeout_minutes:` field names
- `run-single.sh`: CHECKS_TOTAL calculation no longer produces multi-line output that breaks integer comparison
- `run-benchmark.sh`: HTML/Markdown reports now generated for all tasks in `--task all` mode (was skipped for multi-task runs)

## [5.3.0] - 2026-02-28

### Added

**Benchmark Task Suites** (Milestone 11 — Tasks 80-82):
- `simple-cli-tool` benchmark: 3 steps (build CSV-to-JSON CLI, test suite, fix empty cells bug)
- `medium-rest-api` benchmark: 4 steps (Express CRUD API, tests, fix DELETE/PUT bugs, refactor routes)
- `complex-auth-system` benchmark: 5 steps (scaffold, JWT auth, tests, fix security issues, docs)
- Verification functions for all three tasks in verify.sh

**Benchmark Runner Enhancements**:
- `--task all` flag to run all benchmark tasks in one command
- Tasks sorted by complexity (trivial → simple → medium → complex)
- Per-task error handling: failures don't abort the entire suite
- ACP init preamble (`@agent/commands/acp.init.md`) prepended to first prompt in ACP mode

### Fixed

- Update script (`acp.version-update.sh`) now writes full `.gitignore` (reports, clarifications, drafts, feedback, preferences) matching install script

## [5.2.0] - 2026-02-28

### Added

**Benchmark Runner Multi-Turn & Metrics Fix** (Milestone 11 — Task 79):
- Multi-turn step loop in run-single.sh with `--resume` session continuity
- Token metrics extraction fix: tries `.usage.*` (nested) then top-level with fallback
- Raw JSON output saved per step for debugging
- `metrics-collector.sh` for multi-run statistical aggregation (mean, stddev)
- `--runs N` flag in run-benchmark.sh for repeated benchmark execution
- Task-aware verification dispatch (`verify_<task_name>` functions)
- Per-step YAML metrics files with phase tagging
- Backward compatibility: single-prompt tasks (hello-world) work unchanged

## [5.1.0] - 2026-02-28

### Added

**@acp.proceed Autonomous Completion Mode** (Milestone 10 — Task 78):
- `--complete` / `--auto` / `--finish-milestone` flags for autonomous milestone completion
- `--commit` / `--commit-each` / `--with-commits` flags for per-task git commits
- `--dry-run` flag to preview planned tasks without execution
- Natural language argument parsing with fuzzy matching ("finish milestone", "just finish everything")
- `--complete` implies `--commit` — autonomous mode always commits per-task
- Mandatory confirmation prompt before autonomous execution
- Autonomous task loop: implements all remaining tasks, commits after each
- Per-task `@git.commit` subroutine integration (version bump, changelog, progress)
- Progress indicators with bar graphs and task status symbols between tasks
- Summary report at end of run (completions, failures, commits, version range)
- Error handling: halt on failures, never commit partial work, seek user intervention
- Interruption handling: infer user intent from messages during autonomous runs
- `@acp.proceed` command bumped to v2.0.0

## [5.0.1] - 2026-02-28

### Changed

- Added "Use Direct Git Commits" best practice to AGENT.md workflow guidelines — agents should use `git commit -m` directly, not bash tools or heredocs

## [5.0.0] - 2026-02-28

### Added

**Template Source Files Support** (Milestone 9):
- `contents.files` section in package.yaml schema for declaring template files
- Template files install to project-specified target paths (not agent/)
- Variable substitution system with `{{PLACEHOLDER}}` format
- `.template` extension stripping during installation
- Selective installation via `--files` flag
- Unsafe target path rejection (no `../` or absolute paths)
- Manifest tracking for template files: target paths, variable values, checksums
- Helper functions: `is_template_file_modified()`, `get_template_file_target()`, `get_template_file_variables()`, `update_template_file_in_manifest()`
- `@acp.package-list` shows template file counts and modification status
- `@acp.package-remove` removes template files from target paths
- `@acp.package-update` updates template files with stored variable reuse
- `@acp.package-validate` validates template file declarations
- Backward compatibility for packages without `contents.files` metadata
- 34 E2E tests covering all template features (100% pass rate)
- AGENT.md documentation for Template Source Files

### Fixed

- Manifest `packages: {}` bug where empty manifest skipped package entry creation

## [4.6.1] - 2026-02-27

### Fixed

- Argument parsing for `--commands`, `--patterns`, `--designs`, and `--files` now correctly stops on single-dash flags like `-y`, preventing them from being consumed as filenames

## [4.6.0] - 2026-02-27

### Added

- `--list` flag for package install now shows full file preview (clone → scan → validate → display) without installing

## [4.5.0] - 2026-02-27

### Added

- `report-html.sh`: standalone HTML report generator with styled metrics and verification tables
- `report-markdown.sh`: standalone Markdown report generator with diff annotations
- `serve-reports.sh`: index.html generator and HTTP dev server with hot reload on refresh
- Benchmark runner now automatically generates HTML and Markdown reports after each run

### Changed

- `run-benchmark.sh` summary output now lists individual report file paths (YAML, Markdown, HTML)

## [4.4.0] - 2026-02-27

### Added

- Benchmark suite infrastructure for empirically measuring ACP's value
- `hello-world` benchmark task: simple shell script creation with automated verification
- `run-benchmark.sh` entry point: runs tasks in ACP vs baseline modes with side-by-side comparison
- `run-single.sh` executor: isolated workspace creation, Claude CLI invocation, JSON metrics parsing
- `verify.sh` verification framework: checks file existence, executability, and output correctness
- Per-run YAML reports and `summary.yaml` with token/turn/cost diff calculations
- Benchmark reports excluded from version control via `.gitignore`

## [4.3.1] - 2026-02-27

### Fixed

- Install script now creates `drafts/`, `clarifications/`, `feedback/`, and `preferences/` directories
- Install script `.gitignore` now includes all local-only directories (was only `reports/`)
- Install script now copies clarification template to `agent/clarifications/`

## [4.3.0] - 2026-02-27

### Added

- `agent/files/` directory support in package installer — files install to project root (`.`), preserving subdirectory structure
- `--files` flag for selective installation of files directory
- Unrecognized directory warning when packages contain dirs outside the known set (patterns, commands, design, scripts, files)
- `scripts: []` and `files: []` arrays in manifest package template

**Project Registry System**:
- Global project registry at `~/.acp/projects.yaml` for tracking all ACP projects
- `@acp.project-list` - List all registered projects with filtering by type, status, tags
- `@acp.project-set` - Switch between projects (context switching)
- `@acp.project-info` - Show detailed project information including metadata
- `@acp.project-update` - Update project metadata (type, status, tags, description, related projects)
- `@acp.project-remove` - Remove projects from registry (keeps project files)
- `@acp.projects-sync` - Discover and register existing projects in `~/.acp/projects/`
- Automatic project registration on creation via `@acp.project-create`
- Current project tracking for context-aware operations
- Relationship and dependency tracking between projects

**Documentation**:
- Added "Project Registry System" section to AGENT.md with commands, examples, and workflow
- Added "Project Registry" section to README.md with quick examples
- Updated command list in README.md with all project registry commands

**Milestone Progress**: M7 (Global ACP Project Registry) - 100% complete (10/10 tasks)

### Fixed

- Manifest tracking: `design` directory now correctly maps to `designs` manifest key (was causing empty arrays for all installed files)
- Manifest template missing `scripts` and `files` arrays — installed scripts were never recorded

Closes #6

## [4.2.2] - 2026-02-27

### Fixed

- `local` keyword used outside function in `acp.package-install.sh` line 276, causing all package installs to fail with `local: can only be used in a function` when `set -e` is enabled
- Closes #5

## [4.2.1] - 2026-02-26

### Added

**Critical Rule**: Never Force-Add Gitignored Files
- Added new critical rule to AGENT.md prohibiting use of `git add -f`
- Agents must never attempt to override `.gitignore` rules
- Gitignored files should be acknowledged and skipped
- Rationale: Prevents security issues (exposing secrets), repository bloat (build artifacts), and merge conflicts (local configs)

**@git.commit Enhancement**: Gitignore Handling
- Updated Step 7 "Intelligently Stage Changes" with gitignore handling
- Added explicit instructions to skip gitignored files
- Added "Gitignore Handling" subsection with DO/DON'T examples
- Clarified that `git add -f` should never be used

**Impact**: All future agents will respect `.gitignore` rules and never force-add gitignored files, preventing common anti-patterns in version control.

## [4.2.0] - 2026-02-26

### Added

**New Command**: `@acp.projects-sync`
- Discover unregistered ACP projects in `~/.acp/projects/` directory
- Automatically detect projects with `agent/progress.yaml` file
- Skip already-registered projects with clear indicators
- Prompt user for each unregistered project found
- Extract metadata from `progress.yaml` (type, description)
- Register selected projects with timestamps
- Display summary statistics (projects found, newly registered)
- Handle edge cases (empty directory, non-ACP directories, malformed YAML)
- Auto-initialize registry if needed
- Interactive prompts with Y/n confirmation

**Use Cases**:
- Migrate existing projects to registry system
- Discover manually created projects
- Organize all ACP projects in one registry
- Bulk registration of multiple projects

**Implementation**:
- Script: `agent/scripts/acp.projects-sync.sh` (105 lines)
- Documentation: `agent/commands/acp.projects-sync.md` (377 lines)
- Tests: `e2e/acp.projects-sync.test.sh` (8 scenarios, 35 assertions)

**Milestone Progress**: M7 (Global ACP Project Registry) - 70% complete (7/10 tasks)

## [4.1.1] - 2026-02-25

### Changed

**Task Structure Documentation**:
- Updated AGENT.md directory structure to show milestone subdirectories as standard
- Updated task structure: `agent/tasks/milestone-{N}-{title}/task-{M}-{name}.md` (standard)
- Added unassigned directory: `agent/tasks/unassigned/task-{M}-{name}.md` (tasks without milestone)
- Noted legacy flat structure: `agent/tasks/task-{N}-{name}.md` (older tasks)
- Updated progress.yaml example to show subdirectory file paths
- Updated `@acp.task-create` command to use milestone subdirectories
- Added note about older tasks using flat structure for historical reasons

**Impact**: Documentation now accurately reflects the current task organization structure used in Milestones 6-8.

## [4.1.0] - 2026-02-25

### Added

**New Command**: `@acp.clarification-create`
- Create structured clarification documents from file input or chat
- Automatic clarification numbering (finds next available number)
- Accepts file path or interactive chat input
- Generates questions organized into Items > Questions > Bullet points
- Follows clarification template structure
- Includes response markers (`>`) for inline user answers
- Supports `--file`, `--title`, and `--auto` arguments
- Can analyze existing files (drafts, designs) to identify gaps
- Interactive mode for chat-based question generation

**Use Cases**:
- Gather detailed requirements for ambiguous specifications
- Analyze draft files before converting to formal documents
- Create structured question documents for stakeholder input
- Clarify design decisions and implementation details

## [4.0.0] - 2026-02-25

### Changed

**BREAKING: AGENT.md Best Practices Consolidation**
- Consolidated all best practices into single section with 3-level hierarchy (## > ### > ####)
- Removed duplicate "For Adding New Features" section (was in 2 locations)
- Moved orphaned subsections (Documentation, Organization, Progress Tracking, Quality) into Best Practices
- Restructured "Best Practices for Agents" from numbered list to hierarchical categories
- Updated table of contents with expanded Best Practices subcategories
- Added 4 strategic cross-references linking workflows to best practices

**Best Practices Structure**:
- Critical Rules (5 practices): Never reject requests, update CHANGELOG, no secrets, respect edits, respect re-execution
- Workflow Best Practices (8 practices): Read first, document, verify, be explicit, organize, track progress, inline feedback, format commands
- Documentation Best Practices (4 practices): Write for agents, focus, link, update
- Organization Best Practices (3 practices): Naming, structure, DRY
- Progress Tracking Best Practices (3 practices): Update frequently, be objective, look forward/back
- Quality Best Practices (3 practices): Verification, patterns, refine

**Entity Creation Simplification**:
- Replaced detailed creation instructions with `@acp.{entity}-create` command references
- Removed step-by-step guides, template copying examples, and manual file creation steps
- Simplified to: "Invoke [`@acp.{entity}-create`](agent/commands/acp.{entity}-create.md) and follow directives"
- Applies to: design documents, tasks, patterns, commands

### Added

**New Best Practice**: Format Commands for User Execution
- Chain commands with `&& \` for dependent execution
- Chain commands with `;` for independent execution
- Don't include `#` comment lines in command blocks
- Don't include EOF newlines in command blocks
- Ensures copy-paste friendliness for users

**Command Version Updates**:
- `@git.commit` bumped to v2.0.0 with version history section documenting AGENT.md restructuring impact

### Fixed

**Documentation Clarity**:
- Eliminated ~15% duplication by consolidating scattered best practices
- Improved navigation with hierarchical structure and cross-references
- Single source of truth for all agent behavior guidelines

**Impact**: This restructuring may affect how agents interpret and apply ACP methodology. The new hierarchical organization provides clearer categorization but represents a significant change to the documentation structure that agents rely on.

## [3.14.1] - 2026-02-25

### Fixed

**Script Installation Bugs** (Task 69):
- Fixed argument parsing bug where `-y` flag was collected as filename in `--commands`, `--patterns`, and `--designs` flags
- Fixed `get_file_version()` returning exit code 1 when file has no version, causing script to exit with `set -e`
- Fixed `add_file_to_manifest()` causing loop to exit early when manifest operations failed
- Fixed `should_install_file()` grep commands failing with `set -e` when no matches found
- Script installation loop now processes all scripts correctly (was stopping after first script)
- Added error handling to `add_file_to_manifest` calls to prevent loop breakage
- All E2E tests now passing (28/28 assertions, 100% pass rate)

**Installation Script Improvements**:
- Argument parsing now explicitly checks for known flags instead of using generic `^-` regex
- Error handling in script installation loop prevents premature exit
- Graceful degradation when manifest operations fail (warns but continues)
- Added `|| true` to grep commands in `should_install_file()` to handle no-match cases

### Changed

**Error Handling**:
- `get_file_version()` now returns exit code 0 even when package.yaml missing
- Script installation continues even if manifest update fails (with warning)
- More robust error handling throughout installation pipeline

## [3.14.0] - 2026-02-24

### Added

**Script-Command Binding System** (Milestone 3 - Tasks 65-68):
- Added `scripts` field to package.yaml schema (REQUIRED for command entries)
- Commands now declare script dependencies in frontmatter (`**Scripts**:` field)
- Dual declaration system: frontmatter + package.yaml (validated for consistency)
- Selective script installation based on installed commands
- Reference counting for shared utilities (acp.common.sh, acp.yaml-parser.sh)
- Scripts only installed when their commands are installed
- Experimental filtering applies to scripts (respects `--experimental` flag)
- Added `validate_script_dependencies()` to `acp.package-validate.sh`
- Validation ensures frontmatter matches package.yaml scripts arrays
- Validation verifies all declared scripts exist in scripts section
- Created `package.yaml` for ACP core with complete script declarations
- Added **Scripts**: field to all 30 ACP commands (14 with scripts, 16 without)

**Installation Enhancements**:
- Updated `acp.package-install.sh` with selective script installation logic
- Updated `acp.install.sh` with selective installation for ACP core
- Scripts collected from package.yaml for each installed command
- Deduplication ensures shared utilities installed once
- Backward compatibility maintained (installs all if no package.yaml)

**Template Updates**:
- Updated `command.template.md` with **Scripts**: field and documentation
- Updated `package.template.yaml` with scripts array examples
- Updated `package.schema.yaml` with required scripts field definition

### Changed

**Installation Behavior**:
- Scripts no longer installed indiscriminately
- Only scripts needed by installed commands are copied
- Experimental commands don't install their scripts (unless `--experimental` used)
- Cleaner installations with no unused script files

**Validation**:
- Package validation now checks script-command binding consistency
- Clear error messages for missing or mismatched script declarations
- Fixable suggestions provided for common issues

### Fixed

**Script Installation**:
- Fixed script clutter from unused files in experimental packages
- Fixed scripts being installed even when commands were skipped
- Fixed lack of dependency tracking between commands and scripts

## [3.13.0] - 2026-02-24

### Added

**Project Registry Commands** (Milestone 7 - Tasks 53-54):
- Added `@acp.project-set` command for seamless context switching between projects
- Command updates `current_project` in `~/.acp/projects.yaml` registry
- Command updates `last_accessed` timestamp for project tracking
- Command changes working directory to project path (interactive mode)
- Command validates project exists in registry and directory exists on filesystem
- Comprehensive error messages with helpful suggestions and available project lists
- Tilde (`~`) expansion support in project paths
- Created `agent/commands/acp.project-set.md` (command documentation)
- Created `agent/scripts/acp.project-set.sh` (context switching script)
- Created `e2e/acp.project-set.test.sh` (8 tests, 29 assertions, 100% passing)

**Test Utilities**:
- Added `assert_not_contains()` function to `tests/common.sh` for negative assertions

### Fixed

**YAML Parser Enhancements** (Task 53):
- Fixed `set -euo pipefail` compatibility in `agent/scripts/acp.common.sh` (line 69)
- Fixed `set -euo pipefail` compatibility in `agent/scripts/acp.yaml-parser.sh` (lines 12, 817)
- Fixed `yaml_query()` to return children keys for map/array nodes (previously returned empty)
- Map/array nodes now return YAML-formatted children list (e.g., "project-1:\nproject-2:\n")
- Scalar values continue to return normally

### Changed

**Project Registry Progress**:
- Milestone 7: 22% → 33% complete (3/9 tasks done)
- Task 54 completed with full E2E test coverage

## [3.12.0] - 2026-02-23

### Added

**Experimental Features System** (Milestone 8):
- Added `experimental` field to package.yaml schema for marking experimental features
- Added `--experimental` flag to `@acp.package-install` for opt-in installation
- Experimental features require explicit opt-in during installation
- Once installed, experimental features update normally (no flag required)
- Validation checks consistency between package.yaml and file metadata
- Graduated features (experimental → stable) automatically detected during updates
- Clear visual indicators for experimental features (⊘ skipped, ⚠ experimental, 🎓 graduated)

**Schema Enhancement**:
- `agent/schemas/package.schema.yaml` now supports optional `experimental: true` field in all content types
- Field is optional and defaults to false (backward compatible)

**Validation**:
- Added `validate_experimental_consistency()` to `agent/scripts/acp.package-validate.sh`
- Checks if `experimental: true` in package.yaml → file MUST have `**Status**: Experimental`
- Checks if file has `**Status**: Experimental` → package.yaml MUST have `experimental: true`
- Provides fixable suggestions for inconsistencies

**Installation**:
- Added `should_install_file()` filtering function to `agent/scripts/acp.package-install.sh`
- Without `--experimental`: Skips features marked `experimental: true`
- With `--experimental`: Installs all features including experimental
- Manifest tracks experimental status for update handling

**Updates**:
- Added `is_experimental_installed()` to `agent/scripts/acp.package-update.sh`
- Added `check_graduation()` to detect experimental → stable transitions
- Already-installed experimental features update normally
- New experimental features are skipped (use --experimental with install)
- Graduated features automatically marked as stable

**Documentation**:
- Created `agent/design/local.experimental-features-system.md` (comprehensive design)
- Created `agent/milestones/milestone-8-experimental-features.md`
- Created 4 task documents for implementation
- Updated `@acp.package-install` command documentation with --experimental flag
- Updated `@acp.package-update` command documentation with experimental behavior
- Updated `@acp.package-validate` command documentation with consistency checks
- Added "Experimental Features" section to AGENT.md
- Added experimental features examples to README.md

### Changed

**Installation Behavior**:
- Default installation now skips experimental features
- `--experimental` flag required to install experimental features
- Clear visual indicators for skipped and experimental files

**Update Behavior**:
- Smart handling based on installation status
- Installed experimental features update without flag
- New experimental features require explicit installation

**Manifest Structure**:
- Files can now have `experimental: true` field
- Enables tracking of experimental status across updates

## [3.11.0] - 2026-02-23

### Added

**YAML Parser Enhancement**:
- `yaml_set()` now automatically creates missing intermediate map nodes
- Added `create_node_and_link()` function for auto-creation with parent linking
- Added `YAML_PARSER_LOADED` guard to prevent variable resets on re-sourcing
- Enhanced `source_yaml_parser()` to check if already loaded

**Project Registry Infrastructure** (Task 52):
- Created `agent/schemas/projects.schema.yaml` - Complete registry schema
- Created `agent/projects.template.yaml` - Registry template
- Added 8 project registry functions to `acp.common.sh`:
  - `get_projects_registry_path()` - Get registry file path
  - `projects_registry_exists()` - Check if registry exists
  - `init_projects_registry()` - Initialize registry
  - `register_project()` - Add project to registry (uses yaml_write!)
  - `project_exists()` - Check if project registered
  - `get_current_project()` - Get active project name
  - `get_current_project_path()` - Get active project path
- Updated `init_global_acp()` to auto-initialize projects registry
- Created `tests/acp.project-registry.test.sh` - 5/5 tests passing (100%)
- Added `assert_file_exists()` to `tests/common.sh`

### Fixed

**YAML Parser**:
- Fixed duplicate children bug in AST (separated `create_node` from `add_child`)
- Fixed `create_node()` to not auto-link (backward compatibility)
- `yaml_set()` now works for creating nested structures, not just updates

### Changed

**Project Registry**:
- Registry template uses clean empty map syntax (`projects:` not `projects: {}`)
- `register_project()` now uses yaml_write instead of sed manipulation

## [3.10.1] - 2026-02-22

### Fixed

**Documentation**:
- Fixed `@acp.package-install` command documentation to match actual script implementation
- Script requires `--repo` flag (not positional argument)
- Updated all examples to use correct syntax: `--repo <url>`
- Added global installation example with `--global --repo <url>`
- Clarified that scripts are installed and made executable automatically

## [3.10.0] - 2026-02-22

### Added

**New Command**:
- Created `@acp.project-create` command for bootstrapping generic ACP projects
- Creates projects without package.yaml (not for distribution)
- No release branches or pre-commit hooks (simpler than packages)
- Always uses `local` namespace (not configurable)
- Collects project metadata (name, description, type, author, license)
- Installs full ACP in new directory
- Creates project-focused README.md with development section
- Creates appropriate .gitignore for project type
- Initializes git repository with initial commit
- Creates progress.yaml with project metadata
- Comprehensive documentation with comparison to `@acp.package-create`

### Changed

**Progress Tracking**:
- Completed Task 49: @acp.project-create Command (1 hour)
- Milestone 5: 86% → 100% complete (7/7 tasks) 🎉
- Updated current_milestone: M5 → M6 (ready for Preferences System)

## [3.9.3] - 2026-02-22

### Added

**Task Planning**:
- Created Task 51: Pattern Reading in Commands for context awareness
- Updates 6 commands to read `agent/patterns/` during execution
- Intelligent pattern selection based on context
- Ensures agents understand project patterns before making decisions
- Estimated 2-3 hours implementation time

### Changed

**Progress Tracking**:
- Updated Milestone 2 tasks_total: 3 → 4 (added task-51)
- Deleted 3 draft files (acp-project-create, acp-search-enhancement, read-patterns-enhancement)

## [3.9.2] - 2026-02-22

### Fixed

**Package Search**:
- Fixed `@acp.package-search` to filter by `topic:acp-package` by default
- Default search now returns 3 actual ACP packages (not 11,356 irrelevant repos)
- Search query construction: `topic:acp-package` (default) or `{query}+topic:acp-package` (with query)
- Updated command documentation to explain topic filter requirement
- Package discovery now requires `acp-package` topic on GitHub repository

### Changed

**Progress Tracking**:
- Completed Task 50: Package Search Default Topic Filter (0.5 hours)
- Milestone 3: 90% → 100% complete (10/10 tasks)

## [3.9.1] - 2026-02-22

### Added

**Task Planning**:
- Created Task 49: `@acp.project-create` command for bootstrapping generic ACP projects
- Task document includes comparison with `@acp.package-create` (packages vs projects)
- Projects use `local` namespace (not configurable, unlike packages)
- Projects don't include package.yaml, release branches, or pre-commit hooks
- Estimated 3-4 hours implementation time
- Created Task 50: Package Search Default Topic Filter (1 hour)

### Changed

**Progress Tracking**:
- Updated Milestone 5 tasks_total: 6 → 7 (added task-49)
- Updated Milestone 3 tasks_total: 9 → 10 (added task-50)
- Added initialization entry to recent_work (context loaded via `@acp.init`)

## [3.9.0] - 2026-02-22

### Added

**Global Package Installation System**:
- Global package installation to `~/.acp/agent/` with `--global` flag
- Packages installed directly into global ACP structure (not separate packages directory)
- Global package discovery via `~/.acp/agent/manifest.yaml`
- Global infrastructure: `~/.acp/` with full ACP installation at root
- Global manifest functions in `acp.common.sh` (7 functions)
- Enhanced [`@acp.init`](agent/commands/acp.init.md) with automatic global package discovery
- Namespace precedence rules (local always overrides global)

**Global Package Commands**:
- [`@acp.package-install`](agent/commands/acp.package-install.md) supports `--global` flag
- [`@acp.package-list`](agent/commands/acp.package-list.md) supports `--global` flag
- [`@acp.package-update`](agent/commands/acp.package-update.md) supports `--global` flag
- [`@acp.package-remove`](agent/commands/acp.package-remove.md) supports `--global` flag
- [`@acp.package-info`](agent/commands/acp.package-info.md) supports `--global` flag

### Changed

- **Global installation architecture**: Packages install directly to `~/.acp/agent/` (not `~/.acp/packages/`)
- **Manifest location**: Global manifest at `~/.acp/agent/manifest.yaml` (following ACP structure)
- **AGENT.md**: Added "Global Package Discovery" section with discovery workflow, precedence rules, and examples
- **README.md**: Added "Global Package Installation" section with usage examples and use cases
- All package command documentation updated with `--global` flag examples

### Documentation

- Documented namespace precedence rules (local > global)
- Added global ACP structure diagram
- Documented when to use global vs local installation
- Added comprehensive examples for global package workflows
- Updated all package management command documentation

## [3.8.0] - 2026-02-22

### Added

**New @acp.plan Command**:
- Created `agent/commands/acp.plan.md` - Systematic milestone and task planning command
- Scans progress.yaml for undefined milestones/tasks
- Supports multiple planning workflows (design first, requirements first, chat, drafts)
- Invokes `@acp.milestone-create`, `@acp.task-create`, `@acp.design-create` as subroutines
- New task structure: `agent/tasks/milestone-{N}-{title}/task-{M}-{title}.md`
- Orphaned tasks: `agent/tasks/unassigned/task-{M}-{title}.md`
- CLI and natural language argument support
- Batch and interactive modes
- Structured draft questions for each entity type (3 questions each)
- Created `agent/clarifications/clarification-6-acp-plan-command.md` with design requirements

**Command Template Enhancement**:
- Added Arguments section to `agent/commands/command.template.md`
- Documents CLI-style and natural language arguments
- Includes argument mapping approach
- Placed before Prerequisites section
- Optional section (omit if command has no arguments)

**Command Creation Enhancement**:
- Updated `agent/commands/acp.command-create.md` to handle Arguments section
- Asks if command accepts arguments during creation
- Fills or removes Arguments section accordingly
- Ensures Arguments placed before Prerequisites

## [3.7.3] - 2026-02-22

### Added

**E2E Test Suite for Package Update Command**:
- Created `e2e/acp.package-update.test.sh` with 13 comprehensive test cases
- Tests all update scenarios: empty manifest, non-existent package, flags (--check, --skip-modified, --force, -y)
- Tests specific package updates and manifest validation
- All 13 assertions passing (100%)

**Test Utilities Enhancement**:
- Added `assert_not_equals()` function to `tests/common.sh`
- Enables negative assertions in test suites
- Used across all E2E tests for error case validation

### Fixed

**Critical Bug in Package Update Script**:
- Fixed function ordering in `agent/scripts/acp.package-update.sh`
- Functions `check_package_for_updates()` and `update_package()` were defined after use (lines 129, 188)
- Moved function definitions before main script logic
- Script now executes correctly without "command not found" errors

**Test Coverage Complete**:
- All 5 package management commands now have E2E tests
- Total: 52/52 assertions passing (100%)
- Commands tested: list (10), info (13), remove (8), search (8), update (13)

## [3.7.2] - 2026-02-22

### Changed

**Package Browser UI Improvements**:
- Reduced vertical spacing throughout for better screen efficiency
- Smaller header (3em → 2em title, 1.2em → 1em subtitle)
- Compact search box (30px → 15px padding)
- Tighter package cards (20px → 12px padding, 20px → 12px margins)
- Smaller fonts (package name 1.5em → 1.2em, meta 0.9em → 0.85em)
- More packages visible per screen (~30% space reduction)
- Maintained readability while improving information density

## [3.7.1] - 2026-02-21

### Fixed

**Critical Bug Fixes in Package Management Scripts**:
- Fixed `(( VAR++ ))` arithmetic expressions causing early exit with `set -e`
  - `acp.package-list.sh` - 2 occurrences fixed
  - `acp.package-search.sh` - 1 occurrence fixed
  - `acp.package-remove.sh` - 8 occurrences fixed
- Fixed file counting in `acp.package-remove.sh` (grep -c returning multiple lines)
- Fixed JSON parsing in `acp.package-search.sh` (handle spaces in JSON)
- Disabled `set -e` in `acp.package-search.sh` (incompatible with while-read subshell)

**Package Search Now Working**:
- Search successfully finds and displays ACP packages
- Tested with real repositories (acp-tanstack-cloudflare, acp-mcp-auth-server-base)
- All search modes working (keyword, topic, user, limit)

### Added

**E2E Test Infrastructure**:
- Created `e2e/` directory for end-to-end tests
- Created `e2e/acp.package-list.test.sh` (10/10 assertions passing)
- Created `e2e/acp.package-info.test.sh` (13/13 assertions passing)
- Created `e2e/acp.package-remove.test.sh` (8/8 assertions passing)
- Created `e2e/acp.package-search.test.sh` (8/8 assertions passing)
- Enhanced `tests/common.sh` with test helper functions
- Total: 39/39 assertions passing (100%)

## [3.7.0] - 2026-02-21

### Changed

**YAML Parser Migration**:
- All scripts now use `acp.yaml-parser.sh` (AST-based parser) via `source_yaml_parser()`
- 10-100x performance improvement for multiple queries (parse once, query many)
- Generic path expressions supported: `.path.to.field`, `.array[0].field`
- Backward-compatible API maintained: `yaml_get()`, `yaml_get_nested()`, `yaml_has_key()`, `yaml_get_array()`
- Updated documentation references from `acp.yaml.sh` to `acp.yaml-parser.sh`

### Removed

- `acp.yaml.sh` - Replaced by `acp.yaml-parser.sh`
  - Old parser removed (migration complete)
  - All functionality now provided by `acp.yaml-parser.sh`
  - Test file `tests/acp.yaml.test.sh` also removed

## [3.6.3] - 2026-02-21

### Fixed
- Renamed `agent/patterns/typescript/library-services.md` to `local.library-services.md` for namespace consistency
- All pattern files now follow proper namespace conventions

## [3.6.2] - 2026-02-21

### Added
- Package creation now includes local-only directories: `agent/clarifications/` and `agent/feedback/`
- Created `.gitkeep` files in local directories to track structure while keeping content local
- Copied clarification template to new packages for easy use
- Added comprehensive documentation in package README about local development directories
- Updated `.gitignore` to exclude content files while tracking `.gitkeep` and templates

### Changed
- Package `.gitignore` now explicitly documents local-only pattern (clarifications, feedback, reports)
- Improved consistency with existing reports directory pattern

## [3.6.1] - 2026-02-21

### Changed
- Package creation script now includes ACP attribution link in generated README files
- Generated package READMEs now have blockquote with link to Agent Context Protocol repository

### Fixed
- Repository URL validation: automatically appends `.git` suffix if missing
- ACP version constraint in package.yaml: removed quotes (was `">=2.8.0"`, now `>=2.8.0`)
- Bootstrap script location: moved from `scripts/` to `agent/scripts/` for consistency

## [3.6.0] - 2026-02-21

### Added

**YAML Parser Modification Operations**:
- Added `yaml_array_append()` - Append scalar values to arrays
- Added `yaml_array_append_object()` - Append objects to arrays
- Added `yaml_object_set()` - Set fields on objects
- Full modification support: parse → modify → append → write cycle
- Auto-converts empty maps to arrays for seamless array operations
- Proper serialization with correct indentation for all structures
- Objects in arrays serialize with dash prefix on first field

**Manifest Integration**:
- `add_file_to_manifest()` now uses YAML parser exclusively (no awk!)
- All installed files tracked with complete metadata
- Verified with real package installations

**Parser Enhancements**:
- Changed shebang to `#!/bin/bash` for BASH_SOURCE compatibility
- Fixed root node serialization (no extra indentation)
- Fixed array item serialization (proper spacing: `-  value`)
- Fixed object-in-array serialization (dash prefix for first field)
- Parent type tracking for context-aware serialization

**Test Coverage**:
- Added 10+ modification operation tests to test suite
- All tests consolidated in single file
- 50+ total tests, 100% passing

**Known Limitations**:
- Inline empty arrays (`patterns: []`) parse as scalars
- Workaround: sed converts `[]` to proper format before parsing
- This is acceptable for ACP's use cases

**Impact**: YAML parser now supports full CRUD operations on complex structures using the parser itself

## [3.5.2] - 2026-02-21

### Fixed

**YAML Parser Integration Bug**:
- Fixed `yaml_has_key()` to check node existence instead of value presence
- Added `yaml_get_array()` function for array element counting
- Resolves BR-2026-02-21-008: validation script now correctly reads package.yaml contents
- Validation now shows "All X files in contents exist" instead of "All 0 files"
- Package files are now properly validated for namespace consistency
- Bug was caused by `yaml_has_key()` returning false for keys with no direct value (arrays, maps)

**Impact**: Package validation now works correctly in all contexts

## [3.5.1] - 2026-02-21

### Fixed

**YAML Validation Integration**:
- Updated `agent/scripts/acp.yaml-validate.sh` to use new generic YAML parser
- Added `yaml_has_key()` function to `acp.yaml-parser.sh` for backward compatibility
- Fixed sourcing behavior to prevent main section execution when sourced
- All validation functions now use AST-based parser for better performance
- Zero breaking changes - drop-in replacement maintains full compatibility

## [3.5.0] - 2026-02-21

### Added

**Generic YAML Parser with AST**:
- New `agent/scripts/acp.yaml-parser.sh` - Pure POSIX shell YAML parser with Abstract Syntax Tree
- Parse once, query many times with efficient AST caching
- Generic path expressions: `.path.to.field`, `.array[0].field`, `.nested.array[0].field`
- Full API: `yaml_parse()`, `yaml_query()`, `yaml_set()`, `yaml_write()`
- Backward compatible with existing `yaml_get()` and `yaml_get_nested()` functions
- Zero external dependencies (no yq, jq, or other tools required)
- Comprehensive test suite with 30+ tests in `tests/acp.yaml-parser.test.sh`
- Reusable test utilities in `tests/common.sh`
- Complete design documentation in `agent/design/yaml-parser-design.md`
- Handles simple maps, nested objects, arrays, object arrays, and complex structures
- Production-ready implementation suitable for extraction as standalone project (`yaml-sh`)

**Benefits**:
- 10-100x faster for multiple queries on same file (parse once, query many)
- Works for ANY YAML structure without hard-coded patterns
- Enables future enhancements (filters, wildcards, YAML 1.2 features)
- Provides foundation for more sophisticated YAML operations

**Completed**:
- Task 34: Build Generic YAML Parser with AST (estimated 80-160 hours, delivered in one session)

## [3.4.3] - 2026-02-21

### Fixed

**Template Distribution**:
- `acp.install.sh` now copies `package.template.yaml`
- `acp.version-update.sh` now copies `package.template.yaml` and `manifest.template.yaml`
- Ensures all template files are distributed correctly during installation and updates

## [3.4.2] - 2026-02-21

### Fixed

**Template Distribution** (partial):
- Initial fix for template distribution

## [3.4.1] - 2026-02-21

### Changed

**Package File Validation Strictness**:
- Changed from warning to error for package files not in contents
- Files matching package namespace MUST be in package.yaml contents
- Prevents accidental omissions
- Provides clear guidance on how to fix

## [3.4.0] - 2026-02-21

### Added

**Smart Package File Detection in Validation**:
- `@acp.package-validate` detects package files not in contents
- Files matching package namespace but excluded from package.yaml
- Shows error with list of affected files
- Provides guidance on how to add them (@acp.command-create, @acp.pattern-create)
- Helps catch forgotten files

## [3.3.2] - 2026-02-21

### Added

**YAML Parser Test Suite**:
- Created `tests/acp.yaml.spec.sh` with comprehensive test coverage
- 14 tests validating parser functionality (all passing)
- Tests basic operations, simple arrays, object arrays with indexing
- Validates `yaml_get_nested()` array indexing feature
- Tests complex nested structures (manifest.yaml format)
- Prevents regressions in parser functionality

## [3.3.1] - 2026-02-21

### Fixed

**ACP Core Tracking in manifest.yaml**:
- `acp.install.sh` now creates `manifest.yaml` with acp-core package entry
- Tracks all installed core commands, patterns, and designs
- `acp.version-update.sh` updates acp-core version in manifest
- `acp.package-validate.sh` checks manifest before warning about unlisted files
- No more false warnings about core commands

## [3.3.0] - 2026-02-21

### Added

**Enhanced YAML Parser for Nested Objects**:
- Added `yaml_get_nested()` function to `acp.yaml.sh` for array indexing support
- Supports syntax: `contents.commands[0].name`
- POSIX-compliant implementation using awk
- Enables reading nested objects in YAML arrays
- Generic solution for all nested object access

**Package Template**:
- Created `agent/package.template.yaml` showing correct package.yaml format
- Documents object format for contents arrays: `{name: "file.md"}`
- Provides single source of truth for package creators

### Changed

**Package Validation Improvements**:
- Updated `acp.package-validate.sh` to use `yaml_get_nested()`
- File existence check now correctly reads package.yaml contents
- Namespace validation now correctly reads package.yaml contents
- Fixed "All 0 files in contents exist" error

**Schema Documentation**:
- Updated `agent/schemas/package.schema.yaml` to document object format
- Contents arrays must contain objects with `name` field
- Enables version tracking per file (extensible for future)

### Fixed

- Package validation can now read files from package.yaml contents correctly
- No more false "unlisted files" warnings
- Object format works consistently across all scripts

## [3.2.1] - 2026-02-21

### Fixed

**Package .gitignore Correction**:
- Removed `agent/progress.yaml` and `agent/manifest.yaml` from package .gitignore
- Both files should be committed in package repositories (just like in ACP projects)
- manifest.yaml tracks installed dependencies for package development
- progress.yaml tracks package development progress
- All ACP files should be version controlled in packages

## [3.2.0] - 2026-02-21

### Added

**Progress Tracking for Package Repositories**:
- `@acp.package-create` now creates `agent/progress.yaml` for package development tracking
- Minimal structure with no predefined milestones or tasks
- Enables full ACP workflow in package repositories (@acp.init, @acp.proceed, @acp.status)
- Package developers can create milestones and tasks as needed
- All ACP files are version controlled (manifest.yaml and progress.yaml committed)

**Benefits**:
- Consistent experience between projects and packages
- Package developers can use standard ACP commands
- Track package development progress
- Plan features with milestones and tasks

## [3.1.1] - 2026-02-21

### Fixed

**Package Validation Bug Fix**:
- Fixed `@acp.package-validate` namespace validation to skip files not in `package.yaml` contents
- Validation now only checks files listed in package contents
- Files not in contents (e.g., installed dependencies) are skipped with informational message
- Fixes false positive namespace violations for package developers
- manifest.yaml already acts as dev dependency tracker (no new fields needed)

**Impact**:
- Package developers can install dependencies (like `git.commit.md`) without validation errors
- Validation correctly focuses only on package content files
- Installation system already worked correctly (only installs contents)

## [3.1.0] - 2026-02-21

### Added

**Bootstrap Installation Feature**:
- `@acp.package-create` now generates `scripts/bootstrap.sh` for one-command installation
- Bootstrap script installs ACP (if needed) and the package in a single command
- README.md template includes "Quick Start (Bootstrap New Project)" section
- Users can run: `curl -fsSL {repo}/raw/{branch}/scripts/bootstrap.sh | bash`
- Perfect for bootstrapping new projects with specific ACP packages
- Automatic generation for every package created

**Benefits**:
- Simplifies onboarding for new users
- One-command setup for ACP + package
- Works whether ACP is installed or not
- Prominently featured in package README.md

## [3.0.0] - 2026-02-21

### Summary

Major release consolidating 33 commits and completing Milestone 4 (ACP Package Development System). This release represents a complete package development workflow from creation to publishing, with breaking changes to `@acp.package-create`.

### Added

**Milestone 4: ACP Package Development System (Complete)**
- Complete package development workflow operational
- 11 tasks completed across 6 implementation phases
- 33 commits since version 2.0.0

**Entity Creation Commands**:
- `@acp.pattern-create` - Create patterns with namespace and draft support
- `@acp.command-create` - Create commands with automatic package.yaml updates
- `@acp.design-create` - Create design documents with namespace enforcement
- `@acp.task-create` - Create tasks with milestone linking and progress updates

**Validation System**:
- `@acp.package-validate` - Comprehensive package validation with shell checks and test installation
- `@acp.validate` v2.0.0 - Enhanced with namespace validation and computer roleplay directive
- YAML schema system with pure bash validator (zero dependencies)
- Namespace consistency checking across all entity types
- Reserved namespace enforcement (acp, local, core, system, global)

**Publishing Automation**:
- `@acp.package-publish` - 13-step publishing workflow with version management
- Automatic version bump detection from Conventional Commits
- CHANGELOG generation support (LLM-based, shell placeholder)
- Branch validation (main, master, mainline, release, custom)
- Test installation from remote after publishing

**Package Creation & Management**:
- `@acp.package-create` v2.0.0 - Complete rewrite with full ACP installation
- `@acp.package-create` v2.1.0 - Non-interactive mode with CLI arguments
- Pre-commit hook system for package.yaml validation
- Default directory: `~/.acp/projects/acp-{name}/`
- Full ACP installation (templates, scripts, schemas) in packages

**Infrastructure & Utilities**:
- YAML schema system (agent/schemas/package.schema.yaml)
- Pure bash YAML validator (acp.yaml-validate.sh) - zero dependencies
- Namespace utilities (5 functions for context-aware namespace handling)
- README update utilities (automatic content list generation from package.yaml)
- Pre-commit hook template system with automatic installation
- install_precommit_hook() function in acp.common.sh

**Documentation & Patterns**:
- TypeScript library-services pattern
- Computer roleplay directive added to command templates
- "Resume a previous session" section in README
- Critical directives about respecting user re-execution commands
- Comprehensive command documentation with examples

**Milestone 5 Planning**:
- Global Package Installation design completed
- 5 tasks created (tasks 25-29)
- Global installation to `~/.acp/packages/` with `--global` flag
- Agent discovery via `~/.acp/manifest.yaml`
- Auto-initialization design (global-acp-installation.md)
- Estimated: 9-13 hours implementation

### Changed

**BREAKING: @acp.package-create** - Complete rewrite (v1.0.0 → v2.0.0 → v2.1.0)
- Now runs `acp.install.sh` to install complete ACP structure (all templates, commands, scripts)
- Changed default directory from arbitrary location to `~/.acp/projects/acp-{name}/`
- Removed example file creation (use templates from ACP installation instead)
- Added release branch configuration (default: main)
- Added pre-commit hook installation (validates package.yaml before commits)
- Added non-interactive mode with CLI arguments (v2.1.0)
- Breaking: Old workflow no longer supported

**Package Development Workflow**:
- Packages now created with complete ACP tooling
- Full validation before publishing
- Automated version management via Conventional Commits
- Pre-commit validation hooks automatically installed

**acp.install.sh Enhancements**:
- Now copies `agent/schemas/*.yaml` files
- Now copies `agent/manifest.template.yaml`
- Ensures complete ACP installation for packages

### Fixed

- **@acp.package-create Directory Structure** - Fixed redundant nesting
  - Changed from `~/.acp/projects/{name}/acp-{name}/` to `~/.acp/projects/acp-{name}/`
  - Fixed SCRIPT_DIR to use absolute path (prevents issues after cd)
  - Fixed directory existence check (was creating before checking)
- **Documentation Formatting** - Fixed command file formatting
  - Fixed missing closing quote in computer roleplay directive
  - Fixed repository URLs in examples to include "acp-" prefix
  - Added explicit confirmation requirement before invoking installed commands

### Migration Guide

**For Package Developers**:
- **Old**: Create packages anywhere with manual setup
- **New**: Use `@acp.package-create` for full ACP installation in `~/.acp/projects/`
- **New**: Packages include pre-commit hooks for automatic validation
- **New**: Use `@acp.package-publish` for automated publishing with version management
- **New**: Use entity creation commands (@acp.pattern-create, @acp.command-create, etc.)

**For Package Users**:
- No breaking changes to package installation
- All existing `@acp.package-install` commands work as before
- New validation and publishing commands available
- New entity creation commands for package development

**Breaking Changes**:
- `@acp.package-create` workflow completely changed
- Old manual package creation workflow no longer supported
- Packages must now be created in `~/.acp/projects/` by default
- Package structure now includes full ACP installation

### Statistics

- **Commits**: 33 since version 2.0.0
- **Milestones**: 4 completed (M1-M4), 1 planned (M5)
- **Tasks**: 24 completed, 5 planned (29 total)
- **Commands**: 25 implemented
- **Scripts**: 17 in agent/scripts/
- **Overall Progress**: 86% (M1-M4 complete, M5 not started)

## [2.11.0] - 2026-02-21

### Added
- **@acp.package-create Non-Interactive Mode** - Command-line argument support
  - Added `--name`, `--description`, `--author`, `--repository` flags
  - Added `--license`, `--homepage`, `--tags`, `--branch`, `--target-dir` optional flags
  - Automatic non-interactive mode when all required args provided
  - Removed `--yes` flag (not needed with CLI args)
  - Script version: 2.0.0 → 2.1.0

### Fixed
- **@acp.package-create Directory Structure** - Fixed redundant nesting
  - Changed default from `~/.acp/projects/{name}/acp-{name}/` to `~/.acp/projects/acp-{name}/`
  - Fixed SCRIPT_DIR to use absolute path (prevents issues after cd)
  - Fixed directory existence check (was creating before checking)

### Changed
- **Test Package Created** - Successfully tested non-interactive mode
  - Created acp-test-package at `~/.acp/projects/acp-test-package/`
  - Verified full ACP installation, package.yaml, git initialization
  - Pre-commit hook installed and working

## [2.10.1] - 2026-02-21

### Changed
- **Milestone 5 Planning** - Global Package Installation design completed
  - Revised design document based on user clarification feedback
  - Removed symlink-based architecture in favor of simple agent discovery
  - Added `@acp.init` enhancement to automatically read and report global packages
  - Created clarification document with 25+ architecture questions answered
  - Updated milestone document with 4 implementation phases
  - Global packages install to `~/.acp/packages/` only (no symlinks)
  - Agents discover packages via `~/.acp/manifest.yaml`
  - Local packages always take precedence over global packages

## [2.10.0] - 2026-02-21

### Added
- **Milestone 4 Complete** - ACP Package Development System fully operational
  - All 11 tasks completed (100%)
  - Complete package development workflow from creation to publishing
  - Entity creation commands, validation system, publishing automation
  - Pre-commit hook system documented and integrated

### Changed
- **Task 24: Pre-Commit Hook System** - Documentation completed
  - Hook implementation already complete from Task 23
  - Comprehensive documentation added to task document
  - Verification checklist completed
  - Implementation notes and testing results documented
- **Milestone 4 Status** - Marked as completed
  - Progress: 91% → 100%
  - All 6 phases complete (Infrastructure, Entity Creation, Validation, Publishing, Package Creation, Hooks)
  - Completed date: 2026-02-21
- **Project Progress** - Overall progress: 92% → 100%
  - All 4 milestones complete
  - 24/24 tasks completed
  - Ready for Milestone 5 planning

## [2.9.1] - 2026-02-21

### Fixed
- Documentation formatting in command files
  - Fixed missing closing quote in computer roleplay directive (acp.proceed.md, command.template.md, git.commit.md)
  - Added computer roleplay directive to acp.package-install.md and acp.report.md
  - Fixed repository URLs in examples to include "acp-" prefix (acp.package-install.md)
  - Added explicit confirmation requirement before invoking installed commands (acp.package-install.md)

## [2.9.0] - 2026-02-21

### Changed
- **@acp.package-create Command** - Complete rewrite with full ACP installation
  - Now runs `acp.install.sh` to install complete ACP structure (all templates, commands, scripts)
  - Collects release branch configuration (default: main)
  - Default directory changed to `~/.acp/packages/{package-name}` or `$HOME/.acp/packages/{package-name}`
  - Installs pre-commit hook automatically (validates package.yaml before commits)
  - Removed example file creation (use templates from ACP installation instead)
  - Creates package.yaml with `release.branch` field
  - Enhanced next steps with entity creation commands
  - Version bump: 1.0.0 → 2.0.0 (breaking - complete rewrite)
- **acp.install.sh** - Enhanced to copy schemas directory and manifest template
  - Now copies `agent/schemas/*.yaml` files
  - Now copies `agent/manifest.template.yaml`
  - Ensures complete ACP installation for packages

### Added
- **install_precommit_hook()** - New function in `acp.common.sh`
  - Installs pre-commit hook for package validation
  - Validates package.yaml before allowing commits
  - Gracefully handles missing validation scripts
  - Documents future enhancements (namespace checking, CHANGELOG validation)

## [2.8.0] - 2026-02-21

### Added
- **@acp.package-publish Command** - Automated package publishing workflow
  - 11-step publishing workflow from validation to testing
  - Delegates to @git.commit for version/CHANGELOG management (avoids logic duplication)
  - Automatic version bump detection from Conventional Commits
  - Analyzes commits for breaking changes, features, and fixes
  - User confirmation for version number (Y/n/custom)
  - Branch validation (main, master, mainline, release, custom)
  - Remote status checking (prevents overwriting)
  - Git tag creation (vX.Y.Z format)
  - Push to remote (commits and tags)
  - Post-publish test installation from remote
  - Comprehensive error handling at each step
  - Shell script: `agent/scripts/acp.package-publish.sh`

### Changed
- Milestone 4 progress: 73% → 82% (9/11 tasks complete)
- Phase 4 (Publishing) complete

## [2.7.0] - 2026-02-21

### Changed
- **Enhanced @acp.validate Command** - Added strict namespace validation
  - STRICT enforcement: All patterns/commands/designs MUST have namespace prefix
  - In packages: Use package namespace (e.g., firebase.pattern.md)
  - In projects: Use local namespace (e.g., local.pattern.md)
  - ERROR for files missing namespace prefix (not just warning)
  - Exception: Template files (*.template.md) don't need namespace
  - Added Step 8: Validate Namespace Conventions
  - Context-aware validation (package vs project detection)
  - Checks for reserved namespace violations (acp, local, core, system, global)
  - Updated verification checklist with namespace checks
  - Updated example output with namespace validation section
  - Added computer roleplay directive to command header
  - Version bump: 1.0.0 → 2.0.0 (breaking - new strict validation)
- Milestone 4 progress: 64% → 73% (8/11 tasks complete)
- Phase 3 (Validation) complete

## [2.6.0] - 2026-02-21

### Changed
- **Enhanced @acp.validate Command** - Added namespace validation and reserved name checking
  - Added Step 8: Validate Namespace Conventions
  - Context-aware validation (package vs project detection)
  - Validates command/pattern/design filenames use correct namespace
  - Checks for reserved namespace violations (acp, local, core, system, global)
  - Updated verification checklist with namespace checks
  - Updated example output with namespace validation section
  - Added computer roleplay directive to command header
  - Version bump: 1.0.0 → 2.0.0 (breaking - new validation checks)
- Milestone 4 progress: 64% → 73% (8/11 tasks complete)
- Phase 3 (Validation) complete

## [2.5.0] - 2026-02-21

### Added
- **@acp.package-validate Command** - Comprehensive package validation system
  - Shell-based validation (YAML structure, file existence, namespace consistency, git setup, README)
  - Test installation to temporary directory with automatic cleanup
  - Remote repository availability checking via git ls-remote
  - Unlisted files detection (finds files not in package.yaml)
  - Validation score calculation and comprehensive reporting
  - Fixable issues identification for LLM auto-fix
  - Command documentation with examples and troubleshooting
  - Shell script: `agent/scripts/acp.package-validate.sh`

### Changed
- Milestone 4 progress: 55% → 64% (7/11 tasks complete)
- Phase 3 (Validation) started with Task 20 complete

## [2.4.0] - 2026-02-21

### Changed
- Enhanced `agent/commands/command.template.md` with computer roleplay directive
  - Clarifies that agent should execute command directives as instructions
  - Improves command execution clarity and consistency

## [2.3.0] - 2026-02-21

### Added
- **@acp.command-create Command** - LLM-based command creation
  - Context-aware namespace detection
  - Collects command-specific fields (category, frequency)
  - Automatic package.yaml and README.md updates
  - Draft file support
- **@acp.design-create Command** - LLM-based design document creation
  - Context-aware namespace detection
  - Automatic package.yaml and README.md updates
  - Draft file support
- **Design: install-local-patterns-feature** - Proposal for --install-local flag
  - Install local namespace patterns from source repos with namespace conversion
  - Enable sharing of implementation patterns between packages

### Changed
- Milestone 4 progress: 55% (6/11 tasks complete)
- Phase 2 (Entity Creation) complete - all 3 entity creation commands implemented

## [2.2.3] - 2026-02-21

### Added
- **Pattern: library-services** - Service layer, database layer, and API client layer architecture
  - Three-layer architecture for TypeScript libraries
  - Complete implementation examples for each layer
  - Dependency injection pattern
  - Testing examples with mocks
  - Benefits, trade-offs, and usage guidance
  - Demonstrates @acp.pattern-create command in action

## [2.2.2] - 2026-02-20

### Added
- **@acp.pattern-create Command** - LLM-based pattern creation (no shell script needed)
  - Context-aware namespace detection
  - Chat-based information collection
  - Draft file support
  - Automatic package.yaml and README.md updates
  - Command documentation complete

### Changed
- Simplified entity creation approach: LLM handles creation directly via command directives
- Removed unnecessary shell script (agent/scripts/acp.pattern-create.sh)
- Entity creation commands are now pure LLM directives (more intelligent and flexible)

## [2.2.1] - 2026-02-20

### Added
- **Task 15: Namespace Utilities** - Context-aware namespace detection and validation
  - Added `is_acp_package()` - Detects if directory is ACP package
  - Added `infer_namespace()` - Infers namespace from package.yaml, directory name, or git remote
  - Added `validate_namespace()` - Validates format and checks reserved names (acp, local, core, system, global)
  - Added `get_namespace_for_file()` - Returns package namespace or "local" for non-packages
  - Added `validate_namespace_consistency()` - Checks for conflicts between sources
- **Task 16: README Update Utilities** - Automatic README.md content list generation
  - Added `update_readme_contents()` - Updates README from package.yaml
  - Added `generate_contents_section()` - Generates formatted markdown lists
  - Added `add_file_to_readme()` - Convenience wrapper
  - Uses HTML comment markers for section boundaries
  - Extracts file names and descriptions from package.yaml

### Changed
- Enhanced `agent/scripts/acp.common.sh` with 8 new utility functions
- Milestone 4 progress: 27% (3/11 tasks complete)

## [2.2.0] - 2026-02-20

### Added
- **Milestone 4: ACP Package Development System** - Comprehensive planning complete
  - Created design document with complete architecture and specifications
  - Created milestone document with 11 tasks across 6 phases
  - Created 11 task documents (task-14 through task-24)
  - Estimated effort: 45-58 hours over 6-8 weeks
- **Clarification System** - 4 clarification documents with 214 questions answered
  - clarification-1: Package create enhancements (31 questions)
  - clarification-2: Package development commands (62 questions)
  - clarification-3: Draft files and schema validation (73 questions)
  - clarification-4: Implementation edge cases (48 questions)
- **Task 14 Complete: YAML Schema System** - Pure bash YAML validator
  - Created `agent/schemas/package.schema.yaml` with comprehensive schema definition
  - Implemented `agent/scripts/acp.yaml-validate.sh` (pure bash, zero dependencies)
  - Validates required fields, types, patterns, lengths, reserved names
  - Tested with valid and invalid package.yaml files
  - Provides helpful error messages
- **New Commands Planned** (to be implemented in M4):
  - `@acp.pattern-create` - Create patterns with namespace enforcement
  - `@acp.command-create` - Create commands with namespace enforcement
  - `@acp.design-create` - Create design documents with namespace enforcement
  - `@acp.package-validate` - Comprehensive package validation with auto-fix
  - `@acp.package-publish` - Automated publishing workflow

### Changed
- Updated `@acp.package-create` command with chat-based collection and target directory support
- Project status changed to in_progress with current_milestone: M4
- Milestone 4 progress: 9% (1/11 tasks complete)

## [2.1.4] - 2026-02-18

### Added
- **CRITICAL: Never Reject User Requests Directive**: Added as Best Practice #1 in AGENT.md
  - Agents must NEVER reject requests based on session duration, token context limits, session cost, or task complexity
  - Emphasizes that users have the right to request any work they need
  - Agents should break down complex tasks and work iteratively
  - Marked with 🚨 CRITICAL warning indicators for maximum visibility
  - Positioned as the most important best practice for agent behavior

### Changed
- Renumbered existing best practices (CHANGELOG.md guideline is now #8, secrets handling remains in sequence)

## [2.1.3] - 2026-02-18

### Added
- **Package Management Commands**: Complete package management system with 6 new commands
  - `@acp.package-search` - Search for available ACP packages
  - `@acp.package-list` - List installed packages
  - `@acp.package-remove` - Remove installed packages
  - `@acp.package-info` - Display package information
  - `@acp.package-update` - Update installed packages
  - `@acp.package-install` - Enhanced with manifest support
- **Manifest System**: YAML-based package metadata
  - `agent/manifest.template.yaml` for package authors
  - Tracks package name, version, description, author
  - Lists all files (commands, patterns, designs)
  - Documents dependencies on other packages
  - Enables selective installation and updates
- Supporting shell scripts for all package commands
- Milestone 3 completed (100% - all 13 tasks done)

## [2.1.2] - 2026-02-18

### Changed
- **Command Display**: Refactored command list display into shared `display_available_commands()` function
  - Added new function in `acp.common.sh` for consistent command display
  - Updated `acp.install.sh` to use shared function
  - Updated `acp.version-update.sh` to use shared function
  - Now displays all 19 commands including 6 package management commands
  - Eliminates code duplication (reduced from 40+ lines to 1 function call)

## [2.1.1] - 2026-02-18

### Fixed
- **Script Installation**: Install and update scripts now copy all *.sh files dynamically
  - Previously hardcoded list was missing new package management scripts
  - `acp.package-search.sh`, `acp.package-list.sh`, `acp.package-remove.sh`, `acp.package-info.sh`, `acp.package-update.sh` now properly installed
  - Future-proof: any new scripts will be automatically copied
  - Simplified code from 10 lines to 4 lines using find command

## [2.1.0] - 2026-02-18

### Added
- **Dependency Checking System**: Project dependency compatibility validation for npm, pip, cargo, and go packages
  - Automatic package manager detection
  - Version compatibility checking with color-coded output
  - User prompts with recommendations for missing dependencies
  - Integration with package installation flow
  - Respects `--yes` flag for CI/CD automation
- Added 6 dependency checking functions to `acp.common.sh`:
  - `detect_package_manager()` - Detects npm/pip/cargo/go
  - `check_npm_dependency()` - Validates npm packages
  - `check_pip_dependency()` - Validates Python packages
  - `check_cargo_dependency()` - Validates Rust packages
  - `check_go_dependency()` - Validates Go packages
  - `validate_project_dependencies()` - Main validation function

### Changed
- Enhanced `acp.package-install.sh` with dependency validation before installation
- Updated project status to "completed" - all 3 milestones (16 tasks) complete
- Milestone 3 progress: 78% → 100%

### Verified
- Pure bash YAML parser (`acp.yaml.sh`) already implemented and functional
- Based on fiftydinar/yaml-parser (MIT license)
- Provides yaml_get(), yaml_set(), yaml_has_key(), yaml_get_array()

## [2.0.0] - 2026-02-18

### Changed
- **BREAKING**: All core ACP scripts renamed with `acp.` prefix for namespace protection
  - `check-for-updates.sh` → `acp.version-check-for-updates.sh`
  - `common.sh` → `acp.common.sh`
  - `install.sh` → `acp.install.sh`
  - `package-install.sh` → `acp.package-install.sh`
  - `uninstall.sh` → `acp.uninstall.sh`
  - `update.sh` → `acp.version-update.sh`
  - `version.sh` → `acp.version-check.sh`
  - `yaml.sh` → `acp.yaml.sh`
- **BREAKING**: Script names now perfectly align with command names
  - `@acp.version-check` → `acp.version-check.sh`
  - `@acp.version-update` → `acp.version-update.sh`
  - `@acp.package-install` → `acp.package-install.sh`
- Installation and update scripts now automatically remove deprecated script names
- All 84+ references updated across documentation

### Added
- `cleanup_deprecated_scripts()` function in `acp.common.sh`
- Automatic cleanup of old script names during install/update

### Migration Guide
**For Users**: No action required if using commands (`@acp.*`)
- Commands still work the same way
- Scripts are called internally by ACP

**For Direct Script Users**: Update script paths
- Old: `./agent/scripts/update.sh`
- New: `./agent/scripts/acp.version-update.sh`

**Why This Change**:
- Enables third-party packages to add their own scripts without conflicts
- Perfect alignment between command names and script names
- Clear namespace ownership (`acp.*` = core, `firebase.*` = firebase package)

## [1.4.3] - 2026-02-16

### Fixed
- **Script Color Output**: Updated remaining shell scripts to use `tput` for colors
  - Updated acp.version-check-for-updates.sh to use tput pattern
  - Updated unacp.install.sh to use tput pattern
  - Updated acp.version-check.sh to use tput pattern
  - Updated package-acp.install.sh to use tput pattern
  - All 6 scripts now use consistent, reliable color handling
  - Removed `echo -e` flags (not needed with tput)
  - Colors work correctly across all shells (bash, sh, zsh)

## [1.4.2] - 2026-02-16

### Changed
- **Script Output**: Added "Git Commands Available" section to acp.install.sh and acp.version-update.sh
  - Separate section highlighting @git.init and @git.commit commands
  - Improves discoverability of git workflow commands for new users
  - Clear separation between ACP commands and Git commands

## [1.4.1] - 2026-02-16

### Fixed
- **Script Color Output**: Fixed color output in acp.install.sh and acp.version-update.sh
  - Replaced unreliable ANSI escape codes with `tput` commands
  - Colors now work correctly across all shells (bash, sh, zsh)
  - No more literal escape character output
  - Added fallback for non-terminal environments
  - Removed unnecessary `-e` flag from echo commands

## [1.4.0] - 2026-02-16

### Added
- **`@git.init` Command**: Intelligent git repository initialization
  - Automatically detects project type (Node.js, Python, Rust, Go, Java, PHP, Ruby, C#, and more)
  - Generates smart `.gitignore` based on detected technology stack
  - Ensures dependency lock files are NOT ignored (package-lock.json, poetry.lock, etc.)
  - Ignores build directories (dist/, build/, target/)
  - Ignores dependency directories (node_modules/, venv/, etc.)
  - Ignores package archives (*.tgz for npm)
  - Uses web search tools for unknown project types
  - Includes 5 examples covering common and uncommon scenarios

## [1.3.2] - 2026-02-16

### Changed
- **Command Namespace**: Renamed `@acp.commit` to `@git.commit`
  - Better namespace organization (git-specific operations under `git` namespace)
  - Updated all references in AGENT.md and CHANGELOG.md
  - Command functionality unchanged, only improved organization

## [1.3.1] - 2026-02-16

### Added
- **Commit Types**: New commit types for better categorization
  - `agent`: Changes to agent/ directory only (designs, tasks, milestones, patterns)
  - `version`: Version bump only (no code changes)
- **Commit Template Enhancements**: Enhanced @git.commit template with metadata
  - Task and milestone completion tracking
  - Test statistics section (tests passing, coverage)
  - Documentation links section (design docs, API docs, related resources)
  - Scope in commit type format: `<type>(<scope>)`

### Changed
- **AGENT.md**: Added rule #9 for respecting user's intentional edits
  - Do not assume missing content needs to be added back
  - Always confirm before reverting user's manual changes
  - Read files to see current state before editing
- **@git.commit**: Clarified intelligent file staging behavior
  - Command automatically determines which files to stage
  - Decision logic for staging all vs specific files
  - Removed redundant prerequisites

### Fixed
- Clarified that `BREAKING CHANGE` is a footer, not a commit type

## [1.3.0] - 2026-02-16

### Added
- **`@git.commit` Command**: Intelligent version-aware git commit automation
  - Automatically detects version impact (major/minor/patch)
  - Updates all version files (package.json, AGENT.md, etc.)
  - Generates CHANGELOG.md entries with proper formatting
  - Creates Conventional Commits format messages
  - Includes decision tree and examples for version bumping
  - Supports semantic versioning workflow

### Changed
- **AGENT.md**: Added critical emphasis on CHANGELOG.md updates for version changes
  - New rule #7 mandates CHANGELOG.md updates for all version changes
  - Recommends using `@git.commit` for version-aware commits
  - Explains rationale for changelog discipline
  - Moved secrets handling to rule #8

## [1.2.2] - 2026-02-16

### Added
- `agent/.gitignore` file to exclude reports directory from version control
- `agent/reports/` directory created during installation
- Reports are now generated locally but not committed to git

### Changed
- `acp.install.sh` now creates `agent/.gitignore` and `agent/reports/` directory
- `acp.version-update.sh` ensures `agent/.gitignore` exists for users updating from older versions

## [1.2.1] - 2026-02-16

### Changed
- Updated installation scripts to display new ACP command format
- `acp.install.sh` now shows all 11 ACP commands with descriptions
- `acp.version-update.sh` now shows all 11 ACP commands with descriptions
- Replaced old "AGENT.md: Initialize" prompt format with `@acp.init` command
- Improved user experience for new installations and updates

## [1.2.0] - 2026-02-16

### Added
- **Package Installation Enhancements**:
  - `agent/scripts/package-acp.install.sh` script for automated package installation
  - Support for installing patterns and design documents (not just commands)
  - `-y` flag to skip confirmation prompts for automated installations
  - Multi-directory installation from agent/ (commands, patterns, design)
  - Conflict detection and resolution

### Changed
- Renamed `@acp.install` to `@acp.package-install` for clarity
- Enhanced package installation to support all agent/ directories
- Simplified Milestone 2 scope by removing creation commands
- Updated package-install documentation with multi-directory examples

## [1.1.0] - 2026-02-16

### Added
- **ACP Commands System**: File-based command interface for ACP operations
  - Command template for creating custom commands
  - Flat directory structure with dot notation (acp.init.md)
  - 11 core commands implemented across 2 milestones:
  
  **Workflow Commands**:
    - `@acp.init` - Initialize agent context (replaces "AGENT.md: Initialize")
    - `@acp.proceed` - Continue with next task (replaces "AGENT.md: Proceed")
    - `@acp.status` - Display project status
  
  **Version Commands**:
    - `@acp.version-check` - Show current ACP version
    - `@acp.version-check-for-updates` - Check for updates
    - `@acp.version-update` - Update ACP to latest version
  
  **Documentation Commands**:
    - `@acp.update` - Update progress.yaml with latest status
    - `@acp.sync` - Synchronize documentation with source code
    - `@acp.validate` - Validate all ACP documents for consistency
  
  **Utility Commands**:
    - `@acp.report` - Generate comprehensive project status report
    - `@acp.package-install` - Install third-party command packages
  
  - Self-documenting commands with step-by-step instructions
  - Autocomplete-friendly namespace system with dot notation
  - Security considerations documented
  - Script-based package installation

- **Documentation Updates**:
  - ACP Commands section in AGENT.md with full documentation
  - Command examples in README.md
  - Updated directory structure diagrams
  - Command invocation syntax documented
  - Comprehensive command documentation with examples

### Changed
- Consolidated all scripts under `agent/scripts/` directory
- Updated installation script path in README
- Improved project organization with commands directory
- Simplified Milestone 2 scope by removing creation commands (natural language is sufficient)

## [1.0.3] - 2026-02-13

### Added
- **Template Files**: Complete set of reusable templates for all ACP document types
  - Design document template with comprehensive sections and examples
  - Requirements template for project planning
  - Milestone template with deliverables and success criteria
  - Task template with steps and verification checklist
  - Pattern template for documenting reusable patterns
  - Bootstrap template for project setup patterns
  - Progress tracking YAML template

- **Generic Patterns**: Database-agnostic, framework-independent patterns
  - TypeScript service layer pattern (applicable to any TypeScript project)

- **Installation & Update Scripts**:
  - `scripts/acp.install.sh` - Automated installation (run from project root)
  - `scripts/acp.version-update.sh` - Direct file updates (git handles diffs)
  - `scripts/acp.version-check-for-updates.sh` - Automatic update checking with changelog display

- **Documentation**:
  - README with quick start guide and example projects
  - CHANGELOG for version tracking
  - AGENT.md with complete ACP methodology and update instructions

- **Features**:
  - Automatic update checking on agent initialization
  - Git-friendly workflow (no backup files)
  - Template files always overwritten on install/update
  - All URLs reference `mainline` branch
  - Sample prompts for AI agents

### Changed
- Converted project-specific remember-mcp documentation to generic templates
- Made all examples platform-agnostic and framework-independent
- Reorganized scripts into dedicated `scripts/` directory
- Simplified installation to assume execution from project root

### Removed
- All project-specific content (remember-mcp milestones, tasks, designs)
- Framework-specific patterns (TanStack Router, Firebase-specific examples)
- Project-specific TypeScript patterns (Firestore users pattern)

