# Milestone 49 — Dogfooding Resolution (v6.9.2)

**Status**: completed  
**Priority**: P1  
**Started**: null  
**Target**: 2026-06-06  
**Estimated**: 1 day  
**Progress**: 0% (0/12 tasks)

---

## Goal

Resolve pain points from two feedback sources:
1. **feedback-003** (dogfooding analysis) — 5 internal pain points
2. **install-windows-cursor-2026-06-06** — 7 Windows/Cursor install bugs

Targeted fixes for developer experience, install reliability, and cross-platform support.

---

## Deliverables

### Dogfooding Fixes (feedback-003)

| Route | Pain Point | Fix |
|-------|-----------|-----|
| 094 | Triple-file parity | Add parity check to `/acp-validate` |
| 095 | AGENTS.md vs AGENT.md | Add version line to AGENTS.md header |
| 096 | No auto-validate | Add `--validate` flag to `/acp-commit` |
| 097 | Visualizer quick-start | Visualizer reads `PROGRESS_YAML_PATH` directly (separate repo) |
| 098 | .gitignore rationale | Document design + `--track-instance-data` concept |

### Install Fixes (install-windows-cursor-2026-06-06)

| Route | Issue | Fix |
|-------|-------|-----|
| 099 | `acp.install.sh` hangs on Windows | Safety cap + Windows detection + timeout |
| 100 | Bootstrap can't self-heal | Completeness check, auto-complete partial installs |
| 101 | No Cursor slash commands | Generate `.cursor/commands/` during install |
| 102 | No post-install verification | `verify_install()` with command/script counts |
| 103 | No backup instruction | Pre-install warning with overwrite/preserve list + `--yes` |
| 104 | No Windows docs | README + QUICKSTART Windows/Cursor sections |
| 105 | No repair path | `--repair` mode for partial/broken installs |

---

## Success Criteria

1. **Triple-file parity**: `/acp-validate` warns on missing wrappers for new commands.
2. **AGENTS.md clarity**: Version visible in header for all tools (Copilot, Cursor, Claude).
3. **Auto-validate**: `/acp-commit --validate` catches issues before committing.
4. **Visualizer**: Works without project registry setup (separate repo).
5. **.gitignore**: Design rationale documented; framework devs know how to track instance data.

---

## Dependencies

- feedback-003 (dogfooding analysis)
- Visualizer repo (route-097)
