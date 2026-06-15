---
id: task-173
milestone: M33
title: Create driver dispatch and workflow override pattern docs
status: completed
priority: 2
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

## Objective

Create two pattern documents describing how to use the pluggable driver system:
1. `agent/patterns/local.driver-dispatch-directive.md` — how commands dispatch to configured drivers
2. `agent/patterns/local.workflow-override-directive.md` — how to override default workflow behaviour per tool

## Context

Patterns in `agent/patterns/` document reusable conventions. The driver system adds two new patterns: how to check a driver before invoking a tool, and how workflow steps can be selectively overridden.

## Implementation

### Pattern 1: `local.driver-dispatch-directive.md`

```markdown
---
id: local.driver-dispatch-directive
version: 1.0.0
category: integration
---

# Driver Dispatch Directive

<!-- @acp.meta.task
topic: driver, dispatch, directive
description: Create driver dispatch and workflow override pattern docs
milestone: M33
status: completed
updated: 2026-05-05
@acp.meta.end -->



## Intent
Route tool invocations (git, shell, lint, etc.) to configured backends rather than
always using local shell execution.

## When to use
In any command or script that invokes an external tool and should honour `agent/driver.yaml`.

## Pattern

In shell scripts:
```bash
source agent/scripts/acp.driver-yaml.sh

if driver_is_native git; then
  git "$@"
else
  _type=$(driver_type git)
  _server=$(driver_query git server)
  _method=$(driver_query git method)
  # Dispatch via MCP or HTTP...
fi
```

In command docs (Step guard syntax):
```
If driver.yaml declares `git: type: mcp`, delegate to MCP server; else run locally.
```

## Related
- `agent/scripts/acp.driver-yaml.sh`
- `agent/driver.template.yaml`
- ADR-7 (upstream integration strategy)
```

### Pattern 2: `local.workflow-override-directive.md`

```markdown
---
id: local.workflow-override-directive
version: 1.0.0
category: integration
---

# Workflow Override Directive

## Intent
Allow team-specific overrides of default ACP workflow behaviour at the step level.

## When to use
When a team runs ACP in a non-standard environment (CI, remote execution, custom lint).

## Pattern

Add an `overrides:` block to `agent/driver.yaml`:
```yaml
drivers:
  git:
    type: mcp
    server: git-mcp
    method: git_exec
overrides:
  acp.proceed:
    step_3_5_audit: skip  # disable post-completion drift audit (use sparingly)
  acp.sync:
    step_1_3_scan: skip   # skip meta-scan step
```

Commands check `driver_query overrides.acp.proceed step_3_5_audit` before running optional steps.

## Constraints
- Only `skip` is a valid override value (not `disable`, `false`, `off`)
- Never override `step_1` or `step_2` in `acp.proceed` — those are the core task steps
- Document any overrides in your team's `agent/wiki/architecture.md` entry

## Related
- `local.driver-dispatch-directive`
- `acp.proceed.md` Step 3.5
```

## Expected Output

### Files Created
- `agent/patterns/local.driver-dispatch-directive.md`
- `agent/patterns/local.workflow-override-directive.md`

## Verification
- [ ] Both files have valid YAML frontmatter
- [ ] Both files have an "Intent", "When to use", "Pattern", and "Related" section
- [ ] Each file is ≤60 lines

## User-Observable Acceptance
A developer implementing a custom command can reference these patterns when adding driver dispatch logic. No need to read the full driver.yaml spec.
