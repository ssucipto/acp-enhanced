# Audit Report: feedback-006 — `/acp-review` Command Scope Analysis

**Audit**: #050  
**Date**: 2026-06-07  
**Subject**: Re-assessment of my review of feedback-006 given ACP Enhanced's actual audience (TypeScript/React/mobile developers) vs. ACP's own codebase (bash/YAML)  

---

## Summary

I audited my own review of feedback-006 (the `/acp-review` command proposal) against the **actual audience** ACP Enhanced serves. My initial recommendation was to scope the 54-rule set down to ~15 ACP-specific bash/YAML rules. That recommendation was **materially wrong** because it confused the tool's own codebase (what ACP itself is built with) with the tool's intended use case (what ACP's users build with it).

ACP Enhanced is a framework that agents and developers adopt for THEIR projects. Those projects are overwhelmingly TypeScript/React/React Native/Expo codebases — exactly the stack the v3 ruleset targets. The full 54-rule set, including OWASP Top 10:2025, OWASP MASVS v2, and TypeScript strict mode rules, is exactly what the audience needs.

The corrected recommendation: **ship the full v3 ruleset as proposed**, with one addition — a small appendix of ACP-specific self-review rules.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md` | feedback | Primary subject — the proposal under review |
| `agent/commands/acp.audit.md` | command doc | Reference for audit procedure |
| `agent/routing/taxonomy.yml` | config | Existing task types; integration point for code-review-* types |
| `agent/core/identity.yml` | core config | Shows repo type: `ai-agent-tooling-protocol` |
| `AGENTS.md` | protocol | ACP context loading protocol — reference for skill routing |
| `blog/blog-00001-acp-intro.md` | blog | Declared audience and use cases |

---

## Key Finding — F1: Audience Misidentification

### What I initially said
> "50% of the rules target TypeScript/web/mobile codebases... ACP Enhanced is primarily Bash/YAML/Markdown — we don't have `src/services/` or React components. Many rules would fire on zero files."

### Why this was wrong

ACP Enhanced is a **framework**, not an end-user application. Its purpose is to be adopted by OTHER projects. The ACP repository itself happens to be built with bash and YAML because that's ACP's domain — but ACP's USERS are building:

| Audience Segment | Stack | Rules Needed |
|-----------------|-------|-------------|
| Web developers | React, Next.js, Express, Node.js | EH-01 through CH-10, all security rules (SC-01 through SC-25), all API rules (AP-01 through AP-09), all TypeScript rules (TS-01 through TS-13) |
| Mobile developers | React Native, Expo | Same as web + SC-19 through SC-23 (MASVS mobile security) |
| Backend developers | Node.js, TypeScript | Error handling, API consistency, security, TypeScript strictness |
| ACP framework developers (self-review) | Bash, YAML, Markdown | ACP-specific rules (SH-01 through SH-04, YM-01 through YM-03, AP-01 through AP-03) |

The fact that ACP's own codebase is bash/YAML is **irrelevant** to the `/acp-review` command's value. The command is designed to run AGAINST the user's project, not against ACP itself. In Cursor/VS Code, the working directory is the user's project — which will contain `src/`, `components/`, `services/`, etc.

---

## Key Finding — F2: The Proposal Is Framework-Level, Not Self-Review

The feedback-006 proposal is correctly designed as a **framework capability** — a tool that ACP provides to its adopters. It belongs in the same category as `/acp-audit` and `/acp-design-spec`:

```
/acp-audit           → Deep-dive investigation (any subject)
/acp-design-spec     → Interface & data-flow inventory
/acp-review          → Codebase-wide standards enforcement ← NEW
/acp-stakeholder-report → Business-level progress summary
```

All of these are framework capabilities that operate on the USER's project, not on ACP itself. Scoping the review rules to ACP's own codebase would be like scoping `/acp-design-spec` to only work on bash scripts.

---

## Key Finding — F3: What IS Missing (Self-Review Addendum)

The one thing the proposal does NOT cover is the ability to review ACP's OWN codebase — i.e., ensuring ACP's bash scripts, YAML files, and markdown docs follow the conventions the project itself preaches. This is a legitimate gap, but it should be an **appendix**, not a replacement for the full ruleset.

### Proposed Addendum: ACP Self-Review Rules

| Rule ID | Rule | Severity | Scope |
|---------|------|----------|-------|
| SH-01 | All `.sh` files use `set -euo pipefail` with `trap ERR` | HIGH | ACP-self |
| SH-02 | No BSD/GNU sed incompatibility (`sed -i ''` on macOS only) | HIGH | ACP-self |
| SH-03 | No unquoted variables in scripts | MEDIUM | ACP-self |
| SH-04 | No `trap cleanup EXIT` inside sourced functions (subshell inheritance risk) | CRITICAL | ACP-self |
| YM-01 | All YAML files parse cleanly — no unquoted braces `{}` in flow sequences | HIGH | ACP-self |
| YM-02 | All Markdown frontmatter parses as valid YAML | MEDIUM | ACP-self |
| YM-03 | Version fields consistent across 8+ version-bearing files | HIGH | ACP-self |
| AP-01 | Command docs have `🤖 Agent Directive` header | MEDIUM | ACP-self |
| AP-02 | Every command has an E2E test file | MEDIUM | ACP-self |
| AP-03 | Scripts follow naming convention `acp.{name}.sh` | LOW | ACP-self |

This addendum activates automatically when `/acp-review` detects ACP's own project structure (`agent/commands/`, `agent/scripts/`, `e2e/` directories present). This is a **scope-detect** mechanism: if the project contains `agent/commands/`, ACP self-review rules are appended to the active ruleset.

---

## Key Finding — F4: Executor Mapping Is Sound for the Audience

The proposal's executor disqualification logic is well-justified:

| Rule | Why Flash/Flash-Max Fails |
|------|--------------------------|
| SC-06 (access control) | Requires tracing auth token through middleware → handler → database — needs cross-file reasoning |
| SC-09 (SSRF) | Requires understanding URL construction from user input across files |
| CH-04 (cognitive complexity) | Requires structural analysis of function body |

Since the audience is building web/mobile apps where these rules are the most critical, the executive selection logic is correct. The fact that the user (ssucipto) typically uses `copilot` (which routes to DeepSeek V4 Pro behind the scenes) means the primary executor is already qualified.

---

## Key Finding — F5: Implementation Scope

The proposal is well-specified but substantial. It requires:

| Component | Effort |
|-----------|--------|
| `agent/commands/acp.review.md` | ~4 hours — command doc with 54 rules embedded |
| `agent/skills/code-review.md` | ~2 hours — compressed 500-token agent prompt |
| `agent/specs/code-quality.standards.md` | ~1 hour — R1-R12 formal requirements |
| `agent/routing/taxonomy.yml` — 4 new task types | ~30 min |
| `agent/core/routing.yml` — command suggestions | ~15 min |
| `e2e/acp.review.test.sh` | ~2 hours |
| Cross-links (AGENTS.md, README, CHANGELOG) | ~1 hour |
| Cursor/OpenCode wrappers | ~15 min (auto-generated) |
| **Total** | **~11 hours (M55-sized milestone)** |

Recommended: **M55 — Code Review Command** (after M54 CI/CD is fully green).

---

## Key Finding — F6: Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Rules don't fire on user's codebase (project structure mismatch) | Medium | Low | `--scope` flag allows users to target specific directories |
| Flash executor accidentally used | Low | High | Skill file explicitly disqualifies Flash; taxonomy enforces qualified executors only |
| Review findings overwhelm users (54 rules produce many hits) | High | Medium | `--severity` flag filters output; `--rules` limits categories; `--ci` mode exits on HIGH+ only |
| Knowledge drift — rules become outdated as OWASP/TS standards evolve | Medium | Medium | Rule IDs traceable to OWASP version; update schedule in CHANGELOG |
| Agent self-assesses "fixed" without verification | Medium | High | §2.6 QG8: re-verification required; never trust self-assessment alone |
| Proposal too large for single milestone | Medium | Medium | Can ship in phases: core rules (M55a) then mobile rules (M55b) |

---

## Revised Verdict

### Original Verdict (❌ incorrect)
> "Yes, but scoped down. The v3 ruleset is built for a TypeScript/React/mobile codebase, not for ACP's bash-script-and-YAML codebase."

### Corrected Verdict (✅ accurate)

**Ship the full v3 ruleset as proposed.** The 54 rules (error handling, TypeScript, naming, API consistency, code health, security baseline including OWASP/MASVS) are exactly what ACP Enhanced's audience needs. ACP is a framework — its value is in the capabilities it provides to adopters, not in reviewing its own bash scripts.

**Add one appendix:** ACP self-review rules (SH-01 through SH-04, YM-01 through YM-03, AP-01 through AP-03) that activate when the project structure matches ACP's own layout. This enables self-review without diluting the primary value.

**Milestone**: M55 (target: ~11 hours). Ship in two phases if desired: core rules (M55a, ~8 hours) then mobile/ACP-self rules (M55b, ~3 hours).

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md` | Full proposal with 54 rules, executor selection, framework integration |
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md§2.3` | Complete ruleset tables (EH-01 through SC-25) |
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md§2.7` | Executor selection guide with disqualification rationale |
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md§3` | Skill file design (500-token agent prompt) |
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md§5` | Full framework integration checklist |
| `agent/routing/taxonomy.yml#task_types` | Existing task types — 4 new entries needed |
| `agent/core/routing.yml#command_suggestions` | New command cross-references needed |
| `blog/blog-00001-acp-intro.md` | Declared audience: developers adopting ACP for their projects |
| `AGENTS.md#who-you-are` | "AI coding assistant working on the agent-context-protocol project" — confirms ACP is the tool, not the user's project |
