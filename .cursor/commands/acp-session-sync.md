---
description: "Manual repair tool — sync session documents from registry. Same engine as `/acp-commit` step 2b, callable without a full commit."
---

# ACP Command: /acp-session-sync

Execute ACP Enhanced command `/acp-session-sync`.

1. Read and follow **every step** in `agent/commands/acp.session-sync.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.session-sync.md`
**Equivalent invocations**: `/acp-session-sync`, `@acp-session-sync`, `@agent/commands/acp.session-sync.md`
