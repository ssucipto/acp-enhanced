# Cross-Agent Handoff (ACP Enhanced)

> **Status:** DRAFT — ships with M67 v6.23.0. Do not treat as enforced until release.  
> **Design:** `agent/design/cross-agent-handoff-protocol.md`  
> **Audit:** `agent/reports/audit-077-cross-agent-handoff-feedback-007.md`  
> **Field evidence:** FIFOZ audit-245 + M51 exemplar (external reference project)

---

## Overview

ACP supports two handoff modes:

| Mode | Use when | Delivery | Command (post-M67) |
|------|----------|----------|-------------------|
| **executor** | Same repo, different agent/model (plan → implement, implement → audit) | Disk file in `agent/reports/` | `/acp-handoff --mode executor --to <executor>` |
| **cross-repo** | Problem transfer to another codebase | Chat-primary (optional disk) | `/acp-handoff --mode cross-repo` (default) |

**`/acp-report`** = session summary for humans. **`/acp-handoff`** = structured transfer to the next agent.

---

## Ritual diagram

```mermaid
sequenceDiagram
    participant A as Outgoing agent
    participant Disk as agent/reports/
    participant B as Incoming agent

    A->>A: /acp-commit
    A->>A: git rev-parse HEAD + branch
    A->>Disk: handoff-{to}-{scope}-{date}.md
    Note over Disk: ADRs, tasks, guardrails, git pin
    B->>B: /acp-receive path (or /acp-resume @path)
    B->>B: Git drift + session gap check
    B->>B: /acp-proceed or /acp-audit
    B->>A: Return handoff (status wave)
```

---

## Outgoing ritual (executor mode)

1. **`/acp-commit`** — persist session to `sessions.md`
2. Record **`git rev-parse HEAD`** and branch
3. **`/acp-handoff --mode executor --to <target>`** — write to `agent/reports/handoff-{to}-{scope}-{YYYY-MM-DD}.md`
4. Include (proposal §4 template):
   - Model / executor requirement
   - Locked decisions (ADR refs — do not re-litigate)
   - Plan reference (milestone, route IDs, task sequence)
   - **What NOT to do**
   - State files to update on completion
5. Push if receiving agent needs remote access

---

## Incoming ritual

Until M67 ships `/acp-receive`, follow manually:

1. Load context protocol (`CLAUDE.md` / `AGENTS.md`)
2. Open handoff (`@` attach in Cursor)
3. Compare handoff `git_commit` vs `git rev-parse HEAD` — if drift, `git log pin..HEAD`
4. Compare handoff date vs last `sessions.md` entry
5. Confirm mode: **Implement** vs **Audit only**
6. **`/acp-proceed`** or **`/acp-audit`** — do not re-litigate locked decisions

Post-M67: **`/acp-receive <path>`** or **`/acp-resume @handoff.md`**

---

## Return handoff

When finishing a wave or blocking, write:

`handoff-{original-from}-{scope}-status-{YYYY-MM-DD}.md`

Include: completed tasks, commits, HUMAN gates, open questions.

---

## Filename conventions

| Pattern | Purpose |
|---------|---------|
| `handoff-{to}-{scope}-{date}.md` | Outgoing executor handoff |
| `handoff-{from}-{scope}-status-{date}.md` | Return / status handoff |
| `HANDOFF-LATEST.md` | Copy of most recent (P2, route-194) |

---

## Exemplars (FIFOZ field project)

These files live in the FIFOZ repo and demonstrate production patterns:

- Claude → Cursor: `handoff-cursor-composer25-m51-2026-07-13.md`
- Cursor → Claude audit: `handoff-claude-m47-m48-plan-audit-2026-07-12.md`

Path: `Project/Rygan/FIFOZ/agent/reports/`

---

## Related commands

| Command | When |
|---------|------|
| `/acp-commit` | Always before outgoing handoff |
| `/acp-handoff` | Create handoff (v2 dual mode post-M67) |
| `/acp-receive` | Load + verify incoming handoff (M67) |
| `/acp-resume` | Session start; optional handoff path (M67) |
| `/acp-status` | Snapshot for handoff context |

---

## Upstream tracking

- **Feedback:** `agent/feedback/feedback-007-cross-agent-handoff-protocol.md`
- **Milestone:** `agent/milestones/milestone-67-cross-agent-handoff-protocol.md`
