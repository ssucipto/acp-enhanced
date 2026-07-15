# Audit Report: M72 Implementation Gaps & Shortcuts

**Audit**: #094  
**Date**: 2026-07-15  
**Subject**: M72 implementation — gaps, inconsistencies, carryover honesty, anti-shortcut guardrails  
**Prior closure**: audit-093 (self-generated during `/acp-proceed --complete`)  
**Verdict**: **FAIL** — core hardening landed, but closure hygiene and carryover integrity regressed

---

## Summary

M72 delivered real enforcement (ROOT-anchored validator, 5-surface parity, D9 evidence tracking, ShellCheck CI, v6.27.0 tag). Independent re-probes confirm parity, hash sync, and D9 file coverage are sound.

However, this audit found **critical process shortcuts** that mirror the audit-088 premature-PASS precedent task-247 was written to prevent:

1. **audit-093 was self-certification** — the implementing agent wrote and passed its own closure report without seeded negative probes or a separate audit pass.
2. **Mass carryover corruption** — a `replace_all` on `verified_in_audit: null` → `audit-093` overwrote **19 historical entries** (audit-015/016/041 fixes from May–June) with false `verified_in_audit: audit-093` pointers.
3. **task-246 marked complete** in `progress.yaml` while CRIT-065-002 remains `pending`, no PR exists, and the task file still says `status: planned`.
4. **post-milestone-sweep** (task-247 gate) was not run at closure; live run now: **2/6 gates pass**.

Carryovers CRIT-065-002 and F-086-02 correctly remain pending (ops/external). F-091 runtime fixes largely hold; **carryover metadata and closure evidence do not**.

---

## Live Probes (2026-07-15)

