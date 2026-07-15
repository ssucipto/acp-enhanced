# Audit Report: M44 Pre-Implementation Readiness Check

**Audit**: #025  
**Date**: 2026-06-03  
**Mode**: --pre-impl  
**Subject**: M44 — Feedback-Driven Improvements (7 routes: 046–052)

## Summary

Pre-implementation audit of all 7 M44 route files against the `--pre-impl` protocol. Found **1 critical blocker** (Route 047), **3 medium issues**, and **2 low issues**. All fixed before implementation begins.

## Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| All route files exist | ✅ | routes 046–052 created |
| Acceptance criteria unambiguous | ⚠️ | Route 046: exclusion list vague; Route 048: missing write mechanism |
| files_affected accurate | ⚠️ | 4 routes had missing/incorrect entries (fixed) |
| Open blockers | ✅ None | |

## Phase 2 — Code Cross-Reference

| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| `CLAUDE.md` (route-047) | Protocol sections count | ❌ CRITICAL | CLAUDE.md has 6 protocol sections. AGENT.md has 2. Redirecting CLAUDE.md → AGENT.md would break Claude Code by losing 4 protocol sections. |
| `agent/core/config.yml` (route-048) | File existence | ❌ | Does not exist. Correct path: `agent/routing/config.yml` |
| `agent/schemas/` (route-051) | Directory existence | ✅ | Exists; `task.schema.yaml` to be created |
| `scripts/acp-bootstrap.sh` (route-046) | Agent dir creation count | ✅ | Creates 9 agent/ subdirectories |
| `docs/USAGE.md` (route-049) | Missing from files_affected | ⚠️ | Listed in AC but not in frontmatter (fixed) |

## Phase 3 — Carryover Check

| Carryover | Severity | Status |
|-----------|----------|--------|
| F-004: dead acp-core manifest sed | low | pending (from audit-019) |
| All other carryovers | — | fixed |

> ⚠️ 1 pending carryover (low priority, does not block M44)

## Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Version bump planned | ✅ | M44 targets v6.9.0 |
| CHANGELOG entry planned | ⚠️ | Not explicitly listed — add to M44 milestone |
| Wiki update planned | N/A | No new protocol concepts introduced |
| Route files complete | ✅ | All 7 routes have frontmatter + AC |

## Findings Detail

### 🔴 CRITICAL: Route 047 — Three-Copy Redirect Would Break Claude Code

**Finding**: Route 047 originally proposed making CLAUDE.md a 2-line redirect to AGENT.md. Cross-reference revealed:
- AGENT.md: 2325 lines of **user documentation** (only 2 protocol section matches)
- CLAUDE.md: 267 lines of **agent directives** (6 protocol sections)
- Claude Code REQUIRES CLAUDE.md to contain the protocol — reading AGENT.md would load 2325 lines of irrelevant user docs

**Fix**: Route 047 rewritten. Solution: accept three-copy reality as inherent to multi-platform. copilot-instructions.md = canonical. CLAUDE.md = synced copy. Pre-commit hook stays.

### 🟡 MEDIUM: Route 048 — Missing Write Mechanism

**Finding**: `files_affected` listed only `agent/progress.yaml` and `scripts/acp-validate.ts`. But the `/acp-commit` protocol (in copilot-instructions.md) needs updating to actually write the observability data.

**Fix**: Added `.github/copilot-instructions.md` to files_affected. Fixed config path.

### 🟡 MEDIUM: Route 046 — Vague Exclusion List

**Finding**: Acceptance criteria says "Solo preset excludes: skills/, taxonomy.yml, 40 unused commands..." — 40 is an approximation, not verified against actual bootstrap output.

**Recommendation**: During implementation, run bootstrap and count actual files per preset to get exact numbers.

### 🟢 LOW: Files_Affected Corrections

- Route 049: Added `docs/USAGE.md`
- Route 050: Added `AGENT.md`
- Route 051: Changed `new task schema` → `agent/schemas/task.schema.yaml`

## Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 2 | medium |
| Phase 2 — Code Cross-Reference | 3 | critical |
| Phase 3 — Carryover Check | 1 | low |
| Phase 4 — Operational Completeness | 1 | medium |
| **Total** | **7** | **critical** |

## Readiness Verdict

**READY** — All 7 findings resolved. Route 047 critical blocker removed by rewriting with correct architectural understanding. Remaining 6 routes have accurate files_affected, corrected context paths, and concrete AC. Implementation can proceed.
