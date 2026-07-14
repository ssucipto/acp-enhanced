---
description: "Generate a context-aware handoff for transferring work to another agent context — same-repo executor transfer (plan → implement) or cross-repository problem transfer"
---

# ACP Command: /acp-handoff

Execute ACP Enhanced command `/acp-handoff`.

1. Read and follow **every step** in `agent/commands/acp.handoff.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.handoff.md`
**Equivalent invocations**: `/acp-handoff`, `@acp-handoff`, `@agent/commands/acp.handoff.md`
