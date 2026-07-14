# Command: handoff

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-handoff` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-handoff` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 2.0.0  
**Created**: 2026-03-13  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Generate a context-aware handoff for transferring work to another agent context — same-repo executor transfer (plan → implement) or cross-repository problem transfer  
**Category**: Workflow  
**Frequency**: As Needed  

---

## What This Command Does

This command supports **two handoff modes** with distinct templates, defaults, and delivery rules:

| Mode | CLI | Use when | Delivery | Implementation steps? |
|------|-----|----------|----------|----------------------|
| **cross-repo** | `--mode cross-repo` (default) | Work in repo A needs change in repo B | User prompted; chat OK | **No** — problem + request only |
| **executor** | `--mode executor` | Same repo, different agent/session (plan → implement, implement → audit) | **Disk required** | **Yes** — task IDs, sequence, ADRs, guardrails |

**Boundary vs `/acp-report`:**

| Command | Scope | Audience | Content |
|---------|-------|----------|---------|
| **`/acp-report`** | Same project, session summary | Humans / stakeholders | Broad progress, milestones, accomplishments, plans |
| **`/acp-handoff`** | Narrow transfer to next agent | Receiving agent session | Executor: locked decisions + task package; Cross-repo: problem + request only |

Do not use `/acp-report` when the goal is to transfer actionable work to another agent. Do not use `/acp-handoff` when the goal is a project status snapshot.

**Cross-repo mode** preserves v1.0.0 behaviour: freeform markdown shaped by the specific need, problem and request only, no prescribed implementation steps.

**Executor mode** encodes what consumer-project field evidence (M51 exemplar) proved works: ADR locks, task sequences, git pins, scope guardrails, and a return-handoff path — all mandatory in the template below.

---

## Arguments

| Argument | Aliases | Mode | Description |
|----------|---------|------|-------------|
| `--mode <mode>` | | Both | `executor` or `cross-repo`. Default: `cross-repo` |
| `--to <target>` | `--target` | Both | **Executor mode:** receiving executor (`cursor`, `claude`, `fable`, `human`, or freeform). **Cross-repo mode:** target project path or registered ACP project name |
| `--scope <slug>` | | Executor | Scope slug for filename (e.g. `m51-consumer-project-pro`). If omitted, derive from milestone/task/conversation and kebab-case |

**CLI-Style Examples**:

```
/acp-handoff                                          # cross-repo, infer target from context
/acp-handoff --mode cross-repo --to weaviate-schema     # cross-repo to named project
/acp-handoff --mode cross-repo --to ~/projects/other    # cross-repo to path
/acp-handoff --mode executor --to cursor                # executor handoff to Cursor
/acp-handoff --mode executor --to claude --scope m67-handoff-v2
```

**Natural Language Examples**:

- `/acp-handoff to weaviate-schema` — cross-repo (default mode)
- `/acp-handoff executor to cursor for M67 implementation` — executor mode
- `/acp-handoff --mode executor --to claude` — return/status handoff to planning agent

### Argument Parsing

The agent infers intent from flags and conversation context:

1. **Mode resolution**
   - If `--mode executor` or natural language mentions "executor", "same repo", "plan to implement", "hand off to Cursor/Claude" → `executor`
   - Otherwise → `cross-repo` (default)

2. **`--to` resolution (mode-dependent)**
   - **Executor mode:** `--to` is the receiving **executor** (`cursor`, `claude`, `fable`, `human`, or freeform string). Required; ask if missing.
   - **Cross-repo mode:** `--to` is target **project** (path or name). Infer from conversation if omitted; resolve names via `~/.acp/projects.yaml`; ask if inference fails.

3. **`--scope` resolution (executor only)**
   - Use explicit `--scope` if provided
   - Else derive from current milestone ID, route/task IDs, or conversation topic; slugify to kebab-case (e.g. `m67-handoff-v2`)

---

## Prerequisites

### Cross-repo mode

- [ ] Active conversation with context about the work to hand off
- [ ] Target project identifiable (via argument, conversation context, or `~/.acp/projects.yaml`)

### Executor mode

