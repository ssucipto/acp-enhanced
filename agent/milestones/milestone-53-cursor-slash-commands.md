# Milestone 53 — Cursor Slash Commands Bootstrap (v6.10.0)

**Status**: Completed  
**Priority**: P1  
**Started**: null  
**Target**: 2026-06-06  
**Estimated**: 0.3 day  
**Progress**: 0% (0/7 tasks)

---

## Goal

Add Cursor IDE slash-command parity to ACP Enhanced install and update workflows. Currently `.opencode/commands/` is bootstrapped during install but `.cursor/commands/` is never created — Cursor users cannot invoke `/acp-*` commands.

**Source**: feedback-001 from SmartDojo (Rygan), with a working reference implementation (`acp.cursor-commands-sync.sh`) and integration guide.

---

## Background

### Current state vs. proposed

| Artifact | OpenCode (today) | Cursor (today) | Cursor (after M53) |
|----------|------------------|----------------|-------------------|
| Slash command dir | `.opencode/commands/` | — | `.cursor/commands/` |
| Install bootstrap | ✅ `acp.install.sh` | ❌ | ✅ sync script |
| Version update | ✅ `acp.version-update.sh` | ❌ | ✅ sync script |
| Bootstrap verify | ✅ checks `.opencode/` | ❌ | ✅ checks `.cursor/` |
| Agent alias protocol | N/A | ❌ | ✅ `.cursor/rules/` (optional) |

### Design principle

Cursor wrappers are **thin stubs** — they reference `agent/commands/` as canonical source, never duplicate command bodies. The `acp.cursor-commands-sync.sh` script auto-generates wrappers from command docs with proper `description` frontmatter for Cursor's `/` picker.

---

## Deliverables

| Route | Task | Priority | Effort |
|-------|------|----------|--------|
| 124 | Port `acp.cursor-commands-sync.sh` → `agent/scripts/` | P0 | Low |
| 125 | Hook into `acp.install.sh` (after opencode copy) + `acp.version-update.sh` | P0 | Low |
| 126 | Bootstrap step 6b: generate `.cursor/commands/` during install; update post-install verification to check `.cursor/commands/` count | P0 | Low |
| 127 | E2E test — asserts file count parity with `agent/commands/`, naming convention, wrapper content format | P1 | Medium |
| 128 | Wiki: Cursor integration guide from `cursor-acp-enhanced.md` feedback reference | P2 | Low |
| 129 | Fix pre-existing `@acp.` occurrences in `acp.visualize.md` (CARRY-047-01) | P2 | Low |
| 130 | Version bump to 6.10.0 + CHANGELOG + sync docs | P2 | Low |

---

## Success Criteria

1. **Fresh install produces `.cursor/commands/`**: One wrapper per `acp.*.md` + `git.*.md` command
2. **Post-install verify checks `.cursor/commands/`**: Count ≥ `agent/commands/acp.*.md` count
3. **Version update regenerates**: `acp.version-update.sh` re-runs sync without overwriting user commands
4. **Naming correct**: `acp.init` → `/acp-init` (dots → hyphens)
5. **Wrapper format correct**: YAML frontmatter with `description`, reference to canonical source
6. **E2E test passes**: File count parity, naming, wrapper content assertions
7. **Pre-existing @acp. bug fixed**: `acp.visualize.md` 3 occurrences cleaned

---

## Dependencies

- feedback-001 + `acp.cursor-commands-sync.sh` reference + `cursor-acp-enhanced.md` guide
- `acp.install.sh` — hook point (after `.opencode/commands/` copy)
- `acp.version-update.sh` — hook point (after opencode sync)
- `acp-bootstrap.sh` — step 6b + post-install verification

---

## Notes

- **Do not duplicate** command bodies — wrappers are thin stubs referencing `agent/commands/`
- **Do not require** Cursor-specific logic in individual command files
- **Preserve** `.opencode/commands/` as-is — this adds Cursor parity, not replacement
- **Optional**: `.cursor/rules/acp-slash-commands.mdc` for agent alias protocol
- The reference script already handles `acp.*.md` and `git.*.md` with proper `description` extraction
- Naming rule: `acp.design-spec` → `/acp-design-spec` (dots → hyphens in slash names)
