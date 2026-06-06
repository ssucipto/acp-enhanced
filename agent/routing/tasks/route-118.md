---
id: route-118
title: "Wrappers + package.yaml entry + template for acp-stakeholder-report"
task_type: command-doc-write
milestone: M52
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.stakeholder-report.md
  - agent/feedback/stakeholder-report.template.md
  - agent/patterns/local.command-naming-convention.md
files_affected:
  - .github/prompts/acp-stakeholder-report.prompt.md
  - .opencode/commands/acp-stakeholder-report.md
  - agent/templates/stakeholder-report.template.md
  - package.yaml
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 118: Wrappers + Template + Package Entry

## Objective

Create the triple-file architecture wrappers, ship the output template, and register the command in `package.yaml`.

## Context

Per `local.command-naming-convention.md`, every `/acp-*` command needs 3 files:
1. Command directive: `agent/commands/acp.stakeholder-report.md` (route-117)
2. VS Code prompt: `.github/prompts/acp-stakeholder-report.prompt.md`
3. OpenCode: `.opencode/commands/acp-stakeholder-report.md`

Template ships to `agent/templates/` alongside the existing `design-spec.template.md`.

## Changes

### 1. Create `.github/prompts/acp-stakeholder-report.prompt.md`

Follow existing prompt wrapper pattern:
```markdown
---
mode: agent
description: Generate concise weekly/monthly stakeholder progress summary with RAG health indicator
---

Read and execute `agent/commands/acp.stakeholder-report.md`.
```

### 2. Create `.opencode/commands/acp-stakeholder-report.md`

```markdown
---
description: Generate concise weekly/monthly stakeholder progress summary with RAG health indicator
---

Read and execute `agent/commands/acp.stakeholder-report.md`.
```

### 3. Copy template

Copy `agent/feedback/stakeholder-report.template.md` → `agent/templates/stakeholder-report.template.md`

Verify template structure matches command doc's Report Structure section:
- Header (period, RAG, rationale, email subject, version, audience)
- Executive summary (≤300 words)
- This period — accomplishments (≤5 bullets)
- Next period — focus (≤5 bullets)
- Blockers & risks (Severity | Impact | Mitigation | Owner)
- Decisions & actions required
- Metrics at a glance (2–4 rows hard limit)
- Changes since last report (optional)
- Detail available on request (links)

### 4. Add to `package.yaml`

Add `acp.stakeholder-report.md` to the command files list, following the existing pattern (no scripts).

## Verification

- [ ] `.github/prompts/acp-stakeholder-report.prompt.md` exists with correct content
- [ ] `.opencode/commands/acp-stakeholder-report.md` exists with correct content
- [ ] `agent/templates/stakeholder-report.template.md` exists with all 9 sections
- [ ] `package.yaml` includes `acp.stakeholder-report.md` entry
- [ ] Wrapper files use hyphen separator (not dot)
- [ ] Triple-file parity check passes
