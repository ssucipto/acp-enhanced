# Command: decide

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-decide` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-decide` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Create a new Architecture Decision Record (ADR) in `agent/memory/decisions.md`  
**Category**: Memory  
**Frequency**: Whenever an architectural or significant technical decision is made  

---

## Arguments

**CLI-Style Arguments**:
- `<decision title>` (positional) — Short title for the decision

**Natural Language Arguments**:
- `/acp-decide "Use YAML for all config files"` — Record a specific decision
- `/acp-decide Switch from Jest to Vitest` — Record a tooling decision

---

## What This Command Does

Records a significant decision so it cannot be relitigated in future sessions. Every ADR has a "DO NOT re-open unless" condition — this prevents future agents from second-guessing settled choices.

**Use this when**:
- Choosing between two meaningful architectural approaches
- Deciding on a tool, framework, file format, or naming convention
- Settling a design debate that should stay settled

---

## Prerequisites

- [ ] `agent/memory/decisions.md` exists

---

## Steps

### 1. Get Next ADR ID

- Read `agent/memory/decisions.md`
- Find the highest existing ADR-NNN ID
- Next ID = highest + 1

### 2. Gather Decision Details

Gather (or infer from context):
- **Context**: Why was this decision needed? What problem does it solve?
- **Options considered**: At least 2 alternatives that were evaluated
- **Decision**: What was decided and why
- **Consequences**: What this means going forward — what is now true, what is now off-limits
- **Re-open condition**: What specific circumstance would justify revisiting this decision

### 3. Append ADR

Append to `agent/memory/decisions.md`:

```markdown
## ADR-[ID] | [date] | [title]
**Status:** Accepted
**Context:** [why this decision was needed]
**Options considered:** [brief list]
**Decision:** [what was decided]
**Consequences:** [what this means going forward]
**DO NOT re-open** unless [specific trigger condition].
```

### 4. Confirm

```
ADR-[ID] created: [title]
```

---

## Verification

- [ ] New ADR block appended to `agent/memory/decisions.md`
- [ ] ID is sequential (highest existing + 1)
- [ ] "DO NOT re-open" condition is specific, not vague
- [ ] Options considered lists at least 2 alternatives

---

**Namespace**: acp  
**Command**: decide  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  
