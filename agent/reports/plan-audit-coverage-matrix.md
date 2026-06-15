# Comprehensive Remediation Plan — Audit Coverage Matrix (audits 062, 065–070)

**Created**: 2026-06-15
**Purpose**: Single source of truth proving **every** pending audit finding is assigned to a milestone + route, so a downstream executor (e.g. Composer 2.5) can implement the entire backlog without re-deriving scope.
**Scope**: All `status: pending` carryovers in `agent/memory/audit-carryovers.md` as of 2026-06-15.
**Milestones**: M59–M63 (pre-existing, audits 065/066/067/062) + **M64** (audit-070) + **M65** (audits 068/069 + straggler) — all now registered in `progress.yaml`.

---

## 1. Milestone Map

| Milestone | Theme | Source audits | Routes | Version |
|-----------|-------|---------------|--------|---------|
| M59 | Critical-Fix & CI Integrity | 065/066/067 | 159–164 (+ F-062-03 promoted) | 6.14.0 |
| M60 | Test Coverage Tier 1 (core commands) | 065 (CRIT-065-003) | 165–166 | 6.15.0 |
| M61 | Production-Readiness Pack | 065/066/067 | 167–172 | 6.16.0 |
| M62 | Quality Hardening, Schemas & Carryovers | 065/066/067/062 | 173–177 | 6.17.0 |
| M63 | Test Coverage Tier 2–3 | 065 (CRIT-065-003) | 178 | 6.18.0 |
| **M64** | **Integrity Gateway v1.1 — Truth & Test** | **070** | **179–184** | **6.19.0** |
| **M65** | **Tracking Reconciliation & M57/M58 Closeout** | **068/069 + 065 straggler** | **185–189** | **6.20.0** |

**Recommended sequence**: M59 (critical) → M64 (gateway truth/test — user priority) → M65 (tracking truth) → M61 (production readiness) → M62 (quality) → M60 → M63 (test coverage). M64/M65 are prioritized high because they remove *false assurance* and *status drift* respectively.

---

## 2. Finding → Milestone → Route (every pending item)

### audit-062 — M57 recurring-tasks carryovers
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| F-062-01 hooks block (2 dropped hooks) | MED | M62 | route-176 |
| F-062-02 milestone checklist verification | MED | M62 | route-176 |
| F-062-03 automated next_due (date drift) | HIGH | **M59 (promoted)** | route-188 promotes → M59 |
| F-062-04 reference git-hook impl | MED | M62 | route-176 |
| F-062-05 findings→task feedback loop | MED | M62 | route-176 |

### audit-065 — comprehensive gap analysis
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| CRIT-065-001 capture ADR history | MED | M65 | route-189 |
| CRIT-065-002 branch protection | CRIT | M59 | route-162 |
| CRIT-065-003 E2E coverage (3 tiers) | CRIT | M60 + M63 | route-165/166 + 178 |
| HIGH-065-004 set -euo pipefail (17 scripts) | HIGH | M62 | route-173 |
| HIGH-065-005 Windows CI runner | HIGH | M61 | route-167–172 |
| HIGH-065-006 SECURITY.md | HIGH | M61 | route-167–172 |

### audit-066 — second-round deep gaps
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| HIGH-066-001 updateRoutingYml overwrite | HIGH | M59 | route-159 |
| HIGH-066-005 acp-validate.ts not in CI | HIGH | M59 | route-161 |
| HIGH-066-006 ci-validate frontmatter no-op | HIGH | M59 | route-161 |
| MED-066-002 OPENROUTER_API_KEY preflight | MED | M59 | route-163 |
| MED-066-003 no unit tests for TS tooling | MED | M61 | route-167–172 (test infra) |
| MED-066-007 memory-layer schemas | MED | M62 | route-175 |

### audit-067 — consolidated audit (new findings only)
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| HIGH-067-001 13 commands missing package.yaml | HIGH | M59 | route-160 |
| MED-067-002 AGENTS.md version stale | MED | M59 | route-164 |
| MED-067-003 e2e `\d` grep bug | MED | M62 / **M64** | route-177 / also fixed at source route-184 |
| MED-067-005 CONTRIBUTING.md | MED | M61 | route-167–172 |
| LOW-067-004 git-provenance YAML grep | LOW | M62 / **M64** | route-177 / also fixed at source route-183 |

