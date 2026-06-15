---
id: task-171
milestone: M33
title: Create driver.schema.yaml and driver.template.yaml
status: completed
priority: 2
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Create `agent/schemas/driver.schema.yaml` (validation schema) and `agent/driver.template.yaml` (starter config) for the pluggable driver system — enabling teams to route ACP tool invocations to MCP servers or custom backends.

## Context

Upstream ACP v5.44+ introduced a pluggable driver system. A `driver.yaml` file declares which tool invocations are delegated to which endpoints:
```yaml
drivers:
  git:
    type: mcp
    server: git-mcp
    method: git_exec
  shell:
    type: native   # default — use local shell
```

This is the first task of M33 (optional milestone). Only begin if MCP server integration is a project goal.

**Constraints**: Schema must be valid YAML (no external schema validators required). Template must include all documented fields with inline comments. Both files must be under 60 lines.

## Implementation

1. Create `agent/schemas/driver.schema.yaml`:
```yaml
# driver.schema.yaml — schema for agent/driver.yaml

<!-- @acp.meta.task
topic: driverschemayaml, schema, for, agentdriveryaml
description: Create driver.schema.yaml and driver.template.yaml
milestone: M33
status: completed
updated: 2026-05-05
@acp.meta.end -->


# Validate with: acp.driver-yaml.sh validate
---
required:
  - drivers

properties:
  drivers:
    type: object
    description: "Map of tool-name to driver configuration"
    additionalProperties:
      type: object
      required: [type]
      properties:
        type:
          enum: [native, mcp, http, custom]
        server:
          type: string
          description: "MCP server name (required for type: mcp)"
        method:
          type: string
          description: "MCP method to call"
        url:
          type: string
          description: "HTTP endpoint URL (required for type: http)"
        command:
          type: string
          description: "Shell command (required for type: custom)"
```

2. Create `agent/driver.template.yaml`:
```yaml
# ACP Driver Configuration
# Governs how ACP routes tool invocations (git, shell, lint, etc.)
# Remove/comment sections you don't need.
# See ADR-7 and agent/patterns/local.driver-dispatch-directive.md for usage.
---
drivers:
  git:
    type: native  # or: mcp (requires server + method fields)
    # server: git-mcp
    # method: git_exec
  shell:
    type: native
  lint:
    type: native
    # type: mcp
    # server: lint-mcp
    # method: lint_file
```

## Expected Output

### Files Created
- `agent/schemas/driver.schema.yaml`
- `agent/driver.template.yaml`

## Verification
- [ ] Both files are valid YAML (`python3 -c "import yaml; yaml.safe_load(open('...'))"` or `bash` read without error)
- [ ] Schema covers all 4 driver types: native, mcp, http, custom
- [ ] Template has inline comments explaining each field
- [ ] Neither file exceeds 60 lines

## User-Observable Acceptance
A developer can copy `agent/driver.template.yaml` → `agent/driver.yaml`, fill in their MCP server names, and the file validates against `driver.schema.yaml`.
