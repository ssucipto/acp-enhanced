# Audit Report: Pre-Implementation Readiness — M72

**Audit**: #092
**Date**: 2026-07-15
**Subject**: M72 (Validation Truth & Drift Hardening) readiness before implementation
**Mode**: --pre-impl

## Summary

M72's plan is structurally sound — all 8 task docs and 8 route files exist, dependencies are coherent, the validator passes on the committed plan, and the fix-with-enforcement pairing (guardrail #1) is correctly encoded in the task gates. Phase 2 cross-referencing found **no blocking errors** but four amendments that should land before or at the start of implementation, the most important being: the plan itself reserves the name "audit-092" for the closure audit, but this pre-implementation audit takes that number by protocol (M70 precedent: audit-087 pre-impl → audit-088 closure) — 15 references must be renumbered to audit-093. Second-most important: **no task regenerates `agent/integrity-manifest.yaml`**, yet the manifest SHA-pins files M72 will rewrite (e.g., `.cursor/commands/acp-validate.md`), so the weekly integrity scan would raise tamper alarms after M72 ships.

Phase 3: 11 pending carryovers, all accounted for — 9 are M72's own subject, CRIT-065-002 is task-246, F-086-02 is non-blocking ops. **Verdict: READY WITH AMENDMENTS** — task-245 can start immediately.

## Pre-Implementation Readiness (M72)

**Mode**: --pre-impl

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Route/task files complete | ✅ | 8/8 tasks, 8/8 routes on disk; frontmatter scan 0 warnings |
| files_affected accurate | ✅ | All referenced paths exist or are created-by-design |
| Acceptance criteria unambiguous | ✅ | Each task has verification + user-observable acceptance |
| Open blockers | ⚠️ | Closure-audit name collision: plan says "audit-092" in 15 places (task-247, route-236, milestone doc, progress.yaml, carryover fix_targets); this pre-impl audit takes #092 → closure becomes **audit-093**. Renumber before task-247 runs (fold into task-245). |

### Phase 2 — Code Cross-Reference

| File | Checked | Result | Notes |
|------|---------|--------|-------|
| scripts/acp-validate.ts | Module style for D1 recipe | ✅ | ESM imports throughout, runs under tsx — `import.meta.url` root-anchoring viable as written |
| scripts/acp-validate.test.ts + scripts/fixtures/ | Vitest infra for guardrail #5 | ✅ | 28 tests present; fixtures dir exists (carryovers-stale.md, coverage-gap fixture) |
| package.yaml (scripts contents) | Entry shape claimed by task-240 | ⚠️ | Actual shape is `name` + `description` + `type` — **no `version` field**. task-240 text says "name + version + description"; the binding phrase "matching existing entries' shape" governs — follow the file, not the task text |
| agent/integrity-manifest.yaml | Registration mechanics | ❌→amend | Manifest is SHA-256 hash-pinned (generator: `agent/scripts/acp.manifest-hash.sh`). It **covers `.cursor/commands/acp-validate.md`** and other wrapper files M72 regenerates — but **no M72 task regenerates the manifest**. Without it, `/acp-integrity --diff` and the weekly-integrity-scan recurring task will flag tampering post-M72. Add manifest regen to task-247 gates (and after task-242/243 wrapper regens) |
| agent/.gitignore | F-091-14 fix scope | ⚠️ | Blast radius larger than audit-091 recorded: `reports/` **88 on disk / 27 tracked** (61 untracked); `feedback/` **28 on disk / 3 tracked** — untracked includes feedback-007, which carryover F-086-02 cites as evidence. `clarifications/` ignore is **intentional** (acp.plan.md Step 10: clarifications are never committed) — do NOT blanket-delete the file; whitelist `reports/` + decide `feedback/` policy (recommend: track) |
| scripts/acp-bootstrap.sh | Hook block source for task-240 | ✅ | `ACP_HOOK_MARKER` block at lines 1400-1412 — copy source confirmed |
| agent/scripts/acp.branch-protection-setup.sh | task-246 tooling | ✅ | Exists; `gh` authenticated (account rygandev01) — admin rights on ssucipto/acp-enhanced unverified until first call |
| shellcheck | task-244 prerequisite | ⚠️ | **Not installed locally** — add install step (`brew install shellcheck`) to task-244; error-severity finding count unknowable until then |
| agent/skills/scripts.md, agent/index/local.main.yaml | task-243 targets | ✅ | Both exist |
| agent/scripts/acp.post-milestone-sweep.sh, CHANGELOG.md | task-247 targets | ✅ | Sweep script exists; CHANGELOG in Keep-a-Changelog form |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks? |
|-----------|----------|--------|---------|
| F-091-01..07, 10, 14 (9 entries) | high→low | pending | No — they ARE the M72 work; each mapped to a task |
| CRIT-065-002 branch protection | critical | pending | No — task-246 owns it; needs admin auth at execution time |
| F-086-02 FIFOZ consumer | medium | pending | No — task-239 (M71) ops, explicitly out of M72 scope |

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ✅ | route-229..236 |
| Version bump planned | ✅ | task-247: v6.27.0 chain (identity, headers, package.yaml, CHANGELOG, tag) |
| Wiki update planned | ✅/N/A | No new protocol concept requiring architecture wiki; task-243 covers skills/lessons/index |
| Integrity-manifest regeneration | ❌ | Missing from plan — see Phase 2; F-092-01 |
| Milestone/progress status consistency | ✅ | planned/planned; validator green post-plan-commit |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 1 | medium (renumber) |
| Phase 2 — Code Cross-Reference | 4 | medium (manifest regen) |
| Phase 3 — Carryover Check | 0 | none |
| Phase 4 — Operational Completeness | 1 | medium (dup of Phase 2 manifest) |
| **Total** | **5 distinct** | **medium** |

### Readiness Verdict

**READY** (with amendments) — no blocker prevents task-245 from starting now. Before task-247 executes: renumber closure audit 092→093 (15 refs), add manifest regeneration to closure gates, add shellcheck install to task-244, and apply the corrected F-091-14 scope (whitelist `reports/`, decide `feedback/`, preserve intentional `clarifications/` ignore) in task-240.

## Key Findings (new, this audit)

| # | Sev | Finding |
|---|-----|---------|
| F-092-01 | medium | No M72 task regenerates `agent/integrity-manifest.yaml` despite M72 rewriting manifest-covered files — post-ship tamper false-alarms guaranteed |
| F-092-02 | medium | Closure-audit name "audit-092" collides with this report — 15 plan references need renumbering to audit-093 |
| F-092-03 | medium | F-091-14 scope extension: 61 untracked reports (not ~13), plus `feedback/` 25 untracked incl. carryover-cited evidence; `clarifications/` ignore is intentional and must survive the fix |
| F-092-04 | low | task-244 missing shellcheck install prerequisite; task-240 text misnames package.yaml entry fields (`version` → `type`) |

## Recommendations

1. Fold F-092-02/03/04 text fixes into task-245 (first task, hygiene) — ~15 minutes total.
2. Add to task-247 verification gates: `bash agent/scripts/acp.manifest-hash.sh` regeneration + clean `/acp-integrity --diff` (F-092-01).
3. Proceed: `/acp-proceed` → task-245.
