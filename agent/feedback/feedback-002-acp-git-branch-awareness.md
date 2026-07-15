# Feedback Report: ACP Enhanced — Git Branch Awareness Gap

**Report ID**: feedback-002  
**Date**: 2026-05-10  
**Author**: ACP Session (GitHub Copilot / Claude Sonnet 4.6)  
**Triggered by**: Developer request to formalise git branching strategy and ACP alignment  
**Priority**: High  
**Status**: Findings documented; changes applied to this project  

---

## Executive Summary

ACP Enhanced v2 does not enforce git branch awareness. As a result, the TikrFlow project accumulated 75 commits directly on `main` — bypassing the `develop → staging → main → production` pipeline that was documented in `local.git-process.md` but not enforced by the ACP protocol itself. This report documents the gap, the applied fixes for this project, and recommended changes to the ACP Enhanced framework for all future projects.

---

## 1. Problem Statement

### What Happened

The existing ACP Enhanced protocol (`AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`) contains:
- A "Git Workflow Rules" section with a branch table  
- Statements like "All feature work goes to `develop`"  
- A rule: "Before any `git commit`, check `git branch` — if on `main`, WARN"

However, these rules existed as documentation only — the agent had no reliable trigger to actually check the branch before each commit. In practice:

1. The first session initialised the repository directly on `main`
2. All subsequent sessions continued on `main` (path of least resistance)
3. The `develop` branch existed on GitHub but was 109 commits behind `main`
4. The Git Workflow Rules section was present in `AGENTS.md` but was added late — it didn't exist during the early sessions that formed the bad habit

### Impact

| Issue | Impact |
|-------|--------|
| 75 commits directly on `main` | All went to production pipeline (Cloud Build prod trigger) |
| `develop` branch stale by 109 commits | Staging was never updated |  
| No staging environment validation | Changes went direct to prod without a staging test |
| ACP memory commits on `main` | Housekeeping and feature commits mixed in prod history |

### Root Cause

**The ACP context-loading protocol (Steps 1–6) does not include a branch check step.** The agent loads identity, constraints, routing, skills, and memory — but never explicitly reads the current git branch and compares it to the configured working branch.

---

## 2. Changes Applied to TikrFlow

The following changes were made in this session to correct and prevent recurrence:

### 2.1 `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md`
Added a **"Git Workflow Rules (MANDATORY)"** section immediately after Step 6 of the context-loading protocol with:
- Branch → environment mapping table
- 6 explicit agent rules (branch check before commit, ACP commits on develop, etc.)
- Clarification that `develop → main` is a RELEASE event

### 2.2 `agent/core/identity.yml`
Added `git_workflow` block:
```yaml
git_workflow:
  default_working_branch: develop
  production_branch: main
  branch_model: gitflow-lite
  deploy_map:
    develop: staging
    main: production
  local_dev_firebase_project: tikrflow-dev
```

### 2.3 `agent/wiki/architecture.md`
Added a **"CI/CD Branch → Environment Map"** section with:
- ASCII diagram of the full local dev → develop → staging → main → production pipeline
- Cloud Build trigger rules (which branches trigger which environment)
- Explicit note that `feature/*` branches do NOT trigger Cloud Build
- Action item: two Cloud Build triggers required in GCP Console

