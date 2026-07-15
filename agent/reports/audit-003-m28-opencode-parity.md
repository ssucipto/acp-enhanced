# Audit Report: M28 opencode Command Parity — Update Mechanism & Content Consistency

**Audit**: #003  
**Date**: 2026-05-04  
**Subject**: How does M28 propagate to existing installed projects, and are there content inconsistencies between `.github/prompts/` (Copilot) and `.opencode/commands/` (opencode)?

---

## Summary

M28 added `.opencode/commands/` as a committed artifact alongside `.github/prompts/`, establishing full `/acp-*` slash command parity between GitHub Copilot and opencode. The audit found **one critical gap** in the update mechanism and **one generation bug** that introduced an extra blank line into all 58 opencode files.

The critical gap: `acp.version-update.sh` did not include a step to update `.opencode/commands/` when existing projects ran `/acp-version-update`. This meant existing projects would never receive opencode commands unless they manually re-bootstrapped. Both issues were fixed and verified during this audit session; 351/351 E2E assertions pass.

---

## Update Mechanism Analysis

### How M28 reaches newly installed projects

| Installation path | Gets `.opencode/commands/`? | Mechanism |
|---|---|---|
| Fresh `acp-bootstrap.sh` run | ✅ Yes | Step 6b generates from `.github/prompts/` on first run |
| `acp.install.sh` (remote clone) | ✅ Yes | Copies `$TEMP_DIR/.opencode/commands/` to `$TARGET_DIR/` |
| `/acp-version-update` (before fix) | ❌ No | No copy step existed — **gap** |
| `/acp-version-update` (after fix) | ✅ Yes | Copy step added to `acp.version-update.sh` |
| Projects that never update | ❌ No | Must manually run bootstrap or update |

### Key architectural fact

`acp.install.sh` clones the repo into `$TEMP_DIR`, then copies specific directories to `$TARGET_DIR`. The `.opencode/commands/` directory is committed to the repo (per ADR-6), so any script that clones `TEMP_DIR` can copy it. `acp.version-update.sh` uses the same clone strategy but was missing the copy step.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/scripts/acp.version-update.sh` | shell | Main update script — had missing `.opencode/commands/` step |
| `agent/scripts/acp.install.sh` | shell | Install script — already had correct copy block from M28 |
| `scripts/acp-bootstrap.sh` | shell | Bootstrap — had extra `echo ""` causing double blank line |
| `.opencode/commands/*.md` (58 files) | opencode commands | Had extra blank line between frontmatter and body |
| `.github/prompts/*.prompt.md` (58 files) | Copilot prompts | Canonical source — no issues |
| `e2e/acp.opencode-commands.test.sh` | E2E test | Missing body content parity suite |

---

## Key Findings

| Finding | Severity | Location | Notes |
|---------|----------|----------|-------|
| `acp.version-update.sh` had no `.opencode/commands/` update step | Critical | `agent/scripts/acp.version-update.sh:206` | Fixed: copy block added |
| All 58 `.opencode/commands/` files had extra blank line | Cosmetic | `.opencode/commands/*.md:5` | Fixed: body regenerated |
| Generation script added `echo ""` before body (body already has leading blank) | Bug | `scripts/acp-bootstrap.sh:1131` | Fixed: `echo ""` removed |
| E2E test lacked body content parity assertion | Test gap | `e2e/acp.opencode-commands.test.sh` | Fixed: Suite 5 added, 58 new assertions |
| Description fields: 58/58 matched exactly between Copilot and opencode | ✅ OK | `.opencode/commands/` | No description drift |
| `mode: agent` field: 0/58 opencode files had the field | ✅ OK | `.opencode/commands/` | No VS Code-specific leakage |

---

## Key Decisions

- **ADR-6** (prior): `.github/prompts/` is canonical source; `.opencode/commands/` is a derived committed artifact regenerated on install/bootstrap. Remains correct.
- **This audit**: The update script must always mirror the install script's file-copying scope. When a new static directory is committed to the repo, it must be added to both `acp.install.sh` AND `acp.version-update.sh`.

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/scripts/acp.version-update.sh:207` | New block: copies `.opencode/commands/` from `$TEMP_DIR` |
| `agent/scripts/acp.install.sh:170` | Existing block: copies `.opencode/commands/` from `$TEMP_DIR` |
| `scripts/acp-bootstrap.sh:1128` | Body awk extraction — `echo ""` removed before `printf '%s\n' "$_oc_body"` |
| `e2e/acp.opencode-commands.test.sh:105` | New Suite 5: body content parity, 1 assertion per file |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-04 | `9913ac2` | feat(M27): distribution readiness fixes — last commit before this session |
| (uncommitted) | — | M28 changes: `.opencode/commands/` (58 files), bootstrap, install, AGENT.md, E2E |

---

## Recommendations

1. **Rule for new static directories**: Any directory committed to the ACP Enhanced repo that should appear in every installed project must be added to **both** `acp.install.sh` and `acp.version-update.sh`. Add a checklist item to the "distribution readiness" milestone pattern.

2. **Body parity test is now mandatory**: Suite 5 in `e2e/acp.opencode-commands.test.sh` enforces body content identity between Copilot source and opencode derived files. If the generation script changes again, this test will catch drift immediately.

3. **Bootstrap `echo ""` anti-pattern**: When using `printf '%s\n' "$body"` where `$body` is awk-extracted (includes leading blank line), do not add a preceding `echo ""`. The awk body already contains the separator blank line from the source file.
