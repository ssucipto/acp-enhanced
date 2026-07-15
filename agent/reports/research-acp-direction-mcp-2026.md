# Research: ACP Enhanced Development Direction — MCP, Product Split, Deterministic Checks

**Type**: Direction research (requested via /acp-audit + research)
**Date**: 2026-07-15
**Question**: Where next? Is an MCP server warranted? Split code-review/code-integrity into MCP products? What happens to deterministic checks? Have we gone beyond "protocol to maintain context"?

---

## 1. The hypothesis is quantitatively true

"We have gone beyond protocol to maintain context" — measured against the repo at v6.27.1:

| Layer | Files | Lines | Nature |
|-------|-------|-------|--------|
| Protocol (command docs) | 73 | 28,744 | Markdown interpreted by LLMs |
| Toolchain (bash scripts) | 47 | 15,157 | Deterministic engines |
| Toolchain (TS validator/dispatch) | 5 | 3,360 | Deterministic engines |
| Tests (e2e + unit) | 77 | 13,135 | Toolchain QA |
| Wrapper glue (5 surfaces) | 288 | — | Exists ONLY because commands are markdown, not tools |

Toolchain + tests (31.7k lines) now **exceed** protocol content (28.7k lines), and 288 generated files + 2 sync scripts + a 5-surface parity validator exist purely as distribution tax. ACP Enhanced is de facto **three products in one repo**:

- **A. Context protocol** — three-layer loading, memory (sessions/lessons/decisions/patterns), planning docs. The original identity.
- **B. Deterministic QA toolkit** — acp-validate.ts (30+ checks), review-scan (64 rules), integrity scanners (unicode/entropy/taint/manifest), meta-scan, post-milestone-sweep. Generic value, mostly not ACP-specific.
- **C. Cross-tool distribution glue** — wrappers, sync scripts, parity enforcement.

## 2. External landscape (verified July 2026)

- **MCP is mainstream infrastructure**: 10,000+ active public servers, 97M+ monthly SDK downloads, native support in ChatGPT, Cursor, Gemini, Microsoft Copilot, VS Code; official registry ~9.6k server records; Linux Foundation governance (Agentic AI Foundation). A new spec finalized **2026-07-28**: stateless protocol core, **Tasks** (long-running operations), Extensions, MCP Apps.
- **Practitioner consensus on Skills vs MCP**: *Skills answer "how do we do X here"; MCP answers "what is true right now over there."* Skills cost ~30–50 tokens until invoked; a five-server MCP setup can burn 50k+ tokens of upfront context. Guidance: **build CLI + Skills first; reach for MCP only when state lives inside another running system** — or when the caller can't run a CLI.
- **AGENTS.md is now a Linux Foundation standard** (same foundation as MCP), read natively by Claude Code, Codex CLI, Cursor, Aider, Devin, Copilot, Gemini CLI, Windsurf, Amazon Q; 60k+ repos carry one. ACP's protocol substrate sits on standardized ground.

## 3. Analysis per question

### Is an MCP server something to consider? — Yes, but narrowly.

The naive move (wrap all 70 commands as MCP tools) would be a mistake: ACP commands are *methodology* — workflows, planning discipline, memory protocol — which is exactly the "Skills/instructions" half of the split, and 70 tools would recreate the 50k-token anti-pattern while violating ACP's own token-efficiency priority. The protocol layer already travels perfectly as markdown + AGENTS.md.

The **deterministic layer (B) is the genuine MCP fit**: validate/review/integrity are CLI programs whose callers today must be bash-capable coding agents. An MCP adapter adds: structured typed output instead of parsed stdout; callability from non-CLI surfaces (Claude Desktop, ChatGPT, dashboards, CI orchestrators); and the new MCP **Tasks** primitive maps cleanly onto long scans (quarterly deep-scan, M58 Phase 2 when it ships). Also strategic: the wrong-cwd vacuous-green class of bug (audit-091) is structurally impossible in a tool with a typed schema.

### Split the app? Create MCP for code-review and code-integrity? — Split boundaries first, extract the one piece with a market.

Review + integrity are the **only components with standalone product value**: "AI-generated-code trust scanning" (unicode injection, entropy, taint flow, provenance manifest) is a defensible niche among 10k mostly-CRUD MCP servers, and it is not ACP-coupled — any repo could consume it. A full repo split today, though, is premature for a solo-maintained project: it doubles release/CI/versioning overhead before demand is proven. Sequence it: monorepo package boundaries → thin MCP adapter → extract only if external adoption shows up.

### Deterministic checks? — One engine, many interfaces.

ADR-13 (deterministic → bash, semantic → LLM) already made the right call; extend it one level: **bash/TS stays the single engine; CLI, CI, and MCP are thin interfaces over it.** Never reimplement a scanner inside the MCP server. CI remains the enforcement backbone regardless of interface.

### The wrapper problem — contain, don't re-architect.

The 288-file glue layer is now fully automated (sync scripts) and validator-enforced (5-surface parity, M72). It's ugly but cheap. The eventual exit is Claude Code **Skills packaging** (SKILL.md format — 30–50 token footprint matches ACP's budget discipline) and, for MCP-capable clients, MCP prompts; both can coexist with wrappers until client support makes wrappers redundant. Don't spend a milestone on this now.

## 4. Recommendation — phased, reversible

| Phase | Milestone | Deliverable | Bet size |
|-------|-----------|-------------|----------|
| 1 | M74 | **Name the layers in-repo**: package boundaries `acp-protocol` / `acp-toolkit` (validate, review, integrity CLIs) inside the monorepo; ADR for the three-product model | Small, reversible |
| 2 | M75 | **`acp-toolkit` MCP server** (one server, ~6–8 tools: validate, review_scan, integrity_scan, status, carryover_query, route, memory_commit) targeting the 2026-07-28 spec (stateless core + Tasks); npx-distributable; CLI stays primary for coding agents | Medium |
| 3 | M76 | **Extract `code-integrity` (+review) as a standalone dual-interface product** (CLI + MCP), listed on the official MCP registry; ACP consumes it as a dependency. Go/no-go gated on M75 signal | The real bet |
| — | ongoing | Protocol layer: converge on AGENTS.md standard; pilot SKILL.md packaging for command docs; **do not MCP-ify the protocol** | Zero-risk |

**Constraints to honor**: `no_external_deps` stays true for the protocol tier (pure markdown+bash, works agent-agnostically); MCP is an *optional* tier. Solo-maintainer bandwidth means M76 only proceeds with evidence (registry installs, external feedback beyond FIFOZ/SmartDojo/TikrFlow).

**What this rejects**: full repo split now (overhead before demand); MCP-ifying all commands (token anti-pattern, wrong tool class); rewriting scanners in server code (engine duplication); dropping wrappers (they're paid for and enforced).

## Sources

- MCP adoption/registry statistics 2026 — digitalapplied.com (MCP Adoption Statistics 2026; 97M downloads; H1 2026 retrospective)
- MCP 2026-07-28 specification release candidate — blog.modelcontextprotocol.io
- WorkOS: Everything your team needs to know about MCP in 2026
- Verdent: Claude Skills vs MCP — When CLI+Skills beats MCP; morphllm.com Skills vs MCP vs Plugins guide
- AGENTS.md field guides 2026 (iuriio.com; morphllm.com; hivetrail.com) — Linux Foundation Agentic AI Foundation governance, cross-tool adoption
