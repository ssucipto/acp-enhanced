---
description: "Deep-dive investigation of a subject, producing a structured report in `agent/reports/`"
---

# ACP Command: /acp-audit

Execute ACP Enhanced command `/acp-audit`.

1. Read and follow **every step** in `agent/commands/acp.audit.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.audit.md`
**Equivalent invocations**: `/acp-audit`, `@acp-audit`, `@agent/commands/acp.audit.md`
