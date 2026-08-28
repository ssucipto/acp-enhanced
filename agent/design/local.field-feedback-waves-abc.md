# Design: Field-feedback waves A–C (Safe-IQ + FIFOZ remainder)

<!-- @acp.meta.design
topic: pr-diff, coderabbit, local-overlays, acp-smoke, exec-host
description: Three sequenced waves to absorb remaining Safe-IQ and FIFOZ field feedback without regressing --diff, CI, or privacy
status: active
updated: 2026-08-28
@acp.meta.end -->

**Version**: 1.1.0  
**Date**: 2026-08-28  
**Source of truth**: `agent/reports/audit-127-m89-m90-m91-pre-impl.md` (also 125–126)  
**Target releases**: M89 → v6.35.0, M90 → v6.36.0, M91 → v6.37.0  
**Out of scope**: F-R006-01..03, F-124-02, Expo/Maestro/AimZero tests, visualizer, ADR-19 Aikido  

---

## Problem statement

Two field teams wrote implementable packets. Most FIFOZ 2026-08-14 command work is already in v6.34.0. Remaining gaps:

1. **No per-PR semantic stop** — operators treat CodeRabbit / `commit_id` as a merge gate; `/acp-audit` and Phase 1 regex are not a substitute.
2. **No optional device preflight** — agents invent ad-hoc emulator paths or dump device work into `/acp-ci --fast`.
3. **Heavy device work on the editor** — without a portable exec-host contract.

Copying consumer implementations would regress AE: FIFOZ smoke 1.1.0 already requires Maestro + `--host`; AE already has `--diff` on `/acp-review`.

## Proposed solution

Three **sequential** milestones. Each has a pre-impl audit gate. Later waves must not start until the prior wave’s regression checks are green.

## Key technical decisions

### D1: `--pr-diff` is not `--diff`

`--diff` stays: Phase 1 scanner on `git diff --name-only` (changed files).  
`--pr-diff` is new: agent reads `git diff <base>...HEAD`, writes blocking vs deferred, **stops**.  
E2E for review **must keep** existing `--diff` assertions.

### D2: `--pr-diff` is an agent pass, not a new scanner

No Python/AST in core for this flag. E2E asserts docs, flags, “not Phase 1”, confirm block. Do not invent an LLM harness in CI.

### D3: Default base

1. `--base <ref>` if given  
2. Else open PR `baseRefName` via `gh` when available  
3. Else `origin/` + `identity.yml` `default_working_branch`  
Triple-dot `...` only.

### D4: Reports stay gitignored (ADR-27)

`--pr-diff` reports go to `agent/reports/review-N-pr-diff.md`. Do not `git add -f`. Do not change weekly `/acp-review --report --carryover`.

### D5: Portable checklist only

Framework checklist: honesty, authz/cache, parse-unknown, enqueue≠sync, dates/IDs, formatter, **stop**.  
Bucket table: A production / B helper — **no** TypeScript/SQLite/Express names in `acp.review.md` or the CR wiki.  
Promote recurring **classes** to **project** convention tests, not Phase 1 regex.

### D6: CodeRabbit docs extend ADR-21; they do not gate

Document: rate-limit = skip; green check ≠ review of HEAD; `commit_id` identifies SHA, not merge; body findings outside the diff still count; one LLM pass per layer; Bucket B onion non-blocking after one parser-level fix.  
**Do not** add CodeRabbit as a required GitHub status check.  
Consumer land-merge policy lives in `agent/wiki/local.*.md` (never shipped). Framework wiki gets a **Consumer overlay** stub heading only.

### D7: `/acp-audit` one-liner

Purpose/Related: not a PR review; not a CodeRabbit replacement.

### D8: `local.*` survival is document + optional wrappers

`acp.version-update.sh` already copies only `acp.*`/`git.*` commands. **Document** `agent/commands/local.*.md` and `agent/wiki/local.*.md` as never-deleted.  
Optional: cursor **and** claude sync emit `local-*` wrappers; **skip if destination already exists** (custom overlay). Update E2E counts so extra local files do not fail `≥ acp+git` parity. Do not overwrite product wrappers.

### D9: Wave B smoke is a stub

`/acp-smoke` delegates to a **project-configured runner**. Missing config → **exit 2**, never PASS/SKIP-as-green.  
E2E: `--help`, `--doctor`, `--dry-run`, unconfigured fail-closed. **No device.**  
Do not ship `--host` in M90. Do not put smoke in `/acp-ci` default tiers. `/acp-pr` **mentions** optional smoke; **does not wait**.  
Never reuse an existing `/acp-ci` step id named `smoke`. New CI alias (if any) gets a **new** id.

### D10: Wave C exec-host is generic `ACP_*`

