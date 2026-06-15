---
id: route-047
title: R5 — Resolve Three-Copy AGENTS/CLAUDE Architecture
task_type: docs-update
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [AGENT.md, CLAUDE.md, .github/copilot-instructions.md]
files_affected: [CLAUDE.md, .github/copilot-instructions.md, scripts/acp-bootstrap.sh]
tokens_est: 2000
created: 2026-06-03
completed: 2026-06-03
---

# R5: Resolve Three-Copy Architecture

**Source**: audit-022, ChoreHive feedback R5 (P1)

## Problem

CLAUDE.md (267 lines) and copilot-instructions.md (267 lines) define the same protocol. AGENT.md (2325 lines) is user-facing documentation — it cannot serve as the canonical protocol file because Claude Code MUST read CLAUDE.md and Copilot MUST read copilot-instructions.md (platform-specific requirements).

## Pre-Impl Cross-Reference (audit-025)

- AGENT.md: 2 protocol section references (user docs — not suitable as protocol source)
- CLAUDE.md: 6 protocol sections (agent directives)
- copilot-instructions.md: 6 protocol sections (agent directives)
- **Finding**: Redirecting CLAUDE.md → AGENT.md would break Claude Code by loading 2325 lines of user docs instead of 267 lines of protocol.

## Solution (Revised)

Accept the three-copy reality as inherent to multi-platform support:
- copilot-instructions.md = canonical protocol source (edit here)
- CLAUDE.md = platform-specific copy (kept in sync by pre-commit hook)
- AGENT.md = user documentation (different content, different purpose)
- Keep the pre-commit sync hook (it's the pragmatic fix, not a workaround)
- Document why three copies exist in AGENT.md

## Acceptance Criteria

- [ ] AGENT.md documents why CLAUDE.md and copilot-instructions.md are separate copies
- [ ] Pre-commit sync hook verified working (copilot-instructions.md → CLAUDE.md)
- [ ] Header comment in CLAUDE.md: "Auto-synced from .github/copilot-instructions.md — do not edit directly"
- [ ] Header comment in copilot-instructions.md: "Canonical protocol source — synced to CLAUDE.md on commit"
