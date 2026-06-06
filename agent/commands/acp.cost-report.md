# Command: cost-report

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-cost-report` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-cost-report` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Generate a weekly token spend report from `agent/routing/ledger.md` with taxonomy improvement suggestions  
**Category**: Reporting  
**Frequency**: Weekly — run on Fridays or after a significant batch of dispatched tasks  

---

## Arguments

None. Reads all entries from `agent/routing/ledger.md`.

---

## What This Command Does

Reads the routing ledger, groups spend by executor, calculates actual vs. baseline cost (what the same tasks would have cost if all run on Claude Sonnet), and produces 3 specific taxonomy improvement suggestions.

**Use this when**:
- Reviewing weekly AI spend
- Checking if routing is saving money vs. all-Claude baseline
- Identifying tasks that were misrouted (too expensive for the actual work)

---

## Prerequisites

- [ ] `agent/routing/ledger.md` exists and has at least one entry
- [ ] `agent/routing/taxonomy.yml` exists (for improvement suggestions)

---

## Steps

### 1. Read Ledger

- Read `agent/routing/ledger.md` — all entries
- Parse columns: date, route-ID, title, executor, tokens_est, tokens_actual, cost_actual_usd, status

### 2. Group by Executor

Calculate per executor:
- Total tasks dispatched
- Total input + output tokens
- Total actual cost (USD)
- What the same tokens would cost on `claude-sonnet` (inputCost: $3.00/1M, outputCost: $15.00/1M)

### 3. Output Spend Table

```
| Executor          | Tasks | Input Tokens | Output Tokens | Actual Cost | If All Claude |
|-------------------|-------|--------------|---------------|-------------|---------------|
| deepseek-v4-flash | N     | N            | N             | $X.XX       | $X.XX         |
| deepseek-v4-pro   | N     | N            | N             | $X.XX       | $X.XX         |
| claude-sonnet     | N     | N            | N             | $X.XX       | $X.XX         |
| TOTAL             | N     | N            | N             | $X.XX       | $X.XX         |
```

### 4. Find Misrouted Tasks

- Flag rows where `tokens_actual > tokens_est × 1.5` — these tasks took significantly more tokens than estimated
- Flag rows where `executor` differs from taxonomy default and `override_reason` is blank

### 5. Taxonomy Improvement Suggestions

- Output exactly 3 specific suggestions for `agent/routing/taxonomy.yml` improvements based on misrouting patterns
- Format: "Consider changing [task_type] executor from [A] to [B] because [reason from data]"

### 6. Summary Line

```
Total saved this period: $[X.XX] vs all-Claude baseline ([N]% savings)
```

---

## Related Commands

- [`/acp-stakeholder-report`](acp.stakeholder-report.md) — Pair on Fridays — exec summary + AI spend
- [`/acp-route`](acp.route.md) — Re-route expensive task types to cheaper models
- [`/acp-dispatch`](acp.dispatch.md) — Apply routing changes to new dispatches

---

## Verification

- [ ] Spend table includes all executors with at least one ledger entry
- [ ] Misrouted tasks flagged (or "no misroutes found")
- [ ] Exactly 3 taxonomy suggestions output
- [ ] Summary savings line included

---

**Namespace**: acp  
**Command**: cost-report  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  
