---
id: local.workflow-override-directive
version: 1.0.0
category: integration
applies: [acp.proceed, acp.sync, acp.validate]
---

# Workflow Override Directive

<!-- @acp.meta.pattern
topic: workflow, override, directive
description: Workflow Override Directive
applies_to: testing, quality
status: active
updated: 2026-06-15
@acp.meta.end -->

## Intent

Allow team-specific overrides of default ACP workflow step behaviour without modifying command docs. Useful for CI, remote execution, or custom tooling environments.

## When to Use

When a team needs to skip specific ACP workflow steps (e.g., post-completion audit in CI, meta-scan in restricted environments).

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
    step_3_5_audit: skip   # disable post-completion drift audit (CI use only)
  acp.sync:
    step_1_3_scan: skip    # skip meta-scan step in restricted environments
```

**Commands check for overrides before running optional steps:**

```bash
source agent/scripts/acp.driver-yaml.sh
# Step 3.5 audit guard
override=$(driver_query "overrides.acp.proceed" "step_3_5_audit")
[ "$override" != "skip" ] && run_audit
```

## Constraints

- Only `skip` is a valid override value — not `disable`, `false`, or `off`
- Never override `step_1` or `step_2` in `acp.proceed` — those are mandatory core steps
- Never override steps that enforce safety (e.g., git staging review)
- Document active overrides in `agent/wiki/architecture.md`
- Treat overrides as temporary workarounds, not permanent configuration

## Related

- `local.driver-dispatch-directive` — tool-level routing
- `agent/scripts/acp.driver-yaml.sh` — `driver_query` helper
- `acp.proceed.md` Step 3.5, `acp.validate.md` Step 11.5
