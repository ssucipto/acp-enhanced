# Plan: Audit-080 Safe Install & Update Policy (M68)

**Plan date**: 2026-07-15  
**Source audit**: audit-080  
**Milestone**: M68 — Safe Install & Update Policy  
**Target version**: v6.24.0  
**Estimated effort**: 18–22h (8 routes, 8 tasks)  

---

## Executive summary

Audit-080 confirmed `/acp-version-update` **unsafe**: M47 route-079 was completed **documentation-only** while `acp.version-update.sh` still blind-copies `agent/core/*.yml`, wiki, and routing config. This plan implements a **tiered file policy** aligned with Debian conffile prompts, npm skip-modified patterns, and existing `acp.package-update.sh` checksum logic.

**P0 blocker**: FIFOZ cannot run `/acp-version-update` for M67 pickup until M68 ships.

---

## Gap analysis (double-checked)

| Audit claim | Verified in code? | Plan covers? |
|-------------|-------------------|--------------|
| No flag parsing in version-update.sh | ✅ `grep` — zero `while/case` args | route-199 |
| `cp agent/core/*.yml` L192 | ✅ Present | route-199 |
| Wiki overwrite L195–196 | ✅ Present | route-199 |
| Routing overwrite L199–201 | ✅ Present | route-199 |
| progress.yaml safe | ✅ Not in script | Document + E2E assert |
| install manifest `cat >` L475 | ✅ Present | route-200 |
| install core overwrite L182 | ✅ Present | route-200 |
| bootstrap `cat >` Tier B | ✅ L375–666 | route-201 |
| xargs Windows failure | ✅ Known pattern | route-200 |
| CHANGELOG false fix v6.9.0 | ✅ CHANGELOG L514–530 | route-203 |
| route-079 marked complete | ✅ Was 2026-06-04 | **Reopened**; re-close in 203 |
| `is_file_modified` needs manifest | ⚠️ Gap for acp-core | **Upstream SHA compare** in design |
| skills `local.*` skipped in install only | ✅ install L190 | Extend to version-update |
| schemas not copied on update | ✅ Absent from script | route-199 Tier C |
| AGENTS.md not synced | ✅ Only AGENT.md L170 | route-199 triple-sync |
| F-004 manifest sed | ✅ version-update L238–252 | Tier D merge in 199 |

**No plan gaps** for audit-080 F-080-01..13 (F-080-13 informational only).

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  acp.common.sh — tier helpers (route-198)               │
│  acp_file_differs_from_upstream / acp_copy_framework  │
└──────────────────────────┬──────────────────────────────┘
                           │
     ┌─────────────────────┼─────────────────────┐
     ▼                     ▼                     ▼
version-update.sh    install.sh          bootstrap.sh
(route-199)          (route-200)         (route-201)
     │                     │                     │
     └─────────────────────┴─────────────────────┘
                           │
                    E2E preserve (route-202)
                           │
              validate anti-pattern (route-204)
                           │
                  release v6.24.0 (route-205)
```

---

## File tier policy (canonical)

See `agent/design/safe-install-update-policy.md`:

- **Tier A**: Never overwrite (progress, memory, routes, designs, …)
- **Tier B**: Preserve if SHA ≠ upstream (identity, domain, taxonomy, …)
- **Tier C**: Always refresh (commands, scripts, AGENTS, schemas, …)
- **Tier D**: Merge only (manifest acp-core block)

**Default update behavior** = safe: skip modified Tier B (matches user expectation; `--force` for explicit override).

---

## Route dependency graph

```
route-198 (helpers)
    ├── route-199 (version-update) ──┐
    ├── route-200 (install)        ├── route-202 (E2E)
    └── route-201 (bootstrap)      │
              route-203 (docs) ◄───┘ (after 199)
              route-204 (validate) ◄── 199
              route-205 (release) ◄── all
```

---

## Industry standards mapping

| Standard / tool | Practice | M68 implementation |
|-----------------|----------|-------------------|
| Debian conffile | Prompt on modified config | TTY prompt; skip default |
| npm/pip | Don't clobber local without consent | Tier B SHA compare |
| Helm | `helm diff` before apply | `--diff` flag |
| Git | User's backup layer | Pre-update banner: commit first |
| 12-Factor | Config in environment/repo | identity.yml stays in repo untouched |
| OWASP SCM | Integrity of delivered artifacts | Tier C refresh commands/scripts |

---

## Platform matrix (Mac / Windows)

| Concern | Mitigation | Route |
|---------|------------|-------|
| BSD vs GNU sed | `_sed_i` in common.sh | Existing |
| xargs sysconf | while-read basename | 200 |
| CRLF in E2E | `tr -d '\r'` on fixtures | 202 |
| Non-TTY agent update | `--preserve-project-core` default | 199 |
| Git Bash path spaces | Quote all `"$var"` paths | 199, 200 |

---

## Risk register

| Risk | Mitigation |
|------|------------|
| Stale framework files if all Tier B skipped | Tier C always updates commands/scripts; log summary of skipped count |
| First-time install missing Tier B | create-if-absent when file absent |
| identity.yml same hash but customized content unlikely | Extra `YOUR_PROJECT_NAME` guard |
| E2E needs network clone | Use fixture upstream dir copied into TEMP_DIR pattern |
| route-079 re-closeed prematurely | Only task-208 stamps after E2E green |

---

## Success criteria

1. Customized `identity.yml` survives default `/acp-version-update`
2. `progress.yaml` never modified by install/update/bootstrap
3. `manifest.yaml` retains non-acp-core packages on reinstall
4. Windows CI passes install manifest path
5. audit-080 carryovers closed at release
6. FIFOZ unblocked for M67 consumer update

---

## Artifacts created

| Artifact | Path |
|----------|------|
| Design | `agent/design/safe-install-update-policy.md` |
| Milestone | `agent/milestones/milestone-68-safe-install-update-policy.md` |
| Routes | `agent/routing/tasks/route-198.md` … `route-205.md` |
| Tasks | `agent/tasks/milestone-68-safe-install-update-policy/task-203..210` |
| Plan | `agent/reports/plan-audit-080-safe-install-update.md` |

---

## Next action

```
/acp-proceed --complete --yes M68
```

M63 test coverage can proceed in parallel; **do not** recommend FIFOZ `/acp-version-update` until M68 tag `v6.24.0`.
