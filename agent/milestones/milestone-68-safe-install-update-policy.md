# Milestone 68 — Safe Install & Update Policy (v6.24.0)

**Milestone ID**: M68  
**Status**: completed  
**Target version**: v6.24.0  
**Priority**: P0 (blocks FIFOZ `/acp-version-update` after M67)  
**Estimated effort**: ~20–24h (8 routes, 8 tasks)  
**Design**: `agent/design/safe-install-update-policy.md`  
**Source**: audit-080, audit-081 (pre-impl), route-079 (reopen), FIFOZ field report  
**Plan amended**: 2026-07-15 (post audit-081)

---

## Problem statement

`/acp-version-update` **destroys project configuration** by blindly copying `agent/core/*.yml`, wiki, and routing files from upstream. M47 route-079 and CHANGELOG v6.9.0 claim guards exist — **implementation was never shipped** (doc-only shortcut SC-080-01). FIFOZ lost `identity.yml` and required `git restore`.

**Goal**: Customer runs install/update on Mac or Windows **without losing project files** and without needing git recovery.

---

## Audit traceability (complete)

### audit-080 findings → routes

| ID | Sev | Finding | Route | Task |
|----|-----|---------|-------|------|
| F-080-01 | CRIT | No flag parsing in version-update | 198, 199 | 203, 204 |
| F-080-02 | CRIT | Blind `cp agent/core/*.yml` | 199 | 204 |
| F-080-03 | HIGH | Wiki overwrite | 199 | 204 |
| F-080-04 | HIGH | Routing config overwrite | 199 | 204 |
| F-080-05 | HIGH | Bootstrap `cat >` Tier B | 201 | 206 |
| F-080-06 | HIGH | Manifest `cat >` wipes packages | 200 | 205 |
| F-080-07 | HIGH | Install core blind overwrite | 200 | 205 |
| F-080-08 | MED | CHANGELOG v6.9.0 false fix | 203, 205 | 208, 210 |
| F-080-09 | MED | AGENT.md vs AGENTS.md entry check | 199 | 204 |
| F-080-10 | MED | No behavioral preserve E2E | 202 | 207 |
| F-080-11 | MED | xargs Windows failure | 200 | 205 |
| F-080-12 | LOW | Wrong domain.yml path in command doc | 203 | 208 |
| F-080-13 | INFO | progress.yaml safe (document + assert) | 202 | 207 |

### audit-081 pre-impl gaps → routes

| ID | Sev | Finding | Route | Task |
|----|-----|---------|-------|------|
| P-081-01 | MED | Third-party commands overwritten (L153) | 199 | 204 |
| P-081-02 | MED | `local.*` skills overwritten on update | 199 | 204 |
| P-081-03 | MED | E2E needs offline upstream fixture | 202 | 207 |
| P-081-04 | LOW | route-079 re-close after route-202 E2E | 203 | 208 |
| P-081-06 | MED | Command doc self-contradiction L38-71 | 203 | 208 |
| P-081-07 | LOW | Do NOT use `is_file_modified` for acp-core | 198 | 203 |
| P-081-08 | LOW | Manifest sed corruption; use Tier D merge | 199 | 204 |

---

## Scope

### In scope

All F-080-01..12, P-081-01..03, P-081-06..08, SC-080-01..04 carryover closure at release.

### Out of scope (defer)

- M63 test coverage tier 2/3 (parallel — do not block M68 P0)
- HIGH-066-005 (validate in CI) — note only; route-204 adds local guard
- CRIT-065-002 (branch protection) — human ops
- Automatic `.bak` file creation (git is sufficient; document in UX)
- Helm-style three-way merge UI
- `.github/prompts/` bootstrap overwrite (Tier C framework — acceptable)

---

## Routes and tasks

| Route | Task | Title | P | Est | Depends |
|-------|------|-------|---|-----|---------|
| route-198 | task-203 | Tier helpers in `acp.common.sh` | P0 | 3h | — |
| route-199 | task-204 | `acp.version-update.sh` — route-079 for real | P0 | 7h | 198 |
| route-200 | task-205 | `acp.install.sh` — tier + manifest + Windows | P0 | 4h | 198 |
| route-201 | task-206 | `acp-bootstrap.sh` — create-if-absent Tier B | P1 | 2h | 198 |
| route-202 | task-207 | E2E behavioral preserve + reinstall tests | P0 | 4h | 199, 200 |
| route-203 | task-208 | Doc reconciliation + route-079 re-close | P1 | 2h | **202** |
| route-204 | task-209 | Validate guard — no blind `cp` patterns | P0 | 2h | 199 |
| route-205 | task-210 | Release v6.24.0 + carryover closure | P0 | 2h | 199–204 |

