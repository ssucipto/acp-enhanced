# Milestone 68 — Safe Install & Update Policy (v6.24.0)

**Milestone ID**: M68  
**Status**: planned  
**Target version**: v6.24.0  
**Priority**: P0 (blocks FIFOZ `/acp-version-update` after M67)  
**Estimated effort**: ~18–22h (8 routes, 8 tasks)  
**Design**: `agent/design/safe-install-update-policy.md`  
**Source**: audit-080, route-079 (reopen), FIFOZ field report  

---

## Problem statement

`/acp-version-update` **destroys project configuration** by blindly copying `agent/core/*.yml`, wiki, and routing files from upstream. M47 route-079 and CHANGELOG v6.9.0 claim guards exist — **implementation was never shipped** (doc-only shortcut SC-080-01). FIFOZ lost `identity.yml` and required `git restore`.

**Goal**: Customer runs install/update on Mac or Windows **without losing project files** and without needing git recovery.

---

## Scope

### In scope (audit-080)

| Finding | Route | Resolves |
|---------|-------|----------|
| F-080-01, F-080-02 | 198, 199 | route-079 **real** implementation |
| F-080-03, F-080-04 | 199 | Wiki + routing Tier B preserve |
| F-080-05 | 201 | Bootstrap create-if-absent |
| F-080-06, F-080-07, F-080-11 | 200 | Install tier + manifest merge + Windows |
| F-080-08, F-080-12 | 203 | Doc reconciliation |
| F-080-09, schemas gap | 199 | AGENTS.md + schemas on update |
| F-080-10 | 202 | Behavioral E2E |
| Release | 205 | v6.24.0 + carryover closure |

### Out of scope (defer)

- M63 test coverage tier 2/3 (parallel — do not block M68 P0)
- HIGH-066-005 (validate in CI) — note only
- Automatic `.bak` file creation (git is sufficient; document in UX)
- Helm-style three-way merge UI

---

## Routes and tasks

| Route | Task | Title | P | Est | Depends |
|-------|------|-------|---|-----|---------|
| route-198 | task-203 | Design + `acp.common.sh` tier helpers | P0 | 3h | — |
| route-199 | task-204 | `acp.version-update.sh` — route-079 for real | P0 | 6h | 198 |
| route-200 | task-205 | `acp.install.sh` — tier preserve + manifest merge + Windows | P0 | 4h | 198 |
| route-201 | task-206 | `acp-bootstrap.sh` — create-if-absent Tier B | P1 | 2h | 198 |
| route-202 | task-207 | E2E behavioral preserve + reinstall tests | P0 | 4h | 199, 200 |
| route-203 | task-208 | Doc reconciliation + reopen route-079 | P1 | 2h | 199 |
| route-204 | task-209 | Validate guard — no blind `cp` in update scripts | P2 | 2h | 199 |
| route-205 | task-210 | Release v6.24.0 + audit-080 carryover closure | P0 | 2h | 199–204 |

**Build order**: 198 → (199, 200, 201 parallel) → 202 → (203, 204) → 205

---

## Shortcuts to avoid (from audit-080)

| # | Anti-pattern | Prevention |
|---|--------------|------------|
| SC-080-01 | Mark route complete after doc-only change | E2E must pass before route-079 re-closed |
| SC-080-02 | CHANGELOG claim without script change | route-205 reconciles v6.9.0 note |
| SC-080-03 | Blind `cp` glob patterns | `acp_copy_framework_file()` single path API |
| SC-080-04 | Manifest `cat >` wipes packages | Tier D merge only |

---

## Verification gates (milestone exit)

### Functional

- [ ] `/acp-version-update` default — customized `identity.yml` preserved
- [ ] `/acp-version-update --diff` — no writes; shows would-change list
- [ ] `/acp-version-update --force` — overwrites Tier B with warning
- [ ] `acp.install.sh` on existing `agent/` — Tier B preserved; manifest packages retained
- [ ] `acp-bootstrap.sh` re-run — no Tier B overwrite
- [ ] `progress.yaml` never touched by update/install

### Quality

- [ ] `e2e/acp.version-update-preserve.test.sh` — 100% pass (macOS + Linux)
- [ ] Windows CI: install manifest path passes without `xargs`
- [ ] route-079 verification checklist ✅ (in shell)
- [ ] `npx tsx scripts/acp-validate.ts` — 0 errors
- [ ] audit-080 carryovers F-080-01..11 → `status: fixed`

### Release

- [ ] CHANGELOG v6.24.0
- [ ] FIFOZ consumer note: safe to run `/acp-version-update` on v6.24.0+

---

## FIFOZ downstream

After v6.24.0: FIFOZ runs `/acp-version-update` (default safe mode), verifies `identity.yml` intact, closes feedback-007 consumer path.

---

**Status**: planned — awaiting `/acp-proceed --complete M68`
