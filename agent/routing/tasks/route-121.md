---
id: route-121
title: "Five-tier reporting model documentation in README + wiki"
task_type: documentation-sync
milestone: M52
complexity: low
executor: copilot
context_required:
  - README.md
  - agent/wiki/domain.yml
  - agent/feedback/feedback-006-acp-stakeholder-report-command-upstream.md
files_affected:
  - README.md
  - agent/wiki/domain.yml
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 121: Five-Tier Reporting Model Documentation

## Objective

Document the five-tier reporting model in README and wiki so users understand which command produces which artifact for which audience.

## Context

Per feedback-006 §2, ACP Enhanced has 5 report types but users conflate them. The five-tier model should be documented prominently. The distinction between `stakeholder-report-*.md` (weekly exec), `report-*.md` (full archive), and `roadmap-brief-*.md` (one-off planning) must be clear.

## Changes

### 1. README.md — Add "Reporting Model" section

Add after the recent enhancements section:

```markdown
### Five-Tier Reporting Model

ACP Enhanced provides five report types, each for a different audience:

| Tier | Command | Output | Audience | Length |
|------|---------|--------|----------|--------|
| 1 | `/acp-status` | Console snapshot | Developer (session) | ~20 lines |
| 2 | `/acp-stakeholder-report` | Weekly exec summary (RAG) | Board, investors, PM | 1–2 pages |
| 3 | `/acp-report` | Full project archive | Team, agents, records | 5–15 pages |
| 4 | `/acp-design-spec` | Interface & data-flow spec | Engineering, QA | 10–30 pages |
| 5 | `/acp-cost-report` | AI token spend | Dev / ops | ~1 page |

**Artefact naming**:
- `stakeholder-report-YYYY-MM-DD.md` — weekly exec summary (this command)
- `report-YYYY-MM-DD.md` — full archive (`/acp-report`)
- `roadmap-brief-{subject}-{date}.md` — one-off planning (not recurring)
```

### 2. `agent/wiki/domain.yml` — Add reporting commands section

Add or update the commands taxonomy section with the five-tier model entries.

## Verification

- [ ] Five-tier model section in README
- [ ] Artefact naming table present
- [ ] All 5 commands listed with audience and length
- [ ] domain.yml updated with reporting command entries
