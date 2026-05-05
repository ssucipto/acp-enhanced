# Milestone 30: agent/drafts/ Convention Fix

<!-- @acp.meta.milestone
topic: drafts, convention, install, bootstrap, gitignore
description: Create the agent/drafts/ directory, template, and install-time setup that acp.plan.md requires but has never existed.
tasks: task-159..task-161
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Fix the live bug where `/acp-plan` writes draft files to `agent/drafts/` but the directory doesn't exist and isn't created by install/bootstrap scripts.  
**Duration**: 0.5–1 day  

---

## Overview

`acp.plan.md` Steps 4 (Option A–D) and Step 10 all reference `agent/drafts/` as the location for planning draft files. The `.gitignore` already excludes `drafts/` under `agent/`. However, the directory itself does not exist in the repo, has no `.gitkeep` placeholder, has no template file, and is not created by `acp.install.sh` or `acp-bootstrap.sh`.

A freshly installed ACP project will fail to create draft files on the first `/acp-plan` invocation if the agent tries to write to the directory.

---

## Deliverables

### 1. agent/drafts/ Directory
- `agent/drafts/.gitkeep` — ensures directory is tracked
- `agent/drafts/draft.template.md` — blank template for structured drafts

### 2. Install/Bootstrap Updates
- `acp.install.sh` creates `agent/drafts/` during install
- `scripts/acp-bootstrap.sh` creates `agent/drafts/` during bootstrap

### 3. AGENT.md Update
- `AGENT.md` directory tree includes `agent/drafts/` with note: "local-only planning drafts (gitignored)"

---

## Success Criteria

- [ ] `agent/drafts/.gitkeep` exists and is committed
- [ ] `agent/drafts/draft.template.md` exists with frontmatter structure
- [ ] `acp.install.sh` creates `agent/drafts/` when missing
- [ ] `scripts/acp-bootstrap.sh` creates `agent/drafts/` when missing
- [ ] AGENT.md directory tree updated
- [ ] `e2e/acp.drafts.test.sh` verifies directory and template exist post-install

---

## Key Files to Create/Update

```
agent/
└── drafts/
    ├── .gitkeep              (new — committed, directory placeholder)
    └── draft.template.md     (new — planning draft template)
agent/scripts/
└── acp.install.sh            (update — mkdir agent/drafts/)
scripts/
└── acp-bootstrap.sh          (update — mkdir agent/drafts/)
AGENT.md                      (update — add drafts/ to directory tree)
e2e/
└── acp.drafts.test.sh        (new — E2E test)
```

---

## Tasks

1. [task-159-create-drafts-directory.md](../tasks/milestone-30-drafts-convention-fix/task-159-create-drafts-directory.md) — Create agent/drafts/ with .gitkeep and draft.template.md
2. [task-160-update-install-scripts.md](../tasks/milestone-30-drafts-convention-fix/task-160-update-install-scripts.md) — Update acp.install.sh and acp-bootstrap.sh to create drafts dir
3. [task-161-update-agent-md-and-e2e.md](../tasks/milestone-30-drafts-convention-fix/task-161-update-agent-md-and-e2e.md) — Update AGENT.md directory tree + add e2e/acp.drafts.test.sh

---

**Next Milestone**: [milestone-31-e2e-test-coverage-marker-spec.md](milestone-31-e2e-test-coverage-marker-spec.md)  
**Blockers**: None — small infra fix, no dependencies  
**Notes**: This fixes a silent bug in the existing codebase. `/acp-plan` currently references this directory in Steps 4 and 10. Priority: fix before M31 (which adds more scripts that need E2E tests).
