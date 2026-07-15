# Audit Report: M67 Cross-Agent Handoff Protocol — Pre-Implementation Readiness

**Audit**: #078  
**Date**: 2026-07-15  
**Subject**: M67 Cross-Agent Handoff Protocol v1 (`--pre-impl`)  
**Mode**: `--pre-impl`  
**Prior audits**: audit-077 (upstream readiness), FIFOZ audit-245 (field evidence)  
**Planning commit**: `621ea59` (plan M67)

---

## Summary

M67 is **well-planned** — design doc, 8 routes (190–197), 8 tasks (195–202), proposal, carryovers H1–U3 filed, and build order are coherent. The codebase is at the expected **pre-implementation baseline**: `acp.handoff.md` v1.0.0 forbids executor content, `acp.receive.md` does not exist, `active_handoff` is absent from schema/validate, and E2E fixtures are uncreated.

**Verdict: READY** to start **route-190** with four documented pre-conditions (below). No hard blockers prevent coding; two medium gaps must be folded into route-196/192 during implementation to avoid shipping broken wiki parity.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-67-cross-agent-handoff-protocol.md` | milestone | Scope, routes, verification gates |
| `agent/design/cross-agent-handoff-protocol.md` | design | Mode split, anti-shortcuts, ecosystem requirements |
| `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` | proposal | §4 template, §8 schema, §13 acceptance |
| `agent/routing/tasks/route-190.md` … `route-197.md` | routes | Implementation units |
| `agent/tasks/milestone-67-cross-agent-handoff-protocol/task-195` … `task-202` | tasks | Detailed steps |
| `agent/commands/acp.handoff.md` | command | v1.0.0 — conflicts at L125, L136 |
| `agent/commands/acp.resume.md` | command | No handoff arg (U1) |
| `agent/schemas/progress.schema.yaml` | schema | Optional-field pattern for `active_handoff` |
| `scripts/acp-validate.ts` | tooling | Schema enforcement L653–762; no handoff rules |
| `agent/core/routing.yml` | config | Premature `acp-receive` block L231–234 |
| `agent/wiki/domain.yml` | wiki | **Corrupt handoff entry L33–37**; count stale |
| `package.yaml` | package | `acp.handoff.md` L358; no receive |
| `agent/index/acp.core.yaml` | index | handoff only L140–149 |
| `agent/wiki/cross-agent-handoff.md` | wiki | DRAFT pilot page |
| `agent/memory/audit-carryovers.md` | memory | 13 audit-077 entries pending |
| `e2e/acp.commit.test.sh` | e2e | Template for structural command E2E |

---

## Key Findings (Pre-Impl)

| ID | Sev | Finding | Location | M67 route |
|----|-----|---------|----------|-----------|
| P-078-01 | **MED** | `domain.yml` **corrupt** — `acp.feedback` entry contains duplicate `category`/`purpose`; `acp.handoff` purpose merged without `- command: acp.handoff` | `domain.yml:33-37` | route-196 |
| P-078-02 | **MED** | Proposal §10 references `.cursor/skills/acp-resume/SKILL.md` — **does not exist** in acp-enhanced; only `acp.resume.md` + wrappers | `proposal §10` | route-192 |
| P-078-03 | **MED** | `routing.yml` lists `acp-receive` suggestions **before command ships** (SC-01) | `routing.yml:231-234` | route-196 audit |
| P-078-04 | LOW | Command count plan says "70×3" but baseline is **69** acp commands; wrappers **68** cursor / **69** prompts / **74** opencode — pre-existing parity drift | counts | route-196 |
| P-078-05 | LOW | `route-190` and `route-195` both list `e2e/acp.handoff.test.sh` — split structural vs behavioral ownership unclear | routes 190, 195 | clarify at impl |
| P-078-06 | LOW | `route-193` omits `agent/progress.yaml` from `files_affected` though handoff writes `active_handoff` | route-193 | add at impl |
| P-078-07 | INFO | `active_handoff.status` enum `active\|superseded\|completed` — schema has no enum helper; follow `recurring_tasks` object pattern | `progress.schema.yaml:279+` | route-193 |
| P-078-08 | INFO | HIGH-066-005 (`acp-validate` not in CI) — new validate rules won't gate CI until separate fix | carryovers | note only |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/commands/acp.handoff.md:125` | "Do NOT include specific implementation steps" — must be mode-gated in v2 |
| `agent/commands/acp.handoff.md:136` | Disk path `handoff-{target-name}-{date}` — executor mode needs `{to}-{scope}-{date}` |
| `agent/commands/acp.resume.md:24-28` | Resume = init + session + proceed; no handoff Step 0 |
| `agent/core/routing.yml:226-234` | Handoff + receive chains (receive premature) |
| `agent/schemas/progress.schema.yaml:242-258` | Optional top-level array fields pattern (`next_steps`, `notes`) |
| `agent/wiki/domain.yml:33-37` | Corrupt YAML entries block — fix when adding `acp.receive` |
| `scripts/acp-validate.ts:657-661` | `progress.schema.yaml` → `agent/progress.yaml` mapping exists |
| `agent/core/identity.yml:36` | Current version `6.21.1` → bump in route-197 |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-15 | `621ea59` | plan(M67): comprehensive cross-agent handoff protocol |
| 2026-06-15 | `f58bfbb` | fix(validate): restore progress.yaml parse (v6.21.1) |

