# Audit Report: M57 Implementation — Industry Standards & Best Practices Deep Dive

**Audit**: #062  
**Date**: 2026-06-08  
**Subject**: M57 Recurring Tasks Scheduler — post-implementation deep dive against industry standards, best practices, and milestone plan  

---

## Summary

M57 delivered a functional recurring tasks scheduler (5 default tasks, protocol integration, schema validation, E2E test). However, a deep comparison against the original milestone plan, industry standards (NIST SP 800-53, OWASP SAMM v2, ISO 27001:2022, CIS Controls), and software engineering best practices reveals **8 gaps** — 2 from plan-implementation divergence, 3 from industry standard non-compliance, and 3 from missing operational best practices. None are CRITICAL but 5 are HIGH severity for production readiness.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-57-recurring-tasks-scheduler.md` | milestone plan | Canonical specification — the "what should be" |
| `agent/progress.yaml` | implementation | Actual recurring_tasks block, 5 tasks |
| `agent/progress.template.yaml` | implementation | Template for new projects |
| `agent/core/constraints.yml` | implementation | Hooks block configuration |
| `agent/schemas/progress.schema.yaml` | implementation | Schema definition for recurring_tasks |
| `AGENTS.md` (line 98-112) | implementation | Step 4.5 protocol text |
| `CLAUDE.md` (line 137) | implementation | Step 4.5 sync |
| `.github/copilot-instructions.md` (line 137) | implementation | Step 4.5 sync |
| `agent/commands/acp.validate.md` (line 177-217) | implementation | Step 2d validation logic |
| `e2e/acp.recurring-tasks.test.sh` | implementation | E2E test, 16 assertions |
| `CHANGELOG.md` (line 10-26) | implementation | [6.12.1] release entry |

## Key Findings

### Finding 1 — Plan-Implementation: hooks block format diverged (HIGH)

**Milestone plan** (milestone-57 §3.3):
```yaml
hooks:
  pre_commit_rule_file_audit: true      # boolean flag
  pre_commit_integrity_phase1: false
  ci_npm_ignore_scripts: true
```

**Implementation** (constraints.yml):
```yaml
hooks:
  pre_commit:
    - task_id: pre-commit-rule-audit
      description: "Scan ACP rule files for Unicode injection before commit"
