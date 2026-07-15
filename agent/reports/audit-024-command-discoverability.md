# Audit Report: Command Discoverability + In-Situ User Guidance

**Audit**: #024  
**Date**: 2026-06-03  
**Subject**: Third-round review — command discoverability, related-command suggestions, in-situ user guidance, and industry alignment for the v6.8.2 updates

## Summary

This audit addresses the root cause behind the feedback's most damning metric: **43 of 48 commands were never invoked in 14 sessions of production use**. The commands work — users simply don't know they exist or when to use them. The fix is a three-part discoverability system:

1. **Post-command suggestions** — After each command completes, the agent suggests 2–3 related commands with "when to use" descriptions
2. **Underused-command detection** — When repetitive manual work is detected, suggest the automation command
3. **Getting-started check** — First-time or returning users get a quick-start suggestion

This mirrors VS Code's command palette "Related" section, npm's post-install tips, and Rails' scaffold "Next steps" output.

## Industry Standards Referenced

| Product | Pattern | ACP Enhanced Equivalent |
|---------|---------|------------------------|
| **VS Code** | Command palette shows "Related" + "Recently Used" | `command_suggestions` map in routing.yml |
| **npm** | "Did you know?" tips after `npm install` | Underused-command detection + tips |
| **Rails** | Scaffold generator outputs "Next steps" list | Post-command related suggestions |
| **GitHub Copilot** | Chat shows related slash commands after invocation | Agent appends related commands inline |
| **Cursor** | Tab-to-accept suggestions with descriptions | One-line "when to use" descriptions per suggestion |

## What We Implemented

### 1. Central Command Relationship Map (`routing.yml`)

Added `command_suggestions` section with 24 command → related-commands mappings. Each entry:
- Command name as key
- List of `{related_command}: "when to use it"` pairs
- Agent selects 2–3 most relevant after each command execution

Example:
```yaml
acp-audit:
  - acp-commit: "Save audit findings to session memory"
  - acp-update: "Update progress.yaml with audit results"
  - acp-status: "Check overall project status after audit"
```

### 2. Post-Command Discoverability Protocol (`copilot-instructions.md`, `CLAUDE.md`)

Three rules added:

**Rule 1 — Suggest Related Commands**: After every command execution, display:
```
📋 Related: /acp-commit (save findings to memory) · /acp-update (update progress) · /acp-status (check status)
```

**Rule 2 — Surface Underused Commands**: When same task type repeated 3+ times manually:
```
💡 Tip: /acp-route can classify and route your tasks. You've classified them manually 3 times this session.
```

**Rule 3 — Getting Started Check**: First session or >7 days since last use:
```
👋 New to ACP Enhanced? Try /acp-status to see your project state, then /acp-proceed to start working.
```

## Gaps Found and Fixed

| ID | Gap | Impact | Fix |
|----|-----|--------|-----|
| **GAP-009** | No discoverability mechanism | 43/48 commands never used — users don't know what exists | Added `command_suggestions` map + post-command protocol |
| **GAP-010** | 10 commands missing Related Commands sections | Users reading those docs have no "what next" guidance | All 24 core commands now have `command_suggestions` entries |
| **GAP-011** | No "getting started" guidance | New users overwhelmed by 63 commands with no entry point | Added 👋 check in protocol |
| **GAP-012** | No underused-command detection | Repetitive manual work not identified as automation opportunity | Added 3x repetition detection rule |
| **GAP-013** | Related Commands sections describe *what* not *when* | Users know command names but not when they apply | All suggestions now use "when to use" format |

## Comparison: Before vs After

| Metric | Before | After |
|--------|--------|-------|
| Commands with discoverable relationship paths | 0 (static docs only) | 24 mapped with "when to use" descriptions |
| Post-command guidance | None | 2–3 related commands per invocation |
| New user onboarding | 63 commands, no entry point | 👋 tip on first session |
| Underused command detection | None | Automatic after 3+ manual repetitions |
| Industry alignment | None | VS Code / npm / Rails / Copilot patterns |

## Expected Impact

| Outcome | Projection |
|---------|-----------|
| Command discovery rate | 10% → ~60% (users see related commands they didn't know existed) |
| Context protocol compliance | 0% → ~80% (light mode is actually usable) |
| Underused command adoption | Gradually as tips surface in relevant contexts |
| New user onboarding time | Reduced by showing clear starting point |

## Files Changed

| File | Changes |
|------|---------|
| `agent/core/routing.yml` | Added `command_suggestions` with 24 command mappings |
| `.github/copilot-instructions.md` | Added Post-Command Discoverability section (3 rules) |
| `CLAUDE.md` | Synced Post-Command Discoverability section |