- [ ] Active conversation with implementation-ready context (tasks, ADRs, assignment)
- [ ] Receiving executor specified via `--to`
- [ ] Git repository with a current branch and commit
- [ ] Session memory committed if this session produced memory-worthy work (see Outgoing Ritual)

---

## Outgoing Ritual (Executor Mode — Mandatory)

**Before generating an executor handoff, you MUST complete this preamble in order. Do not skip steps.**

```
1. If this session produced memory-worthy work → run /acp-commit first
2. Capture git_branch and git_commit (full SHA) via git commands
3. Generate handoff using template § Executor Handoff Template (all sections required)
4. Save to disk at agent/reports/handoff-{to}-{scope-slug}-{YYYY-MM-DD}.md
5. Update agent/progress.yaml → active_handoff (see Step 5b)
6. Copy to agent/reports/HANDOFF-LATEST.md (see Step 5c)
7. If superseding a prior handoff → mark old file status: superseded (see Step 5d)
```

**Routing chain** (see `agent/core/routing.yml`):

```yaml
acp-handoff:
  - acp-commit: "Commit session before handoff (required executor mode)"
  - acp-receive: "Incoming agent loads and verifies handoff"
  - acp-report: "Session summary — distinct from executor handoff"
  - acp-status: "Include status snapshot in handoff body"
```

---

## Steps

### 0. Display Command Header

```
⚡ /acp-handoff
  Generate a context-aware handoff for transferring work to another agent context

  Usage:
    /acp-handoff --mode cross-repo [--to <project>]   Cross-repo problem transfer (default)
    /acp-handoff --mode executor --to <executor>      Same-repo executor handoff (disk required)

  Related:
    /acp-commit     Commit session before executor handoff (mandatory)
    /acp-receive    Incoming agent loads and verifies handoff
    /acp-report     Session summary for humans (NOT a handoff substitute)
    /acp-status     Status snapshot for handoff context
    /acp-resume     Session start; optional handoff path
```

This step is informational only — do not wait for user input.

### 1. Resolve Mode and Target

Determine handoff mode and target.

**Actions**:
- Parse `--mode` (default: `cross-repo`)
- Parse `--to` / `--target` per Argument Parsing rules
- **Executor mode:** confirm receiving executor; require `--to` (ask if missing)
- **Cross-repo mode:** resolve project name via `~/.acp/projects.yaml` or treat as filesystem path; infer from context if omitted
- **Executor mode:** resolve scope slug for filename

**Expected Outcome**: Mode, target, and (executor) scope slug identified  

### 2. Branch on Mode

Route to the correct workflow path.

**Actions**:
- If `executor` → continue to Step 3 (Executor Path)
- If `cross-repo` → skip to Step 4 (Cross-Repo Path)

**Expected Outcome**: Correct path selected  

---

### 3. Executor Path — Outgoing Ritual and Context Gathering

Execute the mandatory outgoing ritual, then gather handoff content.

**Skip item**: N/A — executor mode cannot skip outgoing ritual  

**Actions**:

**3a. Commit chain**
- If this session wrote to `sessions.md`, `lessons.md`, `decisions.md`, routing tasks, or other memory → run `/acp-commit` **before** proceeding
- Read last entry from `agent/memory/sessions.md`; note date for handoff reference chain

**3b. Git pin**
- Run `git branch --show-current` → capture `git_branch`
- Run `git rev-parse HEAD` → capture full `git_commit` SHA
- Run `git remote get-url origin` (or note if no remote) → capture `git_remote`
- Read `agent/core/identity.yml` → `version` if present → `app_version`

**3c. Gather executor handoff content**
- Identify `from_executor` (current session executor: claude, cursor, fable, human, or inferred)
- Extract locked decisions (ADR IDs from `agent/memory/decisions.md`, stakeholder verdicts, audit conclusions)
- Extract assignment mode: Implement | Audit only | Document only
- Extract plan reference: milestone path, route/task IDs, dependency sequence
- Extract "What NOT to do" and adjacent out-of-scope context
- Extract model/executor requirements for receiving agent (e.g. Composer 2.5 non-fast)
- Optionally run `/acp-status` for snapshot context to embed in Problem / context
- Identify prior active handoff from `agent/progress.yaml` → `active_handoff.path` if set (for supersession)

