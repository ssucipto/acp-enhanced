---
mode: agent
description: Create a new Architecture Decision Record
---

Create a new ADR for the decision: {{input}}

1. Read `.agent/memory/decisions.md` to get the next ADR ID
2. Gather (or infer from context):
   - Why this decision was needed
   - What alternatives were considered (at least 2)
   - What was decided and why
   - What the consequences are going forward
   - What specific condition would justify re-opening this decision
3. Append to `.agent/memory/decisions.md`:
   ```markdown
   ## ADR-[ID] | [date] | [title]
   **Status:** Accepted
   **Context:** [why this decision was needed]
   **Options considered:** [brief list]
   **Decision:** [what was decided]
   **Consequences:** [what this means going forward]
   **DO NOT re-open** unless [specific trigger condition].
   ```
4. Confirm: "ADR-[ID] created: [title]"
