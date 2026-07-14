# Command: receive

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-receive` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-receive` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-07-15  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Load an incoming handoff, verify git and session alignment, and print the assignment checklist before work begins  
**Category**: Workflow  
**Frequency**: Per Session (when receiving a handoff from another agent or executor)  

---

## Arguments

| Argument | Aliases | Description |
|---|---|---|
| `<path>` | (positional) | Path to a handoff markdown file on disk |
| `@<path>` | `@attach` | Attached handoff file (Cursor `@` reference or equivalent) |
| `--latest` | `-l` | Resolve handoff from `progress.yaml` → `HANDOFF-LATEST.md` → error |

**CLI-Style Arguments**:
- `<path>` (positional) — explicit handoff file path
- `@<path>` — attached handoff file from the user's message
- `--latest` or `-l` — resolve the most recent handoff pointer

**Natural Language Arguments**:
- `/acp-receive` — same as `--latest` (resolve from project pointers)
- `/acp-receive @agent/reports/handoff-cursor-m51-2026-07-13.md` — load attached handoff
- `/acp-receive agent/reports/handoff-cursor-m51-2026-07-13.md` — load by path
- `/acp-receive --latest` — resolve from `active_handoff` or `HANDOFF-LATEST.md`

**Argument Parsing**:
The agent infers intent from context:
- If `@<path>` or an attached file is present → use that path (strip leading `@` if present)
- Else if a positional `<path>` is provided → use that path
- Else if `--latest` is passed or no arguments → run `--latest` resolution (see Step 1)
- `--latest` resolution order (stop at first hit):
  1. Read `agent/progress.yaml` → `active_handoff.path` (when `status` is `active` or unset)
  2. Read `agent/reports/HANDOFF-LATEST.md` (repo-relative `HANDOFF-LATEST.md` copy)
  3. **Error** — output: `No handoff found. Provide a path, attach a file, or run outgoing /acp-handoff first.`

---

## What This Command Does

This command is the **receiving-side protocol** for cross-agent handoffs (M67). It loads a handoff document produced by `/acp-handoff`, verifies that the local git state matches the handoff pin, checks for session memory gaps, and prints an assignment checklist so the incoming agent knows what to implement, audit, or document — and what **not** to do.

Unlike `/acp-report` (session summary) or `/acp-resume` (full init + proceed), `/acp-receive` is a **narrow verification gate** focused on handoff integrity before work starts.

---

## Prerequisites

- [ ] ACP installed in current directory (`agent/` exists)
- [ ] A handoff file exists (explicit path, attachment, or resolvable via `--latest`)
- [ ] Git repository available (for drift check)

---

## Steps

### 0. Display Command Header

```
⚡ /acp-receive
  Load and verify an incoming handoff before starting work

  Usage:
    /acp-receive                                    Resolve latest handoff
    /acp-receive --latest                           Same as above
    /acp-receive @agent/reports/handoff-....md      Load attached handoff
    /acp-receive agent/reports/handoff-....md       Load by path

  Related:
    /acp-handoff    Generate outgoing handoff
    /acp-resume     Receive + init + proceed (optional handoff arg)
    /acp-proceed    Start work after receive checklist
```

This step is informational only — do not wait for user input.

### 1. Resolve Handoff Path

Determine which handoff file to load.

**Actions**:
- Apply argument parsing rules (see Arguments section)
- For `--latest` / no-args resolution:
  1. Read `agent/progress.yaml` and extract `active_handoff.path`
  2. If missing or file not found, try `agent/reports/HANDOFF-LATEST.md`
  3. If still missing, **stop** with error (do not proceed to later steps)
- Verify the resolved file exists and is readable
- Record the resolved absolute path for output

**Expected Outcome**: Handoff file path resolved and file loaded into context  

### 2. Parse Frontmatter and Metadata

Extract git pin, mode, executors, and date from the handoff.

**Actions**:
- If YAML frontmatter delimited by `---` is present, parse these fields (when set):
  - `handoff_mode` — `executor` or `cross-repo`
  - `from_executor`, `to_executor`
  - `date`
  - `git_branch`, `git_commit` (full SHA preferred)
  - `status`, `supersedes`
- If frontmatter is absent (legacy cross-repo handoff), scrape from body:
  - Search for `git_commit:` / `git branch:` / `HEAD:` / `branch:` patterns
  - Infer `handoff_mode: cross-repo` unless body contains executor template sections (`## Assignment`, `## What NOT to do`)
