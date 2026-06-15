# Task 134: Add Three-Persona Deployment Model Section to AGENT.md

<!-- @acp.meta.task
topic: add, three-persona, deployment, model, section, to, agentmd
description: Task 134: Add Three-Persona Deployment Model Section to AGENT.md
milestone: M24
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M24 — AGENT.md Completeness  
**Estimated Time**: 2–3 hours  

---

## Objective

Add a "Three-Persona Deployment Model" section to AGENT.md. This is the central concept of ACP Enhanced (described fully in `scripts/PRD-MAIN.md` and `scripts/QUICKSTART.md`) but absent from AGENT.md — the document installed in every project. Consumers reading AGENT.md currently have no way to know which setup path applies to them.

## Context

From `scripts/PRD-MAIN.md` and `scripts/QUICKSTART.md`:

| Persona | Setup | Key Benefit |
|---------|-------|-------------|
| **A — Copilot Pro only** | No API keys, no dispatch script | Memory layer + ADRs = 20–30% fewer premium requests. Zero infrastructure. |
| **B — DeepSeek/multi-model** | OpenRouter API key + `acp-dispatch.ts` | Full task routing to cheapest model. 60–85% cost reduction target. |
| **C — Copilot + DeepSeek** | Both | Recommended. Copilot for IDE, DeepSeek for heavy/batch tasks. |

The Three-Persona Model should appear:
- In the **ToC** (currently missing)
- As a new section between "How to Use ACP Enhanced" and "Pattern Significance & Impact"

## Steps

1. **Read `scripts/QUICKSTART.md` Persona section** (lines ~130–160) to capture exact Persona A/B/C descriptions
2. **Read `scripts/PRD-MAIN.md` architecture section** for the token cost figures and 3-layer model description
3. **Draft the new section** — "Three-Persona Deployment Model" — content:
   - Brief intro: ACP Enhanced supports three deployment configurations
   - Table with Persona A/B/C: Setup, Tools Used, Key Benefit, Monthly Cost Profile
   - Subsection: "Which Persona Should I Use?" — decision guide
   - Subsection: "Three-Layer Context Model" — brief description of Layer 1/2/3 from PRD
   - Reference to `scripts/QUICKSTART.md` for detailed setup steps
4. **Add section to AGENT.md** between "How to Use ACP Enhanced" and "Pattern Significance & Impact"
5. **Update the ToC** — add entry #9 "Three-Persona Deployment Model" and renumber subsequent entries
6. **Update the "ACP Enhanced — What's New" table** if needed (the persona model was an M0 addition)

## Verification

- [ ] ToC contains "Three-Persona Deployment Model" entry with correct anchor link
- [ ] New section exists between "How to Use ACP Enhanced" and "Pattern Significance & Impact"
- [ ] Section contains Persona A/B/C table with Setup, Benefit, and Cost Profile columns
- [ ] "Which Persona?" decision guide is present
- [ ] Three-layer context model (Layer 1/2/3) is briefly described with token estimates
- [ ] Cross-reference to `scripts/QUICKSTART.md` is present
- [ ] All ToC anchor links still resolve (renumbering check)
- [ ] Token estimates from PRD are cited accurately (Layer 1: ~180 tokens, Layer 3: ~1,200–1,700 per task)

---

**Next Task**: [task-135](task-135-conclusion-and-sample-prompts.md)
