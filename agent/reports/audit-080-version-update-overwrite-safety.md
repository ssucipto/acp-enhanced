# Audit Report: `/acp-version-update` & Install Overwrite Safety

**Audit**: #080  
**Date**: 2026-07-15  
**Subject**: Ensure `acp-version-update`, `acp.install`, and bootstrap do not overwrite project-owned files (identity.yml, progress.yaml, wiki, routing config) — Mac + Windows smoothness  
**Trigger**: Field report — FIFOZ `/acp-version-update` overwrote project files; customer had to `git restore`  
**Prior art**: route-079 (M47, marked complete 2026-06-04), CHANGELOG v6.9.0 claims guards shipped  

---

## Summary

**Verdict: NOT SAFE — doc-only fix shipped; script still destructive.**

`/acp-version-update` (`agent/scripts/acp.version-update.sh`) **unconditionally overwrites** all `agent/core/*.yml`, all `agent/wiki/*`, and routing config files on every run. The command doc (`acp.version-update.md` v1.1.0) and CHANGELOG v6.9.0 describe `--diff`, `--preserve-project-core`, confirmation prompts, and protection for `identity.yml` — **none of this exists in the shell script** (zero argument parsing).

`progress.yaml` is **not** directly touched by version-update (good), but consumers still lose `identity.yml`, customized `domain.yml`, `constraints.yml`, `routing.yml`, and `taxonomy.yml` — the files that define project identity and routing behavior.

`acp.install.sh` on re-run overwrites `agent/core/*.yml` and **always recreates** `agent/manifest.yaml` (wiping third-party package entries). `scripts/acp-bootstrap.sh` on partial re-run overwrites `constraints.yml`, `routing.yml`, wiki stubs, and routing taxonomy even when `identity.yml` is preserved.

**No behavioral E2E** tests assert preserve-on-update. Existing `e2e/acp.version.test.sh` only checks bash syntax.

---

## Files Analyzed

| File | Relevance |
|------|-----------|
| `agent/scripts/acp.version-update.sh` | Primary update path — blind `cp` overwrites |
| `agent/commands/acp.version-update.md` | Documents guards **not implemented** in script |
| `agent/scripts/acp.install.sh` | Reinstall overwrites core + manifest |
| `scripts/acp-bootstrap.sh` | Re-bootstrap overwrites wiki/routing/constraints |
| `agent/scripts/acp.package-update.sh` | Reference: has `--force`, `--skip-modified`, checksum diff |
| `agent/routing/tasks/route-079.md` | Guard spec — marked complete, script unchanged |
| `e2e/acp.version.test.sh` | Syntax-only; no preserve tests |
| `e2e/acp.install.test.sh` | Smoke grep-only; no overwrite tests |
| `CHANGELOG.md` v6.9.0 | Claims guards shipped — **false for script** |

---

## Overwrite Matrix (version-update.sh)

| Path | Touched? | Mode | Project-owned? | Risk |
|------|----------|------|----------------|------|
| `agent/progress.yaml` | ❌ No | — | Yes | **Safe** |
| `agent/memory/*` | ❌ No (create-if-absent only) | preserve | Yes | **Safe** |
| `agent/routing/tasks/route-*.md` | ❌ No | preserve | Yes | **Safe** |
| `agent/routing/ledger.md` | ❌ No (create-if-absent) | preserve | Yes | **Safe** |
| `agent/manifest.yaml` | ⚠️ Partial | sed in-place version fields only | Yes (packages) | **Medium** — sed can corrupt YAML |
| `agent/core/identity.yml` | ✅ Yes | **blind overwrite** L192 | **Yes** | **CRITICAL** |
| `agent/core/constraints.yml` | ✅ Yes | blind overwrite L192 | Often customized | **HIGH** |
| `agent/core/routing.yml` | ✅ Yes | blind overwrite L192 | Often customized | **HIGH** |
| `agent/wiki/domain.yml` | ✅ Yes | blind overwrite L195 | **Yes** | **HIGH** |
| `agent/wiki/*.md` | ✅ Yes | blind overwrite L196 | Often customized | **HIGH** |
| `agent/routing/taxonomy.yml` | ✅ Yes | blind overwrite L199 | Often customized | **HIGH** |
| `agent/routing/rules.md` | ✅ Yes | blind overwrite L200 | Often customized | **MED** |
| `agent/routing/config.yml` | ✅ Yes | blind overwrite L201 | Often customized | **MED** |
| `agent/commands/*.*.md` | ✅ Yes | blind overwrite L153 | Framework (+ local cmds) | **MED** |
| `agent/skills/*.md` | ✅ Yes | blind overwrite L193 | Framework (no `local.*` skip) | **MED** |
| `AGENT.md` | ✅ Yes | blind overwrite L170 | Protocol copy | Expected |
| `AGENTS.md` / `CLAUDE.md` | ❌ No | — | Sync copies | **Gap** — Enhanced projects use AGENTS.md |
| `agent/schemas/*` | ❌ No | — | Framework | Version drift on update |
| `agent/index/*` | ❌ No | — | Mixed | Version drift |

