---
id: route-091
title: "/acp-index init — bootstrap index from project patterns/commands"
task_type: command-doc-write
milestone: M48
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.index.md
  - agent/patterns/
  - agent/commands/
files_affected:
  - agent/commands/acp.index.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 091: /acp-index init

## Objective

Add an `init` subcommand to `/acp-index` that bootstraps the key file index
from existing project patterns and commands.

## Context

FIFOZ feedback-002 (B-066-07) found that `local.main.yaml` was never bootstrapped,
leaving the index layer unused. The index is valuable for context loading
(`/acp-init`, `/acp-plan`, `/acp-proceed`) but requires manual setup. An init
command would auto-discover project content and generate the index.

## Changes

### acp.index.md — Add init Subcommand

Add to the command doc:

```
### init — Bootstrap Index

**Purpose**: Auto-discover project patterns, commands, and designs and generate
a `local.main.yaml` index file.

**Actions**:
1. Scan `agent/patterns/` for `local.*.md` files → create index entries with
   kind: pattern, weight based on file size/complexity
2. Scan `agent/commands/` for `local.*.md` files → create index entries with
   kind: command
3. Scan `agent/design/` for `local.*.md` files → create index entries with
   kind: design
4. Write `agent/index/local.main.yaml` with discovered entries
5. Output summary: "Index bootstrapped: N patterns, M commands, K designs"

**Dry run**: `/acp-index init --dry-run` shows what would be created.
```

## Verification

- [ ] `init` subcommand documented in acp.index.md
- [ ] Auto-discovers local patterns, commands, and designs
- [ ] Generates valid index entries with weight, kind, description
- [ ] `--dry-run` previews without writing

## Dependencies

None.