- Record parsed values for steps 3–6

**Expected Outcome**: `handoff_mode`, `git_commit`, `git_branch`, and handoff `date` available (or explicitly marked missing)  

### 3. Git Drift Warning

Compare handoff git pin to current repository state.

**Actions**:
- Run `git rev-parse HEAD` → current SHA
- Run `git branch --show-current` → current branch
- Compare `git_commit` from handoff to current SHA (match full SHA or unique short prefix)
- Compare `git_branch` from handoff to current branch when both are present
- Set drift flag:
  - **Match** — SHA matches (and branch matches when specified)
  - **DRIFT** — SHA or branch mismatch, or handoff pin missing
- If **DRIFT** and handoff pin exists:
  - Warn prominently (non-blocking — do not abort)
  - List commits since pin: `git log <pin>..HEAD --oneline`
  - Note: incoming agent may be ahead of planner; confirm intent before reverting or replanning
- If handoff pin missing, warn: `Handoff has no git_commit pin — drift check skipped`

**Expected Outcome**: Drift status determined as `match` or `DRIFT`  

### 4. Session Gap Warning

Compare handoff date to the most recent session memory entry.

**Actions**:
- Read the **last entry** from `agent/memory/sessions.md` (most recent `- date:` block)
- Compare handoff `date` (frontmatter or filename) to last session `date`
- If handoff date is **newer** than last session date:
  - Warn prominently: `Session gap detected — handoff is newer than last /acp-commit entry`
  - Recommend: run outgoing agent's `/acp-commit` or manually note the gap before proceeding
- If `sessions.md` is empty or unreadable, warn once and continue

**Expected Outcome**: Session gap noted or confirmed absent  

### 5. Assignment Checklist

Print actionable checklist based on handoff mode.

**Actions**:
- Read `handoff_mode` (default `cross-repo` if unknown)
- **If `handoff_mode: executor`**, extract and print:
  - **Assignment** — Implement | Audit only | Document only (from `## Assignment` section)
  - **What NOT to do** — bullet list from `## What NOT to do`
  - **Sequence** — task order from `## Plan reference` (milestone, tasks, dependency graph)
  - **Locked decisions** — ADR IDs from `## Locked decisions (do not re-litigate)` (summary only)
  - **Return handoff** — remind: generate `/acp-handoff --mode executor --to {from_executor}` when done or blocked
- **If `handoff_mode: cross-repo`**, extract and print:
  - **Problem / request** summary (from body)
  - **Source project** back-reference if present
  - Note: no task sequence — receiving agent applies local judgment
- If `status: superseded` in frontmatter, warn: `This handoff is marked superseded — confirm before proceeding`

**Expected Outcome**: Incoming agent sees a clear, mode-appropriate checklist  

### 6. Output Status Banner

Emit the canonical one-line status banner.

**Actions**:
- Output exactly one line using resolved values:

```
[ACP Receive] handoff loaded | git {match|DRIFT} | mode {executor|cross-repo}
```

- Substitute `{match|DRIFT}` from Step 3
- Substitute `{executor|cross-repo}` from `handoff_mode`
- Include resolved file path on the next line for traceability

**Expected Outcome**: Banner printed; user can scan git and mode at a glance  

### 7. Confirm Before Proceeding

Prompt the receiving agent (and user) to acknowledge the assignment.

**Actions**:
- Prompt: `Confirm assignment mode before proceeding.`
- Do **not** auto-start implementation — wait for confirmation unless the user already stated intent in the same message
- After confirmation, suggest: `/acp-proceed` (executor handoff) or `/acp-resume @handoff-path` (receive + full init)

**Expected Outcome**: User or agent explicitly confirms assignment before work begins  

---

## Verification

- [ ] Handoff path resolved (argument, `@attach`, or `--latest` chain)
- [ ] `--latest` tries `active_handoff.path` then `agent/reports/HANDOFF-LATEST.md` before error
- [ ] Frontmatter parsed; legacy body scrape attempted when frontmatter absent
- [ ] Git drift check run; `match` or `DRIFT` reported with `git log` on drift
- [ ] Session gap warning when handoff date > last `sessions.md` entry
- [ ] Executor mode prints assignment, NOT list, and sequence
- [ ] Status banner matches: `[ACP Receive] handoff loaded | git {match|DRIFT} | mode {executor|cross-repo}`
- [ ] Confirmation prompt issued before proceeding