### 2.4 `agent/patterns/local.git-process.md`
Added **"ACP Agent Git Rules"** section at the bottom with:
- Branch check script the agent must run before every commit
- Decision tree: develop ✅ / feature/* ✅ / main ⛔
- ACP memory commit flow (correct commands)
- Release flow (develop → main with `--no-ff` merge)
- Cloud Build trigger setup table

### 2.5 Git State
- `develop` branch reset to `main` (force-push to sync 109-commit gap)
- Local checkout switched to `develop`
- All future commits will target `develop`

---

## 3. Recommended Changes to ACP Enhanced Framework

These are recommendations for the ACP Enhanced framework itself (not project-specific) that would prevent this class of problem in future projects.

### Recommendation 1: Add Branch Check to Context-Loading Protocol (Step 1b)

**Current**: Step 1 loads identity.yml, constraints.yml, routing.yml  
**Proposed**: Add a mandatory Step 1b after loading identity.yml:

```markdown
### Step 1b — Git Branch Safety Check (mandatory if git_workflow defined in identity.yml)
Run: `git branch --show-current`
Compare result to `identity.yml → git_workflow.default_working_branch`.
- If current branch matches → proceed
- If current branch is `main` (or the production branch) → STOP.
  Output: "⚠️ [ACP] You are on `main` (production branch). All work should go to `develop`. Run `git checkout develop` before proceeding."
  Do not commit. Do not proceed until the developer confirms or switches branch.
- If current branch is `feature/*` → note it, confirm with developer before proceeding
```

**Priority**: HIGH — prevents silent production commits  
**Effort**: Low (one paragraph addition to AGENTS.md template)

### Recommendation 2: Add `git_workflow` to `identity.yml` Template

The `identity.yml` template should include a `git_workflow` block as a standard field, not an optional one. Projects that don't configure it default to `default_working_branch: main` (safe — no-op). Projects that configure `develop` get enforcement automatically.

**Proposed addition to `identity.yml` template:**
```yaml
git_workflow:
  default_working_branch: develop   # branch agent commits to by default
  production_branch: main           # protected branch — never commit directly
  branch_model: gitflow-lite        # gitflow-lite | trunk | github-flow
  deploy_map:
    develop: staging
    main: production
```

**Priority**: MEDIUM — improves framework completeness  
**Effort**: Low (template update)

### Recommendation 3: `/acp-commit` Protocol Should Include Branch Guard

**Current**: The `/acp-commit` protocol writes to `sessions.md` and commits — but does not check the current branch first.  
**Proposed**: Add as Step 0 of the `acp-commit.prompt.md` protocol:

```markdown
## Step 0 — Pre-commit branch guard
Before writing any memory entries or committing:
1. Run `git branch --show-current`
2. If on production branch → warn developer, stop, ask to switch
3. If on correct working branch → proceed to Step 1
```

**Priority**: HIGH — ACP memory commits should never land on `main`  
**Effort**: Low (one step addition to acp-commit.prompt.md)

### Recommendation 4: Session Entry Should Record Active Branch

**Current**: `sessions.md` entries record `executor`, `tasks`, `done`, `deferred`, `key_fact`  
**Proposed**: Add `branch` field:

```yaml
- date: 2026-05-10
  executor: claude-sonnet-4-6
  branch: develop          # ← NEW: which branch work was on
  tasks: [M20/T141-T157]
  done: [...]
```

**Priority**: LOW — useful for traceability but not critical  
**Effort**: Trivial (one field addition to sessions.md schema)

### Recommendation 5: ACP Init Should Set Up Branch Structure

When `/acp-init` is run on a new project, it should:
1. Check if `develop` branch exists → if not, create it from `main`
2. Switch the local workspace to `develop`
3. Write `git_workflow` block to `identity.yml`
4. Push `develop` to remote

**Priority**: MEDIUM — prevents the "started on main, forgot develop" pattern  
**Effort**: Medium (changes to `acp.init.md` command)

---

## 4. Confirmed Architecture — TikrFlow Going Forward

```
┌──────────────────────────────────────────────────────────────────┐
│  LOCAL DEV                                                       │
│  • Branch: develop (or feature/*)                                │
│  • Firebase: tikrflow-dev                                        │
│  • Backend: uvicorn localhost:8000                               │
│  • Frontend: npm start localhost:3000                            │
└────────────────────────┬─────────────────────────────────────────┘
                         │ git push origin develop
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│  STAGING (auto-deploy on develop push)                           │
│  • Cloud Build trigger: branch = develop                         │
│  • Firebase: tikrflow-staging                                    │
│  • Cloud Run: tikrflow-api-staging (min=0, max=3, 512Mi)        │
│  • Firebase Hosting: staging target                              │
│  • URL: tikrflow-staging.web.app                                 │
└────────────────────────┬─────────────────────────────────────────┘
                         │ PR: develop → main (RELEASE only)
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│  PRODUCTION (deploy on main merge)                               │
│  • Cloud Build trigger: branch = main                            │
│  • Firebase: tikrflow-prod                                       │
│  • Cloud Run: tikrflow-api-prod (min=1, max=10, 512Mi)          │
│  • Firebase Hosting: production target                           │
│  • Domain: tikrflow.app                                          │
└──────────────────────────────────────────────────────────────────┘
```

### Branch Rules Summary

| Branch | Created from | Merges to | Auto-deploy | Protected |
|--------|-------------|-----------|-------------|-----------|
| `main` | — | — | Production | Yes (PR required) |
| `develop` | `main` | `main` (release) | Staging | Yes (PR required) |
| `feature/*` | `develop` | `develop` (squash) | No | No |
| `fix/*` | `develop` | `develop` (squash) | No | No |
| `hotfix/*` | `main` | `main` + `develop` | Production (via main) | No |

### New Branches Required

| Branch | Status | Action |
|--------|--------|--------|
| `main` | ✅ Exists | No action |
| `develop` | ✅ Exists, synced to main | No action |
| `feature/*` | Created per task | Create when starting a task |
| `hotfix/*` | Created when needed | Create on production incidents only |

No new permanent branches needed.

### Cloud Build Action Required

Verify in GCP Console → Cloud Build → Triggers that TWO triggers exist:
1. **`tikrflow-staging-build`**: trigger on push to `develop` → runs `cloudbuild.yaml`
2. **`tikrflow-prod-build`**: trigger on push to `main` → runs `cloudbuild.yaml`

If only one trigger exists (for `main`), add the `develop` trigger:
- Go to Cloud Build → Triggers → Create Trigger
- Branch: `^develop$` (regex)
- Config: `cloudbuild.yaml`
- Project: `tikrflow-staging`

---

## 5. Summary

| Item | Status |
|------|--------|
| TikrFlow branching strategy documented | ✅ `local.git-process.md` (existing, confirmed correct) |
| Agent context files updated | ✅ `AGENTS.md`, `CLAUDE.md`, `copilot-instructions.md` |
| identity.yml git_workflow block | ✅ Added |
| architecture.md CI/CD map | ✅ Updated |
| local.git-process.md ACP section | ✅ Added |
| `develop` synced to `main` | ✅ Done (force-push) |
| Local checkout on `develop` | ✅ Done |
| Cloud Build trigger for `develop` | ⚠️ Verify manually in GCP Console |
| ACP Enhanced framework improvements | 📋 5 recommendations above (for framework authors) |
