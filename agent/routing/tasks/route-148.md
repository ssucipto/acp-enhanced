---
id: route-148
title: "M56-007: Wrappers + aliases + taxonomy + routing + package.yaml"
task_type: command-doc-update
milestone: M56
complexity: low
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, route-147, audit-054 INC-053-03]
files_affected: [.github/prompts/acp-integrity.prompt.md, .opencode/commands/acp-integrity.md, .github/prompts/acp-rule-file-audit.prompt.md, .opencode/commands/acp-rule-file-audit.md, agent/routing/taxonomy.yml, agent/core/routing.yml, package.yaml]
tokens_est: 3000
created: 2026-06-07
completed: 2026-06-08
---

# Route 148: Integration — Wrappers, Aliases, Taxonomy, Routing, Package

## Objective

Wire the `/acp-integrity` command into the ACP framework — wrappers, the `acp-rule-file-audit` alias, taxonomy entry, routing suggestions, and package registration.

## Expected Output

### Files Created
- `.github/prompts/acp-integrity.prompt.md` — standard prompt wrapper
- `.opencode/commands/acp-integrity.md` — standard opencode wrapper
- `.github/prompts/acp-rule-file-audit.prompt.md` — alias → `acp-integrity --self --fast`
- `.opencode/commands/acp-rule-file-audit.md` — same alias

### Files Modified
- `agent/routing/taxonomy.yml` — add `code-integrity-scan` task type
- `agent/core/routing.yml` — add acp-integrity command suggestions
- `package.yaml` — add acp.integrity.md entry

## Alias Design (per audit-054 INC-053-03)

`acp-rule-file-audit` is a 3-line wrapper, NOT a separate command. No separate command doc. No separate taxonomy type. It maps directly to `acp-integrity --self --fast`.

```
---
mode: agent
description: Fast scan of ACP rule files for Unicode injection and hidden instructions (alias for acp-integrity --self --fast)
---

Read and execute `agent/commands/acp.integrity.md` with flags --self --fast.
```

## Taxonomy Entry

```yaml
code-integrity-scan:
  executor: copilot
  complexity: high
  context_required: [commands/acp.integrity.md, skills/code-integrity.md, wiki/integrity-rules.md]
  tokens_est: 8000
  skill: code-integrity
```

## Routing Suggestions

```
acp-integrity:
  - acp-review: "Code quality review after integrity scan passes"
  - acp-audit: "Deep-dive a specific integrity finding"
  - acp-commit: "Save session after addressing integrity findings"
```

## Verification

- [ ] Both acp-integrity wrappers exist (prompt + opencode)
- [ ] Both acp-rule-file-audit alias wrappers exist — 3-line files
- [ ] `taxonomy.yml` has `code-integrity-scan` entry (exactly 1, not 2)
- [ ] `core/routing.yml` has acp-integrity command suggestions
- [ ] `package.yaml` has acp.integrity.md entry with `scripts: []`
- [ ] Alias wrappers reference `agent/commands/acp.integrity.md` (not a separate command doc)

## User-Observable Acceptance

- `/acp-integrity` is discoverable via `@code-integrity` skill
- `/acp-rule-file-audit` works as shorthand for `acp-integrity --self --fast`
- Taxonomy correctly routes integrity scan tasks to copilot executor
