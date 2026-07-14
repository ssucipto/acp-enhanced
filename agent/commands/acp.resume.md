# Command: resume

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-resume` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-resume` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.1.0  
**Created**: 2026-02-21  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Resume work on a project by initializing context, reviewing recent progress, and continuing with the next task  
**Category**: Workflow  
**Frequency**: Per Session  

---

## What This Command Does

This command is a convenient alias that combines three essential workflow commands into one:

1. **Initialize Context** - Loads all project documentation via `/acp-init`
2. **Review Recent Work** - Reads the latest session report to understand what was done
3. **Continue Work** - Proceeds with the current/next task via `/acp-proceed`

**Use this when**: Starting a new session or returning to a project after a break.

When an optional handoff path is provided, this command runs the `/acp-receive` verification gate before initialization so the incoming agent confirms assignment, git pin, and session alignment first.

---

## Arguments

| Argument | Aliases | Description |
|---|---|---|
| `<path>` | (positional) | Optional path to an incoming handoff markdown file |
| `@<path>` | `@attach` | Attached handoff file (Cursor `@` reference or equivalent) |

**CLI-Style Arguments**:
- `<path>` (positional) — explicit handoff file path
- `@<path>` — attached handoff file from the user's message

**Natural Language Arguments**:
- `/acp-resume` — standard resume (no handoff receive step)
- `/acp-resume @agent/reports/handoff-cursor-m67-example-2026-07-15.md` — receive then init + proceed
- `/acp-resume agent/reports/handoff-cursor-m67-example-2026-07-15.md` — same, by path

**Argument Parsing**:
- If `@<path>` or an attached file is present → use that path (strip leading `@` if present)
- Else if a positional `<path>` ending in `.md` is provided → use that path
- Else → skip handoff receive (Step 1) and proceed directly to initialization

---

## Prerequisites

- [ ] ACP installed in project
- [ ] `agent/progress.yaml` exists
- [ ] Session reports exist in `agent/reports/` (optional but recommended)

---

## Steps

### 0. Display Command Header

```
⚡ /acp-resume
  Resume work by initializing context, reviewing progress, and continuing next task

  Related:
    /acp-receive   Load and verify incoming handoff only
    /acp-handoff   Generate outgoing handoff
    /acp-init      Initialize context only
    /acp-proceed   Proceed with task only
    /acp-status    Check status without proceeding
    /acp-report    Generate session report
```

This step is informational only — do not wait for user input.

### 1. Optional Handoff Receive

If a handoff path was provided via arguments, run the incoming handoff protocol before initialization.

**Actions**:
- If no handoff path was resolved from arguments → skip this step entirely
- If a handoff path was provided → execute [`/acp-receive`](acp.receive.md) **Steps 1–6** against that path:
  1. Resolve handoff path (already known from arguments)
  2. Parse frontmatter and metadata
  3. Git drift warning (`match` or `DRIFT`)
  4. Session gap warning
  5. Assignment checklist (executor or cross-repo mode)
  6. Output status banner: `[ACP Receive] handoff loaded | git {match|DRIFT} | mode {executor|cross-repo}`
- Do **not** run receive Step 7 (confirm prompt) as a hard stop — after banner and checklist, continue to Step 2 unless the user explicitly asked to pause
- Record resolved handoff path and drift status for the session summary

**Expected Outcome**: Handoff verified (or step skipped when no path provided); assignment checklist visible before init  

### 2. Initialize Agent Context

Run the initialization workflow to load complete project context.

**Actions**:
- Execute `/acp-init` workflow
- Check for ACP updates
- Read all agent documentation
- Read key files from `agent/index/` (via `/acp-init` step 2.8)
- Review key source files
- Update stale documentation
- Refresh progress tracking

**Expected Outcome**: Complete project context loaded (including key file index)  

### 3. Read Latest Session Report

Find and read the most recent session report to understand what was accomplished.

**Actions**:
- List files in `agent/reports/` directory
- Find most recent report (by date in filename)
- Read the report file
- Summarize key accomplishments
- Note any blockers or issues mentioned

**Expected Outcome**: Recent work understood  

### 4. Proceed with Current/Next Task

Continue work by executing the current or next task.

**Actions**:
- Execute `/acp-proceed` workflow
- Identify current task from progress.yaml
- Read task document
- **START IMPLEMENTING immediately**
- Update progress tracking

