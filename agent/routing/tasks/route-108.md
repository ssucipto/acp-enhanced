---
id: route-108
title: "Create agent/templates/ directory and ship design-spec.template.md"
task_type: command-doc-write
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/feedback/design-spec.template.md
  - agent/commands/acp.design-spec.md
files_affected:
  - agent/templates/design-spec.template.md
tokens_est: 100
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 108: Create Templates Directory + Ship Design-Spec Template

## Objective

Create the `agent/templates/` directory (if it doesn't exist) and copy the design-spec output template from the feedback folder.

## Context

The feedback-005 includes a `design-spec.template.md` with the stable 19-section structure. This template ships with the framework so agents that cannot read the full command doc can still produce a correctly-structured spec. The `agent/templates/` directory does not currently exist in ACP Enhanced.

## Changes

### 1. Create `agent/templates/` directory

```bash
mkdir -p agent/templates
```

### 2. Add `.gitkeep` 

```bash
touch agent/templates/.gitkeep
```

### 3. Copy template file

Copy `agent/feedback/design-spec.template.md` → `agent/templates/design-spec.template.md`

### 4. Verify template structure

Ensure the template has all 19 sections (§1–§19) matching the command doc's Report Structure section:
- §1 Executive summary
- §2 Terminology
- §3 System context
- §4 Interface inventory — screens
- §5 Interface inventory — state stores
- §6 Persistence map
- §7 Backend API catalog & data flows
- §8 Client calculation engines
- §9 Before-state architecture
- §10 Target-state architecture
- §11 Requirements traceability
- §12 Bootstrap & session lifecycle
- §13 Encryption & security boundaries
- §14 Aggregation / composite interfaces
- §15 Known residual dual paths & technical debt
- §16 Next scope preview
- §17 Verification matrix
- §18 File reference index
- §19 Mermaid rendering notes

## Verification

- [ ] `agent/templates/` directory exists
- [ ] `agent/templates/.gitkeep` exists
- [ ] `agent/templates/design-spec.template.md` exists
- [ ] Template contains all 19 sections matching command doc
- [ ] Template section numbers are stable (match feedback-005 exemplar v2.1)
