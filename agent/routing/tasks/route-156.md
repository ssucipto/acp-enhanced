---
id: route-156
title: "M58-002: Docs — Phase 2 rules, confidence model, self-protection protocol"
task_type: command-doc-update
milestone: M58
complexity: medium
executor: copilot
context_required: [milestones/milestone-58-acp-integrity-v2-semantic-analysis.md, route-155, agent/commands/acp.integrity.md, agent/wiki/integrity-rules.md, agent/skills/code-integrity.md]
files_affected: [agent/wiki/integrity-rules.md, agent/commands/acp.integrity.md, agent/skills/code-integrity.md]
tokens_est: 8000
created: 2026-06-08
completed: 2026-06-15
---

# Route 156: Documentation — Phase 2 Rules & Confidence Model

## Objective

Update three documentation files with Phase 2 content: the wiki rule catalogue, the command doc, and the skill file.

## Expected Output

### Files Modified
- `agent/wiki/integrity-rules.md` — Un-defer Cat 8/9/10; add rules with confidence ceilings
- `agent/commands/acp.integrity.md` — Add Phase 2 section, confidence model, self-protection protocol
- `agent/skills/code-integrity.md` — Add Phase 2 guidance and human-review gate (≤800 tokens maintained)

## Changes Required

### Wiki: integrity-rules.md
- Cat 8: Remove `⚠️ DEFERRED` marker; add IG-45–IG-50 with `confidence: MEDIUM/LOW` column
- Cat 9: Remove `⚠️ DEFERRED` marker for IG-53/54/56/57; add `confidence: LOW` column
- Cat 10: Remove `⚠️ DEFERRED` marker for IG-58–IG-62; add `confidence: LOW` column (IG-61 stays HIGH)
- Total rules: 70 (55 v1.0 + 15 v2.0 — no new rules added, just un-deferred)

### Command Doc: acp.integrity.md
- Add `## Phase 2 — Semantic Analysis` section after Quality Gates
- Add `### Confidence Ceiling Model` with the 3-category table
- Add `### Self-Protection Protocol` with IG-53/54/56/57 handling
- Add `--phase2` flag to arguments table
- Update executor selection: Composer 2.5 or Claude Sonnet 4.6+ for Phase 2

### Skill File: code-integrity.md
- Add `## Phase 2 (v2.0)` section with:
  - Confidence ceiling table (3 rows)
  - Self-protection protocol summary (3 bullet points)
  - `verdict: REQUIRES_HUMAN_REVIEW` output field
- Maintain ≤800 token budget by compressing existing content if needed

## Verification

- [ ] Wiki: Cat 8/9/10 no longer marked DEFERRED
- [ ] Wiki: All 15 un-deferred rules have confidence columns
- [ ] Wiki: No rule has `confidence: HIGH` (except IG-61)
- [ ] Cmd doc: Phase 2 section present
- [ ] Cmd doc: Self-Protection Protocol present
- [ ] Cmd doc: `--phase2` flag documented
- [ ] Skill file: Phase 2 guidance present
- [ ] Skill file: ≤800 tokens
- [ ] All three files cross-reference each other

## User-Observable Acceptance

- `/acp-integrity --phase2` is documented and discoverable
- Developers understand what confidence levels mean before running Phase 2
- Self-protection protocol is clearly documented
- Wiki header updated to v2.0.0 with 70 total rules; Cat 8/10 active (Phase 2)
