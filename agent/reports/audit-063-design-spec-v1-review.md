# Audit Report: design-spec-acp-enhanced-features-v1.0 — Detail Review

**Audit**: #063  
**Date**: 2026-06-09  
**Subject**: design-spec-acp-enhanced-features-v1.0.md — gaps, inconsistencies, and accuracy cross-check against live codebase  

---

## Summary

The v1.0 feature capability report is structurally sound and covers all 71 commands and 36 scripts. However, a line-by-line cross-reference against the live codebase reveals **12 inaccuracies** and **6 missing sections**. Most are numerical errors (stale line counts, wrong milestone count, wrong development duration) and missing subsystems (TypeScript tooling, CI/CD, directory structure, installation). No CRITICAL errors — all fixable in a v2.0 update.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/reports/design-spec-acp-enhanced-features-v1.0.md` | audit subject | Full report under review |
| `agent/progress.yaml` | source-of-truth | Milestone counts, version, recurring tasks |
| `agent/commands/*.md` | source-of-truth | Command inventory cross-reference |
| `agent/scripts/*.sh` | source-of-truth | Script inventory + line counts |
| `scripts/*.ts`, `scripts/package.json` | missing | TypeScript tooling not in report |
| `.github/workflows/*.yaml` | missing | CI/CD pipelines not in report |
| `e2e/*.test.sh` | source-of-truth | E2E test counts |
| `agent/core/*.yml` | source-of-truth | Core config files |

## Key Findings

### Finding 1 — §1: "57 completed milestones" is wrong (HIGH)

**Report says**: "Version 6.12.1 ships 57 completed milestones"  
**Actual**: 56 of 58 milestones completed (M54 active at 30%, M58 planned at 0%)  

**Impact**: Misrepresents project completeness by 1. Fix to "56 of 58 completed milestones (97%)".

### Finding 2 — §1: "11 months of development" is wrong (MEDIUM)

**Report says**: "11 months of development (Feb–Jun 2026)"  
**Actual**: February 2026 to June 2026 = 5 months  

**Impact**: Overstates development timeline by 6 months. Fix to "5 months".

### Finding 3 — §4.4: Category count header mismatches table (MEDIUM)

**Report says**: "§4.4 Project Registry Commands (9)"  
**Table has**: 8 commands (project-create, list, set, info, update, remove, sync-projects, restore-projects)  

**Impact**: Internal inconsistency. Fix header to (8).

### Finding 4 — §5.1: Script line counts are stale (LOW)

| Script | Report | Actual | Delta |
|--------|--------|--------|-------|
| `acp.common.sh` | ~1537 | 1829 | +292 lines (+19%) |
| `acp.yaml-parser.sh` | ~549 | 1058 | +509 lines (+93%) |

**Impact**: Both scripts have grown significantly since the counts were last updated. Fix to current line counts.

### Finding 5 — §10: "91+ assertions" is imprecise; "26 other suites" is vague (MEDIUM)

**Report says**: "91+ assertions on core suites" and "26 other suites"  
**Actual**: Review = 49, Integrity = 26, Recurring Tasks = 16. Total = 91. Plus 37 other suites with varying assertion counts.

**Impact**: Vague metrics erode credibility. Fix to exact counts and list all suites.

### Finding 6 — Missing: TypeScript Tooling (§) (HIGH)

**Missing from report**:
- `scripts/acp-validate.ts` — TypeScript validation engine (placeholder detection, frontmatter, parity)
- `scripts/acp-dispatch.ts` — Task dispatcher with routing and model selection
- `scripts/package.json` — Node.js project configuration
- `scripts/PRD-MAIN.md` — Product requirements document

**Impact**: These are production tools that exist in the repo but are undocumented. Add as new section.

### Finding 7 — Missing: CI/CD Pipelines (§) (HIGH)

**Missing from report**:
- `.github/workflows/ci.yaml` — Validate, shellcheck, E2E smoke on all branches
- `.github/workflows/e2e-tests.yaml` — Parallel E2E on ubuntu + macos
- `.github/workflows/benchmark.yaml` — On-demand benchmark runs

**Impact**: CI/CD is a core infrastructure capability. Add as new section.

### Finding 8 — Missing: Installation & Bootstrap System (§) (MEDIUM)

**Missing from report**:
- `scripts/acp-bootstrap.sh` — 8-step self-healing bootstrap installer
- `agent/scripts/acp.install.sh` — Core installation script
- `agent/scripts/acp.uninstall.sh` — Clean uninstall
- `scripts/QUICKSTART.md` — Quick start guide

**Impact**: The installation system is the first thing users touch. Add as new section.

### Finding 9 — Missing: Directory Structure Overview (§) (MEDIUM)

**Missing from report**: The 20+ `agent/` subdirectories are not inventoried — `benchmarks/`, `design/`, `drafts/`, `feedback/`, `tasks/`, `templates/`, `sessions/`, `index/`, `configurables/`, `preferences/`, `artifacts/`, `clarifications/`, `specs/`, `routing/tasks/`

**Impact**: Without a directory map, new contributors can't navigate the project. Add as new section or expand §15.

### Finding 10 — §4.10: `acp.dispatch` mis-categorized (LOW)

**Report says**: §4.10 "Visualization & Reporting" includes `acp.dispatch`  
**Actual**: `acp.dispatch` is a task dispatcher that routes work to executors — not visualization  

**Impact**: Category confusion. Move to Workflow (§4.1) or create a Task Dispatch section.

### Finding 11 — Missing command: `acp.task` not categorized (LOW)

**Report lists**: 69 commands across 12 categories  
**Missing from any category**: `acp.task` (task management/status)  

**Impact**: One command unaccounted for. Add to appropriate category.

### Finding 12 — Missing: `/acp-install` as separate from `acp.install` (LOW)

**Report**: `acp.install` is listed under Package Management  
**Actual**: `acp.install` is the core framework installer, not a package tool. It belongs in an Installation section.

**Impact**: Category confusion. The install command installs the ACP framework itself, not packages.

## Code Pointers

| Location | Issue |
|----------|-------|
| `design-spec-acp-enhanced-features-v1.0.md:18` | "57 completed" → should be "56 of 58" |
| `design-spec-acp-enhanced-features-v1.0.md:18` | "11 months" → should be "5 months" |
| `design-spec-acp-enhanced-features-v1.0.md:122` | "§4.4 (9)" → should be "(8)" |
| `design-spec-acp-enhanced-features-v1.0.md:165` | "~1537 lines" → 1829 actual |
| `design-spec-acp-enhanced-features-v1.0.md:166` | "~549 lines" → 1058 actual |
| `design-spec-acp-enhanced-features-v1.0.md:282` | "91+ assertions" → exact counts needed |
| `scripts/acp-validate.ts:1` | Not in report — TypeScript tooling |
| `.github/workflows/ci.yaml:1` | Not in report — CI/CD |
| `scripts/acp-bootstrap.sh:1` | Not in report — installation |
| `agent/commands/acp.dispatch.md:1` | Mis-categorized in §4.10 |
| `agent/commands/acp.task.md:1` | Not in any category |

## Recommendations

### P0 — Fix before publishing v2.0

1. **Finding 1**: Fix milestone count to "56 of 58"
2. **Finding 2**: Fix development duration to "5 months"
3. **Finding 6**: Add §TypeScript Tooling section
4. **Finding 7**: Add §CI/CD Pipelines section

### P1 — Fix for accuracy

5. **Finding 3**: Fix §4.4 header count to (8)
6. **Finding 5**: Replace "91+" with exact counts; list all 40 test suites in §10
7. **Finding 4**: Update script line counts

### P2 — Nice improvements

8. **Finding 8**: Add §Installation & Bootstrap section
9. **Finding 9**: Add directory structure overview to §15
10. **Finding 10**: Re-categorize `acp.dispatch` to Workflow
11. **Finding 11**: Add `acp.task` to appropriate category
12. **Finding 12**: Separate core install from package management

## Phase Summary

| Category | Findings | Highest Severity |
|----------|----------|-----------------|
| Numerical Inaccuracies | 5 (F1, F2, F3, F4, F5) | HIGH |
| Missing Subsystems | 4 (F6, F7, F8, F9) | HIGH |
| Categorization Errors | 3 (F10, F11, F12) | LOW |
| **Total** | **12** | **HIGH** |

## Readiness Verdict

**UPDATE RECOMMENDED** — v1.0 is a solid first pass but contains 5 factual inaccuracies and omits 4 significant subsystems. A v2.0 update incorporating these 12 findings will produce a production-quality feature specification suitable for external distribution.

---

*Audit-063 | 2026-06-09 | Detail review of design-spec-acp-enhanced-features-v1.0.md*
