---
id: route-083
title: "Pattern promotion enforcement — commit step 3 prompts key_fact → patterns"
task_type: command-doc-update
milestone: M47
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/core/constraints.yml
files_affected:
  - agent/commands/acp.commit.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed: 2026-06-04
override_reason:
---

# Route 083: Pattern Promotion Enforcement

## Objective

Enforce the `write_patterns_at_discovery` rule from `agent/core/constraints.yml` by
adding a prompt to `/acp-commit` step 3 that asks whether the session's `key_fact`
should be promoted to a reusable pattern.

## Context

`constraints.yml` states:
```
- write_patterns_at_discovery: when a reusable pattern emerges, append to patterns.md
  before continuing
```

However, `/acp-commit` step 3 is a passive "check if session produced a reusable pattern"
without any prompting. Agents and developers often forget to promote key_facts that
contain reusable patterns — they get buried in session entries.

## Changes

### acp.commit.md — Step 3 Enhancement

Update Step 3 to actively prompt when `key_fact` looks like a reusable pattern:

```
### 3. Check for Reusable Patterns

- Read the session's `key_fact` from the entry just written (Step 2)
- If `key_fact` contains:
  - Code snippets or template blocks → prompt: "key_fact contains a code pattern.
    Promote to patterns.md? (y/n)"
  - Architectural insight, workflow pattern, or repeatable process → same prompt
  - A lesson/correction that could benefit other projects → same prompt
- If yes → append to agent/memory/patterns.md:
  ```yaml
  - date: [today]
    name: [kebab-case slug from key_fact]
    task_type: [from session]
    description: [key_fact summary]
  ```
- Step 3b will then auto-sync the document file (per route-075)
```

### Heuristics for "looks like a reusable pattern"

The agent should check for:
1. Contains code blocks (```) — likely a code pattern
2. Contains phrases like "pattern:", "template:", "repeatable", "workaround"
3. Contains references to specific files/lines (code_ref)
4. Is not purely a status update or task list

## Verification

- [ ] Commit step 3 actively prompts for pattern promotion
- [ ] False positives are minimized (not every key_fact is a pattern)
- [ ] When promoted, pattern is appended to patterns.md registry
- [ ] Step 3b auto-syncs the new pattern document (per route-075)

## Dependencies

- route-075 (step 3b auto-sync must be in place)
