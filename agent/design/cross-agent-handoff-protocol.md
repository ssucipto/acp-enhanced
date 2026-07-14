# Cross-Agent Handoff Protocol — Design

<!-- @acp.meta.design
topic: cross-agent, handoff, multi-executor, claude, cursor
description: Dual-mode handoff (executor + cross-repo), receive protocol, active_handoff lifecycle
status: accepted
updated: 2026-07-15
milestone: M67
proposal: agent/proposals/acp-enhanced-cross-agent-handoff-v1.md
audit: agent/reports/audit-077-cross-agent-handoff-feedback-007.md
@acp.meta.end -->

**Status**: Accepted (M67)  
**Target version**: v6.23.0  
**Field evidence**: FIFOZ audit-245, feedback-007, M51 exemplar

---

## Problem

ACP `/acp-handoff` v1.0.0 optimizes for **cross-repo, problem-only** transfers. Production teams run **same-repo multi-executor** workflows (Claude plan → Cursor implement) with disk-persisted handoffs that include ADR locks, task sequences, and git pins — content the v1 command **explicitly forbids**.

Without framework support, teams take shortcuts (S1–S6 in audit-245): handoff without commit, ad-hoc structure, no git drift check, no return path.

---

## Solution overview

| Layer | Component | Responsibility |
|-------|-----------|----------------|
| Outgoing | `/acp-handoff --mode executor` | Mandatory §4 template, git pin, commit chain |
| Outgoing | `/acp-handoff --mode cross-repo` | Preserve v1.0.0 behaviour (default) |
| Incoming | `/acp-receive` | Drift warning, session gap, assignment checklist |
| Bridge | `/acp-resume @handoff` | Receive steps then standard resume |
| State | `progress.yaml` → `active_handoff` | Discoverability + `--latest` resolution |
| Docs | `agent/wiki/cross-agent-handoff.md` | Ritual diagram, mode selection, exemplar refs |
| Lifecycle | P2 (route-194) | superseded, HANDOFF-LATEST, ancestry validate |

---

## Mode selection

```
Same repo + different executor?  → --mode executor --to <target>
Different repository?            → --mode cross-repo (default)
Session summary for humans?        → /acp-report (NOT handoff)
```

---

## Executor template (mandatory sections)

Per proposal §4 — command verification **fails** if any section missing in executor mode:

1. YAML frontmatter (`handoff_mode`, executors, `git_commit`, `git_branch`, `status`)
2. Model / executor requirements
3. Start here (receiving agent protocol)
4. Problem / context
5. Locked decisions (ADR refs)
6. Assignment (Implement | Audit | Document)
7. Plan reference (milestone, tasks, sequence)
8. What NOT to do
9. State to update
10. Adjacent context (out of scope)
11. Return handoff instructions
12. Reference chain

---

## Anti-shortcut guardrails (audit-245 S1–S6)

| Shortcut | Guardrail | Route |
|----------|-----------|-------|
| S1 Handoff without commit | Outgoing ritual step 1; receive warns on session gap | 190, 191 |
| S2 Ad-hoc structure | Executor template mandatory sections + E2E | 190, 195 |
| S3 No git freshness | receive step 3 drift warning | 191, 195 |
| S4 No return handoff | Template § Return + wiki | 190, 193 |
| S5 Assuming handoff sufficient | Wiki ritual + routing chain text | 190, 193 |
| S6 Adjacent scope confusion | Template § Adjacent context | 190 |

---

## Ecosystem integration (no orphan commands)

New `/acp-receive` must ship with full framework parity — **not** command-doc only:

- `package.yaml` entry (closes HIGH-067-001 class for this command)
- `agent/wiki/domain.yml` taxonomy entry
- `agent/index/acp.core.yaml` discoverability (`applies: acp.handoff, acp.receive, acp.resume`)
- 3× wrappers (cursor, opencode, github prompts)
- E2E behavioral fixtures (not grep-only)
- CHANGELOG v6.23.0

---

## Dependency graph

```
route-190 (handoff v2)
  → route-191 (receive)
    → route-192 (resume)
      → route-193 (schema + wiki)
        → route-194 (lifecycle P2)
        → route-195 (E2E fixtures)
        → route-196 (ecosystem parity)
          → route-197 (release + carryover closure)
```

---

## Non-goals (v1)

- Agent-to-agent transport / messaging bus
- Handoff merge/diff for concurrent handoffs
- Replacing `/acp-report`

---

## Acceptance

Proposal §13 + feedback-007 §6 — all criteria must pass before marking M67 complete and closing carryovers H1–H10.
