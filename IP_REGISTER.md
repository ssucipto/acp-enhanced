# Intellectual Property Register

**Document Type**: Pre-Existing IP Schedule  
**Purpose**: Founder Agreement — Pre-Existing Intellectual Property Disclosure  
**Date**: 2026-05-17  
**Status**: Active / In Development

> **Legal Notice**: This document is a factual record of pre-existing intellectual property
> intended to support a founder agreement. It does not constitute legal advice. The owner
> should seek independent legal counsel before executing any founder, shareholder, or IP
> assignment agreement.

---

## IP Item #001 — ACP Enhanced (Agent Context Protocol Enhanced)

### 1. Identification

| Field | Detail |
|---|---|
| **Name** | ACP Enhanced — Agent Context Protocol Enhanced |
| **Type** | Proprietary Software — AI Agent Tooling Framework |
| **Category** | Original Authorship — Computer Software |
| **Current Version** | 6.29.3 |
| **Repository** | `https://github.com/ssucipto/acp-enhanced` (public) |
| **License** | MIT License (portions of original ACP: © Patrick Michaelsen) |

---

### 2. Ownership

| Field | Detail |
|---|---|
| **Author / Creator** | Suryo Sucipto |
| **Nature of Creation** | Fork of open-source project (Agent Context Protocol by Patrick Michaelsen), substantially extended and enhanced by Suryo Sucipto as an original, independent work |
| **Creation commenced** | February 2026 (first commit: 2026-02-11) |
| **Employment at time of creation** | Created independently, outside of any employer engagement |
| **Funding at time of creation** | Self-funded; no third-party capital contributed |
| **Claim type** | Original Derivative Work — author asserts ownership of all original contributions as pre-existing IP; upstream open-source portions remain under MIT licence |

---

### 3. Description

ACP Enhanced is an AI agent tooling framework that implements the Agent Context Protocol — a documentation-first development methodology enabling AI coding agents to maintain structured, persistent project knowledge across sessions. The framework solves the "zero-context" problem: without ACP Enhanced, every AI coding session starts cold with no memory of prior decisions, corrections, or architectural choices.

The software provides a five-layer structured memory system: identity and constraint files (loaded every session), domain-specific skill files (one per session), a session log with lessons learned, a task routing taxonomy that classifies work by type and routes it to the appropriate AI model, and a wiki reference layer. Together these layers give the AI agent a reproducible, deterministic context budget of 5,000 tokens per session, ensuring consistency and cost efficiency across long-lived software projects.

ACP Enhanced is deployed by running a single bootstrap script (`acp-bootstrap.sh`) that installs the full `agent/` directory framework into any target project. It registers 63 slash commands accessible via VS Code Copilot (`.github/prompts/`) and opencode TUI (`.opencode/commands/`), and includes TypeScript tooling (`acp-dispatch.ts`, `acp-validate.ts`) for automated model routing, cost tracking, and schema validation.

The framework is designed for solo developers and small teams building complex software with AI coding agents, providing capabilities including: proactive mid-session memory writes (Write-Ahead Log pattern), git branch safety guards, pre-implementation audit protocols, audit carryover tracking, and automatic cost ledgering per task.

---

### 4. Technical Architecture

#### 4.1 Protocol Layer (Bash Shell)

| Component | Detail |
|---|---|
| Language | Bash 3.2+ (cross-platform: macOS BSD + Linux GNU) |
| Entry point | `scripts/acp-bootstrap.sh` |
| Runtime scripts | `agent/scripts/*.sh` (28 shell scripts) |
| Key constraint | No external dependencies (no jq, yq, python in scripts) |
| Custom parser | Pure-bash YAML parser (`tests/acp.yaml-parser.test.sh`) |

#### 4.2 Command Documentation Layer (Markdown)

| Component | Detail |
|---|---|
| Format | Markdown with embedded agent directives |
| Count | 63 command files (`agent/commands/*.md`) |
| Delivery | VS Code Copilot prompts (`.github/prompts/`), opencode commands (`.opencode/commands/`) |
| Namespaces | `acp.*` (61 commands), `git.*` (2 commands) |

#### 4.3 TypeScript Tooling Layer

