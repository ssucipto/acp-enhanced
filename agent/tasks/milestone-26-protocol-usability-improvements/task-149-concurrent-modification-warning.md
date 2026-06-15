---
id: task-149
title: Add concurrent modification warning to sessions system
milestone: M26
task_type: command-doc-update
complexity: low
executor: Persona A (Copilot)
files_affected:
  - agent/commands/acp.sessions.md
  - agent/commands/acp.init.md
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: add, concurrent, modification, warning, to, sessions, system
description: Add concurrent modification warning to sessions system
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Extend the sessions system (`/acp-sessions`) and session initialization (`/acp-init`) to warn the user when another session appears to be actively working on the same milestone or task area. This closes the silent multi-agent overlap gap without requiring file locking (which is out of scope for ACP's advisory-only session model).

## Context

- **Current state**: The sessions system tracks active sessions in `~/.acp/sessions.yaml`. It is "advisory-only" — no locking, no enforcement.
- **The gap**: Two agents can simultaneously edit the same milestone task files with no warning. As multi-terminal and multi-agent workflows become common, this silent overlap risk grows.
- **Solution scope**: Remain advisory-only. Add a heuristic overlap check: if another session's `current_task` or `current_milestone` matches the current agent's target, emit a visible warning. Do NOT block execution.

## Steps

1. **Read `agent/commands/acp.sessions.md`** — understand the current session write/read protocol
2. **Read `agent/commands/acp.init.md`** — find where it reads sessions (if at all)
3. **Add an "Overlap Check" step** to `acp.sessions.md`:
   a. When a session registers or updates its `current_milestone` and `current_task`:
      - Read `~/.acp/sessions.yaml`
      - Filter sessions that are NOT the current session ID AND have `status: active`
      - For each active foreign session, check if `current_milestone` matches the current agent's milestone
      - If match found: emit warning block:
        ```
        ⚠️  Concurrent Session Detected
        Session: <session-id> (started <time>)
        Working on: M<N> — <milestone name>
        
        Both sessions are targeting the same milestone. Coordinate to avoid conflicts:
        - Assign different tasks to each session
        - Or stop one session before continuing
        
        This is advisory only — you can continue, but be aware of potential file conflicts.
        ```
      - If match on `current_task` as well: escalate to a stronger warning ("Same task")
      - If no match: proceed silently
4. **Add the overlap check to `acp.init.md`** as a "Session Conflict Check" step (after session registration, before loading key files):
   - Same logic as above — run at session start when the agent declares its milestone/task intent
5. **Define "recently active" threshold**: sessions with `last_updated` within the past 2 hours are treated as potentially active, even if status is not `active`

## Verification

- [ ] `acp.sessions.md` includes an "Overlap Check" step that reads `~/.acp/sessions.yaml`
- [ ] The check compares `current_milestone` of all active sessions
- [ ] A visible warning is emitted when a milestone match is found
- [ ] A stronger warning is emitted when a task match is found
- [ ] The warning is advisory — execution is not blocked
- [ ] `acp.init.md` includes the same overlap check at session registration
- [ ] Sessions with `last_updated` within 2 hours are included even if status is unknown

## Dependencies

- None

## Estimated Hours

2–3 hours
