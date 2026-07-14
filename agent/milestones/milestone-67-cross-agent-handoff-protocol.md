# Milestone 67 — Cross-Agent Handoff Protocol v1

**Milestone ID**: M67  
**Status**: planned  
**Target version**: v6.23.0  
**Priority**: 4  
**Estimated effort**: ~25–30h (8 routes, 8 tasks)  
**Design**: `agent/design/cross-agent-handoff-protocol.md`  
**Source**: FIFOZ feedback-007, audit-077, audit-245, proposal v1.0.0

---

## Problem statement

Multi-executor same-repo workflows (Claude/Fable → Cursor) are **operationally proven** in FIFOZ (9 handoffs, M51 gold standard) but **structurally unsupported** by ACP Enhanced. The v1 `/acp-handoff` command forbids implementation steps and has no receiving protocol — forcing tribal knowledge and repeatable shortcuts (commit skip, git drift, ad-hoc filenames).

---

## Scope

### In scope

| Finding cluster | Routes | Resolves |
|-----------------|--------|----------|
| H1, H3, H5, H7, S1–S2, S5–S6 | 190, 193 | Dual-mode handoff + enforced outgoing ritual |
| H2, H4, S3 | 191, 195 | `/acp-receive` + behavioral E2E |
| U1 | 192 | Resume handoff path |
| H9, H8, U3 | 193 | `active_handoff` + wiki |
| H10, H6, S4 | 194 | Lifecycle + return template |
| Ecosystem gaps | 196 | package.yaml, domain.yml, index |
| Release | 197 | CHANGELOG, carryover closure, feedback-007 |

### Out of scope (defer)

- Cross-repo transport automation
- Handoff diff/merge
- M63 test coverage (parallel track — do not block M67 P0)

---

## Routes and tasks

| Route | Task | Title | P | Est | Depends |
|-------|------|-------|---|-----|---------|
| route-190 | task-195 | Handoff v2 dual mode + executor template | P0 | 5h | — |
| route-191 | task-196 | New `/acp-receive` + wrappers | P0 | 4h | 190 |
| route-192 | task-197 | Resume handoff integration | P1 | 2h | 191 |
| route-193 | task-198 | `active_handoff` schema + wiki + validate | P1 | 4h | 191 |
| route-194 | task-199 | Lifecycle P2 (LATEST, superseded, ancestry) | P2 | 2h | 193 |
| route-195 | task-200 | E2E fixtures (M51 anonymized) + behavioral tests | P0 | 4h | 191 |
| route-196 | task-201 | Ecosystem parity (package, domain, index, README) | P1 | 3h | 191 |
| route-197 | task-202 | Release gate v6.23.0 + carryover closure | P0 | 2h | 190–196 |

**Build order**: 190 → 191 → (192, 193, 195, 196 parallel) → 194 → 197

---

## Shortcuts taken in audit-077 intake (remediate in M67)

| # | Shortcut | Remediation |
|---|----------|-------------|
| SC-01 | `routing.yml` references `acp-receive` before command exists | route-196 verifies routing ↔ shipped commands only |
| SC-02 | Wiki published as if shipped | Wiki header `DRAFT until v6.23.0`; route-193 finalizes |
| SC-03 | No carryovers filed for H1–H10 | route-197 closes audit-077 carryovers |
| SC-04 | Routes without task docs / E2E plan | task-195..202 + route-195 fixtures |
| SC-05 | No design doc | `agent/design/cross-agent-handoff-protocol.md` |
| SC-06 | Version target drift (audit said v6.22) | Unified **v6.23.0** (M66 consumed v6.22) |
| SC-07 | No `agent/proposals/` intake process documented | route-196 adds feedback intake note to CONTRIBUTING |

---

## Linked carryovers (existing — do not regress)

| ID | Severity | M67 touchpoint |
|----|----------|----------------|
| HIGH-067-001 | high | route-196 adds `acp.receive` to package.yaml |
| HIGH-066-005 | high | route-198 validate rules must be CI-runnable when CI fixed |
| MED-066-007 | medium | route-198 extends progress.schema.yaml properly |
| CRIT-065-002 | critical | Human: branch protection (not M67 — note in release) |

---

## Verification gates (milestone exit)

### Functional (proposal §13)

- [ ] `/acp-handoff --mode executor --to cursor` — all §4 sections, git pin required
- [ ] `/acp-handoff --mode cross-repo` — v1.0.0 parity
- [ ] `/acp-receive` — git drift + session gap warnings
- [ ] `/acp-resume @handoff.md` — receive then resume
- [ ] `active_handoff` written and validates

### Quality (no shortcuts)

- [ ] `e2e/acp.handoff.test.sh` — section presence + mode branch
- [ ] `e2e/acp.receive.test.sh` — **behavioral** drift fixture (not grep-only)
- [ ] `agent/benchmarks/fixtures/handoff/` — M51-anonymized exemplar
- [ ] 70×3 command parity (new receive = 70th command)
- [ ] `npx tsx scripts/acp-validate.ts` — 0 errors
- [ ] `bash agent/scripts/acp.sync-cursor-commands.sh --check`

### Release

- [ ] CHANGELOG v6.23.0
- [ ] audit-077 carryovers H1–H10, U1–U3 → `status: fixed`
- [ ] feedback-007 §6 acceptance criteria checked

---

## FIFOZ downstream

After v6.23.0 ships: FIFOZ runs `/acp-version-update`, retires local wiki workaround, closes feedback-007.

---

**Status**: planned — `/acp-proceed M67` or `route-190`