---

## Expected Output

### Successful Receive (executor mode, git match)

```
[ACP Receive] handoff loaded | git match | mode executor
File: agent/reports/handoff-cursor-m67-example-2026-07-15.md

Assignment: Implement
Sequence: task-196 → task-200 → task-201
NOT: Do not modify acp.handoff.md v1 sections until route-190 lands

Confirm assignment mode before proceeding.
```

### Git Drift (non-blocking)

```
⚠️ Git DRIFT: handoff pin abc1234 ≠ HEAD def5678 (branch: develop)

Commits since pin:
def5678 fix: receive wrapper parity
...

[ACP Receive] handoff loaded | git DRIFT | mode executor

Confirm assignment mode before proceeding.
```

### No Handoff Found

```
❌ No handoff found. Provide a path, attach a file, or run outgoing /acp-handoff first.
```

---

## Examples

### Example 1: Attached executor handoff

**Invocation**: `/acp-receive @agent/reports/handoff-cursor-m51-consumer-project-pro-2026-07-13.md`  

**Result**: Parses frontmatter, verifies git pin, prints assignment checklist and NOT list, emits banner with `mode executor`.  

### Example 2: Latest pointer

**Invocation**: `/acp-receive --latest`  

**Result**: Reads `active_handoff.path` from `progress.yaml`, loads file, runs full receive protocol.  

### Example 3: Cross-repo legacy handoff

**Invocation**: `/acp-receive agent/reports/handoff-weaviate-schema-2026-06-01.md`  

**Result**: No executor template sections → `mode cross-repo`, problem/request summary only, no task sequence.  

---

## Related Commands

- [`/acp-handoff`](acp.handoff.md) — Generate outgoing handoff (executor or cross-repo)
- [`/acp-resume`](acp.resume.md) — Optional handoff path → receive steps then init + proceed
- [`/acp-proceed`](acp.proceed.md) — Start implementation after receive checklist
- [`/acp-status`](acp.status.md) — Verify project state matches handoff pin
- [`/acp-commit`](acp.commit.md) — Close session gap before or after receive

---

## Troubleshooting

### Issue 1: `--latest` finds nothing

**Symptom**: Error after checking `active_handoff` and `HANDOFF-LATEST.md`  

**Solution**: Run outgoing `/acp-handoff --mode executor` to create a handoff and set `active_handoff`, or pass an explicit path.  

### Issue 2: Git DRIFT on purpose

**Symptom**: Banner shows `git DRIFT` but work should continue  

**Solution**: Drift is a **warning**, not a hard stop. Review commits since pin; confirm the handoff intent still applies on current HEAD.  

### Issue 3: Session gap warning

**Symptom**: Handoff newer than last `sessions.md` entry  

**Solution**: Outgoing agent may have skipped `/acp-commit`. Note the gap in your session or ask them to commit memory before you implement.  

---

## Security Considerations

### File Access
- **Reads**: Handoff file, `agent/progress.yaml`, `agent/memory/sessions.md`, git metadata
- **Writes**: None
- **Executes**: `git rev-parse`, `git branch`, `git log` (read-only)

### Network Access
- **APIs**: None
- **Repositories**: None (local git only)

### Sensitive Data
- **Secrets**: Handoffs must not contain credentials; warn if obvious secret patterns detected
- **Credentials**: Never echo secrets from handoff body into chat

---

## Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Drift handling | Warn, non-blocking | Incoming agent may legitimately be ahead of planner |
| `--latest` resolution | `active_handoff` → `HANDOFF-LATEST.md` → error | Matches M67 discoverability chain |
| Legacy handoffs | Body scrape fallback | cross-repo v1.0.0 handoffs lack frontmatter |
| After receive | Confirm, then suggest proceed/resume | Prevents auto-implementation on wrong assignment |
| vs `/acp-report` | Narrow transfer gate | Report is session summary; receive is incoming verification |

---

## Notes

- Pair with `/acp-handoff --mode executor` on the outgoing side for full round-trip protocol
- `/acp-resume @handoff.md` delegates to this command's steps 1–6 before standard resume
- See `agent/wiki/cross-agent-handoff.md` for ritual diagram and mode selection
- Proposal reference: `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` §6

---

**Namespace**: acp  
**Command**: receive  
**Version**: 1.0.0  
**Created**: 2026-07-15  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Compatibility**: ACP 6.23.0+ (M67)  
**Author**: ACP Project  
