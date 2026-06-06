---
description: "Generate a specification document from a clarification, design, draft, requirements doc, or interactive input"
---

# ACP Command: /acp-spec

Execute ACP Enhanced command `/acp-spec`.

1. Read and follow **every step** in `agent/commands/acp.spec.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.spec.md`
**Equivalent invocations**: `/acp-spec`, `@acp-spec`, `@agent/commands/acp.spec.md`
