---
id: task-154
milestone: M27
title: Revise token budget from 2800 to 5000
status: not_started
priority: 3
complexity: trivial
estimated_hours: 0.5
created: 2026-05-04
started:
completed:
---

<!-- @acp.meta.task
topic: revise, token, budget, from, 2800, to, 5000
description: Revise token budget from 2800 to 5000
milestone: M27
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Update the ACP context budget from 2,800 tokens to 5,000 tokens across all protocol files. The rationale blockquote (added in task-147) already explains the budget is a discipline practice; now update the numbers to something achievable and realistic.

## Context

The 2,800-token budget was set early in ACP development when the protocol was smaller. A real session now loads:
- Layer 1 (3 core files): ~300–500 tokens
- Layer 2 (1 skill file): ~400–700 tokens  
- Layer 3 (3 session entries + 5 lesson entries + 1 wiki section): ~600–1,200 tokens

That's already 1,300–2,400 tokens before reading any task file. A moderately complex task file adds 300–800 tokens more, exceeding 2,800 immediately.

**New targets** (still a discipline cap, not a hard limit):
- Layer 1 (core): 300 → **500** tokens
- Layer 2 (skills): 500 → **1,000** tokens
- Layer 3 (memory + wiki): 2,000 → **3,500** tokens
- Total: 2,800 → **5,000** tokens

## Implementation

Update all 4 files:

1. **`agent/core/constraints.yml`**: Update `context_budget:` values
2. **`AGENTS.md`**: Update the "Context Budget Hard Limits" section numbers
3. **`CLAUDE.md`**: Same update
4. **`.github/copilot-instructions.md`**: Same update

In each AGENTS-style file, change:
```
- Layer 1 (core): max 300 tokens
- Layer 2 (skills): max 500 tokens
- Layer 3 (memory + wiki): max 2,000 tokens
- Total session context: max 2,800 tokens (before task content)
```
→
```
- Layer 1 (core): max 500 tokens
- Layer 2 (skills): max 1,000 tokens
- Layer 3 (memory + wiki): max 3,500 tokens
- Total session context: max 5,000 tokens (before task content)
```

In `constraints.yml`, update:
```yaml
context_budget:
  layer1_max_tokens: 300
  layer2_max_tokens: 500
  layer3_max_tokens: 2000
  total_max_tokens: 2800
```
→
```yaml
context_budget:
  layer1_max_tokens: 500
  layer2_max_tokens: 1000
  layer3_max_tokens: 3500
  total_max_tokens: 5000
```

## Expected Output

### Files Modified
- `agent/core/constraints.yml`
- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`

## Verification
- [ ] `grep "total_max_tokens" agent/core/constraints.yml` shows `5000`
- [ ] `grep "max 5,000" AGENTS.md` matches
- [ ] `grep "max 5,000" CLAUDE.md` matches
- [ ] `grep "max 5,000" .github/copilot-instructions.md` matches

## User-Observable Acceptance
All 4 files show `5,000` as the total budget cap. The rationale blockquote (added in task-147) is preserved and unchanged.
