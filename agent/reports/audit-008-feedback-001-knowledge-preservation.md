# Audit Report: Field Feedback — Proactive Commit & Knowledge Preservation

**Audit**: #008  
**Date**: 2026-05-09  
**Subject**: feedback-001 — Knowledge loss from context window overflow (TikrFlow project)  
**Feedback source**: `agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md`  
**Executor**: copilot (claude-sonnet-4-6)

---

## Summary

Field report from the TikrFlow project (a SaaS using ACP Enhanced) documented **3 consecutive sessions of work permanently lost** to context window overflow. Lost material included: 2 full audit reports (audit-40: 14 findings, audit-41: 19 findings), 6 ADR-level architectural decisions, 8 code patterns, and critical bug fix documentation (Firestore composite index). Retroactive reconstruction required a full additional session and likely lost nuance permanently.

Root cause: the ACP Enhanced base protocol treats `/acp-commit` as an **end-of-session, developer-triggered** action. This design fails when sessions overflow silently — which is structurally unavoidable at certain task sizes. The feedback report proposes — and partially implements in the TikrFlow project — a shift to **proactive, continuous, event-triggered** memory writes.

This audit reviews their analysis, validates their proposed fixes, and implements the approved changes in ACP Enhanced upstream.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md` | Feedback | Primary source — full problem/solution analysis |
| `AGENTS.md` | Protocol | Context loading protocol — Step 4 and Session Commit section |
| `CLAUDE.md` | Protocol | Identical to AGENTS.md — same changes required |
| `.github/copilot-instructions.md` | Protocol | Identical to AGENTS.md — same changes required |
| `agent/core/constraints.yml` | Config | Hard rules — `never_skip_acp_commit` exists but unenforced |
| `agent/commands/acp.commit.md` | Command | v1.0.0 — end-of-session framing throughout |
| `agent/memory/lessons.md` | Memory | Lessons log — no knowledge-preservation entry yet |
| `agent/memory/sessions.md` | Memory | Confirms passive commit pattern in all existing entries |

---

## Key Findings

| Finding | Severity | Location | Notes |
|---------|----------|----------|-------|
| `never_skip_acp_commit` rule has no trigger mechanism | High | `agent/core/constraints.yml:6` | Rule is aspirational only — fires on honour system |
| `/acp-commit` framing: "end of session" 3 times | High | `agent/commands/acp.commit.md:19,32,35` | Reinforces passive-reactive mental model |
| Step 4 reads sessions.md but never checks for gaps | Medium | `AGENTS.md:52-56` | Agent cannot detect a missed commit from prior session |
| No trigger for mid-session knowledge writes | High | `AGENTS.md` (absent) | Audit creation, git commits, ADRs — none trigger memory writes |
| `key_fact: null` is common in existing sessions | Low | `agent/memory/sessions.md` | Suggests knowledge capture is underprioritised |
| Context budget section warns about tokens but not overflow | Medium | `AGENTS.md:73-95` | No mention of context overflow as a data-loss risk |

---

## Key Decisions

### Accepted from feedback-001 (all 5 recommendations)

1. **R1 — Add Mid-Session Commit Triggers table** to AGENTS.md/CLAUDE.md between Step 6 and Context Budget. This is the highest-leverage single change.

2. **R2 — Add gap-check substep to Step 4** of context loading protocol. Zero extra file reads; surfaces knowledge gaps at session start automatically.

3. **R3 — Add context overflow risk warning to acp.commit.md**. Upgrades from v1.0.0 → v1.1.0. Adds proactive trigger list to command definition.

4. **R4 — Add 6 knowledge-preservation hard rules to constraints.yml**. Elevates guidance to constraint-level enforcement.

5. **R5 (Optional) — NOT adopted**: Rename `/acp-commit` to `/acp-checkpoint`. The naming change would require updating 58+ command docs, .github/prompts/, .opencode/commands/, AGENT.md, README.md. Too invasive for the marginal framing benefit. The proactive trigger table achieves the same mental model shift.

### Analysis Notes

- The feedback's root cause analysis (4 failure modes) is accurate and well-grounded. All 4 are structural, not behavioral — they cannot be fixed by telling agents to "try harder."
- The WAL (write-ahead logging) analogy in L2 is correct and maps well to how ACP memory should behave.
- L3 ("rules without enforcement mechanisms have near-zero effect") directly explains why the existing `never_skip_acp_commit` rule failed. The fix is operational triggers, not stronger language.
- The rename proposal (R5) is philosophically correct but rejected on cost grounds. The trigger table achieves the same shift.

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `AGENTS.md:52` | Step 4 — add gap-check as substep 2 |
| `AGENTS.md:69` | After Step 6 — insert Mid-Session Commit Triggers section |
| `AGENTS.md:112` | Session Commit Protocol — update to reference proactive triggers |
| `agent/core/constraints.yml:6` | `never_skip_acp_commit` — supplement with 6 new rules below it |
| `agent/commands/acp.commit.md:19` | Frequency line — change to "phase boundary AND session end" |
| `agent/commands/acp.commit.md:28` | "What This Command Does" — add overflow warning + trigger list |
| `agent/memory/lessons.md:1` | Prepend high-priority postmortem lesson |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-06 | `4cdd98d` | chore(memory): acp-commit — status + Q&A session |
| 2026-05-06 | `ee065b8` | chore(memory): acp-commit — M25 session + tanstack-start-v1 pattern |
| 2026-05-06 | `7a99f46` | feat(commands): add @acp.visualize + M25 milestone complete |

*(TikrFlow commits bed391e and 39b47bd are in the external project — not in this repo)*

---

## Recommendations

1. **[DONE]** Implement R1–R4 from feedback-001 in AGENTS.md, CLAUDE.md, constraints.yml, acp.commit.md, and lessons.md.
2. **[FUTURE]** Consider adding an `/acp-checkpoint` command (additive, not rename) as a shorter alias for mid-session partial commits — zero cost, could improve adoption.
3. **[FUTURE]** Add a "sessions gap detector" step to `/acp-init`: compare most recent `sessions.md` date against recent git log dates — alert if gap > 1 day with uncommitted sessions.