```

**Analysis**: The plan called for 3 boolean flags; the implementation has a single array entry with task binding. The array approach is actually *better* for extensibility (arbitrary pre-commit tasks vs hardcoded flags), and correctly uses `task_id` to reference existing recurring_tasks. However, 2 of 3 planned hooks were dropped (`pre_commit_integrity_phase1`, `ci_npm_ignore_scripts`).

**Impact**: Missing CI npm safety enforcement at config level. The `ci_npm_ignore_scripts` flag was a defense-in-depth measure against npm postinstall script attacks (OWASP Top 10:2025 — A06:2021 Vulnerable and Outdated Components).

**Recommendation**: Document the format change as an architectural decision (ADR). Add the 2 dropped hooks if applicable.

### Finding 2 — Plan-Implementation: 3 verification checklist items unverified (MEDIUM)

Milestone plan §7 lists 15 verification items. 12 are confirmed complete. 3 were **not verified**:

| Item | Plan Expectation | Implementation Status |
|------|-----------------|----------------------|
| *Disabled tasks excluded from overdue checks* | `status: disabled` tasks skipped | **Not implemented** — Step 4.5 only checks `status: overdue` and `next_due`, no disabled exclusion |
| *frequency and trigger mutually exclusive (one required)* | XOR validation | **Partial** — validate.md Step 2d only checks "at least one present", doesn't enforce mutual exclusivity |
| *Executor values cross-validated against taxonomy.yml* | Validate executor exists in taxonomy | **Not implemented** — no executor cross-validation in schema, validate, or E2E |

**Impact**: A task could have both `frequency: weekly` and `trigger: on-commit` — behavior undefined. A misspelled executor would silently fail at runtime.

### Finding 3 — Industry: Manual scheduler, not automated (NIST SP 800-53 SI-4) (HIGH)

**Standard**: NIST SP 800-53 Rev 5 — SI-4 "System Monitoring" requires *automated* mechanisms for security control monitoring.

**Current state**: The scheduler is purely informational — human-readable `next_due` dates + session-start output. No automated script execution, no CI/CD integration for schedule-based scans, no webhook trigger.

**Gap**: SI-4 requires "automated tools" and "near real-time" monitoring. A manual reminder at session start is Level 1 maturity (ad-hoc); SI-4 expects Level 3 (systematic, repeatable).

**Mitigation**: The milestone doc (§8) explicitly states "ACP Enhanced is a framework, not a git hook manager" — this is a deliberate design choice. The gap is acceptable for v1.0 but should be documented as known limitation.

### Finding 4 — Industry: No findings database integration (ISO 27001 A.8.8) (HIGH)

**Standard**: ISO 27001:2022 — A.8.8 "Technical vulnerability management" requires "timely remedial action" and tracking of vulnerability status from discovery to closure.

**Current state**: Recurring tasks track WHAT to run and WHEN, but not WHAT WAS FOUND. There's no integration with:
- `/acp-review` findings output
- `/acp-integrity` scan results
- `agent/memory/audit-carryovers.md` carryover tracking

A weekly integrity scan could find the same Unicode byte month after month without automated tracking.

**Gap**: No feedback loop from scan results → recurring task status. Without this, the scheduler is a reminder system, not a vulnerability management system.

### Finding 5 — Industry: No remediation SLA per severity (CIS Control 7, NIST SI-2) (MEDIUM)

**Standard**: CIS Control 7 — "Continuous Vulnerability Management" requires remediation timeframes by severity. NIST SP 800-53 SI-2 — "Flaw Remediation" requires tracking time-to-fix.

**Current state**: All 5 tasks have the same `status: current` with date-based.next_due. No differentiation between:
- CRITICAL finding remediation (should be <24h)
- HIGH finding remediation (should be <7 days)
- MEDIUM finding remediation (should be <30 days)

**Gap**: The scheduler enforces *cadence* but not *urgency*. A monthly scan that finds a CRITICAL supply chain issue has the same priority as a routine weekly review.

### Finding 6 — Practice: No automated next_due calculation (HIGH)

**Current state**: `next_due` is a hardcoded date. After running a task, the developer must manually update `last_run` and `next_due`. This creates:
1. **Drift risk**: Forgetting to update dates makes tasks appear current when overdue
2. **No auto-increment**: Running a weekly task doesn't push.next_due forward 7 days
3. **Human error**: Manual date calculation introduces errors (month boundaries, holidays)

**Best practice**: Tools like cron, systemd timers, and GitHub Actions schedules all auto-calculate next execution. An ACP framework should at minimum provide a `--complete` flag that auto-sets `last_run = today` and `next_due = today + frequency`.

### Finding 7 — Practice: No grace period for near-miss tasks (LOW)

**Current state**: Step 4.5 checks `next_due <= today`. A task due today but not yet run triggers an overdue warning immediately at session start.

**Best practice**: Many scheduling systems (e.g., Nagios, PagerDuty, cron with retry) include a grace period. A task due within a configurable window (e.g., within 24h of due date) should show as "⚠️ upcoming" rather than "⏰ overdue".

**Impact**: False-alarm fatigue — if every session starts with ⏰ warnings for tasks due "today but not yet run," developers will learn to ignore them.

### Finding 8 — Practice: No reference git hook implementation (MEDIUM)

**Current state**: The `pre-commit-rule-audit` task has `trigger: on-commit` but there's no reference `.git/hooks/pre-commit` script that demonstrates how to wire it up.

**Milestone doc §8**: "The actual hook mechanism (.git/hooks/pre-commit, Husky, or CI workflow step) is the developer's responsibility to wire up."

**Gap**: Without a reference implementation, the feature is documentation-only. A 5-line example hook in the milestone doc or a `agent/examples/pre-commit-hook.sh` would bridge the gap between "ACP provides the command" and "developer provides the trigger."

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/milestones/milestone-57-recurring-tasks-scheduler.md:126-130` | Planned hooks vs boolean flags |
| `agent/core/constraints.yml:28-33` | Implemented hooks as array with task_id binding |
| `AGENTS.md:98-112` | Step 4.5 — overdue check logic, no disabled exclusion |
| `agent/commands/acp.validate.md:177-217` | Step 2d — schema validation, no executor cross-check |
| `agent/progress.yaml:6307-6344` | Actual recurring_tasks data with hardcoded dates |
| `e2e/acp.recurring-tasks.test.sh:46-94` | T9-T10 — count assertions, no behavioral validation |
| `agent/schemas/progress.schema.yaml:282-320` | recurring_tasks schema — no frequency/trigger XOR constraint |