**Build order**: 198 → (199, 200, 201 parallel) → 202 → (203, 204 parallel) → 205

---

## Shortcuts we must NOT repeat

| ID | Anti-pattern | Who did it | Prevention in M68 |
|----|--------------|------------|-------------------|
| **SC-080-01** | Mark route-079 complete after **doc-only** change (M47) | route-079 `completed: 2026-06-04` | Re-close only after route-202 E2E green + shell checklist |
| **SC-080-02** | CHANGELOG v6.9.0 claims fix without script change | v6.9.0 release | route-205 reconciles; note doc-only gap in v6.24.0 |
| **SC-080-03** | Blind `cp` glob patterns (`agent/core/*.yml`, `*.*.md`) | version-update L153, L192 | `acp_copy_framework_file()` API + route-204 validate |
| **SC-080-04** | Manifest `cat >` wipes third-party packages | install L475 | Tier D merge only |
| **SC-080-05** | Doc contradicts implementation (overwrite vs preserve lists) | version-update.md L38-71 | route-203 single authoritative tier table |
| **SC-080-06** | Ship without behavioral E2E (syntax-only tests) | acp.version.test.sh | route-202 ≥12 assertions, offline fixture |

---

## Pre-implementation conditions (audit-081)

1. Route-199: copy only `acp.*` / `git.*` commands (P-081-01); skip `local.*` skills (P-081-02)
2. Route-198: upstream SHA compare — **not** `is_file_modified()` for acp-core (P-081-07)
3. Route-202: `ACP_UPSTREAM_ROOT` offline fixture — no live git clone in CI (P-081-03)
4. Route-203: route-079 `completed:` only after route-202 E2E (P-081-04)
5. Route-199: `export TEMP_DIR` before tier helpers (P-081-08)
6. Route-205: tag v6.24.0 only after route-204 validate guard passes (SC-080-03)

---

## Verification gates (milestone exit)

### Functional

- [x] `/acp-version-update` default — customized `identity.yml` preserved
- [x] `/acp-version-update --diff` — no writes; shows would-change list
- [x] `/acp-version-update --force` — overwrites Tier B with warning
- [x] Third-party command namespaces preserved on update (P-081-01)
- [x] `local.*` skills preserved on update (P-081-02)
- [x] `acp.install.sh` reinstall — Tier B preserved; manifest packages retained
- [x] `acp-bootstrap.sh` re-run — no Tier B overwrite
- [x] `progress.yaml` never touched by update/install/bootstrap (F-080-13)

### Quality

- [x] `e2e/acp.version-update-preserve.test.sh` — ≥12 assertions, 100% pass (offline fixture)
- [x] `e2e/acp.install-preserve.test.sh` — manifest merge + core preserve
- [x] Windows CI: install manifest path passes without `xargs`
- [x] route-079 verification checklist ✅ (in shell, not doc)
- [x] `npx tsx scripts/acp-validate.ts` — 0 errors (includes route-204 guard)
- [x] audit-080 F-080-01..12 → `status: fixed`
- [x] audit-081 P-081-01..03 → `status: fixed`

### Release

- [x] CHANGELOG v6.24.0
- [x] FIFOZ consumer note: safe to run `/acp-version-update` on v6.24.0+
- [x] route-079 `completed:` stamped (post-E2E only)

---

## Carryover closure (route-205)

Close in `agent/memory/audit-carryovers.md` with `verified_in_audit: 081`:

- F-080-01 through F-080-12 (all pending)
- P-081-01, P-081-02, P-081-03 (pending)

---

## FIFOZ downstream

After v6.24.0: FIFOZ runs `/acp-version-update` (default safe mode), verifies `identity.yml` intact, closes feedback-007 consumer path.

**Until v6.24.0**: Do NOT recommend `/acp-version-update` — use `git commit` + selective merge.

---

**Status**: completed — shipped v6.24.0 (2026-07-15)
