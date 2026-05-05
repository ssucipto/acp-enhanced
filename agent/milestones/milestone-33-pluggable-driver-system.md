# Milestone 33: Pluggable Driver System (Optional)

<!-- @acp.meta.milestone
topic: driver, pluggable, dispatch, mcp, integration, optional
description: Port upstream's pluggable driver system enabling MCP server or custom tool dispatch via driver.yaml config.
tasks: task-171..task-175
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Port the pluggable driver system from upstream (introduced v5.44+) — enabling teams to redirect ACP tool invocations (git, shell, lint) to MCP servers or custom backends via a declarative `driver.yaml`.  
**Duration**: 2–3 weeks  

---

## Overview

Upstream ACP v5.44+ introduced a pluggable driver system:
- `agent/driver.yaml` — declares which tools are delegated to which MCP endpoints
- `agent/scripts/acp.driver-yaml.sh` — 8 POSIX helpers for reading driver config
- Two new pattern types: **Driver Dispatch Directive** and **Workflow Override Directive**
- `@acp.validate` Step 11.5 — validates driver binding consistency
- `@acp.sync` integration — queries driver config during sync passes
- `@acp.proceed` Step 1 — reads driver config before task execution

This is **optional** — ACP Enhanced works fine without it. It is only needed when teams want to route tool invocations through MCP servers.

**Priority**: Low. Only begin this milestone if MCP server integration is a project goal.

---

## Deliverables

### 1. Schema and Template
- `agent/schemas/driver.schema.yaml` — validation schema for driver.yaml
- `agent/driver.template.yaml` — starter template with documented fields

### 2. Driver Script
- `agent/scripts/acp.driver-yaml.sh` — 8 POSIX helper functions: `driver_get`, `driver_list`, `driver_query`, `driver_override`, `driver_validate`, `driver_status`, `driver_dispatch`, `driver_reset`

### 3. Pattern Documents
- `agent/patterns/local.driver-dispatch-directive.md` — pattern for using driver dispatch in commands
- `agent/patterns/local.workflow-override-directive.md` — pattern for overriding workflow steps via driver config

### 4. Command Integrations
- `acp.sync.md` Step 1.3 updated with `query.run` dispatch hook (conditional on driver.yaml presence)
- `acp.proceed.md` Step 1 updated with driver config read (conditional)
- `acp.validate.md` Step 11.5 added — driver binding consistency check

### 5. E2E Tests
- `e2e/acp.driver-yaml.test.sh` — tests all 8 script helpers with fixture driver.yaml

---

## Success Criteria

- [ ] `agent/schemas/driver.schema.yaml` validates a well-formed driver.yaml
- [ ] `acp.driver-yaml.sh` all 8 functions work on macOS (BSD bash 3.2+) and Linux
- [ ] `acp.validate.md` Step 11.5 checks driver binding consistency
- [ ] Driver integration in sync/proceed is conditional — no change if driver.yaml absent
- [ ] `e2e/acp.driver-yaml.test.sh` all assertions pass

---

## Key Files to Create/Update

```
agent/
├── driver.template.yaml                                (new)
├── schemas/
│   └── driver.schema.yaml                             (new)
├── scripts/
│   └── acp.driver-yaml.sh                             (new)
└── patterns/
    ├── local.driver-dispatch-directive.md             (new)
    └── local.workflow-override-directive.md           (new)
agent/commands/
├── acp.sync.md                                        (update — Step 1.3 hook)
├── acp.proceed.md                                     (update — Step 1 hook)
└── acp.validate.md                                    (update — Step 11.5)
e2e/
└── acp.driver-yaml.test.sh                            (new)
```

---

## Tasks

1. [task-171-driver-schema-and-template.md](../tasks/milestone-33-pluggable-driver-system/task-171-driver-schema-and-template.md) — Create driver.schema.yaml and driver.template.yaml
2. [task-172-driver-yaml-sh.md](../tasks/milestone-33-pluggable-driver-system/task-172-driver-yaml-sh.md) — Port acp.driver-yaml.sh (8 POSIX helpers, macOS-safe)
3. [task-173-driver-pattern-documents.md](../tasks/milestone-33-pluggable-driver-system/task-173-driver-pattern-documents.md) — Create driver dispatch and workflow override pattern docs
4. [task-174-wire-driver-into-sync-proceed.md](../tasks/milestone-33-pluggable-driver-system/task-174-wire-driver-into-sync-proceed.md) — Add conditional driver hooks to acp.sync.md and acp.proceed.md
5. [task-175-driver-e2e-and-validate-step.md](../tasks/milestone-33-pluggable-driver-system/task-175-driver-e2e-and-validate-step.md) — E2E tests + add acp.validate.md Step 11.5

---

## Risks and Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| Driver system is overly complex for ACP Enhanced use cases | Medium | Medium | Implement conditionally — no-op when driver.yaml absent |
| BSD bash 3.2 compat for driver helpers | High | Medium | All helpers must use `while IFS= read` patterns; no bash 4 associative arrays |

---

**Next Milestone**: [milestone-34-command-naming-convention.md](milestone-34-command-naming-convention.md)  
**Blockers**: Requires M29 (parity matrix) to confirm driver system is not partially implemented already  
**Notes**: **OPTIONAL** — only start if MCP server integration is needed. The rest of ACP Enhanced works correctly without this milestone.
