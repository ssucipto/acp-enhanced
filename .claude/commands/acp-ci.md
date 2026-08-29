---
description: "Run the gates GitHub Actions runs, locally, before pushing"
---

# ACP Command: /acp-ci

Execute ACP Enhanced command `/acp-ci`.

1. Read and follow **every step** in `agent/commands/acp.ci.md`.
2. Treat text after the command in the user's message as command arguments ($ARGUMENTS).
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.ci.md`
**Equivalent invocations**: `/acp-ci`, `@acp-ci`, `@agent/commands/acp.ci.md`
