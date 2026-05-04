---
description: Bootstrap domain knowledge from codebase — run ONCE on new project or after major refactor
---

Bootstrap ACP domain knowledge from this codebase:

1. Scan `agent/commands/` — extract all command names and their purpose
2. Scan `agent/scripts/` — extract all script names and what they implement
3. Scan `agent/schemas/` — extract schema names and what they validate
4. Scan `e2e/` and `tests/` — extract test suite names and coverage areas
5. Write to `.agent/wiki/domain.yml`:
   - commands: all `acp.*` command files with their category and purpose
   - scripts: all `acp.*.sh` scripts with what they implement
   - schemas: all YAML schemas and what they validate
   - test_suites: all E2E test files with assertion counts if known
6. Write to `.agent/wiki/architecture.md`:
   - The agent/commands/ → agent/scripts/ binding pattern
   - The package.yaml manifest system overview
   - The YAML parser dependency chain
   - last_verified: [today]
7. Confirm: "[ACP] Domain extraction complete | [N] commands | [N] scripts | [N] schemas"
