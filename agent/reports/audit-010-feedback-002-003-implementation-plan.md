# Audit Report: feedback-002 + feedback-003 — Implementation Review and Plan

**Audit**: #010  
**Date**: 2026-05-11  
**Subject**: Review feedback-002 (git branch awareness) and feedback-003 (pre-implementation audit protocol) — assess implementation status in ACP Enhanced, produce a solid plan.  

---

## Summary

Two field feedback reports were submitted from the TikrFlow project, both dated 2026-05-10:

- **feedback-002**: ACP Enhanced has no git branch awareness. Projects accumulate commits on
  `main` (production) because the protocol never checks the active branch. 5 recommendations.
- **feedback-003**: The `/acp-audit` command has a single investigation mode. Three consecutive
  pre-implementation passes were required for M21/M22/M23 because (a) one pass can't catch
  both plan-level and code-level bugs, and (b) there is no mechanism to track pending audit
  fixes between sessions. 4 recommendations.

**Implementation status as of 2026-05-11**: Neither feedback has been implemented in ACP Enhanced.
All recommended changes are absent from `AGENTS.md`, `acp.audit.md`, `acp.commit.md`,
`identity.yml`, the task template, and the memory layer.

**Verdict**: Both feedbacks are HIGH value, low-to-medium effort. Recommend implementing as
M39 (feedback-002) and M40 (feedback-003) in sequence.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/feedback/feedback-002-acp-git-branch-awareness.md` | feedback | Subject — 5 recommendations |
| `agent/feedback/feedback-003-pre-implementation-audit-protocol.md` | feedback | Subject — 4 recommendations |
| `AGENTS.md` (Steps 1–6) | protocol | No branch check, no carryover check |
| `agent/core/identity.yml` | core | No `git_workflow` block |
| `agent/commands/acp.audit.md` (v1.0.0) | command | Single investigation mode only |
| `agent/commands/acp.commit.md` (v1.1.0) | command | No pre-commit branch guard |
| `agent/tasks/task-1-{title}.template.md` | template | Verification section has no quality gate |
| `agent/memory/sessions.md` | memory | No `branch:` field in entries |
| `agent/memory/` (directory) | memory | No `audit-carryovers.md` |

---

## Key Findings

| # | Finding | Severity | Source |
|---|---------|----------|--------|
| F1 | No git branch check in Steps 1–6 of context-loading protocol | High | FB-002 R1 |
| F2 | `identity.yml` has no `git_workflow` field — branch config has nowhere to live | High | FB-002 R2 |
| F3 | `acp.commit.md` has no Step 0 branch guard — memory commits can land on `main` | High | FB-002 R3 |
| F4 | Sessions.md entries have no `branch:` field — no traceability of which branch work occurred on | Low | FB-002 R4 |
| F5 | `/acp-init` does not create `develop` branch or set up `git_workflow` | Medium | FB-002 R5 |
| F6 | `acp.audit.md` has a single investigation mode — no `--pre-impl` structured protocol | High | FB-003 R1 |
| F7 | No `agent/memory/audit-carryovers.md` — pending audit fixes are silently lost between sessions | High | FB-003 R2 |
| F8 | Task template Verification section has no quality gate — wrong field names/HTTP methods go uncaught | High | FB-003 R3 |
| F9 | Skill files (`scripts.md`, `crosscut.md`) have no code cross-reference discipline | Medium | FB-003 R4 |

---

## Gap Analysis: Feedback-002 (Git Branch Awareness)

### Current Protocol (Steps 1–6) — What's Missing

The context-loading protocol in `AGENTS.md`/`CLAUDE.md`/`.github/copilot-instructions.md` loads:
- `identity.yml`, `constraints.yml`, `routing.yml` (Step 1)
- `taxonomy.yml`, skill file, sessions.md, lessons.md (Steps 2–4)
- Optional reference (Step 5)
- Confirms and proceeds (Step 6)

**There is no branch check anywhere in this sequence.** An agent reading AGENTS.md has no prompt
to run `git branch --show-current`, no way to know what the configured working branch is (it's
not in `identity.yml`), and no warning mechanism if they're on `main`.

### What `identity.yml` Currently Has

The file has: `project`, `type`, `description`, `stack`, `platform_constraints`, `team`,
`priorities`, `fork_of`, `repo`, `version`. No `git_workflow` block.

Without a `git_workflow` block, even if Step 1b were added to the protocol, there would be
nothing to compare `git branch --show-current` against. The two changes must be paired.

### `acp.commit.md` Gap

`acp.commit.md` v1.1.0 starts at Step 1 (Identify Completed Tasks). It has no pre-flight check.
If the developer runs `/acp-commit` while on `main`, the session entry commit lands on `main`.
This is the exact failure mode that caused the TikrFlow 75-commit `main` accumulation.

---

## Gap Analysis: Feedback-003 (Pre-Implementation Audit Protocol)

### Current `acp.audit.md` — What's Missing

`acp.audit.md` v1.0.0 has a single investigation mode: Steps 0–5 (parse subject, determine
report number, investigate, generate report, report success). Step 3 says "cast the net as wide
or narrow as user instructions imply" — there is no structured depth protocol.

For pre-implementation task file auditing specifically, this is insufficient. The bug classes
discovered in audit-43/44/45 required two qualitatively different reads:
1. Task files read in isolation (plan correctness)
2. Task files cross-referenced against the actual codebase (code correctness)

These cannot be collapsed into one pass without a dramatically expanded prompt — and even then,
an LLM tends to skip the code-level read if not explicitly required.

### Carryover Tracking Gap

The memory layer has: `sessions.md` (session-level), `lessons.md` (general patterns),
`decisions.md` (ADRs), `patterns.md` (reusable code patterns). There is no file for
**"pending action items from a prior audit that have not yet been applied"**.

When audit-44 found NM2 and NM4 as needed fixes:
- They were documented in the audit-44 report file
- But nothing was written to memory tracking "these specific fixes must happen before next pass"
- The audit-45 session loaded lessons.md and sessions.md — neither contained the NM2/NM4 items
- audit-45 had to re-discover them from scratch, escalating their severity

The carryover gap is structurally identical to the feedback-001 knowledge loss problem — a specific
state (pending fixes) had no memory location to persist it.

### Task Template Quality Gate Gap

The task template Verification section at line 199 is:
```markdown
## Verification
[Provide a checklist of items to verify the task is complete...]
- [ ] Verification item 1: [Specific condition to check]
```

There is no prompt to cross-reference field names, enum values, import paths, or HTTP methods
against the actual codebase before writing checklist items. A task file author writes the
checklist from memory/assumption, producing verification items that look correct but reference
non-existent fields (e.g., `wo_id` instead of `work_order_id`).

---

## Implementation Plan

### Milestone 39: Git Branch Awareness Protocol (feedback-002)

**Scope**: Add git branch awareness to the ACP Enhanced protocol — identity template, context
loading, commit guard, session traceability.  
**Effort**: Low — 4 targeted file changes  
**Risk**: Low — all changes are additive; the branch check is conditional (`only if git_workflow defined`)  

| Task | File | Change | Priority |
|------|------|--------|----------|
| T-M39-1 | `agent/core/identity.yml` | Add `git_workflow:` optional block with inline docs | High |
| T-M39-2 | `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` | Add Step 1b branch safety check after Step 1 | High |
| T-M39-3 | `agent/commands/acp.commit.md` | Add Step 0 pre-commit branch guard; bump v1.1.0 → v1.2.0 | High |
| T-M39-4 | `agent/commands/acp.commit.md` | Add optional `branch:` field to session entry schema in Step 2 | Low |

**Defer**: T-M39-5 (`/acp-init` branch setup) — medium effort, separate milestone.

#### T-M39-1: `identity.yml` — `git_workflow` block

Add as an optional, commented-out block at the bottom of `identity.yml`:

```yaml
# Optional: configure git branch awareness (uncomment to enable)
# When set, Step 1b will check current branch and warn if on production branch
# git_workflow:
#   default_working_branch: develop   # branch agent commits to by default
#   production_branch: main           # never commit directly to this
#   branch_model: gitflow-lite        # gitflow-lite | trunk | github-flow
```

#### T-M39-2: AGENTS.md — Step 1b

Insert between Step 1 and Step 2:

```markdown
### Step 1b — Git Branch Safety Check (conditional)
Only run this step if `identity.yml` contains a `git_workflow` block.

