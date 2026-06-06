---
id: route-119
title: "Framework integration: routing.yml + taxonomy.yml + cross-links"
task_type: yaml-schema
milestone: M52
complexity: low
executor: copilot
context_required:
  - agent/core/routing.yml
  - agent/routing/taxonomy.yml
  - agent/commands/acp.report.md
  - agent/commands/acp.cost-report.md
  - agent/commands/acp.status.md
  - agent/feedback/feedback-006-acp-stakeholder-report-command-upstream.md
files_affected:
  - agent/core/routing.yml
  - agent/routing/taxonomy.yml
  - agent/commands/acp.report.md
  - agent/commands/acp.cost-report.md
  - agent/commands/acp.status.md
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 119: Framework Integration — routing.yml + taxonomy.yml + Cross-links

## Objective

Register `/acp-stakeholder-report` in the framework's routing and taxonomy systems, and add cross-references in peer commands.

## Context

Per feedback-006 §5, the command needs:
- `routing.yml` command_suggestions (including cross-refs from acp-report, acp-status, acp-cost-report)
- `taxonomy.yml` task_type for dispatch
- Cross-links in peer commands to prevent confusion with `/acp-report`

## Changes

### 1. `agent/core/routing.yml` — Add `acp-stakeholder-report` block

Insert alphabetically after `acp-status`:

```yaml
  acp-stakeholder-report:
    - acp-report: "Full archive when stakeholders need detail"
    - acp-update: "Refresh progress.yaml before reporting"
    - acp-cost-report: "Pair on Fridays — AI spend"
    - acp-commit: "Save session after reporting phase"
```

### 2. `agent/core/routing.yml` — Cross-references in existing entries

Add to `acp-report`:
```yaml
    - acp-stakeholder-report: "Weekly executive summary (not this full report)"
```

Add to `acp-status`:
```yaml
    - acp-stakeholder-report: "Friday stakeholder update"
```

Add to `acp-cost-report`:
```yaml
    - acp-stakeholder-report: "Pair on Fridays — exec summary + AI spend"
```

### 3. `agent/routing/taxonomy.yml` — Add `stakeholder-report` task_type

Insert after `design-spec`:

```yaml
  stakeholder-report:
    executor: copilot
    complexity: low
    context_required: [commands/acp.stakeholder-report.md, progress.yaml]
    tokens_est: 5000
    skill: crosscut
    description: >
      Generating weekly/monthly stakeholder progress summaries with RAG health
      indicators. Reads progress.yaml, filters to business outcomes (no task
      IDs), produces 1-2 page executive summary.
```

### 4. Cross-links in peer commands

**`acp.report.md`** — Add to Related Commands AND update Example 3:

**Related Commands addition:**
```markdown
- [`/acp-stakeholder-report`](acp.stakeholder-report.md) — Weekly executive summary (not this full report)
```

**Example 3 update (line 338):** Change from:
```markdown
### Example 3: Stakeholder Update
**Context**: Monthly update for stakeholders  
**Invocation**: `/acp-report`  
**Result**: Executive-friendly report with high-level progress...
```
To:
```markdown
### Example 3: Stakeholder Update
**Context**: Monthly update for stakeholders  
**Invocation**: `/acp-stakeholder-report`  
**Result**: 1–2 page RAG summary with decisions required, ≤4 KPIs.
            For full detail, use `/acp-report`.
```
This is a specific feedback-006 Phase B requirement — the example must
point to the correct command to prevent agents from sending the wrong artifact.

**`acp.cost-report.md`** — Add to Related Commands:
```markdown
- [`/acp-stakeholder-report`](acp.stakeholder-report.md) — Pair on Fridays — exec summary + AI spend
```

**`acp.status.md`** — Add to Related Commands or command header:
```markdown
- [`/acp-stakeholder-report`](acp.stakeholder-report.md) — Friday stakeholder update from progress.yaml
```

## Verification

- [ ] `acp-stakeholder-report` entry in `routing.yml → command_suggestions`
- [ ] Cross-refs in `acp-report`, `acp-status`, `acp-cost-report` suggestions
- [ ] `stakeholder-report` entry in `taxonomy.yml → task_types`
- [ ] Cross-links in `acp.report.md` Related Commands
- [ ] Cross-links in `acp.cost-report.md` Related Commands
- [ ] Cross-links in `acp.status.md` Related Commands or header
- [ ] YAML syntax valid (no duplicate keys, correct indentation)
