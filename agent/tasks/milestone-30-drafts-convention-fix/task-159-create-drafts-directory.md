---
id: task-159
milestone: M30
title: Create agent/drafts/ directory with gitkeep and template
status: completed
priority: 4
complexity: trivial
estimated_hours: 0.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Create `agent/drafts/.gitkeep` and `agent/drafts/draft.template.md` so the directory exists in the repo and new installations have the template available for `/acp-plan` structured drafts.

## Context

`acp.plan.md` Steps 4 (Options A–D) and Step 10 write files to `agent/drafts/`. The `.gitignore` already has `drafts/` under the `agent/` ignore rules (confirmed present). However, the directory itself does not exist in the repo — it has no `.gitkeep`, no template, and is not created by install scripts.

If an agent runs `/acp-plan` on a fresh install and tries to create a draft file, it may fail silently or create the directory in an unexpected location.

**Note**: `agent/.gitignore` ignores `drafts/` content but NOT `draft.template.md` (templates are tracked). Confirm this is the case before proceeding — if `agent/.gitignore` ignores the whole directory, add a `!draft.template.md` exception.

## Implementation

1. Check `agent/.gitignore` — verify `drafts/` entry behavior for templates
2. Create `agent/drafts/.gitkeep` (empty file)
3. Create `agent/drafts/draft.template.md` with frontmatter:

```markdown
# Draft: {Title}

<!-- @acp.meta.task
topic: draft, title
description: Create agent/drafts/ directory with gitkeep and template
milestone: M30
status: completed
updated: 2026-05-05
@acp.meta.end -->



**Type**: design | requirements | milestone | task  
**Created**: YYYY-MM-DD  
**Status**: in-progress | ready | abandoned  

---

## Question 1: What problem does this solve?

[Answer here]

---

## Question 2: What is the proposed solution?

[Answer here]

---

## Question 3: What are the key decisions / constraints?

[Answer here]

---

## Notes

[Any additional context]
```

4. If `agent/.gitignore` has `drafts/` as a blanket exclude, add:
   ```
   !drafts/draft.template.md
   !drafts/.gitkeep
   ```
   to track the placeholder and template.

## Expected Output

### Files Created
- `agent/drafts/.gitkeep`
- `agent/drafts/draft.template.md`

### Files Potentially Updated
- `agent/.gitignore` (if exception needed)

## Verification
- [ ] `ls agent/drafts/` shows `.gitkeep` and `draft.template.md`
- [ ] `git status` shows `agent/drafts/.gitkeep` and `agent/drafts/draft.template.md` as tracked
- [ ] `git status` does NOT show `agent/drafts/*.draft.md` as tracked (gitignore working)
- [ ] `draft.template.md` contains the 3-question structure

## User-Observable Acceptance
After `/acp-plan` creates a draft file like `agent/drafts/my-feature.draft.md`, it appears in `ls agent/drafts/` but NOT in `git status` (correctly gitignored). The template file is always available and tracked.
