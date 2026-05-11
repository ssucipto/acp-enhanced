---
id: route-024
title: M41a — Create acp.feedback.md command doc (BUG-003a)
task_type: command-doc-write
milestone: M41
complexity: medium
executor: deepseek-v4-pro
context_required:
  - wiki/domain.yml#commands
  - memory/patterns.md
  - agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md
  - agent/commands/acp.audit.md
files_affected:
  - agent/commands/acp.feedback.md
  - .github/prompts/acp-feedback.prompt.md
  - .opencode/commands/acp-feedback.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Create `agent/commands/acp.feedback.md` — the missing command doc for the feedback capture system. The feedback loop produced M38, M39, M40, and M41 but developers cannot reliably invoke it because no command doc exists. Closes BUG-003a from audit-014.

All three companion files must be created atomically (lessons.md lesson: command-prompt pairing).

## Acceptance Criteria

- [ ] `agent/commands/acp.feedback.md` created with standard ACP command directive header
- [ ] Version 1.0.0, Created 2026-05-11, Status: Active
- [ ] **Purpose**: Capture structured developer feedback about ACP Enhanced system failures, gaps, or improvements; write to `agent/feedback/feedback-NNN.md`
- [ ] **Arguments**: `<type>` (failure|gap|improvement), optional `--severity <critical|high|medium|low>`, optional `--project <name>`
- [ ] **Steps**:
  - Step 0: Display header
  - Step 1: Determine next feedback number (find highest NNN in `agent/feedback/`)
  - Step 2: Gather feedback via chat (problem statement, root cause, proposed fix, evidence)
  - Step 3: Write `agent/feedback/feedback-NNN-{slug}.md` in ACP feedback format
  - Step 4: If severity is critical/high → prompt: "Trigger postmortem audit? Run /acp-audit {subject}"
  - Step 5: Confirm: "Feedback saved: agent/feedback/feedback-NNN-{slug}.md"
- [ ] `.github/prompts/acp-feedback.prompt.md` created: `Read and execute agent/commands/acp.feedback.md`
- [ ] `.opencode/commands/acp-feedback.md` created: same content as prompt file
- [ ] All 3 files created (atomic — command-prompt pairing lesson from lessons.md)

## Implementation Notes

Feedback file format (from feedback-001/002/003 as reference):
```markdown
# ACP Enhanced — Field Feedback Report
## Submission: {title}

**Report ID**: feedback-{NNN}
**Date**: {date}
**Project**: {project}
**ACP Version in use**: {version}
**Executor**: {executor}
**Category**: {type}
**Severity**: {severity}

---

## 1. Problem Statement
...

## 2. Root Cause Analysis
...

## 3. Proposed Fix
...

## 4. Evidence
...
```
