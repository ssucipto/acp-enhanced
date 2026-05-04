---
id: route-010
title: Fix namespace placeholder refs in 7 command files body text
task_type: command-doc-update
milestone: M26-audit
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/commands/acp.package-install.md
  - agent/commands/acp.package-validate.md
files_affected:
  - agent/commands/acp.package-install.md
  - agent/commands/acp.package-validate.md
  - agent/commands/acp.design-create.md
  - agent/commands/acp.pattern-create.md
  - agent/commands/acp.spec.md
  - agent/commands/acp.task-create.md
  - agent/commands/acp.validate.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
---

## Task: Fix namespace placeholder refs in command files body text

## Problem

Several command files have unfilled `@{namespace}` / `{namespace}` template placeholder
references in their body text (not the directive header — those are clean). These confuse
AI agents trying to understand how to invoke commands.

Confirmed instances (from audit):

- `acp.package-install.md:264` — `@{namespace}.{action}` in "test a command" step
- `acp.package-validate.md:130` — `@{namespace}-{command}` in namespace consistency check

Other files with `{namespace}` in body text (may be intentional generic references or
unfilled placeholders — must verify each):
`acp.design-create.md`, `acp.pattern-create.md`, `acp.spec.md`, `acp.task-create.md`,
`acp.validate.md`

Also: `**Scripts**:` field formatting issues across multiple commands:
- Trailing spaces after script names (`acp.version-check.sh `, `acp.yaml-parser.sh `)
- `acp.preferences.sh` referenced with full path `agent/scripts/acp.preferences.sh`
  instead of bare filename like all other scripts

## Acceptance Criteria

- [ ] `acp.package-install.md:264` updated to use concrete `/acp-` invocation example
- [ ] `acp.package-validate.md:130` updated to use `/acp-<command>` notation
- [ ] Other body text `{namespace}` references reviewed — unfilled ones fixed,
      intentional generic ones left as-is (e.g. in a section explaining the concept)
- [ ] Trailing spaces removed from `**Scripts**:` fields
- [ ] `agent/scripts/acp.preferences.sh` path prefix removed — use bare filename