### audit-068 — M57/M58 implementation (residual pending)
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| F-068-03 promote F-062-03 to M59 | HIGH | M65 | route-188 |
| F-068-04 fixture max_confidence/ci_blocking | MED | M65 | route-187 |
| F-068-07 wiki v2.0 surface staleness | MED | M65 | route-188 (→ route-156 owns) |
| F-068-10 quarterly-deep-scan premature | LOW | M65 | route-188 |
| F-068-12 acp.meta-scan.sh pipefail | LOW | M65 | route-188 (→ route-173) |

### audit-069 — M57/M58 post-sync re-audit
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| F-069-01 status desync (milestone docs) | HIGH | M65 | route-185 (+ route-186 guard) |
| F-069-02 route-155 completion desync | HIGH | M65 | route-185 |
| F-069-03 route-155 scope under-delivery | HIGH | M65 | route-187 |
| F-069-04 circular go/no-go gate | HIGH | M65 | route-187 |
| F-069-05 audit-062 carryovers open | HIGH | M65 | route-188 (= F-068-03) |
| F-069-07 fixture confidence policy | MED | M65 | route-187 (= F-068-04) |
| F-069-09 M54 dangling pointer | MED | M65 | route-185 (+ route-186 guard) |
| F-069-10 taint script naming | LOW | M65 | route-187 |

### audit-070 — M55–M58 gateway deep dive (the engineering integrity gateway)
| Finding | Sev | Milestone | Route |
|---------|-----|-----------|-------|
| F-070-01 entropy-scan crash on findings | HIGH | M64 | route-179 |
| F-070-02 claimed >> implemented coverage | HIGH | M64 | route-180 (impl) + route-181 (truth) |
| F-070-03 E2E never tests detection | HIGH | M64 | route-184 |
| F-070-04 unicode-scan perf (32 spawns/line) | HIGH | M64 | route-179 |
| F-070-05 no uniform output contract | MED | M64 | route-182 |
| F-070-06 --ci severity semantics | MED | M64 | route-182 |
| F-070-07 coverage tables overstate | MED | M64 | route-181 |
| F-070-08 typosquat/IG-29 missing | MED | M64 | route-180 |
| F-070-09 YAML-by-grep (fail-open) | MED | M64 | route-183 |
| F-070-10 mtime staleness | MED | M64 | route-183 |
| F-070-11 IG-37 no-op | MED | M64 | route-183 |
| F-070-12 manifest dir-enum + write | MED | M64 | route-183 |
| F-070-13 rule mis-attribution | LOW | M64 | route-182 |
| F-070-14 e2e `\d` count bug | LOW | M64 | route-184 |
| F-070-15 sha portability | LOW | M64 | route-183 |
| F-070-16 token-budget inconsistency | LOW | M64 | route-181 |

---

## 3. Coverage Assertion

Every `status: pending` finding in `audit-carryovers.md` (audits 062/065/066/067/068/069/070) is assigned above. Two findings (MED-067-003, LOW-067-004) appear in both a docs-cleanup route (M62) and their root-cause source route (M64) — the M64 route is authoritative (fixes at source); the M62 route should be marked done-by when M64 lands.

**Definition of done for the whole backlog**: all routes 159–189 completed per their double-verify gates, all listed carryovers set to `status: fixed` with `verified_in_audit`, and a closing audit confirms no regressions.

---

## 4. Quality Bar for Executors (Composer 2.5 and others)

Each route file (`agent/routing/tasks/route-NNN.md`) is self-contained and includes: Objective, Context (with audit finding + code pointers), explicit Steps, Expected Output (files), a **double-verify** Verification block (automated proof that fails-before/passes-after + manual proof), User-Observable Acceptance, and the Addresses backlink. Execute routes in the milestone's recommended order; do not mark a route complete until BOTH verification proofs pass.

*Plan coverage matrix | ACP Enhanced | audits 062/065–070 | 2026-06-15*
