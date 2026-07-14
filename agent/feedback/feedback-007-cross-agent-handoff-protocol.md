# ACP Enhanced — Field Feedback Report
## Submission: Cross-Agent Handoff Protocol — Claude ↔ Cursor same-repo workflow

**Report ID**: feedback-007  
**Date**: 2026-07-13  
**Project**: FIFOZ (Rygan-Institute/FIFOZ, React Native / FastAPI / Firestore)  
**ACP Version in use**: 2.14.2 (`agent/` layout)  
**Executor**: cursor (+ claude/fable field evidence)  
**Category**: gap — protocol missing for multi-executor same-repo handoffs  
**Severity**: high  
**Companion**: audit-245, proposal `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md`

**Submit to**: ACP Enhanced maintainers (same channel as feedback-001…006)

---

## Executive Summary

FIFOZ routinely hands work between **Claude Code / Fable** (planning, audit, product) and **Cursor Composer 2.5** (implementation) on the **same repository**. Nine handoff reports exist in `agent/reports/`; the best (M51 → Cursor, July 2026) include ADR locks, task sequences, git commit pins, and explicit "do not implement" guardrails.

The formal **`/acp-handoff` v1.0.0 command contradicts this practice** — it forbids implementation steps and targets cross-repo transfers only. There is **no `/acp-receive`**, **`/acp-resume` does not load handoffs**, and **`/acp-commit` is not enforced** before handoff despite `routing.yml` suggesting it should be.

**Ask:** Ship **Cross-Agent Handoff Protocol v1** per attached proposal — dual-mode handoff, receive command, executor template, `active_handoff` pointer.

---

## 1. Problem Statement

Multi-executor workflows are a first-class FIFOZ pattern but a second-class ACP feature. Teams compensate with ad-hoc markdown files. This causes:

- `sessions.md` drift (handoff dated 2026-07-13; last session 2026-07-12)
- Receiving agents replanning locked decisions (ADR-019 re-litigation risk on M51)
- No git commit freshness check when picking up handoffs
- No standard return path (implementation status back to Claude)

---

## 2. Root Cause Analysis

| Assumption in `acp.handoff.md` v1.0.0 | FIFOZ reality |
|---------------------------------------|---------------|
| Handoff = different repository | Same repo, different agent/session |
| Receiver applies own judgment without steps | Implementation handoffs need task-730→739 sequence |
| Chat delivery sufficient | Disk + `@` attach is standard |
| Self-contained without source repo | Executor handoffs reference `agent/tasks/`, `progress.yaml` |
| No lifecycle | Handoffs go stale; no active pointer |

audit-066 listed `/acp-handoff` as unused in **sessions** — undercounted because handoffs persist to disk without session commits.

---

## 3. Evidence (FIFOZ)

| Artifact | Role |
|----------|------|
| `handoff-cursor-composer25-m51-2026-07-13.md` | Exemplar executor handoff (Claude → Cursor) |
| `handoff-claude-m47-m48-plan-audit-2026-07-12.md` | Exemplar audit handoff (Cursor → Claude) |
| `audit-245-cross-agent-handoff-acp-enhanced.md` | Gap register H1–H10 |
| `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` | Full spec for upstream |

---

## 4. Proposed Fix (summary — full spec in proposal)

### P0 (framework)

1. **`/acp-handoff --mode executor`** — same-repo template with ADRs, task sequence, git pin, NOT list, return instructions
2. **`/acp-handoff --mode cross-repo`** — retain current behaviour (default)
3. **`/acp-receive [path|--latest]`** — git drift warning, session date check, assignment checklist
4. **Extend `/acp-resume`** — optional handoff path triggers receive protocol

### P1

5. `progress.yaml` → `active_handoff` field  
6. Wiki page `cross-agent-handoff.md` in ACP template  
7. Enforce outgoing chain: commit → handoff → disk → set active_handoff

### P2

8. Frontmatter `status: active|superseded|completed`  
9. `/acp-validate` optional handoff ancestry check

---

## 5. What FIFOZ Will Do Locally Until Upstream Ships

Document ritual in project wiki; manual filename convention; mandatory `/acp-commit` before handoff; manual git pin verify on receive. **Not a substitute for framework support** — drift will recur without structural enforcement.

---

## 6. Acceptance Criteria (for closing feedback-007)

- [x] `acp.handoff.md` bumped to v2 with dual modes — shipped v6.23.0 (`4baae9b`)
- [x] `acp.receive.md` added to `agent/commands/` — shipped v6.23.0
- [x] Cursor/OpenCode command wrappers synced — 70×3 parity verified audit-079
- [x] Proposal §13 acceptance criteria met — audit-079 cross-check ✅
- [ ] FIFOZ `/acp-version-update` picks up release and retires local wiki workaround — **consumer action** (FIFOZ runs after upstream tag `v6.23.0`)

---

## 7. Priority Justification

**High severity** because:

- Monetisation milestone M51 (FIFOZ Pro) handoff is active **now**
- Wrong-agent replanning wastes multi-day planning artifacts (ADR-019, audits 241–243)
- Git drift without warning risks implementing on wrong commit base
- Pattern will repeat every milestone at FIFOZ scale (240+ audits, 50+ milestones)

---

## 8. Related Feedback

| ID | Relationship |
|----|--------------|
| feedback-002 | Workflow alignment; commit/sync gaps |
| audit-066 | Undercounted handoff usage |

---

**Full specification:** `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md`  
**Audit backing:** `agent/reports/audit-245-cross-agent-handoff-acp-enhanced.md`
