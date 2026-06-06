---
id: route-110
title: "Add command_suggestions in routing.yml + design-spec task_type in taxonomy.yml"
task_type: yaml-schema
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/core/routing.yml
  - agent/routing/taxonomy.yml
  - agent/feedback/feedback-005-acp-design-spec-command-upstream.md
files_affected:
  - agent/core/routing.yml
  - agent/routing/taxonomy.yml
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-06
override_reason:
---

# Route 110: Framework Integration — routing.yml + taxonomy.yml

## Objective

Add the new command to the framework's routing and taxonomy systems so it is discoverable and dispatchable.

## Context

Per feedback-005 §5.1–5.2, the command needs entries in two framework files. The command_suggestions map enables the agent to suggest related commands after invocation. The task_type entry enables `/acp-route` and `/acp-dispatch` to classify and route design-spec tasks.

## Changes

### 1. `agent/core/routing.yml` — Add `command_suggestions` entry

Add after the `acp-design-create` block:

```yaml
  acp-design-spec:
    - acp-audit: "Verify spec against codebase (--audit flag)"
    - acp-visualize: "Render Mermaid diagrams in Docs tab"
    - acp-commit: "Save session when spec completes a milestone phase"
```

Also add cross-references to existing commands:

```yaml
  acp-report:
    # existing entries...
    - acp-design-spec: "Generate interface spec (not progress report)"  # ADD

  acp-design-create:
    # existing entries...
    - acp-design-spec: "Document implemented interfaces after build"  # ADD
```

### 2. `agent/routing/taxonomy.yml` — Add `design-spec` task_type

Add new entry in the task_types list:

```yaml
  design-spec:
    executor: copilot
    complexity: medium
    context_required: [commands/acp.design-spec.md, wiki/domain.yml, memory/decisions.md]
    tokens_est: 15000
    skill: crosscut
    description: >
      Generating Application Interface & Data-Flow Design Specifications
      using /acp-design-spec. Scans codebase for routes, stores, APIs,
      persistence; produces 19-section spec with Mermaid diagrams.
```

## Verification

- [ ] `acp-design-spec` entry exists in `routing.yml → command_suggestions`
- [ ] Cross-references added to `acp-report` and `acp-design-create` suggestions
- [ ] `design-spec` entry exists in `taxonomy.yml → task_types`
- [ ] YAML syntax valid (no duplicate keys, correct indentation)
