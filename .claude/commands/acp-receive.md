---
description: "Load an incoming handoff, verify git and session alignment, and print the assignment checklist before work begins"
---

# ACP Command: /acp-receive

Execute ACP Enhanced command `/acp-receive`.

1. Read and follow **every step** in `agent/commands/acp.receive.md`.
2. Treat text after the command in the user's message as command arguments ($ARGUMENTS).
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.receive.md`
**Equivalent invocations**: `/acp-receive`, `@acp-receive`, `@agent/commands/acp.receive.md`