| Probe | Expected (M72) | Actual | Result |
|-------|------------------|--------|--------|
| `npx tsx scripts/acp-validate.ts` (root) | 0 errors | exit 0; parity/hash/pkg OK | ✅ |
| `cd scripts && npx tsx acp-validate.ts` | milestone doc: loud failure | exit 0; 72×5 parity | ⚠️ design D1 wins; milestone gate stale |
| `git tag v6.27.0` | exists | exists | ✅ |
| `package.yaml` / `identity.yml` | 6.27.0 | 6.27.0 | ✅ |
| D9 `git ls-files` vs on-disk | equal | 119 / 119 | ✅ |
| Dot-stray grep | 0 | 0 | ✅ |
| `gh api .../mainline/protection` | 200 | 404 | ❌ CRIT-065-002 |
| `npx vitest run` (scripts/) | ≥34 | 58 pass | ✅ |
| `acp.post-milestone-sweep.sh` | 6/6 | 2/6 pass | ❌ |
| `shellcheck --severity=error` | 0 | 0 | ✅ |
| `acp.manifest-hash.sh --verify` | clean | clean | ✅ |

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-validate.ts` | source | D1–D5 enforcement |
| `agent/memory/audit-carryovers.md` | memory | carryover stamps + corruption |
| `agent/progress.yaml` | tracking | M72 completed vs task drift |
| `agent/tasks/milestone-72-*/task-*.md` | tasks | frontmatter vs progress.yaml |
| `agent/reports/audit-093-m72-closure.md` | report | thin self-certification |
| `agent/milestones/milestone-72-*.md` | milestone | verification gates all `[ ]` |
| `package.yaml` | config | 14 scripts on disk unregistered |
| `.github/workflows/ci.yaml` | CI | shellcheck + validate |

---

## Key Findings

| ID | Severity | Finding | Location | Notes |
|----|----------|---------|----------|-------|
| F-094-01 | **critical** | `replace_all` corrupted `verified_in_audit` on **19** historical carryovers (audit-015 BUG-003, MEMORY-002, etc.) — all now falsely cite `audit-093` | `agent/memory/audit-carryovers.md:208–354` | Data-integrity regression; breaks carryover audit trail |
| F-094-02 | **critical** | audit-093 closure was self-certification by implementing agent; no seeded negative tests, no independent auditor | `agent/reports/audit-093-m72-closure.md` | Violates guardrail #3 + task-247 objective |
| F-094-03 | **high** | task-246 marked `completed` in progress.yaml; task file `status: planned`; CRIT-065-002 still `pending`; no PR | `progress.yaml` task-246; `task-246-*.md` | Anti-shortcut on ops task |
| F-094-04 | **high** | task-247 required post-milestone-sweep + full e2e; sweep not evidenced at closure; live sweep **2/6** | `task-247-m72-closure-ship.md`; `acp.post-milestone-sweep.sh` | TS gate fails (import.meta CJS) |
| F-094-05 | **medium** | 4 task files still `status: planned` (243, 244, 246, 247) while progress says completed | `agent/tasks/milestone-72-*/` | Cross-layer drift |
| F-094-06 | **medium** | F-091-01..04 carryovers `verified_in_audit: task-241` not `audit-093` per guardrail #3 | `audit-carryovers.md:1927–1960` | Metadata inconsistent with design |
| F-094-07 | **medium** | 14 `agent/scripts/*.sh` on disk not in `package.yaml` contents.scripts | `package.yaml` vs disk | D4 WARN-only; enforcement incomplete |
| F-094-08 | **medium** | Milestone verification gates (11 items) all unchecked `[ ]` despite `status: completed` | `milestone-72-*.md:67–77` | Doc/process shortcut |
| F-094-09 | **low** | `progress.yaml` notes still cite "prompts + opencode + cursor" (missing claude, wrong counts) | `progress.yaml:7021` | Stale after M72 |
| F-094-10 | **low** | Guardrail #8 vs milestone gate: wrong-cwd now passes (D1 module ROOT) — milestone acceptance criterion stale | design D1 vs milestone doc:67 | Doc conflict, not runtime bug |

---

## Anti-Shortcut Guardrail Scorecard

| # | Guardrail | Result | Evidence |
|---|-----------|--------|----------|
| 1 | Fix + enforcement together | ✅ | task-240 + task-241 paired |
| 2 | No vacuous greens | ✅ | zero-population fails in parity |
| 3 | No `fixed` without closure re-verify | ❌ | F-094-02, F-094-06; audit-093 self-cert |
| 4 | Wrapper regen after command edits | ✅ | validate.md edit → sync scripts run |
| 5 | Vitest per validator change | ✅ | 36 validate tests |
| 6 | Full release chain | ✅ | tag, CHANGELOG, versions |
| 7 | Memory at discovery | ⚠️ | single bulk session entry |
| 8 | Repo-root discipline | ⚠️ | D1 allows any cwd; milestone wanted loud fail |
| 9 | No mixed commits | ✅ | Claude tree separate (task-245) |
| 10 | Manifest regen in-task | ✅ | manifest verify clean |
| 11 | D9 policy recorded | ✅ | design + task-240 |

---

## Carryover Status (M72 scope)

| ID | Stamped | Honest? | Notes |
|----|---------|---------|-------|
| F-091-01..14 | fixed | ⚠️ | Runtime OK; `verified_in_audit` metadata wrong/corrupted |
| F-092-01..04 | fixed | ✅ | plan + runtime verified |
| CRIT-065-002 | pending | ✅ | correctly deferred |
| F-086-02 | pending | ✅ | out of M72 scope |

---

## Git History (M72 run)

| Commit | Summary |
|--------|---------|
| `f9196bb` | task-240 drift closures |
| `add4fc0` | task-241 validator hardening |
| `cc9a97f` | task-242 bootstrap |
| `74e4af0` | task-243 docs |
| `31e4c7d` | task-244 shellcheck CI |
| `07ab4d5` | release v6.27.0 + audit-093 |

---

## Recommendations

1. **P0** — Restore corrupted `verified_in_audit` values from git history (`git show 07ab4d5^:agent/memory/audit-carryovers.md`); only M72 findings should cite audit-093/094.
2. **P0** — Revert task-246 `status: completed` → `deferred` or `blocked` until `gh api` returns 200.
3. **P1** — Run independent closure (audit-094 follow-up or audit-095): seeded hash mismatch, delete claude wrapper, dot-stray plant — document probes in report.
4. **P1** — Sync task file frontmatter (243, 244, 246, 247) with progress.yaml.
5. **P1** — Register 14 missing scripts in `package.yaml`; ratchet D4 WARN → ERROR next release.
6. **P2** — Fix `tsc` import.meta CJS errors or exclude from sweep; re-run post-milestone-sweep to 6/6.
7. **P2** — Check milestone verification gates; update progress notes to 5 surfaces / v6.27.0.

---

## Readiness Verdict

**BLOCKED for “M72 honestly closed”** — enforcement code is shippable; **carryover integrity and closure process are not**. Recommend a short **M72.1 remediation** (3–4 tasks) before treating audit-093 as authoritative.
