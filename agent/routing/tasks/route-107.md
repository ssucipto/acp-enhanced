---
id: route-107
title: "Add cursor/opencode wrappers and package.yaml entry for acp-design-spec"
task_type: command-doc-write
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/patterns/local.command-naming-convention.md
  - agent/commands/acp.design-spec.md
files_affected:
  - .cursor/commands/acp-design-spec.md
  - .opencode/commands/acp-design-spec.md
  - package.yaml
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 107: Prompt/OpenCode Wrappers + Package Entry

## Objective

Create the two wrapper files required by the triple-file architecture for every ACP command, and register the command in `package.yaml`.

## Context

Every `/acp-*` command requires exactly 3 files per `local.command-naming-convention.md`:
1. Command directive: `agent/commands/acp.design-spec.md` (route-106)
2. VS Code prompt wrapper: `.github/prompts/acp-design-spec.prompt.md` (this route)
3. OpenCode wrapper: `.opencode/commands/acp-design-spec.md` (this route)

Note: `.cursor/commands/` is NOT part of the ACP triple-file architecture. The VS Code
prompt surface is `.github/prompts/`. If Cursor IDE integration is needed separately,
that is a distinct concern outside the ACP naming convention.

## Changes

### 1. Create `.github/prompts/acp-design-spec.prompt.md`

Follow the existing prompt wrapper pattern (see `.github/prompts/acp-plan.prompt.md`):

```markdown
---
mode: agent
description: Generate Application Interface & Data-Flow Design Specifications from the live codebase
---

Read and execute `agent/commands/acp.design-spec.md`.
```

### 2. Create `.opencode/commands/acp-design-spec.md`

Follow the existing opencode wrapper pattern (see `.opencode/commands/acp-design-create.md`):

```markdown
---
description: Generate Application Interface & Data-Flow Design Specifications from the live codebase
---

Read and execute `agent/commands/acp.design-spec.md`.
```

### 3. Add to `package.yaml`

Add `acp.design-spec.md` to the command files list in `package.yaml` under the `acp-core` or commands section, following the existing pattern for other command entries.

## Verification

- [ ] `.github/prompts/acp-design-spec.prompt.md` exists with correct content + frontmatter
- [ ] `.opencode/commands/acp-design-spec.md` exists with correct content + frontmatter
- [ ] Wrapper files use hyphen separator (`acp-design-spec`) not dot
- [ ] `package.yaml` includes `acp.design-spec.md` entry
- [ ] Triple-file parity check passes (route-094 validation)
