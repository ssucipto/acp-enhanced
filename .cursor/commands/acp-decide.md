---
description: "Create a new Architecture Decision Record (ADR) in `agent/memory/decisions.md`"
---

# ACP Command: /acp-decide

Execute ACP Enhanced command `/acp-decide`.

1. Read and follow **every step** in `agent/commands/acp.decide.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.decide.md`
**Equivalent invocations**: `/acp-decide`, `@acp-decide`, `@agent/commands/acp.decide.md`