**Expected Outcome**: Git pin captured, all template content gathered, commit chain satisfied  

### 3d. Generate Executor Handoff (Disk Required)

Write the handoff file using the **Executor Handoff Template** below. **Every section header is mandatory** — you may add subsections but must not omit headers.

**Filename**:

```
agent/reports/handoff-{to}-{scope-slug}-{YYYY-MM-DD}.md
```

Examples:
- `handoff-cursor-m67-handoff-v2-2026-07-15.md`
- `handoff-claude-m51-implementation-status-2026-07-20.md`

Create `agent/reports/` if it does not exist.

**Expected Outcome**: Complete executor handoff written to disk  

### 3e. Update `active_handoff` in progress.yaml

Update discoverability pointer for receiving agents and `/acp-receive --latest`.

**Actions**:
- Read `agent/progress.yaml`
- Set or replace top-level `active_handoff` block:

```yaml
active_handoff:
  path: agent/reports/handoff-{to}-{scope-slug}-{YYYY-MM-DD}.md
  date: "YYYY-MM-DD"
  to_executor: {executor from --to}
  from_executor: {from_executor}
  git_commit: {full SHA}
  status: active   # active | superseded | completed
```

- Preserve all other `progress.yaml` fields unchanged
- Write file back

**Expected Outcome**: `active_handoff` points to new handoff with `status: active`  

### 3f. HANDOFF-LATEST.md Lifecycle

Maintain a stable discoverability copy.

**Actions**:
- Copy the new handoff file contents to `agent/reports/HANDOFF-LATEST.md` (overwrite)
- `HANDOFF-LATEST.md` is a **copy**, not a symlink — receiving agents may `@agent/reports/HANDOFF-LATEST.md` without knowing the dated filename

**Expected Outcome**: `HANDOFF-LATEST.md` matches the new handoff  

### 3g. Superseded Marking (When Applicable)

If a prior handoff exists and is being replaced:

**Actions**:
- Read prior handoff at `active_handoff.path` (before overwrite) or from conversation context
- In the **new** handoff YAML frontmatter, set `supersedes: {path to prior handoff}`
- In the **prior** handoff file, update frontmatter: `status: superseded`
- In `progress.yaml`, if prior handoff had `active_handoff.status: active`, that status is now on the new file only

**Expected Outcome**: Prior handoff marked superseded; new handoff references it  

### 3h. Deliver Executor Handoff

**Actions**:
- Output confirmation (see Expected Output — Executor)
- Summarize: file path, git pin, receiving executor, assignment mode
- Instruct receiving agent: `/acp-receive @{path}` or `/acp-resume @{path}`
- Do **not** default to chat-only for executor mode — disk save is mandatory; you may also paste a short summary in chat

**Expected Outcome**: Executor handoff persisted and user informed  

---

### 4. Cross-Repo Path — Context Gathering

Preserve v1.0.0 behaviour: problem + request only, no implementation steps.

**Actions**:
- Identify the problem or need that triggered the handoff
- Extract the request — what needs to happen in the target project
- Identify relevant file paths (use absolute paths from `/`, not relative)
- Note error messages or blockers only if they add necessary context
- Note environment or dependency details only if they add necessary context
- Optionally check `agent/progress.yaml` if task context is relevant
- Get source project: current working directory (absolute), git remote URL if available

**Expected Outcome**: Core handoff content gathered from conversation  

### 5. Cross-Repo Path — Generate and Deliver

Write freeform handoff markdown shaped by the specific need.

**Actions**:
- Write a clear description of the problem
- Write the request — what the receiving agent should understand and address
- Include source project location for back-reference
- Include absolute file paths, code references, or schema details only if they add context
- Include error messages or blockers only if necessary
- Include environment/dependency context only if necessary
- If the target project is ACP-aware, suggest relevant files to read (e.g. `AGENT.md`), but keep the report generic enough for any agent
- **Do NOT include specific implementation steps** — describe the problem and request; let the receiving agent decide how to solve it
- **Do NOT include** task sequences, milestone references, or ADR locks unless the target repo shares the same monorepo
- Prompt: "Output to chat or save to disk?"
  - If **chat**: Output the full report directly in the conversation
  - If **disk**: Save to `agent/reports/handoff-{target-name}-{date}.md` (v1 filename pattern; no scope slug required)