Run: `git branch --show-current`
Compare to `identity.yml → git_workflow.default_working_branch`.

- **Matches default_working_branch** → proceed normally
- **Is the production_branch (e.g. `main`)** → STOP. Output:
  ```
  ⚠️ [ACP] You are on `main` (production branch).
  All work should target `develop`. Switch with: git checkout develop
  Do not commit until you are on the correct branch.
  ```
  Do not commit, do not proceed. Wait for developer to switch branch.
- **Is `feature/*` or `fix/*`** → note it, proceed normally
- **`git_workflow` not defined** → skip this step entirely
```

#### T-M39-3: `acp.commit.md` — Step 0 branch guard

Insert as new Step 0 before existing Step 1:

```markdown
### 0. Pre-commit Branch Guard (conditional)
Only run if `agent/core/identity.yml` contains `git_workflow`.

1. Run `git branch --show-current`
2. Read `git_workflow.production_branch` from `identity.yml`
3. If current branch = production_branch:
   Output: "⚠️ [ACP] Refusing to commit on `main`. Switch to `develop` first."
   Stop. Do not write sessions.md. Do not make a git commit.
4. Otherwise → proceed to Step 1
```

#### T-M39-4: sessions.md schema — `branch:` field

In `acp.commit.md` Step 2, add optional `branch:` field to the YAML schema:

```yaml
- date: [today]
  executor: [executor]
  branch: [git branch, e.g. develop — omit if git_workflow not configured]
  tasks: [...]
  done: [...]
  deferred: [...]
  key_fact: [...]
