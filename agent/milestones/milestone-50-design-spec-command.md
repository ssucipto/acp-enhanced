# Milestone 50 — Design-Spec Command Integration (v6.9.3)

**Status**: Completed  
**Priority**: P1  
**Started**: null  
**Target**: 2026-06-06  
**Estimated**: 0.5 day  
**Progress**: 0% (0/7 tasks)

---

## Goal

Integrate the `/acp-design-spec` command (v1.1.0) from upstream feedback-005 into the ACP Enhanced framework distribution. The command generates structured Application Interface & Data-Flow Design Specifications from the live codebase — a documentation artifact type for QA matrices, onboarding, and staging sign-off.

**Source**: feedback-005 from FIFOZ (Rygan-Institute/FIFOZ), validated via audit-070 with a 731-line, 12-diagram production exemplar (M15 pay-profile spine v2.1).

---

## Background

### What `/acp-design-spec` fills

| Gap | Current state | After M50 |
|-----|---------------|-----------|
| No command for interface / data-flow specs | Agents improvised structure | Standard 19-section template |
| `/acp-design-create` targets planning docs | Wrong artifact for "what exists" inventory | Clear distinction table |
| `/acp-report` is progress-focused | Stakeholders confuse with design specs | Different output category |
| No Mermaid-heavy spec command | Diagrams ad-hoc, no standards mapping | arc42 + C4 + IEEE 1016 + ISO 42010 |

### Command positioning

```
/acp-design-create  →  agent/design/     →  PLAN (what to build)
/acp-design-spec   →  agent/reports/    →  INVENTORY (what exists, how data flows)
/acp-report        →  agent/reports/    →  PROGRESS (milestone/task status)
/acp-audit         →  agent/reports/    →  INVESTIGATE (deep dive)
```

---

## Deliverables

| Route | Task | Priority | Effort |
|-------|------|----------|--------|
| 106 | Port `acp.design-spec.md` v1.1.0 from feedback to `agent/commands/` | P0 | Low |
| 107 | Add prompt/opencode wrappers + `package.yaml` entry | P0 | Low |
| 108 | Create `agent/templates/` directory + ship `design-spec.template.md` | P1 | Low |
| 109 | Create E2E smoke test `e2e/acp.design-spec.test.sh` | P1 | Medium |
| 110 | Add `command_suggestions` in `routing.yml` + `design-spec` task_type in `taxonomy.yml` | P1 | Low |
| 111 | Cross-link in `acp.report.md` + `acp.design-create.md` Related Commands | P2 | Low |
| 112 | Version bump to 6.9.3 + CHANGELOG entry | P2 | Low |

---

## Success Criteria

1. **Command available**: `/acp-design-spec` executes from fresh `acp-package-install` projects
2. **Command documented**: Triple-file architecture complete (command + prompt + opencode wrapper)
3. **Template ships**: `agent/templates/design-spec.template.md` exists with stable 19-section structure
4. **E2E tested**: Smoke test passes on macOS + Linux CI — verifies directive header, steps, verification checklist, report structure
5. **Framework integrated**: `routing.yml` command_suggestions, `taxonomy.yml` task_type, cross-links in peer commands
6. **Version bumped**: All 8 version-bearing files updated to 6.9.3

---

## Dependencies

- feedback-005 (upstream command + audit-070 + exemplar)
- upstream integration runbook (`agent/patterns/local.upstream-integration-runbook.md`)
- command naming convention (`agent/patterns/local.command-naming-convention.md`)
- E2E testing pattern (`agent/patterns/local.e2e-testing.md`)

---

## Notes

- The command is **stack-agnostic** — detects UI/store/API roots; FIFOZ paths removed
- Industry standards: arc42 §1–8, §11–12; C4 L1–L3; IEEE 1016; ISO 42010; DFD L0–L2
- P3 items (Visualizer preset + exemplar) deferred to later milestone
- No shell scripts needed (pure agent directive command)
