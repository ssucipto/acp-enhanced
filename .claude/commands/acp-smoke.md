---
description: "Optional device preflight via a project-configured runner. Unconfigured → exit 2 (never PASS). Not a CI step."
---

# ACP Command: /acp-smoke

Execute ACP Enhanced command `/acp-smoke`.

1. Read and follow **every step** in `agent/commands/acp.smoke.md`.
2. Treat text after the command in the user's message as command arguments ($ARGUMENTS).
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.smoke.md`
**Equivalent invocations**: `/acp-smoke`, `@acp-smoke`, `@agent/commands/acp.smoke.md`
