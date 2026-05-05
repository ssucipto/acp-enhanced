# Milestone 32: AGENT.md Protocol Documentation

<!-- @acp.meta.milestone
topic: documentation, agent-md, markers, specs, naming-convention, dr-ids, stacked
description: Document all protocol features in AGENT.md that currently exist in the codebase but are undocumented for developers and agents.
tasks: task-167..task-170
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Make AGENT.md the authoritative reference for all ACP Enhanced protocol features — specifically the undocumented metadata markers, specs system, command naming convention, DR-IDs, and stacked mode.  
**Duration**: 1–1.5 weeks  

---

## Overview

Several significant ACP Enhanced protocol features were implemented but never documented in AGENT.md:

1. **Metadata Markers** (`@acp.meta.*` / `@acp.meta.end`) — used in specs, tasks, milestones, designs, and code. No AGENT.md section explains the sentinel syntax, 8 kinds, or field catalog.
2. **Specs System** (`agent/specs/`, `@acp.spec`, FR-IDs, Behavior Tables) — fully implemented but AGENT.md has no "Specs" section.
3. **Command Naming Convention** — the critical `/acp-` vs `@acp.` duality, the triple-file architecture (command doc + VS Code prompt + opencode command), and porting rules are undocumented for contributors.
4. **DR-IDs and `incorporates:`** — design atomic unit IDs used in tasks are undocumented in AGENT.md.
5. **Advanced proceed modes** — `--stacked`, `--yolo`, Step 3.5 audit, drift remediation sub-agent protocol not summarized in AGENT.md.

A contributor (or agent on a fresh session) cannot discover these features from AGENT.md alone.

---

## Deliverables

### 1. Metadata Markers Section
- New "Metadata Markers" section in AGENT.md covering: sentinel syntax, 8 marker kinds (spec, task, milestone, design, pattern, clarification, code, artifact), required and optional fields, `acp.meta-scan.sh` usage

### 2. Specs Section
- New "Specs" section in AGENT.md covering: `agent/specs/` directory, `@acp.spec` command, FR-IDs (`R<N>`), Behavior Tables, spec-to-task traceability via `covers:`

### 3. Command Invocation Section
- New "Command Invocation" section in AGENT.md with: naming table (file, VS Code, opencode, user invocation), invocation chain diagram, porting rules for upstream content

### 4. Design Reference Updates
- Existing "Designs" section in AGENT.md updated with DR-IDs (`D<N>`), `incorporates:` field, and `--stacked` / `--yolo` summary under "Proceed Modes"

---

## Success Criteria

- [ ] AGENT.md has a "Metadata Markers" section documenting all 8 marker kinds
- [ ] AGENT.md has a "Specs" section documenting `agent/specs/`, FR-IDs, and `covers:`
- [ ] AGENT.md has a "Command Invocation" section with the full naming table
- [ ] AGENT.md documents DR-IDs and `incorporates:` in the designs section
- [ ] AGENT.md documents `--stacked` and `--yolo` briefly in the proceed section
- [ ] New sections do not push AGENT.md total size beyond 200 lines (use cross-references to command docs for detail)

---

## Key Files to Update

```
AGENT.md    (update — add 4 new sections / expand 2 existing)
```

---

## Tasks

1. [task-167-agent-md-metadata-markers.md](../tasks/milestone-32-agent-md-protocol-documentation/task-167-agent-md-metadata-markers.md) — Add "Metadata Markers" section to AGENT.md
2. [task-168-agent-md-specs-section.md](../tasks/milestone-32-agent-md-protocol-documentation/task-168-agent-md-specs-section.md) — Add "Specs" section to AGENT.md
3. [task-169-agent-md-command-invocation.md](../tasks/milestone-32-agent-md-protocol-documentation/task-169-agent-md-command-invocation.md) — Add "Command Invocation" section with naming table
4. [task-170-agent-md-dr-ids-and-stacked.md](../tasks/milestone-32-agent-md-protocol-documentation/task-170-agent-md-dr-ids-and-stacked.md) — Update designs section with DR-IDs and proceed section with stacked/yolo

---

**Next Milestone**: [milestone-33-pluggable-driver-system.md](milestone-33-pluggable-driver-system.md)  
**Blockers**: None — documentation only, no implementation dependencies  
**Notes**: Keep each new AGENT.md section under 20 lines by referencing command docs for full detail. Goal is discoverability, not exhaustive documentation.
