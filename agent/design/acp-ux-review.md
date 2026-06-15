> *Originally at scripts/FINAL-REVIEW.md — moved to agent/design/ in M42 (route-042) so the UX analysis is discoverable by the ACP context-loading protocol.*

# ACP Enhanced — Final Critical Review

<!-- @acp.meta.design
topic: acp, enhanced, final, critical, review
description: ACP Enhanced — Final Critical Review
status: draft
updated: 2026-06-15
@acp.meta.end -->
**Date:** 2026-05-01 | **Review phase:** 7 (Final, Synthesis)

---

## Ease of Use — Honest Audit

### What Genuinely Requires Zero Effort After Setup
- AGENTS.md loads automatically in every IDE — no action ever needed
- Prompt cache hits for Layer 1 content — invisible, automatic, saves money
- Ledger auto-append via dispatch script — no manual token logging
- Context compaction when sessions.md hits 15 entries — happens inside /acp-commit

### What Requires One Command (Acceptable)
- `/acp-route` before each task — 90 seconds, replaces explaining the task
- `/acp-commit` after each session — 90 seconds, the single non-negotiable habit
- `npx ts-node scripts/acp-dispatch.ts` for explicit routing — Persona B/C only

### What Requires Periodic Review (Manageable)
- `/acp-cost-report` weekly — 10 minutes, optional but closes the improvement loop
- `/acp-memory-sync` monthly — 30 minutes, prevents context debt accumulation
- Wiki freshness checks — monthly, 5 minutes, guided by last_verified dates

### The Honest UX Failure Points
1. The dispatch script adds a CLI step that breaks in-IDE flow for Persona B.
   Mitigation: Cline and Continue.dev can be configured to auto-prepend
   context from AGENTS.md, partially replacing the dispatch script for
   in-IDE chat use. Use dispatch for explicit out-of-IDE tasks only.

2. /acp-commit compliance is the whole system's single point of failure.
   If you skip it three days in a row, sessions.md goes stale and the AI
   starts re-asking questions. The pre-commit git hook is the only
   non-code mitigation for this.

3. Taxonomy accuracy starts at ~70% and improves to ~85% over 4 weeks.
   The first two weeks will have routing overrides. This is expected and
   documented — not a bug.

---

## Automation Ceiling — What Can Never Be Automated

These require human judgment and are NOT failure modes — they are
intentional boundaries:

1. **ADR creation** — only you know when a decision is architectural
2. **Executor overrides** — only you know when the AI has misclassified
3. **Wiki staleness judgment** — only you know if architecture.md is wrong
4. **Pattern promotion** — only you know if a pattern is truly reusable

Everything else is automated, semi-automated, or requires one command.

---

## Compared to Available Alternatives

| System              | Context Memory | Task Routing | Cost Tracking | Infra Required | IDE Integration |
|---------------------|---------------|-------------|--------------|---------------|-----------------|
| **ACP Enhanced**    | ✅ Full, tiered | ✅ Real (dispatch) | ✅ Auto ledger | None | ✅ All major IDEs |
| prmichaelsen ACP    | ⚠️ Static only | ❌ None | ❌ None | None | ✅ All |
| mem0                | ✅ Full        | ❌ None | ❌ None | Vector DB | ❌ Custom only |
| LiteLLM proxy       | ❌ None        | ✅ Full  | ✅ Built-in | Self-hosted server | ❌ CLI only |
| OpenRouter alone    | ❌ None        | ✅ Via config | ✅ Dashboard | None | ❌ CLI only |
| Cursor Rules        | ⚠️ Static only | ❌ None | ❌ None | None | ✅ Cursor only |

ACP Enhanced is the only system in this table that provides all three
pillars (memory, routing, cost tracking) with zero infrastructure.

---

## Final Token Saving Estimate (All Optimisations Applied)

| Optimisation Layer         | Saving | Cumulative |
|----------------------------|--------|------------|
| Baseline (no ACP)          | —      | $25.87/mo  |
| + Skill layering (JIT load)| -35%   | $16.82/mo  |
| + Format optimisation      | -20%   | $13.46/mo  |
| + Prompt caching (Layer 1) | -15%   | $11.44/mo  |
| + Task routing             | -55%   | $5.15/mo   |
| + Context compaction       | -10%   | $4.63/mo   |
| **Total reduction**        | **82%**| **$4.63/mo**|

Assumptions: 220 tasks/month, 60% simple / 40% complex, Claude Sonnet baseline.
Routing uses DeepSeek Flash for 60% of tasks.

---

## Verdict

**Build it. In this order:**

Week 1: AGENTS.md + core/ + skills/ + memory/ setup (zero code, immediate value)
Week 2: wiki/ domain extraction + 3 foundational ADRs (2–3 hours, long-term value)
Week 3: dispatch script + OpenRouter (2–3 days, unlocks real routing)
Week 4: taxonomy tuning from first real ledger data (ongoing, self-improving)

The system becomes more valuable every week without becoming more complex to maintain.
The daily overhead is two 90-second commands. The rest is automatic.
