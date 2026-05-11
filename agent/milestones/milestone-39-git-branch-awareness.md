# Milestone 39: Git Branch Awareness — feedback-002 Fixes

<!-- @acp.meta.milestone
topic: protocol, git, branch-awareness, branch-safety, context-loading, feedback
description: Implement all fixes from feedback-002 (git branch awareness) — optional git_workflow block in identity.yml, Step 1b branch safety check in context-loading protocol, Step 0 branch guard in acp.commit.md v1.2.0, and optional branch: field in sessions.md schema.
tasks: route-014, route-015, route-016, route-017
status: completed
updated: 2026-05-11
@acp.meta.end -->

**Goal**: Add conditional git branch awareness to the ACP Enhanced protocol so agents can be configured to warn (and stop) when working on a production branch, preventing accidental direct commits to `main`.  
**Duration**: 0.5 day  
**Priority**: High (prevents accidental production branch commits with a lightweight opt-in mechanism)

---

## Overview

Feedback item `feedback-002-acp-git-branch-awareness.md` documented the absence of any branch safety
checks in the ACP Enhanced context-loading protocol. Without these checks, an agent working on a
project with a gitflow-style branch model could accidentally commit directly to the production branch
(`main`), bypassing code review or CI gates.

The fix introduces a **conditional** git branch safety system: an optional `git_workflow:` block in
`identity.yml` that projects can uncomment to enable branch checks. When enabled, Step 1b in the
context-loading protocol runs `git branch --show-current` and halts if on the production branch.
The `acp.commit.md` command also gains a Step 0 pre-commit guard for the same protection.

The system is a **safe no-op by default** — projects that don't define `git_workflow:` in
`identity.yml` skip Step 1b entirely.

---

## Deliverables

### 1. identity.yml — Optional git_workflow Block (route-014)
- `agent/core/identity.yml` — commented-out `git_workflow:` block added at the bottom
- Fields: `default_working_branch`, `production_branch`, `branch_model`
- Inline comments explain each field and valid values for `branch_model`

### 2. Context Loading Protocol — Step 1b (route-015)
- `AGENTS.md` — Step 1b added between Step 1 and Step 2
- `CLAUDE.md` — Step 1b added (synced copy)
- `.github/copilot-instructions.md` — Step 1b added (synced copy)
- Step 1b is conditional: no-op if `git_workflow` not defined in `identity.yml`
- On production branch: outputs warning and STOPS — does not continue task steps

### 3. acp.commit.md v1.2.0 — Step 0 Branch Guard (route-016)
- `agent/commands/acp.commit.md` — version 1.1.0 → 1.2.0
- Step 0 Pre-commit Branch Guard inserted before Step 1
- Conditional: only runs if `identity.yml` has `git_workflow:`
- Optional `branch:` field added to sessions.md YAML entry schema in Step 2

### 4. Milestone + Version Bump (route-017)
- `agent/milestones/milestone-39-git-branch-awareness.md` (this file)
- `agent/progress.yaml` — M39 added, status: completed
- `CHANGELOG.md` — [6.5.0] entry
- `agent/core/identity.yml` — version 6.4.13 → 6.5.0
- `package.yaml` — version 6.4.13 → 6.5.0
- `AGENT.md` — version reference updated
- `agent/wiki/architecture.md` — Step 1b git branch safety check section added
- `agent/wiki/domain.yml` — `git_workflow` field added to identity.yml schema description

---

## Acceptance Criteria

- [x] `git_workflow:` commented block in `identity.yml` with 3 fields and inline docs
- [x] Step 1b in all 3 protocol files — conditional, halts on production branch
- [x] `acp.commit.md` v1.2.0: Step 0 branch guard + optional `branch:` field in session schema
- [x] `milestone-39-git-branch-awareness.md` created (this file)
- [x] `progress.yaml` M39 status: completed
- [x] `CHANGELOG.md` [6.5.0] entry
- [x] Version bumped to 6.5.0 across `identity.yml`, `package.yaml`, `AGENT.md`
- [x] `wiki/architecture.md` — Step 1b section added
- [x] `wiki/domain.yml` — `git_workflow` field documented

---

## Design Notes

- `git_workflow:` is intentionally **commented out** in the template — activating it requires
  a deliberate uncomment, not an accidental YAML key. This prevents false positives for projects
  that don't use gitflow.
- Step 1b uses the `production_branch` value (not just hardcoded `main`) so trunk-based development
  projects can configure their own production branch name.
- The `branch:` field in sessions.md schema is **optional** — agents omit it if `git_workflow` is
  not configured. This maintains backward compatibility with existing session entries.
- The `branch_model` field documents intent but is not enforced programmatically — it's a hint for
  future tooling.

---

## Version

`6.4.13 → 6.5.0` (minor version bump — new protocol step in context loading and commit command)
