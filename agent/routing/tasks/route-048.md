---
id: route-048
title: R8 — Observability Dashboard in progress.yaml
task_type: data-schema
milestone: M44
complexity: medium
executor: deepseek-v4-pro
context_required: [agent/routing/ledger.md, agent/progress.yaml, agent/routing/config.yml]
files_affected: [agent/progress.yaml, scripts/acp-validate.ts, .github/copilot-instructions.md]
tokens_est: 5000
created: 2026-06-03
completed: 2026-06-03
---

# R8: Observability Dashboard

**Source**: audit-022, ChoreHive feedback R8 (P1)

## Problem

The routing ledger tracks task → executor → tokens → cost as a static table. No latency tracking, no error rates, no per-session summaries, no weekly trends. `/acp-cost-report` exists but requires manual invocation.

## Solution

Auto-populate `observability:` section in `agent/progress.yaml` on each `/acp-commit`:
- this_week: sessions, total_tokens, total_cost, avg_latency, top_executor
- by_executor: per-model breakdown
- weekly_trend: historical cost/latency data

## Acceptance Criteria

- [ ] `progress.yaml` has `observability:` section that auto-populates on `/acp-commit`
- [ ] Weekly cost summaries with per-executor breakdown
- [ ] Latency tracking (avg per session)
- [ ] Error rate tracking per executor
- [ ] `/acp-cost-report` auto-triggered weekly (not manual)
- [ ] `acp-validate.ts` validates observability section schema