**Expected Outcome**: Task implementation in progress  

---

## Verification

- [ ] Handoff receive completed when `@path` or `<path>` provided (Steps 1–6)
- [ ] Context initialized successfully
- [ ] Latest report read and summarized
- [ ] Current task identified
- [ ] Implementation started
- [ ] No errors encountered

---

## Expected Output

### Console Output
```
🚀 Resuming Work on Project

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Initializing Context (/acp-init)

✓ ACP version check: v3.7.1 (up to date)
✓ Read agent/progress.yaml
✓ Read 6 design documents
✓ Read 5 milestone documents
✓ Read 36 task documents
✓ Reviewed key source files
✓ Documentation is current
✓ Progress tracking updated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 2: Reviewing Recent Work

📋 Latest Report: agent/reports/report-2026-02-21-session-4.md

Recent Accomplishments:
- ✅ Task 34: Generic YAML parser with AST
- ✅ Task 35: YAML parser migration
- ✅ Created E2E test infrastructure
- ✅ Fixed 11 critical bugs in package scripts
- ✅ Created GitHub Pages package browser

Current Status:
- Milestone 5: Global Package Installation (0% complete)
- Next: Task 25 - Global Infrastructure Setup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 3: Proceeding with Next Task (/acp-proceed)

📋 Current Task: task-25-global-infrastructure

Objective: Create ~/.acp/ directory structure with AGENT.md and manifest.yaml

[Implementation begins...]
```

---

## Examples

### Example 1: Resuming After Break

**Context**: Haven't worked on project in a few days  

**Invocation**: `/acp-resume`  

**Result**: 
- Loads complete context
- Reviews last 3 sessions of work
- Identifies current task (task-12)
- Starts implementing task-12

### Example 2: Starting New Session

**Context**: Beginning work for the day  

**Invocation**: `/acp-resume`  

**Result**:
- Initializes context
- Shows yesterday's accomplishments
- Continues with current task

### Example 3: Switching Agents

**Context**: Different AI agent picking up the project  

**Invocation**: `/acp-resume`  

**Result**:
- Complete onboarding via /acp-init
- Understands recent work from reports
- Ready to contribute immediately

### Example 4: Resume with Executor Handoff

**Context**: Incoming Cursor agent receives a Claude planner handoff  

**Invocation**: `/acp-resume @agent/reports/handoff-cursor-m67-example-2026-07-15.md`  

**Result**:
- Runs receive Steps 1–6 (git pin check, assignment checklist, status banner)
- Initializes full project context via /acp-init
- Proceeds with handoff task sequence via /acp-proceed

---

## Related Commands

- [`/acp-receive`](acp.receive.md) - Load and verify incoming handoff only
- [`/acp-handoff`](acp.handoff.md) - Generate outgoing handoff (executor or cross-repo)
- [`/acp-init`](acp.init.md) - Initialize context only
- [`/acp-proceed`](acp.proceed.md) - Proceed with task only
- [`/acp-status`](acp.status.md) - Check status without proceeding
- [`/acp-report`](acp.report.md) - Generate session report

---

## Troubleshooting

### Issue 1: No reports found

**Symptom**: Warning "No session reports found"  

**Cause**: No reports in agent/reports/ directory  

**Solution**: This is fine for new projects. The command will skip report review and proceed to task execution.  

### Issue 2: Context initialization fails

**Symptom**: Error during /acp-init  

**Cause**: Missing agent/ directory or corrupted files  

**Solution**: Run `/acp-init` separately to see detailed error, fix issues, then run `/acp-resume` again  

### Issue 3: No current task

**Symptom**: Error "No current task found"  

**Cause**: All tasks completed or progress.yaml doesn't have current task  

**Solution**: Review progress.yaml, create new tasks, or mark a task as in_progress  

---

## Notes

- This is a convenience command that chains three workflows
- Equivalent to running: optional `/acp-receive` → `/acp-init` → read reports → `/acp-proceed`
- With handoff path: `/acp-receive` Steps 1–6 run inline before init
- Saves time when starting new sessions
- Provides comprehensive context before starting work
- Reports are optional but highly recommended for context
- If no reports exist, command still works (skips report review)

---

**Namespace**: acp  
**Command**: resume  
**Version**: 1.1.0  
**Created**: 2026-02-21  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Compatibility**: ACP 6.23.0+ (M67 handoff integration)  
**Author**: ACP Project  