| Component | Detail |
|---|---|
| Language | TypeScript (Node.js 18+) |
| Runtime | `ts-node` |
| Key files | `scripts/acp-dispatch.ts` (model routing + cost ledger), `scripts/acp-validate.ts` (schema + parity validation) |
| Package manager | npm (`scripts/package.json`) |

#### 4.4 Configuration + Schema Layer

| Component | Detail |
|---|---|
| Format | YAML |
| Key files | `agent/core/identity.yml`, `agent/core/constraints.yml`, `agent/routing/taxonomy.yml`, `agent/schemas/*.yaml`, `package.yaml` |
| Custom schema | Pure-bash YAML parser for config reading in shell scripts |

#### 4.5 Memory + Knowledge Layer

| Component | Detail |
|---|---|
| Session log | `agent/memory/sessions.md` (YAML blocks, auto-compacted at 15 entries) |
| Lessons log | `agent/memory/lessons.md` (filtered by task type, max 5 per session) |
| Audit carryovers | `agent/memory/audit-carryovers.md` (unresolved findings across sessions) |
| Decisions | `agent/memory/decisions.md` (Architectural Decision Records) |
| Patterns | `agent/memory/patterns.md` (reusable implementation patterns) |

---

### 5. Scope of Pre-Existing IP

#### 5.1 Original Source Code

The following directories and files represent original authored contributions by Suryo Sucipto (not present in the upstream fork at the time of forking):

- `scripts/acp-bootstrap.sh` — full bootstrap installer (eight-step setup, pre-commit hook, opencode generation)
- `scripts/acp-dispatch.ts` — model routing engine with OpenRouter API integration and cost ledger
- `scripts/acp-validate.ts` — schema and parity validation tool (five check functions)
- `agent/core/` — all three core YAML files (identity, constraints, routing)
- `agent/skills/` — all seven skill domain files (commands, crosscut, schemas, scripts, testing, typescript, upstream-sync)
- `agent/routing/taxonomy.yml` — task classification taxonomy (30+ task types with executor mappings)
- `agent/routing/rules.md` — routing rules and threshold definitions
- `agent/routing/ledger.md` — cost tracking ledger
- `agent/memory/` — sessions.md, lessons.md, audit-carryovers.md, decisions.md, patterns.md (all original content)
- `agent/wiki/` — domain.yml, architecture.md reference wiki
- `agent/reports/` — all 18 audit reports
- `.github/prompts/` — all 63 VS Code Copilot prompt files
- `.opencode/commands/` — all 63 opencode slash command files

#### 5.2 System Architecture & Design

- Five-layer tiered context loading protocol (identity → skill → memory → wiki → task)
- Proactive Write-Ahead Log (WAL) pattern for mid-session memory writes (7 triggers)
- Task taxonomy-based model routing (flash/pro/sonnet selection per task type)
- Audit carryover tracking system across sessions
- Pre-implementation readiness audit protocol (`--pre-impl` flag, 4 phases)
- Git branch safety guard (Step 1b in context-loading protocol)
- Cost-per-task ledgering with per-model pricing
- AGENTS.md → CLAUDE.md pre-commit sync hook

#### 5.3 Configuration & Infrastructure Definitions

- `agent/core/identity.yml` — project identity schema
- `agent/core/constraints.yml` — hard rules and context budget definitions
- `agent/core/routing.yml` — session executor configuration
- `agent/routing/config.yml` — per-model pricing and routing configuration
- `agent/schemas/*.yaml` — YAML schemas for ACP artefacts
- `package.yaml` — ACP package definition

#### 5.4 Documentation & Design Artefacts

- `README.md` — full product documentation
- `CHANGELOG.md` — version-by-version record (v6.0 → v6.9.1)
- `scripts/QUICKSTART.md` — user onboarding guide
- `docs/USAGE.md` — extended usage documentation
- `agent/design/` — UX review and design documents
- `agent/milestones/` — milestone planning documents (M38–M43)
- `agent/memory/decisions.md` — Architectural Decision Records

---

### 6. Exclusions — Third-Party Components

The following are **not** claimed as original IP. They are open-source or third-party components used under their respective licences:

