---
id: route-070
title: Token budget performance test
task_type: e2e-test-write
milestone: M45
complexity: low
executor: deepseek-v4-flash
context_required: [tests/common.sh, agent/core/identity.yml, agent/progress.yaml, agent/memory/sessions.md]
design_reference: [M45 Pre-Impl Gap Analysis](../reports/audit-034-m45-pre-impl-gap-analysis.md)
files_affected: [tests/acp.performance.test.sh]
tokens_est: 1500
created: 2026-06-03
completed: 2026-06-03
depends_on: []
---

# Token Budget Performance Test

Create `tests/acp.performance.test.sh` verifying documented token budgets:

1. **Light mode ≤ 300 tokens**: identity.yml (~60) + progress.yaml first 30 lines (~100) + last 3 sessions.md entries (~40) + overhead = ≤ 300
2. **Full mode ≤ 900 tokens**: core files (~180) + taxonomy first 20 lines (~50) + one skill file (~200) + 3 sessions + 5 lessons + wiki section = ≤ 900
3. **Bootstrap solo ≤ 40 files**: `acp-bootstrap.sh --team-size solo` creates ≤ 40 files
4. **Bootstrap team ≥ 200 files**: `acp-bootstrap.sh --team-size team` creates ≥ 200 files

Token estimation: characters / 4 (rough tokenizer approximation: 1 token ≈ 4 chars).
