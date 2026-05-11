# Command: feedback

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-feedback` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-feedback` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-11  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Capture structured developer feedback about ACP Enhanced system failures, gaps, or improvements; write to `agent/feedback/feedback-NNN.md`  
**Category**: Workflow  
**Frequency**: As Needed  

---

## Arguments

**CLI-Style Arguments**:
- `<type>` (positional) — feedback category: `failure`, `gap`, or `improvement`
- `--severity <level>` — `critical`, `high`, `medium`, or `low` (default: `medium`)
- `--project <name>` — the project where the issue was observed (default: current project from identity.yml)
- `--title <text>` — short title slug for the feedback file name

**Natural Language**:
- `/acp-feedback` — guided capture with prompts for all fields
- `/acp-feedback gap --severity medium` — capture a gap at medium severity
- `/acp-feedback failure --severity critical "sessions.md lost context"` — capture a critical failure

---

## What This Command Does

Captures structured developer feedback about ACP Enhanced behaviour that needs improvement. The feedback is written to a persistent Markdown file in `agent/feedback/` for:

- System failures (bugs, data loss, crashes)
- Protocol gaps (features that should exist but don't)
- Improvement suggestions (things that work but could be better)

High/critical severity feedback can optionally trigger a postmortem audit via `/acp-audit`.

---

## Prerequisites

- [ ] ACP installed in current directory (`agent/` directory exists)
- [ ] `agent/feedback/` directory exists (create if not)

---

## Steps

### Step 0 — Display Header

```
📣 /acp-feedback
  Capture structured developer feedback about ACP Enhanced
```

### Step 1 — Determine Next Feedback Number

**Actions**:
- List all files matching `agent/feedback/feedback-*.md`
- Extract the highest NNN found (e.g. `feedback-003` → NNN = 3)
- New feedback number = NNN + 1
- If no files exist, start at 001
- Format as zero-padded 3 digits (e.g. `004`)

### Step 2 — Gather Feedback

If `<type>` was passed as argument, use it. Otherwise prompt:

```
Feedback type? (failure / gap / improvement):
```

Then gather the following — ask concisely in one or two questions:

1. **Problem statement** — What went wrong or what is missing? (1–3 sentences)
2. **Root cause** — Why did this happen? What design assumption failed?
3. **Proposed fix** — What should ACP do differently?
4. **Evidence** — Any specific file paths, line numbers, error messages, or session context?

Use the conversation context to pre-fill answers where obvious. Ask only for what is unclear.

### Step 3 — Write Feedback File

Create `agent/feedback/feedback-{NNN}-{slug}.md` where `{slug}` is a short kebab-case label derived from the title.

**File format**:
```markdown
# ACP Enhanced — Field Feedback Report
## Submission: {title}

**Report ID**: feedback-{NNN}
**Date**: {today}
**Project**: {project}
**ACP Version in use**: {version from identity.yml}
**Executor**: {executor from routing.yml}
**Category**: {type} — {brief category description}
**Severity**: {severity}

---

## 1. Problem Statement

{problem_statement}

---

## 2. Root Cause Analysis

{root_cause}

---

## 3. Proposed Fix

{proposed_fix}

---

## 4. Evidence

{evidence}
```

Write the file. Confirm: `✓ Feedback saved: agent/feedback/feedback-{NNN}-{slug}.md`

### Step 4 — Postmortem Prompt (conditional)

If `severity` is `critical` or `high`, prompt the user:

```
Severity is {severity}. Trigger a postmortem audit?
  Run: /acp-audit {slug}
  This will produce an audit report investigating the root cause.

Proceed with audit? (yes/no)
```

If yes: invoke `/acp-audit {slug}` (read and execute `agent/commands/acp.audit.md` with subject = slug).  
If no: skip.

### Step 5 — Confirm

```
✅ /acp-feedback complete
  Feedback: agent/feedback/feedback-{NNN}-{slug}.md
  Severity: {severity}
  Type: {type}

  To trigger a postmortem now: /acp-audit {slug}
  To view all feedback: ls agent/feedback/
```