- **Recommend disk** if the report exceeds ~30 lines

**Expected Outcome**: Cross-repo handoff delivered in user's preferred format  

---

## Executor Handoff Template (Mandatory — §4)

When `--mode executor`, populate this structure exactly. Agent may add subsections; **must not omit headers**.

```markdown
---
handoff_version: 1
handoff_mode: executor
from_executor: {claude|cursor|fable|human}
to_executor: {claude|cursor|...}
date: {ISO date YYYY-MM-DD}
status: active
supersedes: {path to prior handoff or null}
git_branch: {branch}
git_commit: {full SHA}
git_remote: {url or "none"}
app_version: {from identity.yml or "unknown"}
---

# Handoff: {title} → {to_executor}

## Model / executor requirements
{If Cursor: Composer 2.5 non-fast, hooks, etc.}

## Start here (receiving agent)
1. Run project context protocol (CLAUDE.md / AGENTS.md Steps 1–6)
2. Run `/acp-receive @this-file` OR verify git_commit matches `git rev-parse HEAD`
3. Read locked decisions — do not re-litigate

## Problem / context
{Why this handoff exists — 1–3 paragraphs}

## Locked decisions (do not re-litigate)
{ADR IDs, stakeholder decisions, audit verdicts}

## Assignment
{Implement | Audit only | Document only — explicit mode}

## Plan reference
- Milestone: {path}
- Tasks: {paths or IDs}
- Sequence: {dependency graph}

## What NOT to do
{Explicit out-of-scope — prevents replanning loops}

## State to update as you work
- `agent/progress.yaml` — {milestone id}
- `agent/memory/audit-carryovers.md` — {CO-xxx if applicable}
- `agent/memory/sessions.md` — via `/acp-commit`

## Adjacent context (out of scope for this handoff)
{Links to audits, reviews, partner docs — read for context, do not implement}

## Return handoff (when you finish or block)
Generate: `/acp-handoff --mode executor --to {from_executor}` with:
- Tasks completed / in progress / blocked
- Commits (SHA list)
- HUMAN gates hit
- Questions for planning agent

## Reference chain
| Artifact | Path |
|----------|------|
| {type} | {path} |
```

**Return handoff additions** (when generating a return/status handoff, add these sections after Assignment or in Problem / context):

```markdown
## Completed this session
- task-NNN: {status} — commit {sha}

## Blocked / HUMAN gates
- task-NNN: {description}

## Git state now
- branch: {branch}
- HEAD: {sha}
- pushed: yes/no

## Questions for receiving agent
1. ...
```

---

## Verification

### Executor mode (all must pass)

- [ ] `/acp-commit` run if session produced memory-worthy work
- [ ] `git_commit` is full SHA (not abbreviated)
- [ ] `git_branch` captured
- [ ] File saved to `agent/reports/handoff-{to}-{scope-slug}-{YYYY-MM-DD}.md`
- [ ] YAML frontmatter present with all required fields
- [ ] All 12 mandatory body sections present (Model/requirements through Reference chain)
- [ ] Locked decisions section includes ADR IDs or explicit "none"
- [ ] Assignment mode is explicit (Implement | Audit only | Document only)
- [ ] Plan reference includes task IDs and sequence
- [ ] "What NOT to do" section is non-empty
- [ ] Return handoff section references `/acp-handoff --mode executor --to {from_executor}`
- [ ] `agent/progress.yaml` → `active_handoff` updated with correct path, date, executors, git_commit, status: active
- [ ] `agent/reports/HANDOFF-LATEST.md` copied from new handoff
- [ ] Prior handoff marked `status: superseded` if superseding
- [ ] New handoff `supersedes:` field set when applicable
- [ ] **Fail verification** if git pin missing or any §4 header omitted

