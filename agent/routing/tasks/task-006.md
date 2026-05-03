---
id: task-006
title: Deep audit — bugs, consistency, usability of ACP Enhanced
task_type: design-document
milestone: M26-audit
complexity: high
executor: claude-sonnet
context_required:
  - agent/core/identity.yml
  - agent/memory/lessons.md
  - agent/memory/decisions.md
  - agent/wiki/architecture.md
  - agent/commands/*.md
  - agent/scripts/*.sh
  - e2e/*.test.sh
  - tests/*.test.sh
files_affected: []
tokens_est: 18000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
---

## Task: Deep Audit — Bugs, Consistency, Usability of ACP Enhanced

Full cross-cutting audit of the ACP Enhanced system across 4 layers.
Output: a ranked findings list organised by severity, with fix tasks created
for any Critical or High finding.

---

## Audit Scope

### Layer 1 — Command Files (agent/commands/*.md)
- 53 files total; 28 have no e2e test
- Check: directive header format (all must use `/acp-X` syntax, not `@acp.X`)
- Check: `**Scripts**:` field — does the named script actually exist?
- Check: template placeholders not filled in (`@{namespace}-{command-name}`)
- Check: `pretend-context` line (line 4) — must not contain unfilled placeholders
- Check: `command.template.md` and `git.*` command files — are these supposed to be skipped?

### Layer 2 — Shell Scripts (agent/scripts/*.sh)
- 28 scripts total
- Check: all `@acp.*` refs converted to `/acp-*` (known gap from task-001: a few scripts
  were in the batch but we should verify the full set)
- Check: every script referenced in `**Scripts**:` fields actually exists in agent/scripts/
- Check: BSD macOS compatibility — no `date +%N`, no GNU-only sed flags
- Check: `set -e` + `trap ERR` pattern — used correctly?
- Check: `acp.install.sh` — new migration block: does it handle edge cases (no memory files,
  partial .agent/ dir, .agent/ with only some subdirs)?
- Check: `acp.version-update.sh` — same migration block edge cases
- Check: `acp.common.sh` — `display_available_commands()` — are all 51 commands listed?

### Layer 3 — E2E + Unit Tests
- 19 e2e tests, 8 unit test files
- Known pre-existing failure: `acp.script-command-binding.test.sh` — 22/28 failures
  (pre-existing, confirmed via git stash test before this session's changes)
- Check: which tests currently pass / fail (baseline from run-e2e-tests.sh)
- Check: 40 commands with no e2e test — identify the 8 with real script bindings
  (package-create, package-install, package-publish, package-validate,
   preferences-create, preferences-get, preferences-set, preferences-show,
   preferences-validate) — these need e2e tests most urgently
- Check: do existing passing tests still pass after this session's changes?

### Layer 4 — ACP Enhanced Meta-Layer (agent/core, skills, wiki, routing, memory)
- Check: `agent/core/identity.yml` — version (6.2.5) matches AGENT.md and progress.yaml
- Check: `agent/core/routing.yml` — executor values match taxonomy.yml entries
- Check: `agent/core/constraints.yml` — token budget limits still reflect actual layer sizes
- Check: `agent/routing/taxonomy.yml` — all task_types cover the work we've been doing
- Check: `agent/skills/*.md` — skill file references use `/acp-` not `@acp.`
- Check: `.github/copilot-instructions.md` — all path references use `agent/` not `.agent/`
- Check: `AGENTS.md`, `CLAUDE.md` — in sync with copilot-instructions.md protocol

---

## Acceptance Criteria

- [ ] All findings documented with severity: Critical / High / Medium / Low
- [ ] All Critical and High findings have a corresponding fix task created
- [ ] E2E baseline recorded (total pass/fail counts by test suite)
- [ ] Commands-with-no-e2e list finalised with priority tiers
- [ ] No new issues introduced by tasks 001–005 (regression check)

---

## Severity Definitions

| Severity | Definition |
|---|---|
| Critical | Breaks install, update, or core workflow for all users |
| High | Breaks a specific command or test suite; wrong output to AI agents |
| Medium | Inconsistency that could confuse AI agents; wrong docs |
| Low | Style, formatting, or minor documentation gap |

---

## Known Issues Going Into This Audit

From `agent/memory/lessons.md` (all priority:high):

1. **set_preference() write path** — writes flat-dot keys, yaml_get cannot read them back.
   Round-trip set→get is broken. _flat_dot_get() fallback added to read side only.

2. **Production preference files in flat-dot format** — `agent/preferences/*.yaml` never
   migrated to nested YAML. Test fixtures migrated, production files were not.

3. **Command.template pretend-context unfilled** — 9 command files had `@{namespace}-{command-name}`
   unfilled on line 4. Fixed in task-001 sweep — verify all 53 files clean.

4. **37/52 commands have no E2E test** (pre task-001: 52 commands; now 53 after command-create
   and git.* additions). The 8 with real script bindings are highest priority.

5. **`acp.script-command-binding.test.sh`** — 22/28 failures confirmed pre-existing.
   Root cause: test package fixture uses dynamic temp dirs that the dispatch script
   cannot locate. Needs investigation as a separate task.
