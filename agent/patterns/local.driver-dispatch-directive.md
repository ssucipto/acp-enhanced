---
id: local.driver-dispatch-directive
version: 1.0.0
category: integration
applies: [acp.proceed, acp.sync, scripts]
---

# Driver Dispatch Directive

<!-- @acp.meta.pattern
topic: driver, dispatch, directive
description: Driver Dispatch Directive
applies_to: testing, quality
status: active
updated: 2026-06-15
@acp.meta.end -->

## Intent

Route tool invocations (git, shell, lint, etc.) to configured backends rather than always using local shell execution. Keeps commands backend-agnostic and honours `agent/driver.yaml` when present.

## When to Use

In any command or script that invokes an external tool and should honour `agent/driver.yaml`. This is an **opt-in** pattern — it is a no-op when `driver.yaml` is absent.

## Pattern

**In shell scripts:**

```bash
source agent/scripts/acp.driver-yaml.sh

if driver_is_native git; then
    # Default path — run git locally
    git "$@"
else
    # Delegated path — read driver config and dispatch
    _type=$(driver_type git)
    _server=$(driver_query git server)
    _method=$(driver_query git method)
    # Dispatch via MCP/HTTP depending on _type...
    echo "Delegating git to $_type backend: $_server::$_method"
fi
```

**In command docs (step guard syntax):**

```
**Driver check** (skip if agent/driver.yaml absent or driver_is_native git):
- Source agent/scripts/acp.driver-yaml.sh
- If driver_is_native git returns false, delegate to MCP server
  (server: driver_query git server, method: driver_query git method)
- Otherwise run git locally as usual
```

## Constraints

- Always guard with `driver_is_native` — never skip the native path check
- `driver_is_native` returns 0 (true) when `driver.yaml` is absent — native is the safe default
- Do not hardcode driver type checks (`if type == mcp`) — use `driver_query` for config values

## Related

- `agent/scripts/acp.driver-yaml.sh` — 8 helper functions
- `agent/driver.template.yaml` — starter config
- `local.workflow-override-directive` — step-level overrides
- ADR-7 (upstream integration strategy)