---

## Finding Register

| ID | Sev | Finding | Location | Blocks consumer update? |
|----|-----|---------|----------|-------------------------|
| **F-080-01** | **CRIT** | **route-079 guards documented + marked complete but script has zero flag parsing** | `acp.version-update.sh` (no `$#`/`getopts`); `route-079.md:69-73` checked but unimplemented | Yes |
| **F-080-02** | **CRIT** | **`cp ... agent/core/*.yml` overwrites identity.yml unconditionally** | `acp.version-update.sh:192` | Yes |
| **F-080-03** | **HIGH** | **Wiki `domain.yml` + all wiki markdown overwritten** | `acp.version-update.sh:195-196` | Yes |
| **F-080-04** | **HIGH** | **routing taxonomy/rules/config overwritten** | `acp.version-update.sh:199-201` | Yes |
| **F-080-05** | **HIGH** | **bootstrap re-run uses `cat >` for constraints/routing/wiki/taxonomy** (only identity is create-if-absent) | `acp-bootstrap.sh:375-666` | Yes on re-bootstrap |
| **F-080-06** | **HIGH** | **`acp.install.sh` always `cat > agent/manifest.yaml`** — destroys non-acp-core packages | `acp.install.sh:475-495` | Yes on reinstall |
| **F-080-07** | **HIGH** | **`acp.install.sh` overwrites `agent/core/*.yml` on existing install** | `acp.install.sh:182-183` | Yes |
| **F-080-08** | **MED** | **CHANGELOG v6.9.0 + command doc claim protection that script lacks** — false assurance | `CHANGELOG.md:514-530`, `acp.version-update.md:24-71` | Misleading |
| **F-080-09** | **MED** | **Script checks `AGENT.md` but ACP Enhanced standard is `AGENTS.md`** | `acp.version-update.sh:49-52` vs bootstrap | Confusing on Enhanced projects |
| **F-080-10** | **MED** | **No behavioral E2E for preserve-on-update** | `e2e/acp.version.test.sh` syntax-only | Regression risk |
| **F-080-11** | **MED** | **Windows: `xargs` in manifest generation** (`install.sh:470-472`) — known Git Bash `sysconf` failures | `acp.install.sh:470` | Install/update fail |
| **F-080-12** | **LOW** | **Command doc places `domain.yml` under `agent/core/`** — actual path is `agent/wiki/domain.yml` | `acp.version-update.md:69-71` | Doc confusion |
| **F-080-13** | **LOW** | **`progress.yaml` correctly not touched** by version-update | (absence in script) | N/A — document as safe |

---

## Doc vs Implementation Gap (route-079)

| route-079 requirement | Command doc | Script |
|----------------------|-------------|--------|
| `--diff` dry-run | ✅ Documented | ❌ Missing |
| `--preserve-project-core` | ✅ Documented | ❌ Missing |
| `--force` | ✅ Documented | ❌ Missing |
| Warn before overwrite modified core | ✅ Documented | ❌ Missing |
| Default silent overwrite unmodified | ✅ Documented | ❌ **Always overwrites all** |

**Shortcut SC-080-01**: route-079 stamped `completed: 2026-06-04` after **command-doc-only** update (M47). CHANGELOG v6.9.0 "Fixed" line repeats the claim without script changes.

---

## Reference: package-update (good pattern)

`acp.package-update.sh` implements the expected safety model:

- `is_file_modified()` checksum comparison against manifest
- `--skip-modified` / `--force` / interactive prompt
- Per-file skip with visible log

Version-update should adopt the same tiered policy.

---

## Recommended File Tier Policy

### Tier A — Never overwrite (project-owned)

