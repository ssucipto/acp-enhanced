# ACP Enhanced — Field Feedback Report
## Submission: Proactive Commit Triggers & Knowledge Preservation System

**Report ID**: feedback-001  
**Date**: 2026-05-11  
**Project**: TikrFlow (timesheet & work order management SaaS)  
**ACP Version in use**: ACP Enhanced (AGENTS.md / CLAUDE.md / copilot-instructions.md pattern)  
**Executor**: claude-sonnet-4-6  
**Submitted by**: TikrFlow solo-developer, via GitHub Copilot agent session  
**Category**: System reliability — knowledge persistence  
**Severity**: High — data loss in production use  

---

## 1. Problem Statement

Three consecutive sessions of development work were **permanently lost** when context window overflow terminated sessions before `/acp-commit` could be run. The work included:

- Firestore composite index bug fix (discovered, fixed, deployed — but never logged to lessons.md)
- `next-themes` pre-installation discovery (architectural decision that changed M20 plan — no ADR written)
- Two full audit reports (audit-40: CSS dark mode readiness, 14 findings; audit-41: optimization, 19 findings) — no session entries written
- 6 new ADR-level decisions about CSS architecture and dark mode implementation sequencing
- 8 new patterns for dark mode, Recharts, Firestore index JSON format

The retroactive reconstruction of this knowledge took a full additional session and required reading git logs, conversation summaries, and partially regenerating conclusions from scratch. **Some nuance may have been permanently lost.**

---

## 2. Root Cause Analysis

Three distinct, compounding failure modes:

### Failure 1 — `/acp-commit` is passive and end-of-session only

The AGENTS.md protocol defines `/acp-commit` as something "the developer runs" at the end of a session. This design assumes:
- Sessions end cleanly
- The developer remembers to run the command
- The agent has context window remaining when the session ends

None of these assumptions hold reliably in practice. **Context window overflow is silent — it terminates without warning, without a final turn.**

### Failure 2 — No session-start continuity check

The context loading protocol (Steps 1–6) loads memory from `sessions.md` but never asks: *"Was the last session actually committed? Is there a gap between the last sessions.md entry and recent git history?"*

A session that overflowed and was never committed looks identical to a freshly started session. The agent has no way to detect the gap automatically.

### Failure 3 — Constraints without enforcement

`constraints.yml` had `never_skip_acp_commit` but no mechanism to enforce it. A rule that is only stated, not triggered, provides no real protection.

### Failure 4 — Knowledge capture was treated as an event, not a habit

The system treated ACP memory writes as a single atomic act (`/acp-commit`) at the end of a session. In practice, valuable knowledge — a discovered bug pattern, an architectural decision, a reusable code pattern — emerges **mid-session**, at the exact moment the agent encounters it. Deferring capture to session end means a single context overflow erases all of it.

---

## 3. Changes Made to ACP Enhanced System Files

### 3.1 `AGENTS.md` / `CLAUDE.md` — Context Loading Protocol

**File(s) modified**: `AGENTS.md` (and equivalent `CLAUDE.md`, `copilot-instructions.md` in the project root)

#### Change A — Step 4: Session-Start Gap Check

Added a mandatory gap-check substep to the context loading protocol. Previously Step 4 was:

```markdown
### Step 4 — Load Working Memory (filtered)
1. Read last 3 entries from `agent/memory/sessions.md` only
2. Read `agent/memory/lessons.md` — filter to entries where
   `trigger` matches current task_type OR `priority: high`
   Load maximum 5 lesson entries.
```

**Changed to:**

```markdown
### Step 4 — Load Working Memory (filtered)
1. Read last 3 entries from `agent/memory/sessions.md` only
2. **Gap check**: Look at the most recent session's `deferred:` list and `date:`.
   If today's date is the same or later than the last commit date AND there are
   deferred items marked `→ next session`, those items are your current backlog —
   acknowledge them before starting.
3. Read `agent/memory/lessons.md` — filter to entries where
   `trigger` matches current task_type OR `priority: high`
   Load maximum 5 lesson entries.
```