---

## Pre-Implementation Readiness (M67)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Route/task files complete | ✅ | 8 routes + 8 tasks; acceptance criteria present |
| `files_affected` accurate | ⚠️ | Most accurate; route-193 missing `progress.yaml`; route-195 fixtures not yet created (expected) |
| Open blockers | ✅ None | route-194 P2 deferral documented in route-197 |

### Phase 2 — Code Cross-Reference

| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| `acp.handoff.md` | v1 forbids impl steps | ✅ confirmed | H1 — route-190 rewrites |
| `acp.receive.md` | exists | ✅ absent | route-191 creates |
| `progress.schema.yaml` | `active_handoff` block | ✅ absent | Add optional object per proposal §8 |
| proposal §8 | `path, date, to/from_executor, git_commit, status` | ✅ | Match schema design to these exact keys |
| proposal §4 frontmatter | `handoff_mode, git_commit, status: active` | ✅ | Template aligns with handoff v2 |
| `routing.yml` | `acp-receive` block | ⚠️ | Exists before command — SC-01 |
| `package.yaml` | `acp.receive` entry | ✅ absent | route-196 adds |
| `domain.yml` | `acp.receive` + handoff entry | ❌ | Corrupt L33-37; P-078-01 |
| `acp-validate.ts` | handoff validation | ✅ absent | route-193 adds |
| `e2e/acp.handoff.test.sh` | exists | ✅ absent | routes 190/195 create |
| `identity.yml` | version 6.23.0 | ✅ | Currently 6.21.1; route-197 |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks M67 start? |
|-----------|----------|--------|-------------------|
| audit-077 H1–H10, U1–U3 | high–low | pending | **No** — these are M67 deliverables |
| HIGH-067-001 (package.yaml gaps) | high | pending | **No** — route-196 adds receive; broader gap remains |
| HIGH-066-005 (validate not in CI) | high | pending | **No** — local validate sufficient for M67 |
| CRIT-065-002 (branch protection) | critical | pending | **No** — human ops, not code |
| P-078-01 (domain.yml corrupt) | medium | new | **No** — fix in route-196 before ship |

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ✅ | route-190..197 |
| Version bump planned | ✅ | route-197 → v6.23.0 |
| Wiki update planned | ✅ | route-193 finalizes DRAFT wiki |
| CHANGELOG planned | ✅ | route-197 |
| E2E planned | ✅ | route-195 behavioral + route-190 structural |
| Design doc | ✅ | `cross-agent-handoff-protocol.md` |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 1 | medium |
| Phase 2 — Code Cross-Reference | 3 | medium |
| Phase 3 — Carryover Check | 0 blocking | — |
| Phase 4 — Operational Completeness | 0 | none |
| **Total** | **4 actionable** | **medium** |

### Readiness Verdict

**READY** — Start **route-190** (`acp.handoff.md` v2). Apply these pre-conditions during implementation:

1. **route-196** must fix `domain.yml:33-37` corruption when adding `acp.receive` (not add-on-top).
2. **route-192** must target `acp.resume.md` only — ignore proposal's `.cursor/skills/` path (FIFOZ-specific).
3. **route-190** owns structural E2E; **route-195** owns behavioral/drift fixtures — no duplicate work.
4. Run `acp.sync-cursor-commands.sh` in route-196; expect **70×3** after receive (not 69).

---

## Recommendations

1. **`/acp-proceed route-190`** — first implementation unit (no dependencies).
2. Add acceptance criterion to **route-196**: "Repair `domain.yml` acp.feedback/acp.handoff entries at L33-37".
3. Add `agent/progress.yaml` to **route-193** `files_affected`.
4. After route-191, run structural E2E before parallel routes 192/193/195/196.
5. Defer route-194 if timeboxed — document in route-197 CHANGELOG (P2 deferred).

---

## Related

| Artifact | Path |
|----------|------|
| M67 milestone | `agent/milestones/milestone-67-cross-agent-handoff-protocol.md` |
| Design | `agent/design/cross-agent-handoff-protocol.md` |
| Prior audit | `agent/reports/audit-077-cross-agent-handoff-feedback-007.md` |
| Proposal | `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` |

---

*Audit-078 | M67 pre-impl | READY | 4 medium pre-conditions*
