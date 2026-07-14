# Audit Report: ACP Enhanced — Whole-System Gaps, Inconsistencies & Standards Alignment

**Audit**: #091
**Date**: 2026-07-15
**Subject**: ACP Enhanced as a whole — gaps, inconsistencies, and industry-standards/best-practices alignment
**Requested as**: `/acp-audit` + "/acp-verify" (no such command exists — standards portion folded in here; the standards-enforcement command is `/acp-review`)

## Summary

The system is in strong overall health: v6.26.0 shipped with M70/M71 closed, the root-invoked TypeScript validator passes all structural checks, E2E coverage registry maps 70/70 commands, memory layers are schema-enforced, and CI follows several hardening best practices (SHA-pinned actions, trufflehog secret scanning). The `.claude/commands/` surface added earlier today works — this very audit was invoked through it.

The gaps found cluster around one theme: **derived/metadata surfaces that nothing enforces**. Two version-bearing files are stale (`copilot-instructions.md` at v6.24.0, `package.yaml` at 6.21.1) and both slipped past the validator because its drift checks compare byte-size only and never read `package.yaml`. The parity checker covers 3 of 5 wrapper surfaces and is blind to 6 stale dot-named duplicates. The documented validator invocation in `acp.validate.md` silently produces a vacuous all-green run. None of these break the shipped release, but they are exactly the "prints green while checks never ran" pattern ADR-10 flagged for `/acp-integrity` — now appearing in the validation layer.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| scripts/acp-validate.ts | source | Validator behavior, parity check, size guard |
| agent/commands/acp.validate.md | doc | Documented checks vs actual enforcement |
| .github/copilot-instructions.md | config | Stale v6.24.0 header |
| package.yaml | config | Stale version 6.21.1; unregistered scripts |
| scripts/acp-bootstrap.sh | source | Dead-glob wrapper copy loops |
| .github/prompts/, .opencode/commands/, .cursor/commands/, .claude/commands/ | derived | 5-surface parity state |
| agent/schemas/session.schema.yaml | schema | Required keys vs validate-doc claim |
| .github/workflows/ci.yaml, e2e-tests.yaml, benchmark.yaml | ci | Standards alignment |
| agent/scripts/*.sh (47) | source | Strict-mode coverage |
| agent/memory/audit-carryovers.md | memory | 2 pending ops carryovers |
| agent/progress.yaml | tracking | Recurring-task overdue; stale summary line |

## Key Findings

| # | Sev | Finding | Location |
|---|-----|---------|----------|
| F-091-01 | high | `.github/copilot-instructions.md` header says **v6.24.0** (two releases stale). Pre-commit sync hook that bootstrap installs for consumers is **not installed in this repo** (`.git/hooks/pre-commit` absent) — the framework doesn't dogfood its own sync mechanism. The validator missed it because the size guard compares bytes only (all three files are 10,721 bytes; the changed version string is the same length) and the version-header check reads AGENTS.md only. | .github/copilot-instructions.md:3 |
| F-091-02 | high | `package.yaml` version is **6.21.1** vs canonical 6.26.0. `acp.validate.md` Step 2c lists package.yaml as a **hard requirement (ERROR)**, but `scripts/acp-validate.ts` contains zero references to package.yaml — the documented check was never implemented. Additionally, three scripts are unregistered in both package.yaml and `agent/integrity-manifest.yaml`: `acp.cursor-commands-sync.sh`, `acp.claude-commands-sync.sh` (new today), `acp.post-milestone-sweep.sh`. (F-089-10's atomic-write/branch-protection registrations were verified correct — an initial reading during this audit was itself contaminated by the F-091-03 cwd trap, then re-verified from root.) | package.yaml:5 |
| F-091-03 | medium | Validator is cwd-sensitive with no repo-root detection. The invocation documented in `acp.validate.md` Step 11.6 — `(cd scripts && npx ts-node acp-validate.ts)` — makes every path-relative check skip and the parity check print a **vacuous pass**: "✅ Parity: 0 commands × 3 surfaces — all matched". Zero commands found should be a hard failure, not a green check. | scripts/acp-validate.ts:189 |
| F-091-04 | medium | Six stale dot-named duplicate wrappers coexist with their hyphen-named twins: `acp.carryover-query`, `acp.pattern-sync`, `acp.session-sync` in both `.github/prompts/` (`.prompt.md`) and `.opencode/commands/`. The parity check filters on `startsWith("acp-")`, so dot-named files are invisible to it. They show as duplicate entries in slash-command pickers. | .github/prompts/, .opencode/commands/ |
| F-091-05 | medium | Wrapper parity check covers 3 of 5 surfaces — `.cursor/commands/` and `.claude/commands/` are unchecked (pre-noted in ADR-18). Related doc staleness: progress.yaml summary line still says "prompts + opencode + cursor parity" (no claude), and the high-priority lesson in lessons.md instructs creating prompt + opencode companions only. | scripts/acp-validate.ts:189, agent/progress.yaml |
| F-091-06 | medium | `scripts/acp-bootstrap.sh` cursor/claude wrapper copy loops use glob `.opencode/commands/acp.*.md` (lines 1330, 1342) but opencode files are hyphen-named (`acp-*.md`) — the glob matches **nothing**; both loops are dead code that print misleading "✓ 0 … slash commands generated". On a fresh bootstrap the fallback sync scripts don't exist yet at that point either (agent/scripts installs in step 7); coverage only recovers because `acp.install.sh` runs the syncs. | scripts/acp-bootstrap.sh:1330,1342 |
| F-091-07 | low | `acp.validate.md` Step 11.6 says sessions entries require `tasks_completed`; the enforced `session.schema.yaml` requires only `date`, `executor`, `done` (and real entries use `tasks:`). Doc drift, echoes the ADR-9 `tasks:`/`tasks_completed:` confusion. | agent/commands/acp.validate.md:566 |
| F-091-08 | low | `sessions.md` has 17 entries; protocol threshold is >15 → compact oldest 10 into a weekly summary. Compaction overdue. | agent/memory/sessions.md |
| F-091-09 | low | Recurring task `monthly-dependency-audit` overdue since 2026-07-08 (7 days). `quarterly-deep-scan` remains blocked on M58 v2.0 per ADR-10 (expected). | agent/progress.yaml (recurring_tasks) |
| F-091-10 | low | No ShellCheck in CI for a bash-first project (47 shell scripts in agent/scripts alone). Industry-standard lint gate absent. | .github/workflows/ci.yaml |
| F-091-11 | info | 4 scripts lack `set -euo pipefail`: `acp.common.sh`, `acp.driver-yaml.sh`, `acp.integrity-output.sh`, `acp.yaml-parser.sh`. All four are sourced libraries where `set -e` propagation is genuinely dangerous — likely deliberate, but the exemption is undocumented. | agent/scripts/ |
| F-091-12 | info | `/acp-verify` does not exist; user reached for it naturally. Standards enforcement lives in `/acp-review`, consistency in `/acp-validate`. Consider a discoverability pointer (e.g., an `acp-index` note or alias). | — |
| F-091-13 | info | Working tree carries substantial uncommitted work post-release: today's Claude Code integration (sync script, 72 wrappers, e2e test, wiki, ADR-18) plus pre-existing modifications. Tagged release v6.26.0 is clean, but memory writes (ADR-18, session entry) exist only in the working tree. | git status |

| F-091-14 | high | **Discovered post-report while committing it**: `agent/.gitignore:5` (`reports/`) blocks all new files in `agent/reports/` — the nested rule overrides the root `.gitignore`'s `!agent/reports/` whitelist. Only 26 reports are tracked; **audit-078 through audit-090 — including M71's closure-audit evidence — are not in version control**. The validator's gitignore-conflict check inspects only already-tracked paths (tracked files stay tracked when ignored), so it reports OK while new protocol evidence silently never enters git. | agent/.gitignore:5 |

**Pending ops carryovers re-confirmed** (not new): CRIT-065-002 — branch protection on mainline still absent (`gh api` 404 live-confirmed during this audit); F-086-02 — FIFOZ consumer verification (task-239, deferred).

## Industry Standards & Best-Practices Alignment

| Practice | Status | Evidence |
|----------|--------|----------|
| SemVer + annotated release tags | ✅ | v6.26.0 tagged; tags match CHANGELOG |
| Keep-a-Changelog format | ✅ | `## [6.26.0] — 2026-07-15` |
| Conventional Commits | ✅ | `release(...)`, `fix(...)`, `chore(agent):` in recent log |
| GitHub Actions pinned by SHA | ✅ | checkout/setup-node/upload-artifact/trufflehog all SHA-pinned |
| Secret scanning in CI | ✅ | trufflehog v3 |
| LICENSE / SECURITY.md / CONTRIBUTING.md / .gitattributes | ✅ | All present |
| ADR practice | ✅ | 18 ADRs, schema-enforced headers |
| Test coverage discipline | ✅ | command-e2e-coverage registry 70/70; 28/28 vitest |
| Bash strict mode | ✅ (43/47) | 4 exemptions are sourced libs (F-091-11: document rationale) |
| ShellCheck lint gate | ❌ | Not in any workflow (F-091-10) |
| Branch protection on release branch | ❌ | gh api 404 (CRIT-065-002, ops) |
| Derived-artifact drift enforcement | ⚠️ | Size-only guard, 3/5 parity, package.yaml unchecked (F-091-01/02/05) |
| Toolchain robustness (cwd-independence) | ⚠️ | Validator vacuous-green from wrong cwd (F-091-03) |

## Code Pointers

| Location | Description |
|----------|-------------|
| scripts/acp-validate.ts:189 | `runParityCheck()` — `startsWith("acp-")` filter (dupes invisible); no zero-command failure; 3 surfaces only |
| scripts/acp-bootstrap.sh:1330,1342 | Dead-glob cursor/claude copy loops |
| agent/commands/acp.validate.md:558 | Step 11.6 broken documented invocation `(cd scripts && …)` |
| .git/hooks/ | No pre-commit hook — AGENTS.md → CLAUDE.md/copilot-instructions sync inactive in this repo |
| agent/schemas/session.schema.yaml | Actual required keys: date, executor, done |

## Recommendations

0. **Restore report version-control (F-091-14)**: remove/whitelist `reports/` in `agent/.gitignore`; `git add` the untracked audit-078..090 evidence; extend the validator's gitignore check to probe *addability* of new files in protocol directories, not just tracked-path status.
1. **Close the drift pair now** (5-min fixes): bump `package.yaml` to 6.26.0; re-copy AGENTS.md → copilot-instructions.md; install the pre-commit sync hook in this repo.
2. **Harden the validator** (one route): repo-root detection (walk up until `agent/` found, or fail loudly); parity hard-fail on 0 commands; extend parity to 5 surfaces incl. dot-named-file detection; add the documented-but-missing package.yaml version check; hash-compare (not size-compare) the three instruction files; fix Step 11.6 invocation text.
3. **Delete the 6 dot-named duplicate wrappers** and fix the two bootstrap dead-glob loops (use `acp-*.md` or call the sync scripts after step 7).
4. **Add ShellCheck to ci.yaml** (bash-first repo; likely surfaces real issues in 47 scripts).
5. **Routine hygiene**: run sessions.md compaction (17 > 15); run the overdue `monthly-dependency-audit`; update the lessons.md companion-file lesson and progress.yaml summary line to name all 4 wrapper surfaces; register the 4 unregistered scripts in package.yaml + integrity manifest; commit the working tree.
6. **Ops** (unchanged, admin-gated): enable branch protection on mainline; FIFOZ consumer verification when repo access is available.