`ACP_EXEC_HOST=github|windows|local`. `ACP_WINDOWS_SSH`, `ACP_WINDOWS_REPO`, bundle+scp, not `ssh -A` as the clone path. Include FIFOZ 012 rules (admin authorized_keys, adb stderr not Stop, detach emulator from SSH job, AVD by name, SkipPull+scp, debug APK must not attach to a foreign packager, Git Bash file not `-lc`).  
LAN adb = `--host local` only.  
E2E dry-run asserts `git bundle`; no secrets printed; no emulator.

### D11: PR extras live in `pr.yml`, not preference arrays

`acp.configurables.yaml` supports string / number / boolean / object only (**no list type**). Do **not** add `integrations.pr.local_gates[]`. Use `agent/configurables/pr.yml` (same ownership as `ci.yml` / P-CI-1): optional `local_gates` and `coderabbit_exclude_globs` lists, default empty. Empty = today’s `/acp-pr` behavior. Wiki: consumers **may** path-filter `agent/**`. AE template may stay narrower so **this** repo still reviews command docs.

### D14: `--diff` and `--pr-diff` may both be present

They are **not** aliases. `--diff` still scopes Phase 1 to `git diff --name-only`. `--pr-diff` is an additional agent pass on `git diff base...HEAD`. If both appear, run both. Do not drop `--diff` semantics.

### D15: `e2e-smoke` ≠ `/acp-smoke`

AE `/acp-ci` already has step id **`e2e-smoke`** (full tier, `run-e2e-tests.sh`). Device preflight is the command `/acp-smoke`. Never create `--only smoke`. Never rename `e2e-smoke`. Docs must use both names in a glossary.

### D16: Smoke runner config is `smoke.yml`

`agent/configurables/smoke.yml` — runtime path to a project runner. **Not** a preference in `acp.configurables.yaml`. Missing file → exit 2.

### D17: `--pr-diff` base without `gh`

Probe `gh` in `bash -c 'command -v gh'` (FG-4), not the agent shell. If missing or no PR: `origin/` + `default_working_branch`. `--pr-diff` must not fail solely because `gh` is absent.

### D18: Every version bump includes golden + counts + manifest

Tasks 353 / 358 / 364 must: refresh yaml-parser golden TSV if `progress.yaml` diverges; restamp `agent/integrity-manifest.yaml` after script edits; bump `domain.yml` `commands.count` and README “72 commands” on **new command** (M90); run `e2e/acp.command-coverage-parity.test.sh`; run post-milestone-sweep.

### D12: Crosscut + wrappers for new commands

New `acp.smoke` needs: command doc, cursor+claude **sync**, opencode + GitHub prompts **committed by hand** (no generator — same as `/acp-pr`), `package.yaml`, `command-e2e-coverage.yaml`, AGENT/README/CHANGELOG, `domain.yml` count.  
`--pr-diff` is **not** a new command file — only `acp.review.md` + E2E + wiki.

### D13: Independent tracks stay independent

F-R006, F-124-02, ADR-19, visualizer 003/004 — not these milestones.

## Binding rules (do not violate)

1. audit-127 (pre-impl) then 126/125 for remaining gaps.  
2. Do not copy FIFOZ `acp.smoke.md` 1.1.0 or AimZero `local.pr-diff-review.md` bodies.  
3. Do not change `--diff` semantics.  
4. Do not fold device work into `--fast`.  
5. Do not `git add -f` reports/feedback/instance milestone bodies.  
6. Dry-run is not verification for scripts that have executable branches (FG-6) — smoke/exec-host E2E still must not boot devices.  
7. FG-1…7 on every new script.  
8. `current_milestone` stays M88 until `/acp-proceed` starts M89.

## Shortcuts these waves refuse

- Aliasing `--pr-diff` to `--diff`  
- Phase 1 regex for honesty/authz  
- Making CodeRabbit a required check  
- SKIP-as-PASS when smoke runner missing  
- Emulator in command E2E  
- `FIFOZ_*` / product `applicationId` in core  
- Starting M91 `--host` before M90 exit 2  
- Blind-copying Windows `.ps1` that embed product paths  
- Preference arrays  
- Aliasing `/acp-smoke` to `--only smoke` or to `e2e-smoke`  
- Skipping command-coverage-parity or golden TSV on release  

## Acceptance (program)

| Wave | Operator can |
|------|----------------|
| A | Merge on CI green + `/acp-review --pr-diff` with buckets; `local.*` files survive version-update; `--diff` still documented |
| B | `/acp-smoke --doctor` fails closed if unconfigured; `/acp-ci --fast` and `/acp-pr` unchanged in duration/gates |
| C | Editor can dispatch `--host windows` dry-run without printing secrets or planning local Gradle |
