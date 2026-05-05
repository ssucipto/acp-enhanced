# Milestone 29: Upstream Integration Audit

<!-- @acp.meta.milestone
topic: upstream, integration, audit, parity, porting
description: Document the full feature parity state between upstream v7.2.0 and ACP Enhanced; create durable porting artifacts.
tasks: task-155..task-158
status: completed
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Produce a complete, durable record of what upstream ACP (prmichaelsen/agent-context-protocol) v7.2.0 has vs what ACP Enhanced already covers, plus a reusable runbook for future upstream syncs.  
**Duration**: 1–2 days  

---

## Overview

ACP Enhanced forked from upstream at v1.0.3 (2026-02-13). Upstream has since released v7.2.0, adding 30+ features across spec management, traceability, stacked worktrees, clarification enhancements, and a pluggable driver system. A code-level audit (2026-05-05, see ADR-7 and ADR-8) confirmed that ACP Enhanced independently implemented most of the same features through parallel development.

This milestone creates the permanent artifacts documenting that parity state and establishing a disciplined process for all future upstream syncs.

---

## Deliverables

### 1. Feature Parity Matrix
- `agent/design/local.upstream-parity-matrix.md` — every upstream v7.2.0 feature tagged HAVE / PARTIAL / PORT / DEFER with rationale

### 2. Upstream Integration Runbook
- `agent/patterns/local.upstream-integration-runbook.md` — step-by-step process: CHANGELOG read → code-level audit → compatibility check → naming translation → selective port → ADR update

### 3. Wiki Sync
- `agent/wiki/domain.yml` updated to reflect all commands, scripts, and schemas added since last wiki sync (audit-005 era)

### 4. Port Compatibility Notes
- Section in parity matrix documenting macOS/bash4+/no-deps/5k-token compatibility verdict for every identified gap

---

## Success Criteria

- [ ] Parity matrix covers all upstream v7.2.0 features from CHANGELOG v1.0.3→v7.2.0
- [ ] Every feature has a PORT/HAVE/PARTIAL/DEFER decision with one-line rationale
- [ ] Runbook includes the naming translation table (`@acp.foo` → `/acp-foo`)
- [ ] Runbook references ADR-7 and ADR-8
- [ ] `agent/wiki/domain.yml` commands section matches actual `agent/commands/` file count (58)
- [ ] `agent/wiki/domain.yml` scripts section matches actual `agent/scripts/` file count

---

## Key Files to Create/Update

```
agent/
├── design/
│   └── local.upstream-parity-matrix.md   (new)
├── patterns/
│   └── local.upstream-integration-runbook.md  (new)
└── wiki/
    └── domain.yml                          (update)
```

---

## Tasks

1. [task-155-feature-parity-matrix.md](../tasks/milestone-29-upstream-integration-audit/task-155-feature-parity-matrix.md) — Create upstream v7.2.0 feature parity matrix
2. [task-156-port-compatibility-audit.md](../tasks/milestone-29-upstream-integration-audit/task-156-port-compatibility-audit.md) — Audit each gap for macOS/bash/constraint compatibility
3. [task-157-upstream-integration-runbook.md](../tasks/milestone-29-upstream-integration-audit/task-157-upstream-integration-runbook.md) — Create reusable upstream integration runbook pattern
4. [task-158-wiki-domain-sync.md](../tasks/milestone-29-upstream-integration-audit/task-158-wiki-domain-sync.md) — Sync agent/wiki/domain.yml to current codebase state

---

## Risks and Mitigation

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|---------------------|
| Missed upstream feature in CHANGELOG reading | Medium | Medium | Cross-check matrix against upstream v7.2.0 AGENT.md directly |
| Parity matrix becomes stale | Low | High | Runbook defines re-run procedure for each new upstream release |

---

**Next Milestone**: [milestone-30-drafts-convention-fix.md](milestone-30-drafts-convention-fix.md)  
**Blockers**: None  
**Notes**: ADR-7 (no-merge strategy) and ADR-8 (no-re-port rule) are already written and in `agent/memory/decisions.md`. This milestone creates the working artifacts that operationalize those decisions.
