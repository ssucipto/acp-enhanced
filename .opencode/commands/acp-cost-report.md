---
description: Weekly token spend report with taxonomy improvement suggestions
---

Generate ACP cost report:

1. Read `.agent/routing/ledger.md` — all entries
2. Group by executor and calculate: total tokens, total cost, task count
3. Calculate: what would same tasks cost if all used claude-sonnet?
4. Output spend table:
   | Executor | Tasks | Input Tokens | Output Tokens | Actual Cost | If All Claude |
5. Find tasks where tokens_actual > tokens_est × 1.5 (likely misrouted)
6. Find rows where executor differs from taxonomy default (manual overrides)
7. Output exactly 3 specific suggestions for taxonomy.yml improvements
8. Output: "Total saved this period: $[X] vs all-Claude baseline"