**Purpose**: Forces the agent to surface deferred work from the previous session before starting anything new, making knowledge gaps visible rather than silent.

#### Change B — New Section: "Mid-Session Commit Triggers"

Added a new top-level section between Step 6 (Confirm and Proceed) and the Context Budget section:

```markdown
## Mid-Session Commit Triggers (PROACTIVE — do not wait for /acp-commit)

The agent MUST proactively write a session entry and update lessons/patterns WITHOUT
waiting for the developer to run `/acp-commit` whenever ANY of these events occur:

| Trigger | Action |
|---------|--------|
| A milestone phase completes (e.g. all tasks in M20 Phase 1 done) | Write session entry to sessions.md |
| An audit report is created (audit-N.md committed) | Capture key findings in lessons.md |
| An architectural decision is made | Create ADR via decisions.md immediately |
| A new reusable pattern is discovered | Append to patterns.md immediately |
| A correction is given by the developer | Append to lessons.md immediately (Correction Protocol) |
| Context window is approaching capacity (summarization imminent) | Write session entry NOW, before overflow |
| A `git commit` is made with more than 5 files changed | Treat as phase boundary — write session entry |

**The rule**: ACP writes happen at the moment of discovery, not at session end.
`sessions.md` entries are written incrementally per phase, not as one big end-of-session dump.

### Why This Matters
Context window overflow is a system-level constraint — it will terminate sessions without
warning and without a chance to run `/acp-commit`. Any knowledge not written to disk at
the time of discovery is permanently lost. Write immediately, not later.
```

**Purpose**: Changes the mental model from "commit at session end" to "commit at the moment of discovery." Seven specific trigger events are enumerated so the agent has unambiguous decision criteria.

---

### 3.2 `agent/core/constraints.yml` — Hard Rules

**File modified**: `agent/core/constraints.yml`

Added 6 new knowledge-preservation rules to the `rules:` block:

```yaml
# Knowledge preservation rules — added 2026-05-11 after knowledge-gap postmortem
- write_lessons_at_discovery: never defer lesson logging to end-of-session; write
    immediately when a bug/mistake/finding is confirmed
- write_session_at_phase_boundary: write a sessions.md entry when a milestone phase,
    audit, or task group completes — do NOT wait for /acp-commit
- write_patterns_at_discovery: when a reusable pattern emerges, append to patterns.md
    before continuing
- write_adr_at_decision: when an architectural decision is made, create the ADR entry
    immediately in decisions.md
- context_overflow_commit_first: if the context window is nearing capacity, write all
    pending ACP entries BEFORE working on implementation
- validate_prior_session_at_start: on session start (Step 4), check if the most recent
    sessions.md entry covers recent git commits — if not, note the gap in your response
```

**Purpose**: Converts the proactive commit behaviour from "guidance in AGENTS.md" to "hard constraint" with the same enforcement weight as existing rules like `never_load_all_wiki_files`.

---

### 3.3 `agent/commands/acp.commit.md` — Command Definition

**File modified**: `agent/commands/acp.commit.md`  
**Version bump**: 1.0.0 → 1.1.0

Three targeted changes:

#### Change A — Metadata update
- `Last Updated`: 2026-05-05 → 2026-05-11
- `Version`: 1.0.0 → 1.1.0

#### Change B — Frequency line
```
# Before
Frequency: End of every session — required, never skip

# After
Frequency: At every phase boundary AND at session end — required, never skip
```

#### Change C — "What This Command Does" section

Added a critical risk warning and proactive trigger list:

```markdown
> **CRITICAL — Context Window Overflow Risk**: If a session ends due to context window
> overflow before `/acp-commit` is run, all session knowledge is permanently lost. Do
> not defer commits to the end of a long session. Write incrementally.

**Use this when**:
- Closing VS Code / opencode at end of a work session
- Handing off to another agent or executor
- Completing a milestone phase before switching focus
- **PROACTIVE (do not wait for /acp-commit command)**:
  - After any audit report is created
  - After a git commit touching >5 files
  - After any architectural decision is made
  - When a correction is given by the developer
  - Whenever the context window is approaching capacity

Each of these events triggers an **immediate partial commit** — you do not wait for the
developer to type `/acp-commit`.
```

#### Change D — Changelog section appended

```markdown
## v1.1.0 Changelog (2026-05-11)

- Frequency changed from "end of session" to "phase boundary" (proactive)
- Added context-window overflow risk warning
- Clarified that agent must commit immediately at phase events, not wait for `/acp-commit`
- Root cause: M19/M20/audit-40/41 sessions lost to context overflow — 3 sessions of work
  required retroactive reconstruction. Lesson: `acp-knowledge-gap` in lessons.md.
```

---

### 3.4 `agent/memory/lessons.md` — Postmortem Lesson Entry

**File modified**: `agent/memory/lessons.md`

Appended a high-priority lesson documenting the postmortem:

```yaml
- date: 2026-05-11
  task_type: all
  mistake: |
    Multiple sessions of work (M19 source changes, Firestore index fix, audit-40 findings,
    audit-41 findings, next-themes discovery, ADR for dark mode) were never committed to
    ACP memory. The context window overflowed before /acp-commit could be run, and the
    developer ran no explicit /acp-commit between sessions. Three sessions of knowledge
    required retroactive reconstruction from git log, conversation summaries, and memory.
  correction: |
    ACP commits must be PROACTIVE, not reactive. Write session entries, lessons, and
    patterns at the moment of discovery — not at session end. Specific triggers:
      1. After every audit report is created → write session entry + lessons to .md files
      2. After every git commit with >5 files → treat as phase boundary → write session entry
      3. When a correction is given → write lesson IMMEDIATELY, acknowledge in response
      4. When a new pattern emerges → append to patterns.md before continuing
      5. When context window approaches capacity → write all pending ACP entries FIRST
    The /acp-commit command should be used to FINALIZE a session that already has most
    of its entries written, not as the sole moment of capture.
    Updated files: AGENTS.md (Mid-Session Commit Triggers table), constraints.yml
    (6 new knowledge-preservation rules), acp.commit.md v1.1.0.
  priority: high
```

---

## 4. Files Changed Summary

| File | Type | Change |
|------|------|--------|
| `AGENTS.md` | Protocol | Step 4 gap-check substep added; new "Mid-Session Commit Triggers" section (7 triggers) |
| `CLAUDE.md` | Protocol | Same changes as AGENTS.md (project uses both) |
| `agent/core/constraints.yml` | Hard rules | 6 new `rules:` entries for knowledge preservation |
| `agent/commands/acp.commit.md` | Command definition | v1.0.0 → v1.1.0; frequency, risk warning, proactive triggers, changelog |
| `agent/memory/lessons.md` | Memory | 1 high-priority postmortem lesson appended |

**Git commits:**
- `bed391e` — `docs(acp): knowledge sweep — M19/M20 lessons, ADR-006/007, dark mode patterns, frontend wiki`
- `39b47bd` — `fix(acp): proactive commit triggers — prevent knowledge-gap from context overflow`

---

## 5. Proposed Changes for ACP Enhanced Upstream

The following changes are recommended for the ACP Enhanced project's base templates:

### 5.1 Recommended: Add "Mid-Session Commit Triggers" to base AGENTS.md template

The proactive trigger table (Section 3.1 Change B above) should be part of the base ACP Enhanced template, placed between Step 6 and the Context Budget section. This is the single highest-leverage change — it shifts the system's mental model from passive-reactive to proactive-continuous.