### Cross-repo mode (all must pass)

- [ ] Target project identified
- [ ] Problem and request clearly described
- [ ] Source project location included
- [ ] File paths use absolute paths (from `/`)
- [ ] Report is understandable without source project context
- [ ] No specific implementation steps prescribed
- [ ] No task sequences or ADR locks (unless shared monorepo)
- [ ] Report delivered in user's preferred format

---

## Expected Output

### Executor Mode (Disk — Mandatory)

```
✅ Executor Handoff Created

File: agent/reports/handoff-{to}-{scope-slug}-{YYYY-MM-DD}.md
Latest: agent/reports/HANDOFF-LATEST.md
Target executor: {to_executor}
From: {from_executor}
Git pin: {branch} @ {full SHA}
Assignment: {Implement | Audit only | Document only}
active_handoff: updated in agent/progress.yaml

Receiving agent: /acp-receive @{path}  OR  /acp-resume @{path}
```

### Cross-Repo Mode — Chat

The handoff report is displayed directly in the conversation, ready to paste into the target agent session.

### Cross-Repo Mode — Disk

```
✅ Handoff Report Created

File: agent/reports/handoff-{target-name}-{date}.md
Target: {target project name/path}
Source: {current project path}

Paste the contents of this file into your agent session in the target project.
```

---

## Examples

### Example 1: Executor Handoff (Plan → Implement)

**Context**: Claude planned M67 handoff v2 on `develop`; Cursor should implement route-190  

**Invocation**: `/acp-handoff --mode executor --to cursor --scope m67-handoff-v2`  

**Result**: Disk file with ADR locks, route-190 task reference, git pin, "What NOT to do" (no acp-receive yet), `active_handoff` updated, `HANDOFF-LATEST.md` copied.  

### Example 2: Return Handoff (Implement → Plan)

**Context**: Cursor completed route-190; Claude should review before next wave  

**Invocation**: `/acp-handoff --mode executor --to claude --scope m67-handoff-v2-status`  

**Result**: Return template with completed tasks, commit SHAs, open questions.  

### Example 3: Cross-Repo Migration (v1 Parity)

**Context**: REST server needs Weaviate schema change in separate repo  

**Invocation**: `/acp-handoff --to weaviate-schema`  

**Result**: Problem + request only; no migration steps prescribed; user prompted for chat vs disk.  

### Example 4: Cross-Repo Inferred Target

**Context**: Conversation mentions "the frontend repo needs API client type updates"  

**Invocation**: `/acp-handoff`  

**Result**: Default cross-repo mode; target inferred from `~/.acp/projects.yaml`; API contract changes described without implementation steps.  

---

## Related Commands

- [`/acp-commit`](acp.commit.md) — Commit session memory before executor handoff (mandatory)
- [`/acp-receive`](acp.receive.md) — Incoming agent loads handoff, verifies git pin, prints checklist
- [`/acp-resume`](acp.resume.md) — Session start; optional handoff path delegates to receive protocol
- [`/acp-report`](acp.report.md) — Session summary for humans (broader scope, same project — **not** a handoff substitute)
- [`/acp-status`](acp.status.md) — Status snapshot for handoff context
- [`/acp-proceed`](acp.proceed.md) — Start implementation from handoff tasks

---

## Troubleshooting

### Issue 1: Cannot infer target (cross-repo)

**Symptom**: Agent asks "Which project should this handoff target?"  

**Solution**: Provide `--to` explicitly, or register the project in `~/.acp/projects.yaml`.  

### Issue 2: Missing `--to` executor (executor mode)

**Symptom**: Agent asks which executor receives the handoff  

**Solution**: Provide `--to cursor`, `--to claude`, or another executor name. Executor mode requires an explicit target.  

### Issue 3: Handoff report too broad (cross-repo)

**Symptom**: Report includes full session context  

**Solution**: Re-invoke with narrower conversation focus. Cross-repo handoffs are problem + request, not session summaries — use `/acp-report` for that.  

### Issue 4: Git pin drift on receive

**Symptom**: Receiving agent HEAD differs from handoff `git_commit`  

