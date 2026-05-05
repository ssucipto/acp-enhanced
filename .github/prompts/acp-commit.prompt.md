---
mode: agent
description: End-of-session memory commit — run before closing VS Code
---

Perform ACP session commit:

1. Ask: "Which task IDs were completed this session?" if not obvious from context
2. Write YAML session entry to `agent/memory/sessions.md`:
   ```yaml
   - date: [today]
     executor: [executor used this session]
     tasks: [task IDs completed]
     done: [kebab-case summary of what was done]
     deferred: [item → task-ID for each deferred item, or none]
     key_fact: [single most important thing learned, or null]
   ```
3. Check: did this session produce a reusable code pattern?
   If yes → append to `agent/memory/patterns.md` with date and code_ref
4. Check: was an architectural decision made?
   If yes → prompt "Create ADR for [decision]? (y/n)"
5. Count entries in sessions.md. If > 15 → compact oldest 10:
   a. Extract key_facts → check if any belong in patterns.md or decisions.md
   b. Replace the 10 entries with a single weekly summary block
6. Mark completed tasks in their `agent/routing/tasks/route-NNN.md` files (set completed: date)
7. Confirm: "[ACP] Session committed | [N] entries in sessions.md | compacted: [y/n]"
