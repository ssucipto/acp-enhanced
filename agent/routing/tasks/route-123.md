---
id: route-123
title: "Version bump to 6.9.5 + CHANGELOG + sync docs"
task_type: changelog-update
milestone: M52
complexity: low
executor: copilot
context_required:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
  - package.yaml
files_affected:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
  - package.yaml
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 123: Version Bump 6.9.3 → 6.9.5 + CHANGELOG

## Objective

Bump version to 6.9.5 (skip 6.9.4 — used by M51 bootstrap fix), update CHANGELOG, sync all docs.

## Context

M52 adds a new command (`/acp-stakeholder-report`), documentation (five-tier model), and resolves 4 carryovers. This is a minor version bump per semver (new backwards-compatible feature).

Version: 6.9.3 → 6.9.5 (skip 6.9.4 — allocated to M51 bootstrap fix in CHANGELOG)

## Changes

### 1. Version-bearing files

Bump `6.9.3` → `6.9.5` in:
- `agent/progress.yaml`
- `agent/core/identity.yml`
- `AGENTS.md`
- `README.md` (badge)
- `IP_REGISTER.md`
- `package.yaml`
- `scripts/PRD-MAIN.md`

### 2. CHANGELOG entry

```markdown
## [6.9.5] — 2026-06-06

### New Commands (M52 — Stakeholder Report + Carryovers)
- **`/acp-stakeholder-report`** — Generate concise weekly/monthly stakeholder progress summaries with RAG health indicator, ≤300-word executive summary, decisions required, and 2–4 KPI metrics. v1.1.0 hardened by audit-071 from FIFOZ production use.

### Added
- Five-tier reporting model documented in README (status → stakeholder → report → design-spec → cost-report)
- `agent/templates/stakeholder-report.template.md` — 9-section output template
- `e2e/acp.stakeholder-report.test.sh` — 14-assertion smoke test
- `routing.yml` command_suggestions for acp-stakeholder-report
- `taxonomy.yml` stakeholder-report task_type
- Cross-links in acp.report.md, acp.cost-report.md, acp.status.md

### Fixed
- Audit-044 carryovers resolved: index entry (G-044-03), domain.yml (G-044-06), README design-spec mention (G-044-07), P3 deferred tracking (DEFER-044-01)
```

### 3. IP_REGISTER milestone entry

Add M52 entry to the milestone register table.

## Verification

- [ ] All version-bearing files show `6.9.5`
- [ ] CHANGELOG `[6.9.5]` entry complete
- [ ] IP_REGISTER M52 entry added
- [ ] `/acp-validate` version consistency check passes
- [ ] M52 marked complete in progress.yaml