**Solution**: Receiving agent runs `/acp-receive` which warns on drift. Outgoing agent should `/acp-commit` and regenerate handoff if pin is stale before handoff.  

### Issue 5: sessions.md older than handoff

**Symptom**: Handoff date newer than last `sessions.md` entry  

**Solution**: Outgoing agent skipped `/acp-commit`. Re-run commit chain, then regenerate handoff.  

---

## Security Considerations

### File Access
- **Reads**: Conversation context, `~/.acp/projects.yaml`, `agent/progress.yaml`, `agent/memory/sessions.md`, `agent/memory/decisions.md`, `agent/core/identity.yml`, git state
- **Writes**: `agent/reports/handoff-*.md`, `agent/reports/HANDOFF-LATEST.md`, `agent/progress.yaml` (executor mode → `active_handoff` only)
- **Executes**: `git branch`, `git rev-parse`, `git remote` (read-only)

### Network Access
- **APIs**: None
- **Repositories**: None (git read-local only)

### Sensitive Data
- **Secrets**: Never include secrets, credentials, or tokens in handoff reports
- **Credentials**: Never include credentials

---

## Key Design Decisions

### Mode Split

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Default mode | `cross-repo` | Preserves v1.0.0 behaviour; no breaking change for existing users |
| Executor mode opt-in | `--mode executor` | Same-repo multi-executor is a distinct workflow with different content rules |
| Implementation steps | Allowed in executor only | consumer-project M51 evidence: receiving agent needs task sequence, not replanning |
| Cross-repo steps | Forbidden (v1 parity) | Receiving agent in different codebase applies its own judgment |

### Executor Mode

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Delivery | Disk required | Rich pointers to tasks, ADRs, audits; chat-only loses structure |
| Template | Mandatory §4 headers | Prevents replanning loops, scope creep, stale memory |
| Outgoing ritual | `/acp-commit` → git pin → disk → `active_handoff` | Aligns `sessions.md` with handoff; reproducible receive |
| Filename | `handoff-{to}-{scope-slug}-{date}.md` | Disambiguates concurrent handoffs (audit-077 H5) |
| Git pin | Full SHA in frontmatter | Receive-side drift detection |
| Lifecycle | `HANDOFF-LATEST.md` + `supersedes` | Discoverability without memorizing dated filenames |
| Return path | Template section + return additions | Round-trip planning ↔ implementation |

### Cross-Repo Mode

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Template | Freeform (v1) | Each cross-repo need differs; rigid templates add friction |
| Output | User prompted (chat or disk) | Quick handoffs stay lightweight |
| Disk location | `agent/reports/handoff-{target}-{date}.md` | v1 filename pattern preserved |
| Context source | Chat conversation | Primary source; progress.yaml optional |
| Long reports | Recommend disk if >30 lines | Proposal §5 clarification |

### Boundary and Lifecycle

| Decision | Choice | Rationale |
|----------|--------|-----------|
| vs `/acp-report` | Handoff = narrow transfer; report = session summary | Teams confused the two (audit-077 §5) |
| `active_handoff` | Written on executor save only | Cross-repo is often ephemeral; executor needs `--latest` resolution |
| Receiving command | `/acp-receive` (separate doc) | Outgoing command does not verify; receive owns drift checks |
| Status tracking | `active_handoff.status` + frontmatter `supersedes` | Lightweight lifecycle without transport layer |

---

## Notes

- Executor handoffs assume the **same repository** — receiving agent has access to referenced task files and ADRs
- Cross-repo handoffs must be **self-contained** — receiving agent should not need source project access
- Chat context is the primary source; synthesize from conversation, not exhaustive file scanning
- Keep cross-repo reports focused — problem + request, not everything that happened
- `agent/reports/` is created on first use if it does not exist
- Wiki reference: `agent/wiki/cross-agent-handoff.md`
- Design reference: `agent/proposals/acp-enhanced-cross-agent-handoff-v1.md` §4, §5, §7

---

**Namespace**: acp  
**Command**: handoff  
**Version**: 2.0.0  
**Created**: 2026-03-13  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Compatibility**: ACP 6.21.0+  
**Author**: ACP Project  