```

---

### Milestone 40: Pre-Implementation Audit Enhancement (feedback-003)

**Scope**: Add `--pre-impl` mode to `/acp-audit`, create `audit-carryovers.md` memory schema,
add quality gate to task template, add code cross-reference discipline to skill files.  
**Effort**: Medium — 4 files, the audit command change is the most involved  
**Risk**: Low — all changes are additive; existing audit behaviour unchanged  

| Task | File | Change | Priority |
|------|------|--------|----------|
| T-M40-1 | `agent/commands/acp.audit.md` | Add `--pre-impl` mode with 4-phase protocol; bump v1.0.0 → v1.1.0 | High |
| T-M40-2 | `agent/memory/audit-carryovers.md` | Create new file with schema + carryover tracking protocol | High |
| T-M40-3 | `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` | Add Step 4.4: check `audit-carryovers.md` for open items | High |
| T-M40-4 | `agent/tasks/task-1-{title}.template.md` | Add verification quality gate HTML comment block | Medium |

**Defer**: Skill file updates (R4) — low urgency, can be a separate task in M40 or deferred.

#### T-M40-1: `acp.audit.md` — `--pre-impl` mode

**Arguments section** — add new CLI argument:
```
--pre-impl          4-phase structured pre-implementation readiness protocol
                    (use before implementing any milestone task set)
```

**New Step 3b** (conditionally activated by `--pre-impl` flag):

```markdown
### 3b. Pre-Implementation Protocol (only when --pre-impl is set)

Run 4 sequential phases. Each phase produces a findings list. Do NOT skip phases.

#### Phase 1 — Plan Correctness (task files in isolation)
For each task file in scope:
- Read the full task file (Steps, Verification, Expected Output)
- Verify internal consistency:
  - Steps don't reference resources created in later steps
  - No placeholder bodies (`...`) in non-scaffolding steps
  - HTTP methods declared consistently across Steps and Verification
  - No schema field names that differ between Steps and Verification sections
- Record all inconsistencies as [P1-N] findings

#### Phase 2 — Code Cross-Reference (KEY PHASE — most bugs live here)
For each task file in scope, read the actual codebase sections the task modifies:
- **Backend tasks**: Read the Pydantic models and confirm every field name used in
  the task file exists in the model. Read enum definitions and confirm every enum
  value used is a valid member (not a free string). Read route decorators and
  confirm HTTP method + path match. Read DI dependencies and confirm they exist.
- **Frontend tasks**: Read the import sources and confirm paths exist. Read the
  component props interfaces and confirm all prop names used are defined. Read
  the API client and confirm response shape matches what the task checks for.
- Record all mismatches as [P2-N] findings

#### Phase 3 — Prior Carryover Validation
Read `agent/memory/audit-carryovers.md` (if it exists).
For each entry with `status: pending`:
- Verify whether the fix has actually been applied in the codebase
- If applied: note it (will be marked fixed after this session)
- If NOT applied: escalate severity by one level; record as [P3-N] finding
If `audit-carryovers.md` does not exist → note "No carryovers file — skip"

#### Phase 4 — Operational Completeness
For each new endpoint, API route, or auth-gated page in scope:
- Auth guard present (require_role or equivalent)
- RBAC scoping to correct org/client (not just role-blocking)
- Not-found and permission-denied error cases handled
- No N+1 query loops without documented justification
- No double-write anti-patterns (batch commit inside a loop)
- Record all gaps as [P4-N] findings

After all 4 phases: generate the report using the standard report structure,
adding a "Phase Summary" table at the top showing finding counts per phase.
Write all actionable fixes to `agent/memory/audit-carryovers.md`.
```

#### T-M40-2: `agent/memory/audit-carryovers.md`

Create a new file at `agent/memory/audit-carryovers.md`:

```yaml
# Audit Carryover Tracking
# Pending fixes from prior audits that require follow-up action
# Written by: /acp-audit (--pre-impl mode) when Phase 3 finds pending items
# Read by: Step 4.4 of context-loading protocol at session start
# Remove an entry when fix is confirmed applied and re-verified

