# Milestone 57: Recurring Tasks Scheduler + Pre-Commit Hook Framework

**Milestone**: M57  
**Version Target**: 6.12.1  
**Priority**: MEDIUM  
**Status**: completed  
**Started**: 2026-06-08  
**Target**: 2026-06-08  
**Estimated Weeks**: 0.5–1  
**Estimated Hours**: ~6  
**Depends On**: M56 (acp-integrity v1.0 scripts must exist for pre-commit hooks)  
**Source**: feedback-007 §4.2–4.3, §5.2; audit-053 GAP-053-04; audit-054 deferred items  

---

## 1. Goal

Add a recurring tasks scheduling system to ACP Enhanced that ensures periodic maintenance reviews are not forgotten. This is the operational backbone that makes `/acp-review` and `/acp-integrity` actually run on schedule — not just exist as commands.

Three components:
1. **Schema** — `progress.yaml` `recurring_tasks:` block defining what reviews exist and when they're due
2. **Protocol** — AGENTS.md Step 4.5 surface-check that warns at session start when reviews are overdue
3. **Hooks** — `constraints.yml` `hooks:` block enabling pre-commit integrity scans

## 2. Industry Standards

| Standard | Relevance |
|----------|-----------|
| NIST SP 800-53 Rev 5 — SI-4 | Scheduled integrity scans are a monitoring control |
| OWASP SAMM v2 — Operational Security | Regular security review cadence is Level 2 maturity |
| CIS Control 18 | Scheduled integrity scans = automated testing cadence |
| ISO 27001:2022 — A.8.8 | Scheduled vulnerability scanning with tracked remediation |

> **Design principle**: The scheduler enforces *cadence*, not *content*. It tracks WHAT should run and WHEN — it does not execute tasks itself.

## 3. Architecture

```
progress.yaml                  AGENTS.md Step 4.5           constraints.yml
┌──────────────────┐           ┌──────────────────┐        ┌────────────────┐
│ recurring_tasks: │──read──→  │ Session-start     │        │ hooks:         │
│  - id: weekly    │           │ overdue check     │        │  pre_commit:   │
│    command: ...  │           │ ⏰ Overdue: weekly │        │    rule_file   │
│    next_due: ... │           │  integrity scan   │        │    _audit: true│
└──────────────────┘           └──────────────────┘        └───────┬────────┘
                                                                    │
                                                                    ▼
                                                        git commit hook fires
                                                        /acp-integrity --fast --ci
```

### 3.1 Schema: `recurring_tasks:` Block

```yaml
# agent/progress.yaml — new top-level block after milestones

recurring_tasks:
  - id: weekly-code-review
    command: /acp-review --report --carryover
    frequency: weekly
    executor: copilot
    last_run: 2026-06-01
    next_due: 2026-06-08
    status: overdue              # current | overdue | disabled
    description: "Weekly code quality review with carryover tracking"

  - id: weekly-integrity-scan
    command: /acp-integrity --self --report --carryover
    frequency: weekly
    executor: copilot
    last_run: 2026-06-08
    next_due: 2026-06-15
    status: current
    description: "Weekly ACP framework integrity scan"

  - id: pre-commit-rule-audit
    command: /acp-integrity --fast --ci
    trigger: on-commit              # special: fires via git hook, not schedule
    executor: deepseek-v4-pro
    last_run: null
    next_due: null
    status: current
    description: "Pre-commit ACP rule file scan for Unicode injection"

  - id: monthly-dependency-audit
    command: /acp-integrity --rules dependencies
    frequency: monthly
    executor: deepseek-v4-pro
    last_run: 2026-06-01
    next_due: 2026-07-01
    status: current
    description: "Monthly dependency and supply chain audit"

  - id: quarterly-deep-scan
    command: /acp-integrity --rules taint-flow,memory --report
    frequency: quarterly
    executor: claude-sonnet
    last_run: 2026-04-01
    next_due: 2026-07-01
    status: current
    description: "Quarterly deep semantic integrity scan (deferred to M58)"
```

### 3.2 AGENTS.md Step 4.5 — Session-Start Overdue Check

Inserted after Step 4 (Working Memory) in Context Loading Protocol:

```markdown
### Step 4.5 — Scheduled Review Due Check (conditional)

Read agent/progress.yaml → recurring_tasks.
If any task has status: overdue OR next_due <= today:
  Output before starting any other task:
  ⏰ [ACP] Scheduled review(s) overdue:
     [task_id]: [command] — last run [date], due [date]
  Recommend running before unrelated work.
  Developer may defer: note in session entry as deferred with reason.

If all tasks are current:
  (Silent — do not output to avoid noise.)
```

