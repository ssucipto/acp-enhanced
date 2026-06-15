# Task 135: Update AGENT.md Conclusion and Sample Prompts

<!-- @acp.meta.task
topic: update, agentmd, conclusion, and, sample, prompts
description: Task 135: Update AGENT.md Conclusion and Sample Prompts
milestone: M24
status: draft
updated: 2026-06-15
@acp.meta.end -->



**Milestone**: M24 — AGENT.md Completeness  
**Estimated Time**: 1–2 hours  

---

## Objective

Two related AGENT.md sections still contain pre-M23 wording:

1. **Conclusion** — still says "The Agent Directory Pattern transforms software development…" instead of "ACP Enhanced"
2. **Sample Prompts** — trigger strings use legacy `AGENT.md: Initialize` format without showing the modern `@acp.*` equivalent commands

## Steps

### Part A — Conclusion Section

1. **Read current Conclusion section** in AGENT.md (search for `## Conclusion`)
2. **Update opening sentence** from:  
   `"The Agent Directory Pattern transforms software development from an implicit…"`  
   to:  
   `"ACP Enhanced transforms software development from an implicit, memory-dependent process into an explicit, documented system…"`
3. **Update "Key Takeaways"** — ensure they reflect ACP Enhanced capabilities (package management, personas, benchmark suite) not just the base directory pattern. Keep the 7 existing points; add or update to reference:
   - Package Management: "A growing ecosystem of installable command packages"
   - Token Efficiency: "Three-layer context model reduces AI token spend ≥60%"
4. **Update "When to Use This Pattern"** — ✅ / ❌ criteria are correct; no change needed

### Part B — Sample Prompts Section

1. **Read current Sample Prompts section** — identify each trigger and its description
2. **For each legacy prompt**, add the modern ACP Enhanced equivalent immediately below:

   | Legacy Trigger | Modern Equivalent |
   |---|---|
   | `AGENT.md: Initialize` | `@acp.init` |
   | `AGENT.md: Proceed` | `@acp.proceed` |
   | `AGENT.md: Update` | `@acp.version-update` or `@acp.update` |
   | `AGENT.md: Check for updates` | `@acp.version-check-for-updates` |
   | `AGENT.md: Uninstall` | `acp.uninstall.sh -y` (bash, no command equivalent) |

3. **Add a note** at the top of the Sample Prompts section:  
   ```
   > **ACP Enhanced users**: Use `@acp.*` command files (below) instead of 
   > legacy trigger strings. The trigger strings remain supported for 
   > backward compatibility with the original ACP pattern.
   ```
4. **Add a new "ACP Enhanced Commands Quick Reference" sub-section** showing the 5 most common daily-use commands with one-line descriptions (init, proceed, resume, plan, status)

## Verification

- [ ] Conclusion opening sentence says "ACP Enhanced" not "Agent Directory Pattern"
- [ ] Key Takeaways mentions package ecosystem and token efficiency
- [ ] Each legacy Sample Prompt shows its `@acp.*` equivalent
- [ ] Note at top of Sample Prompts explains the legacy/modern distinction
- [ ] ACP Enhanced Commands Quick Reference sub-section is present
- [ ] No other mentions of "Agent Directory Pattern" remain in document (except historical/quote context)

---

**Next Task**: [task-136](task-136-session-memory-and-housekeeping.md)
