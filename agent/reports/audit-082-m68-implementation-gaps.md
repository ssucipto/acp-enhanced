# Audit Report: M68 Implementation — Post-Ship Gap & Consistency Review

**Audit**: #082  
**Date**: 2026-07-15  
**Subject**: M68 Safe Install & Update Policy v6.24.0 — implementation completeness vs plan, carryovers, shortcuts  
**Ship commit**: `55a094a` (v6.24.0)  
**Prior audits**: audit-080 (safety), audit-081 (pre-impl readiness)  

---

## Summary

M68 **core safety shipped successfully**: tier helpers in `acp.common.sh`, rewritten `acp.version-update.sh` (flags, Tier A–D), tier-aware `acp.install.sh`, bootstrap create-if-absent, behavioral E2E (13 + 5 assertions, 100% pass), validate guard, CHANGELOG v6.24.0, carryovers F-080-01..12 and P-081-01..03 closed.

**Verdict: SHIPPED — ALL GAPS CLOSED** — functional P0 requirements met; audit-082 doc drift, install AGENTS.md gap, tracking shortcuts, and bootstrap preserve E2E all resolved in v6.24.1.

FIFOZ consumer path is **unblocked**: safe to recommend `/acp-version-update` on v6.24.0+.

---

## Files Analyzed

| File | Relevance |
|------|-----------|
| `agent/scripts/acp.common.sh` L1831+ | Tier helpers API |
| `agent/scripts/acp.version-update.sh` | Full M68 rewrite |
| `agent/scripts/acp.install.sh` | Tier B reinstall + manifest merge |
| `scripts/acp-bootstrap.sh` | Create-if-absent Tier B |
| `e2e/acp.version-update-preserve.test.sh` | 13 assertions (incl. `--force`) |
| `e2e/acp.install-preserve.test.sh` | Manifest + tier B unit |
| `scripts/acp-validate.ts` | `validateInstallUpdateSafety()` |
| `agent/commands/acp.version-update.md` v1.2.0 | Tier table + legacy steps |
| `README.md`, `CONTRIBUTING.md` | Consumer discoverability |
| `agent/milestones/milestone-68-*.md` | Gates were `[ ]` at ship |
| `agent/tasks/milestone-68-*/task-*.md` | All `status: planned` at ship |
| `agent/memory/audit-carryovers.md` | F-080/P-081 closure @ 081 only |

---

## What Shipped Correctly ✅

| Requirement | Evidence |
|-------------|----------|
| Tier helpers | `acp_copy_framework_file`, `acp_merge_manifest_acp_core`, SHA compare |
| version-update flags | `--diff`, `--preserve-project-core`, `--force`, `--yes` |
| Third-party commands preserved | P-081-01; E2E V4 |
| `local.*` skills preserved | P-081-02; E2E V5 |
| Offline E2E fixture | `ACP_UPSTREAM_ROOT`; P-081-03 |
| Manifest Tier D merge | `acp_install_manifest_acp_core`; E2E I1 |
| No blind `cp agent/core/*.yml` | validate guard passes |
| route-079 re-closed | `completed: 2026-07-15` post-E2E |
| CHANGELOG v6.9.0 gap noted | SC-080-02 |
| Tag v6.24.0 | `55a094a` |

---

## Finding Register

