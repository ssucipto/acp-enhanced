# Audit Report: Documentation Currency — Implementation Progress vs Docs

**Audit**: #020  
**Date**: 2026-06-03  
**Subject**: Check implementation progress and update all documentation to reflect latest development, including a version/status banner on README

## Summary

ACP Enhanced is at **v6.8.2** with **43 completed milestones** (M1–M43, all 100%), 48 command docs, 27 scripts, and 63 slash commands. However, several key documents are stale — some describe the original v2.0 vision rather than the current v6.8.2 reality. The PRD still says "Ready for Implementation" despite 43 milestones being done. The progress.yaml version field is stuck at 6.6.0. The README lacks a version/status banner.

## Files Analyzed

| File | Type | Current Version | Stale? |
|------|------|----------------|--------|
| `README.md` | docs | v6.8.2 references | ⚠️ Missing banner, stale dir tree, old template names |
| `scripts/PRD-MAIN.md` | docs | v2.0 FINAL (2026-05-01) | ❌ Severely stale — describes pre-implementation vision |
| `agent/progress.yaml` | config | v6.6.0 | ❌ Version field 2 minor versions behind |
| `docs/README.md` | docs | package browser | ⚠️ References upstream prmichaelsen URL |
| `docs/USAGE.md` | docs | current | ✅ Generally current |
| `AGENT.md` | docs | v6.8.2 | ✅ Current |
| `CHANGELOG.md` | docs | up to v6.8.2 | ✅ Current |
| `package.yaml` | config | v6.8.2 | ✅ Current |
| `agent/core/identity.yml` | config | v6.8.2 | ✅ Current |

## Key Findings

| ID | Finding | Location | Severity | Notes |
|----|---------|----------|----------|-------|
| F-001 | README missing version/dev-status banner | README.md:1 | **HIGH** | No version badge, build status, or development status visible at top of README. User explicitly requested this. |
| F-002 | README directory tree shows only original ACP structure | README.md:895–945 | MEDIUM | Missing `agent/core/`, `agent/skills/`, `agent/memory/`, `agent/wiki/`, `agent/routing/`, `agent/artifacts/`, `agent/clarifications/`, `agent/reports/`, `agent/feedback/`, `agent/drafts/`, `agent/preferences/`, `agent/configurables/`, `agent/schemas/`, `agent/scripts/` |
| F-003 | README "Template Files" section lists old upstream template names | README.md:950–970 | LOW | References `design.template.md`, `milestone-1-{title}.template.md` etc — these are ACP Enhanced names now |
| F-004 | PRD-MAIN.md status says "Ready for Implementation" | scripts/PRD-MAIN.md:5 | **HIGH** | 43 milestones completed since this was written. Should reflect current state. |
| F-005 | PRD-MAIN.md skills list is wrong | scripts/PRD-MAIN.md:130–135 | MEDIUM | Lists ui/data/deploy/gamification/auth skills — actual skills are commands/scripts/schemas/testing/typescript/crosscut/upstream-sync |
| F-006 | PRD-MAIN.md directory tree is outdated | scripts/PRD-MAIN.md:107–168 | MEDIUM | Shows old layout with agent/tasks/, only 7 .github/prompts, no routing/tasks/, no .opencode/ |
| F-007 | PRD-MAIN.md uses @acp- prefix instead of /acp- | scripts/PRD-MAIN.md:145–152 | LOW | All commands now use /acp- prefix |
| F-008 | agent/progress.yaml version field is 6.6.0 | agent/progress.yaml:5 | MEDIUM | Should be 6.8.2 — two minor versions behind |
| F-009 | docs/README.md references upstream GitHub Pages URL | docs/README.md:28 | LOW | `https://prmichaelsen.github.io/agent-context-protocol/` — should note this is the upstream package registry, not ACP Enhanced |

## Banner Specification (for README.md)

The user requested a banner with:
- Version number (6.8.2)
- Development status
- Build/CI status
- Key project info

Recommended banner format:
```markdown
[![ACP Enhanced](https://img.shields.io/badge/ACP%20Enhanced-v6.8.2-blue)](https://github.com/ssucipto/acp-enhanced)
[![Status](https://img.shields.io/badge/status-production%20pattern-brightgreen)]()
[![Milestones](https://img.shields.io/badge/milestones-43%2F43%20complete-brightgreen)]()
[![Commands](https://img.shields.io/badge/commands-63%20slash%20commands-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Fork](https://img.shields.io/badge/fork%20of-prmichaelsen%2Facp-orange)](https://github.com/prmichaelsen/agent-context-protocol)
```

## Recommendations

1. **Add banner to README.md** (F-001) — shields.io badges for version, status, milestones, commands, license, fork
2. **Update PRD-MAIN.md status** (F-004) — Change to "Implemented — 43 milestones complete (v6.8.2)" with a brief update note
3. **Fix README directory tree** (F-002) — Show complete enhanced layout with all agent/ subdirectories
4. **Fix progress.yaml version** (F-008) — Bump to 6.8.2
5. **Fix PRD skills list** (F-005) — Update to actual skills
6. **Fix PRD directory tree** (F-006) — Update to current layout
7. **Fix README template names** (F-003) — Use current template filenames
8. **Fix docs/README.md URL note** (F-009) — Add note that this is upstream package browser
