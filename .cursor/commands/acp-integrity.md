---
description: "Verify AI-generated code **trustworthiness and provenance** — detect malicious patterns, hidden Unicode, exfiltration vectors, supply chain risks, and CI injection surfaces. Distinct from `/acp-review` which verifies code **quality**."
---

# ACP Command: /acp-integrity

Execute ACP Enhanced command `/acp-integrity`.

1. Read and follow **every step** in `agent/commands/acp.integrity.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.integrity.md`
**Equivalent invocations**: `/acp-integrity`, `@acp-integrity`, `@agent/commands/acp.integrity.md`