### 3.3 `constraints.yml` — Pre-Commit Hooks

```yaml
# agent/core/constraints.yml — new hooks: block

hooks:
  pre_commit_rule_file_audit: true      # /acp-integrity --fast --ci on commit
  pre_commit_integrity_phase1: false    # Opt-in full Phase 1 scan
  ci_npm_ignore_scripts: true           # Enforce --ignore-scripts in CI
```

## 4. Deliverables

| # | Deliverable | Route |
|---|-------------|-------|
| 1 | `progress.yaml` + `progress.template.yaml` — recurring_tasks schema | 150 |
| 2 | AGENTS.md Step 4.5 + copilot-instructions sync | 151 |
| 3 | `constraints.yml` hooks + `progress.schema.yaml` | 152 |
| 4 | `acp.validate.md` — recurring_tasks validation step | 153 |
| 5 | E2E test + cross-links + version bump 6.12.1 + CHANGELOG | 154 |

## 5. Tasks (5 Routes, ~6h)

| Route | Task | Hours | Depends On |
|-------|------|-------|------------|
| 150 | M57-001 — progress.yaml + template recurring_tasks schema | 1 | — |
| 151 | M57-002 — AGENTS.md Step 4.5 + copilot-instructions sync | 1 | — |
| 152 | M57-003 — constraints.yml hooks + progress.schema.yaml | 1 | — |
| 153 | M57-004 — acp.validate.md recurring_tasks validation | 0.5 | 150, 152 |
| 154 | M57-005 — E2E test + cross-links + version bump 6.12.1 + CHANGELOG | 2.5 | 150–153 |

## 6. E2E Test (12 Assertions)

### Structural (5)
1. `progress.yaml` has `recurring_tasks:` block with ≥5 entries
2. `progress.template.yaml` has `recurring_tasks:` section
3. AGENTS.md contains "Step 4.5" section
4. `constraints.yml` has `hooks:` block with `pre_commit_rule_file_audit: true`
5. `progress.schema.yaml` validates recurring_tasks fields

### Behavioral (7)
6. Schema: all 5 default tasks have required fields (id, command, frequency/trigger, executor, last_run, next_due, status, description)
7. Frequency validation: all entries have valid frequency or trigger values
8. Status validation: all entries have valid status values
9. Command reference: every `command` starts with `/acp-`
10. Executor validation: every `executor` exists in taxonomy.yml
11. Overdue simulation: task with past next_due triggers overdue detection
12. Disabled exclusion: task with `status: disabled` excluded from overdue count

## 7. Verification Checklist

- [ ] `progress.yaml` has `recurring_tasks:` block with 5 default tasks
- [ ] `progress.template.yaml` includes `recurring_tasks:` section
- [ ] AGENTS.md Step 4.5 exists between Step 4 and Step 5
- [ ] `.github/copilot-instructions.md` synced with AGENTS.md
- [ ] `constraints.yml` has `hooks:` block
- [ ] E2E test: 12/12 assertions pass
- [ ] Overdue tasks surface at session start (⏰ emoji)
- [ ] Current tasks produce no output (silent)
- [ ] Disabled tasks excluded from overdue checks
- [ ] `frequency` and `trigger` fields mutually exclusive (one required)
- [ ] Executor values cross-validated against taxonomy.yml
- [ ] Version bumped to 6.12.1
- [ ] CHANGELOG entry (Keep a Changelog)
- [ ] `acp-validate` passes
- [ ] `acp-sync` run (wrapper parity + domain.yml counts)

## 8. Pre-Commit Hook Scope

> ⚠️ **Important**: `constraints.yml` `hooks:` is a **configuration** flag, not a hook implementation. ACP Enhanced is a framework, not a git hook manager. The `pre_commit_rule_file_audit: true` flag tells agents and CI pipelines that pre-commit scanning is expected. The actual hook mechanism (`.git/hooks/pre-commit`, Husky, or CI workflow step) is the developer's responsibility to wire up.

ACP provides the command (`/acp-integrity --fast --ci`). The developer provides the trigger.

## 9. Excluded

| Item | Reason |
|------|--------|
| Auto-execution of overdue tasks | Security boundary — agent must not autonomously run scans |
| Cron/OS scheduling | ACP is a framework, not a daemon |
| Visualizer integration | Separate milestone |

---

*Milestone 57 | ACP Enhanced v6.12.1 | feedback-007 + audit-053/054 | 2026-06-08*
