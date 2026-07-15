# Audit Report: M68 Safe Install & Update Policy — Pre-Implementation Readiness

**Audit**: #081  
**Date**: 2026-07-15  
**Subject**: M68 Safe Install & Update Policy (`--pre-impl`)  
**Mode**: `--pre-impl`  
**Prior audits**: audit-080 (overwrite safety), plan commit `09738f5`  
**Planning**: M68 milestone, design `safe-install-update-policy.md`, routes 198–205, tasks 203–210  

---

## Summary

M68 is **well-planned** and directly maps audit-080 findings to 8 routes with a coherent tier A/B/C/D policy aligned with `acp.package-update.sh` checksum patterns and industry conffile practice. Code cross-reference confirms the **destructive baseline is unchanged**: `acp.version-update.sh:192` still blind-copies `agent/core/*.yml`; `acp.install.sh:182-183` and `475` still overwrite core + manifest; `acp-bootstrap.sh:375+` still uses `cat >` for Tier B stubs.

**Verdict: READY** to start **route-198** with **six pre-conditions** (below). No hard blockers prevent coding. Three **new implementation gaps** (P-081-01..03) must be folded into routes 199/202 during implementation — they are absent from route acceptance criteria but required by the tier design doc.

**Do not recommend `/acp-version-update` to consumers until route-205 ships v6.24.0.**

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-68-safe-install-update-policy.md` | milestone | Scope, gates, shortcuts SC-080-01..04 |
| `agent/design/safe-install-update-policy.md` | design | Tier policy, helpers, flags |
| `agent/reports/audit-080-version-update-overwrite-safety.md` | audit | Source findings F-080-01..13 |
| `agent/routing/tasks/route-198.md` … `route-205.md` | routes | Implementation units |
| `agent/routing/tasks/route-079.md` | route | Reopened; doc-only M47 shortcut |
| `agent/tasks/milestone-68-safe-install-update-policy/task-203` … `task-210` | tasks | Detailed steps |
| `agent/scripts/acp.version-update.sh` | script | **Destructive baseline** L192-201 |
| `agent/scripts/acp.install.sh` | script | Core overwrite L182; manifest `cat >` L475; xargs L470 |
| `scripts/acp-bootstrap.sh` | script | Tier B `cat >` L375-666 |
| `agent/scripts/acp.common.sh` | script | `calculate_checksum`, `is_file_modified` — reuse target |
| `agent/scripts/acp.package-update.sh` | script | Reference `--force` / `--skip-modified` pattern |
| `agent/commands/acp.version-update.md` | command | Documents flags **not in script**; path errors L69 |
| `agent/memory/audit-carryovers.md` | memory | 10 pending F-080-* entries |
| `e2e/acp.version.test.sh` | e2e | Syntax-only; domain.yml notes no network |
| `scripts/acp-validate.ts` | tooling | No destructive-pattern guard yet (route-204) |

---

## Key Findings (Investigation)

| ID | Sev | Finding | Location | M68 route |
|----|-----|---------|----------|-----------|
| **F-080-01** | CRIT | Zero argument parsing in version-update | `acp.version-update.sh` (no `while/case`) | route-199 |
| **F-080-02** | CRIT | Blind `cp agent/core/*.yml` | `acp.version-update.sh:192` | route-199 |
| **F-080-03** | HIGH | Wiki overwrite | `acp.version-update.sh:195-196` | route-199 |
| **F-080-04** | HIGH | Routing config overwrite | `acp.version-update.sh:199-201` | route-199 |
| **F-080-05** | HIGH | Bootstrap `cat >` Tier B | `acp-bootstrap.sh:375-666` | route-201 |
| **F-080-06** | HIGH | Manifest `cat >` wipes packages | `acp.install.sh:475-495` | route-200 |
| **F-080-07** | HIGH | Install core blind overwrite | `acp.install.sh:182-183` | route-200 |
| **F-080-08** | MED | CHANGELOG v6.9.0 false fix claim | `CHANGELOG.md` | route-203/205 |
| **F-080-09** | MED | Script checks `AGENT.md` only; Enhanced uses `AGENTS.md` | `acp.version-update.sh:49-52` | route-199 |
| **F-080-10** | MED | No behavioral preserve E2E | `e2e/acp.version.test.sh` | route-202 |
| **F-080-11** | MED | `xargs` Windows Git Bash failure | `acp.install.sh:470-472` | route-200 |
| **F-080-12** | LOW | `domain.yml` path wrong in command doc | `acp.version-update.md:69` | route-203 |
| **F-080-13** | INFO | `progress.yaml` not touched by update | (absent in script) | Document + E2E assert |
| **P-081-01** | MED | **Third-party commands overwritten** — L153 copies all `*.*.md`; Tier A design says preserve non-acp/git namespaces | `acp.version-update.sh:153` | **Add to route-199 AC** |
| **P-081-02** | MED | **`local.*` skills overwritten on update** — install skips (L190); update does not (L193) | `acp.version-update.sh:193` vs `acp.install.sh:190` | **Add to route-199 AC** |
| **P-081-03** | MED | **E2E offline strategy unspecified** — `domain.yml:398` says version-update has no network in CI; preserve test needs `ACP_UPSTREAM_ROOT` fixture or local repo copy | route-202 task | **Add to route-202 AC** |
| **P-081-04** | LOW | **route-079 re-close timing** — route-203 AC says after route-199 E2E; milestone gates require route-202 E2E | `route-203.md:35` | Use route-202 as gate |
| **P-081-05** | LOW | **F-080-09, F-080-12 missing from carryovers.md** | `audit-carryovers.md` | Filed in audit-081 |
| **P-081-06** | MED | **Command doc self-contradiction** — L38-47 lists core/wiki as overwritten; L49-71 claims preserved | `acp.version-update.md` | route-203 rewrite |
| **P-081-07** | LOW | **`is_file_modified` unsuitable for acp-core Tier B** — requires manifest checksums per file; design correctly specifies upstream SHA compare | `acp.common.sh:705` | route-198 must NOT reuse `is_file_modified` for core |
| **P-081-08** | LOW | **Manifest sed corruption risk** on multi-package manifests | `acp.version-update.sh:238-252` | route-199 Tier D merge |
| **SC-080-01** | CRIT | route-079 completed doc-only (M47) | `route-079.md:18-19` | E2E before re-close |
| **SC-080-02** | HIGH | CHANGELOG claim without script | v6.9.0 | route-205 |
| **SC-080-03** | HIGH | Blind `cp` globs | L192, L153 | route-198 API |
| **SC-080-04** | HIGH | Manifest `cat >` | `acp.install.sh:475` | route-200 |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `acp.version-update.sh:10-17` | Self-re-exec guard — `"$@"` passes new flags correctly ✅ |
| `acp.version-update.sh:49-52` | Entry check `AGENT.md` only — must accept `AGENTS.md` OR `AGENT.md` |
| `acp.version-update.sh:153` | `find … *.*.md -exec cp` — overwrites third-party commands |
| `acp.version-update.sh:192` | **CRITICAL** `cp … agent/core/*.yml` |
| `acp.version-update.sh:193` | Blind skills copy — no `local.*` skip |
| `acp.version-update.sh:238-252` | Manifest sed — not Tier D merge |
| `acp.install.sh:182-183` | Blind core copy on reinstall |
| `acp.install.sh:190` | `local.*` skill skip — **regression test required** |
| `acp.install.sh:470-472` | `xargs -n1 basename` — Windows failure |
| `acp.install.sh:475` | `cat > manifest.yaml` — destroys packages |
| `acp-bootstrap.sh:350` | identity create-if-absent ✅ |
| `acp-bootstrap.sh:375` | constraints `cat >` — overwrite on re-run |
| `acp.common.sh:36-48` | `calculate_checksum` — SHA-256 portable macOS/Linux ✅ |
| `acp.package-update.sh:213-248` | Modified-file detection + prompt pattern to mirror |
| `acp.version-update.md:38-47` vs `49-71` | Contradictory overwrite/preserve lists |
| `acp.version-update.md:69` | Wrong path `agent/core/domain.yml` |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-15 | `09738f5` | plan(M68): safe install/update policy from audit-080 |
| 2026-07-15 | audit-080 | Field report + overwrite matrix |
| 2026-06-04 | M47 route-079 | Doc-only; script unchanged (SC-080-01) |
| 2026-06-04 | v6.9.0 CHANGELOG | False guard claim (SC-080-02) |

---

## Recommendations (Pre-Implementation)

### P0 — Fold into route-199 before ship

1. **Tier A command filter**: Copy only `acp.*.md` and `git.*.md`; skip other namespaces (P-081-01).
2. **`local.*` skills skip** on version-update matching install (P-081-02).
3. **`export TEMP_DIR`** before sourcing tier helpers (P-081-08).
4. **Accept `AGENTS.md` OR `AGENT.md`** as project root marker (F-080-09).
5. **Replace manifest sed** with `acp_merge_manifest_acp_core` (P-081-08).

### P0 — Fold into route-202

6. **Offline E2E pattern**: Use `ACP_UPSTREAM_ROOT="${PROJECT_ROOT}"` or copied fixture tree — no live `git clone` in CI (P-081-03, aligns with `domain.yml:398`).

### P1 — Plan hygiene

7. **route-079 re-close** only after route-202 E2E green, not route-199 alone (P-081-04).
8. **route-203** rewrite command doc — remove L38-47 contradiction; fix domain.yml path (P-081-06, F-080-12).

### P2 — Do not shortcut

9. **SC-080-01**: No route-079 `completed:` until behavioral E2E passes.
10. **SC-080-03**: route-204 validate guard must land before v6.24.0 tag.

---

## Pre-Implementation Readiness (M68)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Route/task files complete | ✅ | 8 routes + 8 tasks; acceptance criteria present |
| `files_affected` accurate | ⚠️ | `install-tier-registry.yaml` will be created (route-198); E2E files not yet created (expected) |
| Open blockers | ✅ None | M68 is the fix for audit-080 blockers |
| Design ↔ routes alignment | ⚠️ | P-081-01, P-081-02 in design Tier A/B but missing from route-199 AC |

### Phase 2 — Code Cross-Reference

| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| `acp.version-update.sh` | flag parsing `--diff`/`--force` | ❌ | Zero implementation — route-199 |
| `acp.version-update.sh` | `cp agent/core/*.yml` | ❌ | L192 present — route-199 removes |
| `acp.common.sh` | `acp_copy_framework_file` | ❌ | Not yet — route-198 creates |
| `acp.common.sh` | `calculate_checksum` | ✅ | Exists L36; reuse in helpers |
| `acp.common.sh` | `is_file_modified` | ⚠️ | Exists but wrong for acp-core — use upstream SHA (P-081-07) |
| `acp.install.sh` | `local.*` skill skip | ✅ | L190 — preserve in route-200 regression |
| `acp.install.sh` | manifest `cat >` | ❌ | L475 — route-200 |
| `acp-bootstrap.sh` | identity create-if-absent | ✅ | L350 |
| `acp-bootstrap.sh` | constraints `cat >` | ❌ | L375 — route-201 |
| `acp.version-update.md` | flags match script | ❌ | Doc ahead of implementation |
| `route-079.md` | `completed:` | ✅ empty | Reopened correctly |
| `install-tier-registry.yaml` | exists | ❌ | Optional per route-198 — create or defer |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks M68 start? |
|-----------|----------|--------|-------------------|
| F-080-01 | critical | pending | **No** — route-199 deliverable |
| F-080-02 | critical | pending | **No** — route-199 deliverable |
| F-080-03..07 | high | pending | **No** — routes 199-201 |
| F-080-08 | medium | pending | **No** — route-203/205 |
| F-080-09 | medium | pending | **No** — route-199 (was missing from carryovers — filed @081) |
| F-080-10 | medium | pending | **No** — route-202 |
| F-080-11 | medium | pending | **No** — route-200 |
| F-080-12 | low | pending | **No** — route-203 (filed @081) |
| HIGH-066-005 | high | pending | **No** — route-204 local validate; CI gap remains |
| CRIT-065-002 | critical | pending | **No** — human ops |

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ✅ | route-198..205 + reopened route-079 |
| Version bump planned | ✅ | v6.24.0 in route-205 |
| Wiki/docs update planned | ✅ | route-203 README, CHANGELOG, command doc |
| E2E registration planned | ✅ | route-202 → `domain.yml` test_suites |
| Validate guard planned | ✅ | route-204 |
| FIFOZ consumer unblock | ✅ | route-205 + milestone gates |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 1 | medium |
| Phase 2 — Code Cross-Reference | 8 | critical |
| Phase 3 — Carryover Check | 12 pending F-080 | critical |
| Phase 4 — Operational Completeness | 0 | none |
| **Total new (P-081)** | **8** | medium |

### Readiness Verdict

**READY** — Start route-198 (`acp.common.sh` tier helpers) with pre-conditions:

1. Route-199 AC must include **third-party command preservation** (P-081-01) and **`local.*` skill skip** (P-081-02).
2. Route-202 must use **offline upstream fixture** — no network clone in CI (P-081-03).
3. Route-198 helpers use **upstream SHA compare**, not `is_file_modified()` for acp-core (P-081-07).
4. Re-close route-079 only after **route-202 E2E green** (P-081-04).
5. `export TEMP_DIR` before tier helper calls (P-081-08).
6. Do not tag v6.24.0 until route-204 validate guard passes (SC-080-03).

---

## Shortcut Register (must not repeat)

| ID | Shortcut | Prevention in M68 |
|----|----------|-------------------|
| SC-080-01 | route-079 doc-only complete | E2E + shell verification before `completed:` |
| SC-080-02 | CHANGELOG without script | route-205 reconciles v6.9.0 note |
| SC-080-03 | Blind `cp` globs | `acp_copy_framework_file()` + route-204 validate |
| SC-080-04 | Manifest `cat >` | Tier D merge only |

---

*Audit-081 | M68 pre-impl | 21 findings cross-ref | Verdict: READY | 6 pre-conditions*
