---
description: "Implement tasks — single-task (default) or autonomous milestone completion (with arguments)"
---

# ACP Command: /acp-proceed

Execute ACP Enhanced command `/acp-proceed`.

1. Read and follow **every step** in `agent/commands/acp.proceed.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.proceed.md`
**Equivalent invocations**: `/acp-proceed`, `@acp-proceed`, `@agent/commands/acp.proceed.md`