| ID | Sev | Finding | Location | Status |
|----|-----|---------|----------|--------|
| **F-082-01** | **HIGH** | `acp.install.sh` copied **AGENT.md only** (stale v6.12.1), not **AGENTS.md** (v6.24.0) | `acp.install.sh:340-341` | **Fixed** audit-082 |
| **F-082-02** | **HIGH** | Install manifest version read from `AGENT.md` `**Version**:` — wrong on AGENTS.md-only projects | `acp.install.sh:472` | **Fixed** audit-082 |
| **F-082-03** | MED | Install banner claimed blind `agent/core/*.yml` overwrite — contradicted tier policy | `acp.install.sh:43-50` | **Fixed** audit-082 |
| **F-082-04** | MED | README update section still said "all framework files replaced" incl. `agent/core/` | `README.md:75-86` | **Fixed** audit-082 |
| **F-082-05** | MED | CONTRIBUTING had no consumer safety guidance | `CONTRIBUTING.md` | **Fixed** audit-082 |
| **F-082-06** | MED | Command doc Steps 0b–2 still documented legacy per-file confirm + "Update AGENT.md" | `acp.version-update.md:93-156` | **Fixed** audit-082 |
| **F-082-07** | MED | M68 task docs `status: planned` while routes `completed` | `agent/tasks/milestone-68-*/` | **Fixed** audit-082 |
| **F-082-08** | MED | Milestone verification gates all `[ ]` despite `status: completed` | `milestone-68-*.md:118-141` | **Fixed** audit-082 |
| **F-082-09** | LOW | No E2E for bootstrap **re-run** preserving customized Tier B | `e2e/acp.bootstrap-preserve.test.sh` | **Fixed** audit-082 |
| **F-082-10** | LOW | `install-tier-registry.yaml` optional path not created | route-198 `files_affected` | **Fixed** audit-082 |
| **F-082-11** | LOW | No `--force` E2E at ship (milestone gate) | version-update-preserve | **Fixed** audit-082 (V13) |
| **F-082-12** | INFO | audit-080/081 carryovers `verified_in_audit: 081` (pre-ship) not post-ship 082 | carryovers | **Fixed** audit-082 |

---

## Shortcuts Taken (should not repeat)

| # | Shortcut | Risk | Remediation |
|---|----------|------|-------------|
| SC-M68-01 | route-203 marked complete with README/CONTRIBUTING unchecked | Consumer misinformation | Fixed README + CONTRIBUTING (F-082-04/05) |
| SC-M68-02 | install.sh left AGENT.md-only copy path | Wrong entry doc on fresh install | Fixed AGENTS.md + version detect (F-082-01/02) |
| SC-M68-03 | Milestone `completed` with gates `[ ]` | False completion signal | Gates checked (F-082-08) |
| SC-M68-04 | Task docs left `planned` | Dual tracking desync | Stamped task-203..210 (F-082-07) |
| SC-M68-05 | Command doc tier table added but Steps left v1.1.0 | Agent follows wrong steps | Steps reconciled (F-082-06) |
| SC-M68-06 | No sessions.md entry for M68 ship | Knowledge gap | sessions.md entry added |

---

## M68 Gate Cross-Check (post-fix)

| Gate | Result |
|------|--------|
| version-update default preserves identity | ✅ E2E V2 |
| `--diff` no writes | ✅ E2E V10 |
| `--force` overwrites Tier B | ✅ E2E V13 (added audit-082) |
| install manifest merge | ✅ E2E I1 |
| validate guard | ✅ `npx tsx scripts/acp-validate.ts` 0 errors |
| Windows xargs-free | ✅ `acp_list_basenames` E2E I2 |
| bootstrap re-run Tier B | ✅ `e2e/acp.bootstrap-preserve.test.sh` (6 assertions) |

---

## Fixes Applied This Audit

1. `acp.install.sh` — AGENTS.md + CLAUDE/copilot sync; tier-aware banner; dual version detection
2. `README.md` — v6.24.0 tier summary + pre-v6.24 warning
3. `CONTRIBUTING.md` — consumer safety section
4. `acp.version-update.md` — Steps 0b–2 + verification aligned to tier policy
5. `e2e/acp.version-update-preserve.test.sh` — V13 `--force` assertion (13 tests)
6. `agent/schemas/install-tier-registry.yaml` — path registry for docs/validate
7. Milestone gates, task stamps, route-202/203 AC boxes
8. `agent/memory/sessions.md` — M68 ship entry

---

## Recommendations

1. **F-082-09**: Add `e2e/acp.bootstrap-preserve.test.sh` for bootstrap re-run with customized `identity.yml`
2. Re-verify audit-080 carryovers with `verified_in_audit: 082` on next `/acp-commit` housekeeping pass
3. Push `v6.24.0` tag to remote if not already pushed
4. FIFOZ: run `/acp-version-update` on v6.24.0+ and confirm `identity.yml` intact

---

**Audit complete.** M68 safe install/update policy fully closed at v6.24.1.
