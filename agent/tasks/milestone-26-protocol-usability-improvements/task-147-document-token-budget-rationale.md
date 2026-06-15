---
id: task-147
title: Document token budget as discipline, not technical necessity
milestone: M26
task_type: command-doc-update
complexity: low
executor: Persona A (Copilot)
files_affected:
  - AGENTS.md
  - agent/core/constraints.yml
  - .github/copilot-instructions.md
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: document, token, budget, as, discipline, not, technical, necessity
description: Document token budget as discipline, not technical necessity
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Add rationale to the context loading protocol explaining *why* the 2,800-token budget exists, making clear it is a discipline practice for reliable, reproducible session startup — not a hard technical limit imposed by LLM context windows. This prevents new users from either (a) dismissing the budget as unnecessary given modern 100K+ context models, or (b) treating it as a hard ceiling that cannot be reasoned about.

## Context

- **Original design**: The 2,800-token budget was designed when frontier models had 4K–8K context (GPT-3.5 era). It forced the agent to load only what it needed.
- **Current reality**: Claude 3.5+, GPT-4o, Gemini 1.5 all have 100K–200K context. The technical necessity is gone.
- **Remaining value**: The discipline value is real and independent of context window size:
  1. **Reproducibility** — deterministic loading means session A and session B start identically
  2. **Speed** — smaller prompts are faster and cheaper
  3. **Focus** — loading less prevents the agent from being distracted by tangential information
  4. **Self-modeling** — ACP preaches documentation discipline; enforcing it on itself is credibility
- **Where to add this**: `AGENTS.md` context budget section, `agent/core/constraints.yml` comment, and `.github/copilot-instructions.md` context budget block

## Steps

1. **Read `AGENTS.md`** — find the "Context Budget Hard Limits" section
2. **Add a "Why This Budget?" rationale block** immediately before or after the limits table:

   ```
   ## Why This Budget?

   The 2,800-token context budget is a discipline practice, not a technical limit.
   Modern LLMs (Claude 3.5+, GPT-4o) have 100K–200K token context windows — this
   budget is not necessary to prevent context overflow.

   The budget exists because:
   - **Reproducibility**: Deterministic loading means every session starts the same way
   - **Speed and cost**: Smaller prompts are faster and cheaper at API scale
   - **Focus**: Less context forces the agent to load only what's decision-relevant
   - **Credibility**: ACP preaches discipline; the protocol must model what it teaches

   If a task genuinely requires more context, exceed the budget deliberately and note it.
   The budget is a default, not a ceiling.
   ```

3. **Read `agent/core/constraints.yml`** — find the `context_budget:` block
4. **Add an inline comment** above the block:
   ```yaml
   # Context budget: a discipline practice, not a hard technical limit.
   # Modern LLMs have 100K+ context — this budget enforces reproducibility and focus.
   # Exceed deliberately when needed; never exceed silently.
   ```

5. **Read `.github/copilot-instructions.md`** — find the "Context Budget Hard Limits" section
6. **Add the same rationale block** (or a condensed 2-sentence version) there

## Verification

- [ ] `AGENTS.md` "Context Budget Hard Limits" section has a "Why This Budget?" rationale block
- [ ] `agent/core/constraints.yml` has a comment above `context_budget:` explaining the purpose
- [ ] `.github/copilot-instructions.md` has rationale inline with the budget section
- [ ] The rationale explicitly states the budget is NOT required by modern context window sizes
- [ ] The rationale explicitly states exceeding it deliberately is acceptable

## Dependencies

- None — purely additive doc changes

## Estimated Hours

1–2 hours