# Schema:
# - audit_id: [N]               # source audit number
#   finding_id: [P2-1]          # phase+number code from source audit
#   severity: [critical|high|medium|low]
#   file: [path/to/file.md]     # task or source file with the issue
#   finding: [one-line description]
#   status: [pending|in-progress|fixed]
#   fix_applied_date: null      # set when status → fixed
#   verified_in_audit: null     # set to audit ID when re-verified after fix
#   escalated_to: null          # set if escalated (e.g. "011-C4")
```

#### T-M40-3: AGENTS.md — Step 4.4 carryover check

Add as Step 4.4 inside the Step 4 (Load Working Memory) block:

```markdown
4. Check `agent/memory/audit-carryovers.md` (if it exists) — if any entries have
   `status: pending`, surface them now:
   "⚠️ [ACP] Open audit carryovers: [N] pending. Review before starting."
   List each pending finding_id and one-line description.
```

Also: at the end of any `/acp-audit --pre-impl` run that produces actionable findings,
write all action items to `audit-carryovers.md` with `status: pending`. Document this
in `acp.audit.md` Step 4 (generate report).

#### T-M40-4: Task template — Verification quality gate

Add before the `## Verification` heading:

```markdown
<!-- QUALITY GATE (do not skip for backend/frontend tasks):
     Before writing verification checklist items:
     1. Read the actual data model/schema — confirm every field name used here exists
     2. Read enum definitions — confirm every enum value used is a valid member, not a free string
     3. Confirm all import paths exist in the file tree (frontend tasks)
     4. Confirm HTTP method and route path match the route decorator
     5. Confirm API response shape matches what you are checking in the checklist
     Writing checklist items from memory creates verification bugs that silently
     pass during implementation but fail at runtime.                           -->
```

---

## Sequencing Decision

| Order | Milestone | Rationale |
|-------|-----------|-----------|
| First | M39 (branch awareness) | Simpler, self-contained, addresses the highest-severity "silent production commits" risk |
| Second | M40 (pre-impl audit) | More involved (acp.audit.md rewrite), builds on stable foundation |

Within M39: T-M39-1 → T-M39-2 → T-M39-3 → T-M39-4 (identity → protocol → command → schema)  
Within M40: T-M40-2 → T-M40-1 → T-M40-3 → T-M40-4 (create carryovers file → audit command → protocol step → template)  

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `AGENTS.md:28-33` | Step 1 (Load Core) — Step 1b inserts after line 33 |
| `AGENTS.md:52-61` | Step 4 (Load Working Memory) — Step 4.4 inserts after line 61 |
| `agent/core/identity.yml:30` | End of file — `git_workflow` block appends here |
| `agent/commands/acp.commit.md:62` | Step 1 header — Step 0 branch guard inserts before this |
| `agent/commands/acp.commit.md:67-78` | Session entry YAML schema — `branch:` field adds here |
| `agent/commands/acp.audit.md:27` | Arguments section — `--pre-impl` flag adds here |
| `agent/commands/acp.audit.md:98` | Step 3 (Investigate) — Step 3b conditional block adds after |
| `agent/commands/acp.audit.md:130` | Step 4 (Generate Report) — add carryover-write instruction |
| `agent/tasks/task-1-{title}.template.md:197` | Before `## Verification` — quality gate HTML comment |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-10 | (TikrFlow project) | feedback-002 and feedback-003 submitted |
| 2026-05-09 | `b6b2988` | audit-009 compliance fixes (no branch awareness present) |
| 2026-05-09 | `4e00a90` | audit-008 feedback-001 proactive commit triggers |

---

## Recommendations Summary

| # | Action | Milestone | Effort | Risk |
|---|--------|-----------|--------|------|
| R1 | Add `git_workflow` to `identity.yml` (optional block) | M39/T1 | 5 min | None |
| R2 | Add Step 1b branch check to context-loading protocol | M39/T2 | 20 min | None |
| R3 | Add Step 0 branch guard to `acp.commit.md` v1.2.0 | M39/T3 | 15 min | None |
| R4 | Add `branch:` field to sessions.md schema in `acp.commit.md` | M39/T4 | 5 min | None |
| R5 | Add `--pre-impl` mode to `acp.audit.md` v1.1.0 | M40/T1 | 45 min | Low |
| R6 | Create `agent/memory/audit-carryovers.md` | M40/T2 | 10 min | None |
| R7 | Add Step 4.4 carryover check to context-loading protocol | M40/T3 | 10 min | None |
| R8 | Add verification quality gate to task template | M40/T4 | 5 min | None |
| R9 | `/acp-init` branch setup (deferred) | M41? | 1–2 hr | Medium |
| R10 | Code cross-reference discipline in skill files (deferred) | M40+ | 30 min | Low |

**Total estimated implementation time**: ~2 hours for R1–R8 (M39 + M40 core).