**Proposed placement in base AGENTS.md:**
```
Step 6 — Confirm and Proceed
  ↓
[NEW] Mid-Session Commit Triggers  ← insert here
  ↓
Context Budget Hard Limits
  ↓
Correction Protocol
  ↓
Session Commit Protocol (/acp-commit)
```

### 5.2 Recommended: Add gap-check substep to Step 4 of base template

The gap-check instruction added to Step 4 (Section 3.1 Change A) should be in the base template. It requires zero extra file reads and adds a self-healing property: the agent surfaces its own knowledge gaps at the start of every session.

### 5.3 Recommended: Add context overflow warning to base acp.commit.md

The risk warning (Section 3.3 Change C) should be in the base command definition. Users who are not aware of context window overflow mechanics will not know this risk exists.

### 5.4 Optional: Add knowledge-preservation rules to base constraints.yml template

The 6 rules added in Section 3.2 could be included in the base `constraints.yml` template under a dedicated comment block. They formalize the proactive commit behaviour as hard constraints rather than guidance.

### 5.5 Optional: Rename `/acp-commit` to `/acp-checkpoint` with `/acp-commit` as alias

The name "commit" implies a one-time, end-of-session act. "Checkpoint" better communicates that this should happen frequently throughout a session. If the upstream project is open to naming changes, this framing would reduce misuse without changing any behaviour.

---

## 6. Observed Impact

After implementing these changes, the agent behaviour changed immediately:

1. **Session-start gap acknowledgement**: Opening the next session, the agent read the `deferred:` list from the most recent `sessions.md` entry and acknowledged outstanding work before starting.

2. **Proactive lesson write**: When the developer asked about the knowledge gap, the agent wrote the postmortem lesson to `lessons.md` mid-conversation, before completing the rest of the task — not at the end.

3. **Reduced backlog recovery time**: The ACP documentation sweep session (which reconstructed 3 sessions of lost knowledge) is now itself fully documented in `sessions.md` — meaning the next session will not need to do any reconstruction.

---

## 7. Lessons for ACP Enhanced Project

### L1 — Context window overflow is the primary threat to ACP knowledge continuity

The ACP system is designed around a `sessions.md` file that acts as working memory. But this memory is only useful if it is written to. The single biggest threat to that write happening is context window overflow — which is invisible, unavoidable at certain task sizes, and provides no warning. The system must be designed as if every session might overflow.

### L2 — "At session end" is not a reliable trigger

Any trigger that depends on a session ending cleanly is fragile. The reliable trigger is: *at the moment knowledge is produced*. This is the same principle as database WAL (write-ahead logging) — write immediately, compact later.

### L3 — Rules without enforcement mechanisms have near-zero effect

`never_skip_acp_commit` existed in `constraints.yml` before this incident. It did not prevent the knowledge gap. Constraints that work are operational (they fire automatically based on detectable events), not aspirational (they rely on the agent remembering to check a list).

### L4 — The cost of retroactive reconstruction is high and lossy

Reconstructing 3 sessions of work took a full additional session. Some nuance (exact wording of decisions, specific error messages, intermediate conclusions) was likely permanently lost. The true cost of a single missed `/acp-commit` is not "one missing entry" — it is "everything produced in all sessions since the last commit."

---

## 8. Attachments / References

- `agent/reports/audit-40-css-dark-mode-readiness.md` — 14 findings, was the work lost in the gap
- `agent/reports/audit-41-optimization-premium-ui.md` — 19 findings, was the work lost in the gap  
- `agent/memory/lessons.md` — postmortem lesson at bottom of file
- `agent/commands/acp.commit.md` — updated command definition (v1.1.0)
- `agent/core/constraints.yml` — updated constraints
- `AGENTS.md` — updated context loading protocol with Mid-Session Commit Triggers

---

*This report was prepared by the GitHub Copilot agent (claude-sonnet-4-6) operating under ACP Enhanced on the TikrFlow project. It is submitted for consideration by the ACP Enhanced development project to improve the base protocol templates.*
