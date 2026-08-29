---
description: "Enforce code quality, security, and consistency standards across a project's codebase using a structured **64-rule** ruleset (54 core + 10 Appendix A) aligned to OWASP Top 10:2025, OWASP MASVS v2.0, TypeScript strict mode, and industry best practices. Optional `--pr-diff` is an agent pass on `git diff <base>...HEAD`, not Phase 1 `--diff`."
---

# ACP Command: /acp-review

Execute ACP Enhanced command `/acp-review`.

1. Read and follow **every step** in `agent/commands/acp.review.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.review.md`
**Equivalent invocations**: `/acp-review`, `@acp-review`, `@agent/commands/acp.review.md`