## Industry Standards Cross-Reference

| Standard | Clause | Requirement | M57 Status | Gap |
|----------|--------|-------------|-----------|-----|
| NIST SP 800-53 Rev 5 | SI-4 | Automated system monitoring | ⚠️ Manual | Finding 3 |
| NIST SP 800-53 Rev 5 | SI-2 | Flaw remediation tracking + time-to-fix | ❌ Not tracked | Finding 5 |
| OWASP SAMM v2 | Operational Security L2 | Regular security review cadence | ✅ Cadence defined | Finding 4 (no results loop) |
| CIS Control 7 | 7.1 | Establish vulnerability management process | ⚠️ Process exists, no SLA | Finding 5 |
| CIS Control 18 | 18.1 | Establish penetration testing program | ✅ Quarterly scan mapped | Finding 3 (manual only) |
| ISO 27001:2022 | A.8.8 | Technical vulnerability management | ⚠️ Schedule only, no tracking | Finding 4 |
| ISO 27001:2022 | A.12.6 | Technical vulnerability management (ops) | ⚠️ Schedule only | Finding 4 |
| OWASP LLM Top 10 | LLM02:2025 | Insecure Output Handling | N/A | — |
| MITRE ATLAS | Reconnaissance | LLM-assisted codebase exploration | N/A | — |

## Recommendations

### P0 — Fix before M57 is considered GA (HIGH)

1. **Finding 6**: Add auto `next_due` calculation logic. Implement a `--complete` flag (or a small bash helper `acp.task-complete.sh`) that:
   - Accepts `task_id` and date
   - Sets `last_run = today`
   - Calculates `next_due = today + frequency` using simple date arithmetic
   - Updates `progress.yaml` atomically

2. **Finding 4**: Add a `deferred_findings:` field to recurring_tasks entries to capture scan output. At minimum, add a `last_findings_count:` field so the scheduler can detect "same finding count persists for N weeks = escalate."

### P1 — Should fix before next milestone (MEDIUM)

3. **Finding 2**: Close the 3 unchecked verification items:
   - Add `status: disabled` exclusion to Step 4.5
   - Add `frequency`/`trigger` XOR constraint to progress.schema.yaml
   - Add executor cross-validation step to validate.md Step 2d

4. **Finding 1**: Document the hooks format change as an ADR. Add `ci_npm_ignore_scripts: true` to hooks if the CI workflow already enforces this.

5. **Finding 8**: Create `agent/examples/pre-commit-hook.sh` with a 5-line reference implementation showing how to wire `{acp-integrity --fast --ci}` into `.git/hooks/pre-commit`.

### P2 — Nice to have (LOW)

6. **Finding 7**: Add a grace period concept — tasks due within `gradient_hours: 24` (configurable) show "⚠️ upcoming" instead of "⏰ overdue".

7. **Finding 5**: Add optional `sla_hours:` field per task for time-to-fix tracking (deferred to M58 where semantic severity analysis exists).

## Phase Summary

| Category | Findings | Highest Severity |
|----------|----------|-----------------|
| Plan-Implementation Divergence | 2 (F1, F2) | HIGH |
| Industry Standard Non-Compliance | 3 (F3, F4, F5) | HIGH |
| Missing Operational Best Practices | 3 (F6, F7, F8) | HIGH |
| **Total** | **8** | **HIGH** |

## Readiness Verdict

**CONDITIONALLY READY** — M57 is functional and ships on schedule (v6.12.1). No CRITICAL bugs or security vulnerabilities. However, 5 HIGH findings remain — the two most impactful (F6 auto-next_due, F4 findings tracking) should be addressed before M57 can be considered production-hardened. The remaining 3 HIGH items (F1 hooks documentation, F2 verification gaps, F8 reference hook) are documentation-quality improvements that do not block operation.

---

*Audit-062 | 2026-06-08 | M57 deep dive against NIST SP 800-53, OWASP SAMM v2, ISO 27001:2022, CIS Controls, and ACP milestone plan*
