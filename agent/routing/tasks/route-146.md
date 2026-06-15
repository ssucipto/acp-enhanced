---
id: route-146
title: "M56-005: integrity-rules.md wiki + code-integrity.md skill (≤500 tokens)"
task_type: command-doc-write
milestone: M56
complexity: medium
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, routes 143-145, audit-054 NEW-054-02]
files_affected: [agent/wiki/integrity-rules.md, agent/skills/code-integrity.md]
tokens_est: 6000
created: 2026-06-07
completed: 2026-06-08
---

# Route 146: Wiki Rule Catalogue + Slim Skill File

## Objective

Create the full 44-rule catalogue in wiki (on-demand loading) and a ≤500-token skill file containing only the boundary rule, script table, and output spec. This addresses audit-054 NEW-054-02 — the 70-rule catalogue would blow the skill file's 1,000-token Layer 2 budget.

## Expected Output

### Files Created
- `agent/wiki/integrity-rules.md` — full rule catalogue, loaded section-by-section
- `agent/skills/code-integrity.md` — ≤500 tokens, slim skill file

## Wiki File: `agent/wiki/integrity-rules.md`

Contains all 55 v1.0 rules across 11 categories. Each category is a section that can be loaded independently. Structure:

```markdown
# Integrity Rules Catalogue — v1.0

## Category 1 — Outbound Network Anomalies
**Script**: acp.network-whitelist-validate.sh
| Rule ID | Rule | Severity |
...
```

Include:
- All 44 v1.0 rules with severities
- Deferred rules (Cat 8, partial Cat 9, Cat 10) clearly marked `**DEFERRED to v2.0 (M58)**`
- SLSA provenance paradox warning in Cat 5
- Agent self-protection limitation warning in Cat 9

## Skill File: `agent/skills/code-integrity.md`

**≤500 tokens ideal, ≤800 tokens acceptable** (within Layer 2 budget of 1,000 tokens per `agent/core/constraints.yml`). Contains ONLY:
1. **LLM/Script Boundary Rule** (one paragraph — the architectural principle)
2. **Script table** (6 scripts → rules covered → deterministic/semantic classification)
3. **Output format spec** (YAML findings schema, ~15 lines)
4. **Confidence ceiling rules** (HIGH for script-backed, MEDIUM for LLM reasoning)
5. **Command binding**: `/acp-integrity` + `task_type: code-integrity-scan`

**Does NOT contain**: Full rule catalogue, individual rule descriptions, category breakdowns. Those are in `agent/wiki/integrity-rules.md`.

## Verification

- [ ] `agent/wiki/integrity-rules.md` has all 55 v1.0 rules with correct severities
- [ ] Deferred rules (Cat 8, Cat 9 partial, Cat 10) clearly marked
- [ ] SLSA provenance paradox warning present in Cat 5
- [ ] `agent/skills/code-integrity.md` file exists
- [ ] `agent/skills/code-integrity.md` byte count ≤ 2,500 bytes (~500 tokens)
- [ ] Skill file includes LLM/Script Boundary Rule
- [ ] Skill file includes 6-script table
- [ ] Skill file includes YAML findings output schema
- [ ] Skill file does NOT contain individual IG-01–IG-70 rule descriptions

## User-Observable Acceptance

- `agent/wiki/integrity-rules.md` is a complete reference for all integrity rules
- `agent/skills/code-integrity.md` is compact enough for every-session loading