`agent/progress.yaml`, `agent/memory/*`, `agent/routing/tasks/route-*.md`, `agent/routing/ledger.md`, `agent/design/*.md` (non-template), `agent/milestones/*.md` (non-template), `agent/patterns/local.*`, `agent/preferences/**`, `agent/drafts/**`, `agent/clarifications/**`, `agent/artifacts/**`, `agent/specs/**`, `agent/index/local.*`

### Tier B — Overwrite only if identical to upstream framework default OR user confirms / `--force`

`agent/core/identity.yml`, `agent/core/constraints.yml`, `agent/core/routing.yml`, `agent/wiki/domain.yml`, `agent/wiki/architecture.md`, `agent/wiki/integrations.md`, `agent/routing/taxonomy.yml` (consumer projects customize heavily)

### Tier C — Always overwrite (framework artifacts)

`agent/commands/acp.*.md`, `agent/scripts/*.sh`, `AGENTS.md`/`AGENT.md` protocol, `agent/skills/*.md` except `local.*`, templates `*.template.*`, `.opencode/commands/*`, `.cursor/commands/*` (regenerated), `agent/schemas/*`, bundled `agent/index/acp.*.yaml`

### Tier D — Merge, never replace wholesale

`agent/manifest.yaml` — update `acp-core` version block only; preserve other `packages:` entries

---

## Platform Notes (Mac vs Windows)

| Issue | Mac | Windows (Git Bash) | Mitigation |
|-------|-----|-------------------|------------|
| `_sed_i` | BSD `sed -i ''` | GNU `sed -i` | ✅ Handled in `acp.common.sh:6-11` |
| `mktemp` / `date -u` | ✅ | ✅ Git Bash | OK |
| `xargs` in manifest | ✅ | ⚠️ `sysconf(_SC_ARG_MAX) failed` | Replace with `while read` loop |
| `find ... -exec cp` | ✅ | ✅ | OK |
| Interactive `read -p` | ✅ TTY | ⚠️ Non-TTY in CI/automation | `--yes` default for CI; agent-driven updates use `--preserve-project-core` |
| Line endings CRLF | Rare issue | E2E uses `tr -d '\r'` elsewhere | Apply to update fixtures |

---

## Recommendations (prioritized)

### P0 — Before any consumer runs `/acp-version-update`

1. **Implement route-079 in `acp.version-update.sh`** — argument parsing, `--diff`, `--preserve-project-core`, per-file hash diff vs upstream, confirmation prompts, `--force`.
2. **Remove blind `cp agent/core/*.yml`** — copy only `constraints.yml` if unmodified; never overwrite `identity.yml` without explicit opt-in.
3. **Stop overwriting `agent/wiki/domain.yml`** by default — Tier B policy.
4. **Fix `acp.install.sh` manifest** — merge acp-core block; never `cat >` whole file on reinstall.

### P1 — Bootstrap + install parity

5. **bootstrap create-if-absent** for `constraints.yml`, `routing.yml`, wiki, taxonomy (match identity.yml pattern).
6. **Sync AGENTS.md** on update (ACP Enhanced), not only legacy `AGENT.md`.
7. **Copy `agent/schemas/`** on version-update (framework drift).

### P2 — Regression prevention

8. **E2E `e2e/acp.version-update-preserve.test.sh`** — temp project with customized `identity.yml` + `progress.yaml`; run update with default flags; assert identity unchanged, progress unchanged.
9. **E2E Windows job** — manifest generation without `xargs` (CI matrix already has `windows-latest`).
10. **Reconcile CHANGELOG + route-079** — mark route-079 as **reopened** until script passes E2E.

### P3 — FIFOZ consumer guidance (interim)

Until P0 ships, document: **Do not run `/acp-version-update`** without `git commit` + use manual selective merge, or cherry-pick framework files from upstream tag.

---

## Git History

| Date | Commit | Note |
|------|--------|------|
| 2026-06-04 | M47 route-079 | Command doc updated; script not |
| 2026-06-04 | v6.9.0 CHANGELOG | Claims guards fixed |
| 2026-06-08+ | audit-036/038 | Bootstrap safety improved; update script not |
| 2026-07-15 | FIFOZ field report | identity.yml overwrite on version-update |

---

## Verdict

**NOT SAFE** — `/acp-version-update` will destroy project configuration unless the customer has committed to git and knows to `git restore`. The documented guards are **aspirational only**. Implement P0 before recommending FIFOZ `/acp-version-update` for M67 handoff pickup.

---

*Audit-080 | 13 findings | 2 CRITICAL | 5 HIGH | 4 MED | 2 LOW/INFO*