| Component | Licence | Use |
|---|---|---|
| Agent Context Protocol (upstream) | MIT | Original fork base: command docs, install scripts, ACP workflow pattern |
| `gray-matter` (npm) | MIT | YAML/frontmatter parsing in TypeScript tooling |
| `js-yaml` (npm) | MIT | YAML parsing in TypeScript tooling |
| `openai` (npm) | MIT | OpenRouter API client (OpenAI-compatible interface) |
| `@types/js-yaml` (npm) | MIT | TypeScript type definitions |
| `@types/node` (npm) | MIT | Node.js type definitions |
| `ts-node` (npm) | MIT | TypeScript execution without pre-compilation |
| `typescript` (npm) | Apache-2.0 | TypeScript compiler |

All third-party components retain their original licences. No proprietary modifications have been made to third-party source code.

**Upstream ACP attribution**: The original Agent Context Protocol by Patrick Michaelsen (https://github.com/prmichaelsen/agent-context-protocol) is available under the MIT licence. ACP Enhanced is a derivative work — the upstream command workflow, ACP concept, and install script pattern are credited to the original author. All enhancements, the `agent/` framework layer, TypeScript tooling, bootstrap installer, and memory system are original contributions by Suryo Sucipto.

---

### 7. Development Timeline

| Period | Event |
|---|---|
| February 2026 | Project forked from upstream ACP; first commit 2026-02-11; `agent/` framework layer conceived and commenced independently by Suryo Sucipto |
| February–April 2026 | Core framework built: context-loading protocol, skill routing, memory system, task taxonomy, TypeScript tooling (v6.0–v6.3) |
| May 2026 (v6.4.13) | M38 — Knowledge Preservation: proactive 7-trigger WAL system shipping |
| May 2026 (v6.5.0) | M39 — Git Branch Awareness: Step 1b branch guard added |
| May 2026 (v6.6.0) | M40 — Pre-Implementation Audit Protocol: `--pre-impl` flag + carryover tracking |
| May 2026 (v6.7.0) | M41 — Command Infrastructure Expansion: 4 new commands, pre-commit hook, Windows/WSL2 docs |
| May 2026 (v6.8.0) | M42 — Dispatch Integrity + Validation Hardening: 5 new validate checks, 9 new task types |
| May 2026 (v6.8.1) | M43 — Taxonomy + Validation Hygiene: `shell-scripting` type, `checkStaleness` order fix, ledger header, command-doc-write threshold rule |
| 2026-06-04 (v6.9.0) | M47 — Memory Integrity: commit-integrated document auto-sync, repair tools, --memory YAML validation, version-update guard, schema alignment, dual-store wiki, pattern promotion, command onboarding |
| 2026-06-04 (v6.9.1) | M48 — Carryover Resolution: E2E tests (12 assertions), atomicity in sync, registry schema lint, audit-first wiki, --health check, index init, carryover query |
| 2026-06-06 (v6.9.2) | M49 — Dogfooding + Install Resolution: triple-file parity, AGENTS.md version, Windows hang fix, bootstrap self-heal, Cursor commands, post-install verify, --repair mode |
| 2026-06-06 (v6.9.3) | M50 — Design-Spec Command: /acp-design-spec integrated from FIFOZ, 19-section template (arc42/C4/IEEE/ISO), stack-agnostic, E2E smoke test (12 assertions) |
| 2026-06-06 (v6.9.4) | M51 — Bootstrap Install Fix: CRITICAL step 7 file-count check, opencode extraction from prompts block, verification exit code + remediation, E2E bootstrap test (8 assertions) |
| 2026-06-07 (v6.9.5) | M52 — Stakeholder Report: /acp-stakeholder-report v1.1.0 from FIFOZ, five-tier reporting model, 4 audit-044 carryovers resolved, E2E test (15 assertions) |
| 2026-06-07 (v6.10.0) | M53 — Cursor Slash Commands: .cursor/commands/ auto-generation via sync script, install/update hooks, bootstrap step 6b, .cursor/rules/ agent protocol, E2E test (10 assertions), @acp. hotfix |
| 2026-06-07 (v6.10.1) | M54 — CI/CD Pipeline + GitFlow-Lite: GitHub Actions ci.yaml (validate, shellcheck, e2e-smoke) + e2e-tests.yaml (parallel ubuntu+macos), develop→mainline branching, YAML EXIT trap fix, 44/44 tests green |
| 2026-06-07 (v6.11.0) | M55 — /acp-review Command: 54-rule code quality & security enforcement (OWASP Top 10:2025 + MASVS v2.0), TypeScript-first, copilot executor, 4 task types, 49-assertion E2E, audit-050/051/052 |
| 2026-06-08 (v6.12.0) | M56 — /acp-integrity Command: 55-rule AI code trustworthiness & provenance (hidden Unicode, exfiltration, supply chain, CI injection), 6 bash scripts, LLM/Script Boundary Rule, 26-assertion E2E, audit-053/054/055/056/057/058 |
| 2026-06-08 (v6.12.0) | M56 — Audit-056/057/058: 3 rounds post-implementation — 13 bugs/gaps found & fixed (shell injection, trap ERR, regex, domain.yml, progress.yaml, cross-links) |
| 2026-06-08 (v6.12.1) | M57 — Recurring Tasks Scheduler: 5 default scheduled tasks (weekly review, integrity scan, pre-commit audit, monthly dependency, quarterly deep scan), AGENTS.md Step 4.5, constraints.yml hooks, progress.schema.yaml recurring_tasks, E2E test (16 assertions) |
| 2026-05-17 | Version 6.8.1; this IP Register created |

---

### 8. Evidence of Creation

The following artefacts constitute evidence of original authorship and creation timeline:

1. **Git repository** — `https://github.com/ssucipto/acp-enhanced` — full commit history with author timestamps from 2026-02-11
2. **CHANGELOG.md** — version-by-version record of all changes from v6.0 through v6.8.1 with dates and task references
3. **`agent/memory/sessions.md`** — AI session log with dated entries covering every work session, tasks completed, and key learnings
4. **`agent/reports/`** — 18 dated audit reports documenting investigative work and architectural decisions
5. **`agent/milestones/`** — milestone planning documents (M38–M43) with task breakdowns and completion records
6. **`agent/memory/decisions.md`** — Architectural Decision Records (ADRs) with dated decision rationale

---

### 9. IP Assignment Position

**This IP is disclosed as pre-existing intellectual property.**

For any founder agreement or company formation, the author asserts:

- This software and all associated artefacts were created **prior to** the formation of any company or partnership
- Any licence granted to a company formed by the author is **by agreement only** and does not constitute automatic assignment
- The **terms of any IP licence or assignment** (including scope, consideration, warranties, and conditions) must be explicitly negotiated and documented in the founder agreement
- The author **retains all moral rights** in the work as the sole original author of all enhancements and additions to the upstream open-source base

> **Recommended clauses for founder agreement:**
> - Define whether this IP is *licensed* to the company (author retains ownership) or *assigned*
>   (ownership transfers to the company, typically in exchange for equity consideration)
> - If licensed: specify exclusivity, territory, field of use, sublicensing rights, and termination conditions
> - If assigned: specify consideration (equity %), warranties of title, and any carve-outs
> - Note: the MIT-licensed upstream components cannot be assigned as proprietary IP; any assignment
>   clause must explicitly carve out third-party components covered by their own licences

---

### 10. Declaration

I, **Suryo Sucipto**, declare that:

1. I am the original author of all ACP Enhanced framework enhancements, tooling, memory system, bootstrap installer, and documentation listed in this register
2. This IP was created independently, prior to any company formation or co-founder arrangement
3. No third party (other than the MIT-licensed upstream contributors credited above) has a claim to ownership of this IP that has not been disclosed above
4. No employer, client, or contractor arrangement in force at the time of creation gave any third party rights over this work
5. The information in this register is accurate to the best of my knowledge as of the date stated above

| | |
|---|---|
| **Name** | Suryo Sucipto |
| **Date** | 2026-05-17 |
| **Signature** | _________________________ |

---

*This document should be attached as a schedule to the relevant founder or shareholder agreement.*  
*Seek independent legal advice before executing any IP-related agreement.*
