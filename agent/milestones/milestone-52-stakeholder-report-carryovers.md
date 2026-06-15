# Milestone 52 — Stakeholder Report Command + Carryover Resolution (v6.9.5)

**Status**: Completed  
**Priority**: P1  
**Started**: null  
**Target**: 2026-06-06  
**Estimated**: 0.5 day  
**Progress**: 0% (0/7 tasks)

---

## Goal

Integrate `/acp-stakeholder-report` v1.1.0 from FIFOZ feedback-006 into ACP Enhanced. Resolve all 4 pending audit-044 carryovers. Document the five-tier reporting model.

**Source**: feedback-006 from FIFOZ (Rygan-Institute/FIFOZ), validated via audit-071 with a 1-page pilot exemplar.

---

## Background

### What `/acp-stakeholder-report` fills

| Gap | Current state | After M52 |
|-----|---------------|-----------|
| No weekly exec summary command | `/acp-report` too long (178 lines) | 1–2 page RAG summary |
| No RAG health indicator | Status buried in progress.yaml | Green/Amber/Red at top |
| No "decisions required" section | Blockers listed, no asks | Actionable stakeholder asks |
| Stakeholders sent wrong artifact | Purpose line said "stakeholders" | Clear distinction table |
| Audit-044 carryovers pending | 4 items deferred | All resolved |

### Five-tier reporting model (documented in M52)

```
progress.yaml + sessions.md
         │
         ├─► /acp-status              Console (~20 lines)     Developer session
         ├─► /acp-stakeholder-report  1–2 pages, RAG          Weekly board/investor
         ├─► /acp-report              5–15 pages              Milestone archive / team
         ├─► /acp-design-spec         10–30 pages + diagrams  Per-milestone engineering
         └─► /acp-cost-report         1 page                  Weekly AI spend
```

---

## Deliverables

| Route | Task | Priority | Effort |
|-------|------|----------|--------|
| 117 | Port `acp.stakeholder-report.md` v1.1.0 from feedback → `agent/commands/` | P0 | Low |
| 118 | Wrappers (`.github/prompts/` + `.opencode/`) + `package.yaml` entry + template to `agent/templates/` | P0 | Low |
| 119 | `routing.yml` command_suggestions + `taxonomy.yml` task_type + cross-links in `acp.report.md`, `acp.cost-report.md`, `acp.status.md` | P0 | Low |
| 120 | E2E smoke test — verifies RAG/blocker rule, anti-patterns, metrics ≤4, email subject, artefact naming | P1 | Medium |
| 121 | Five-tier reporting model documentation in README + wiki | P1 | Low |
| 122 | Resolve 4 audit-044 carryovers: index entry, domain.yml, README design-spec mention, P3 deferred tracking | P1 | Low |
| 123 | Version bump to 6.9.5 + CHANGELOG + sync docs | P2 | Low |

---

## Success Criteria

1. **Command available**: `/acp-stakeholder-report` executes from fresh install
2. **RAG rule enforced**: Cannot be Green when `current_blockers` non-empty (documented + E2E-testable)
3. **Output ≤2 pages**: From progress.yaml, filtered to business outcomes
4. **Five-tier model documented**: In README and/or wiki, with artefact naming table
5. **All audit-044 carryovers resolved**: Index entry, domain.yml, README, P3 deferred
6. **E2E test passes**: 12+ assertions on macOS + Linux

---

## Industry Standards Basis

| Standard | What we apply |
|----------|--------------|
| **PMI weekly status** | RAG indicator, accomplishments, forward look, risks with severity |
| **ISO/IEC/IEEE 42010** | Stakeholder viewpoint — separate from developer/progress viewpoint |
| **Executive communication** | ≤300 words summary, no task IDs, outcome-focused language |
| **Email best practice** | Suggested subject line with RAG + date for mobile scanning |

---

## Dependencies

- feedback-006 + `acp.stakeholder-report.md` v1.1.0 + `stakeholder-report.template.md`
- audit-071 (v1.0.0 → v1.1.0 hardening)
- audit-044 carryovers (G-044-03, G-044-06, G-044-07, DEFER-044-01)
- M50 pattern (command integration template)

---

## Notes

- v1.1.0 includes 11 audit-071 changes — ship the hardened version
- Auto-amber RAG rule: `current_blockers` non-empty → minimum Amber
- Metrics hard limit: ≤4 rows (enforced in command doc + E2E test)
- Anti-patterns: no task IDs, no ACP commands, no emoji task logs in accomplishments
- Artefact naming: `stakeholder-report-YYYY-MM-DD.md` (not `report-*-stakeholder-*.md`)
- Paired with M50's design-spec as the "FIFOZ reporting pack"
