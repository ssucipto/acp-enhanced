---
description: "Capture structured developer feedback about ACP Enhanced system failures, gaps, or improvements; write to `agent/feedback/feedback-NNN.md`"
---

# ACP Command: /acp-feedback

Execute ACP Enhanced command `/acp-feedback`.

1. Read and follow **every step** in `agent/commands/acp.feedback.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.feedback.md`
**Equivalent invocations**: `/acp-feedback`, `@acp-feedback`, `@agent/commands/acp.feedback.md`
