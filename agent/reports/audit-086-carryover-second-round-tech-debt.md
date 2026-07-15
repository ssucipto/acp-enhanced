# Audit Report: Carryover Second-Round Tech Debt & Shortcuts

**Audit**: #086  
**Date**: 2026-07-15  
**Subject**: Second-round verification of all open carryovers, v6.25.2 shortcuts, and planning readiness  
**Verdict**: **PARTIAL** — 21 stale carryovers closed; 4 structural debts remain for M70 planning

---

## Summary

Second-round audit re-verified 27 carryover entries and v6.25.2 shortcuts against live code on `develop` @ v6.25.2. **21 findings were stale** (fixed in M59–M64 or v6.25.2 but never stamped). **4 remain genuinely open** (branch protection, memory schemas, FIFOZ consumer ops, commit-sync atomicity enforcement). **3 new findings** logged for M70 planning.

Remediation applied in-session: carryover hygiene, `acp.recurring-complete.sh`, manifest `--generate` default write, `ci-validate.sh` Steps/Verification hard-fail, `code-integrity.md` coverage truth pass, `git-provenance.sh` IG-35 descope.

---

## Carryover Re-Verification Matrix

| finding_id | Prior status | Re-verify | Action |
|------------|--------------|-----------|--------|
| HIGH-065-004 | pending | **FIXED** | All scripts `set -euo pipefail` (route-173) |
| HIGH-066-001 | pending | **FIXED** | Surgical `routing.yml` session update (`acp-dispatch.ts:191-206`) |
| HIGH-066-005 | pending | **FIXED** | `acp-validate.ts` in CI (`ci.yaml:37-38`) |
| HIGH-066-006 | pending | **FIXED** | Command-doc structure checks; Steps/Verification now FAIL |
| MED-066-002 | pending | **FIXED** | OPENROUTER preflight (`acp-dispatch.ts:226-231`) |
| MED-066-007 | pending | **OPEN** | Memory-layer schemas still missing |
| MED-067-002 | pending | **FIXED** | Version header @ v6.25.2 + validate guard |
| LOW-067-004 | pending | **FIXED** | `yaml_get_array` in git-provenance (INT-002) |
| F-068-03 | pending | **FIXED** | `acp.recurring-complete.sh` advances `next_due` |
| F-070-02 | pending | **FIXED** | Gateway multi-script: `pattern-scan` covers IG-07–13, IG-21–26 |
| F-070-06 | pending | **FIXED** | `--ci` severity filter in `acp.integrity-output.sh` |
| F-070-07 | pending | **FIXED** | Skill coverage note + gateway table corrected |
| F-070-08 | pending | **FIXED** | Levenshtein typosquat + IG-29 shadow deps implemented |
| F-070-09 | pending | **FIXED** | `yaml_get_array` scoped whitelist (INT-002) |
| F-070-10 | pending | **FIXED** | IG-31 uses `git log` not mtime |
| F-070-11 | pending | **FIXED** | IG-37 explicit skip warning |
| F-070-12 | pending | **FIXED** | `--generate` defaults to `integrity-manifest.yaml` |
| F-070-13 | pending | **FIXED** | Per-codepoint rule IDs in unicode-scan |
| F-070-14 | pending | **FIXED** | ERE `IG-[0-9]+` in integrity E2E |
| F-070-15 | pending | **FIXED** | `sha256sum` fallback in `acp.common.sh` |
| F-070-16 | pending | **FIXED** | Token budget note reconciled |
| F-073-04 | pending | **FIXED** | progress.yaml parses; duplicate keys cleaned |
| CRIT-065-002 | pending | **OPEN** | GitHub branch protection — manual enable |
| GAP-041-04/07/08 | in-progress | **OPEN** | Schema lint E2E, atomicity enforcement |

---

## v6.25.2 Shortcuts Assessed

| Shortcut | Severity | Status | Notes |
|----------|----------|--------|-------|
| `acp.review-scan.sh` — 4/64 rules only | medium | **By design** | Phase 1 subset; doc states agent reasoning required |
| `integrity-manifest` `--output` footgun | low | **FIXED** | Default write to manifest file |
| Integrity single-script coverage claim | high | **FIXED** | Relabeled; pattern-scan owns exfil/persistence |
| Direct merge to `mainline` | critical | **OPEN** | CRIT-065-002 — no PR gate |
| FIFOZ `/acp-version-update` consumer | medium | **OPEN** | feedback-007 §6 — downstream ops |

---

## New Findings (audit-086)

| ID | Severity | Finding | Fix target |
|----|----------|---------|------------|
| F-086-01 | low | IG-35 claimed in `git-provenance.sh` header but never implemented | Descoped header (done); implement or remove from wiki |
| F-086-02 | medium | FIFOZ consumer path for handoff protocol untested | Consumer project runs `/acp-version-update` |
| F-086-03 | medium | `/acp-review` cannot serve as standalone CI gate (4/64 automated) | M70: expand scanner or document gate policy |
| F-086-04 | low | Carryover registry drift — 21 entries stale 30+ days | M70: add carryover re-verify to `/acp-validate` |

---

## Files Analyzed

| File | Relevance |
|------|-----------|
| `agent/memory/audit-carryovers.md` | 27 entries re-verified |
| `scripts/acp-dispatch.ts` | HIGH-066-001, MED-066-002 |
| `.github/workflows/ci.yaml` | HIGH-066-005 |
| `scripts/ci-validate.sh` | HIGH-066-006 |
| `agent/scripts/acp.*.sh` | Integrity gateway scripts |
| `agent/scripts/acp.review-scan.sh` | Review Phase 1 scope |
| `agent/skills/code-integrity.md` | F-070-07 coverage truth |
| `agent/progress.yaml` | F-068-03, F-073-04 |

---

## Recommendations (M70 Planning)

1. **P0 — CRIT-065-002**: Enable GitHub branch protection on `mainline` (required CI + no force-push).
2. **P1 — MED-066-007**: Add `session.schema.yaml`, `carryovers.schema.yaml`; wire validate.
3. **P1 — F-086-03**: Publish explicit review gate policy (Phase 1 scanner + agent pass required).
4. **P2 — GAP-041-07**: E2E for commit auto-sync, repair tools, `--memory` validation.
5. **P2 — F-086-04**: `validateCarryoverFreshness()` — flag `pending` entries where code fix exists.

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-15 | 1eae07e | v6.25.2 review+integrity+audit-085 remediation |
| 2026-07-15 | 1a7a55a | Merge develop → mainline |

---

## Readiness Verdict

**PARTIAL** — Carryover backlog reduced from 27 open to **4 open + 3 in-progress**. Framework integrity and CI gaps from audit-065/066/070 are closed in code. Remaining debt is operational (branch protection, FIFOZ consumer) and schema coverage (memory layer). Ready to plan **M70 Tech Debt & Gate Hardening**.
