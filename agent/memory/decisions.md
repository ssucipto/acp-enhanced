# Architecture Decision Records (ADR Log)
# Loaded by section (ADR ID) only — never fully loaded
# Add entries via /acp-decide command

## ADR-5 | 2026-05-03 | Merge agent/ hidden directory into agent/
**Status:** Accepted
**Context:** ACP Enhanced introduced `agent/` as a hidden meta-layer separate from the original `agent/` protocol directory. This caused ongoing confusion: developers must remember which layer a file lives in; the dot-prefix hides the directory from `ls` and GitHub web UI; the agent/vs-agent/ split is not intuitive.
**Options considered:** (1) Keep `agent/` hidden — preserves fork separation. (2) Merge into `agent/` — makes ACP Enhanced additions visible and first-class alongside original protocol files.
**Decision:** Merge `agent/` into `agent/`. Subdirs map directly except `agent/routing/tasks/` → `agent/routing/tasks/` (to avoid collision with existing `agent/tasks/` project task files).
**Consequences:** Single `agent/` tree. ACP Enhanced additions (`core/`, `memory/`, `routing/`, `skills/`, `wiki/`) are visible and navigable. All `agent/` path references updated across 13 files. Install/update scripts updated in task-003.
**DO NOT re-open** unless ACP Enhanced is used as an overlay package on a separate project's `agent/` directory (multi-repo use case requiring namespace separation).

## ADR-1 | 2026-05-01 | Use flat dot-notation command directory structure
**Status:** Accepted
**Context:** Commands needed to be discoverable via IDE autocomplete and distinguishable by namespace without nested directories.
**Options considered:** Nested directories (acp/init.md), flat with prefix (acp-init.md), flat with dot notation (acp.init.md)
**Decision:** Flat directory with dot notation (`agent/commands/acp.foo.md`). Namespace prefix before first dot, command name after.
**Consequences:** Autocomplete shows all commands. Namespace is explicit. No directory traversal needed.
**DO NOT re-open** unless the number of commands exceeds 200 and discoverability suffers.

## ADR-2 | 2026-05-01 | Pure bash YAML parser — no external dependencies
**Status:** Accepted
**Context:** ACP scripts need to read/write YAML but must work with zero external dependencies on any macOS or Linux system.
**Options considered:** jq (JSON only, separate install), yq (separate install), python pyyaml (not always present), pure bash
**Decision:** Custom pure-bash YAML parser (agent/scripts/acp.yaml-parser.sh) based on fiftydinar/yaml-parser (MIT).
**Consequences:** Works everywhere bash 4+ is available. Limited to flat/simple YAML — no anchors or complex nesting.
**DO NOT re-open** unless the YAML structures grow beyond what the parser handles correctly.

## ADR-4 | 2026-05-03 | Standardize command invocation syntax to /acp-<command>
**Status:** Accepted
**Context:** Two patterns coexisted — `@acp.<command>` in 51 command files, AGENT.md, README; `/acp-<command>` in AGENTS.md, CLAUDE.md, copilot-instructions.md. Dual-alias notation ("run /acp-commit or @acp.commit") confirmed this was never resolved.
**Options considered:** (1) Keep `@acp.<command>` — matches original ACP upstream. (2) Keep `/acp-<command>` — matches VS Code slash-command convention, unambiguous in terminal/chat UIs. (3) Support both forever — already proven confusing.
**Decision:** `/acp-<command>` is the single canonical syntax everywhere. `@acp.<command>` is eliminated across all command docs, AGENT.md, README, shell scripts, docs, and e2e tests.
**Consequences:** task-001 (text/docs), task-002 (directory migration), task-003 (install scripts), task-004 (e2e tests + skill files) implement this fully. `git.*` namespace commands are out of scope — separate decision required.
**DO NOT re-open** unless a new AI runtime mandates `@` prefix over `/`.

## ADR-3 | 2026-05-01 | ACP Enhanced: three-layer context model replaces monolithic AGENT.md
**Status:** Accepted
**Context:** The original AGENT.md loaded all project knowledge for every task, wasting tokens and preventing prompt caching.
**Options considered:** Single AGENT.md (current), per-task context files (too granular), three-layer model (core/skills/memory)
**Decision:** Three-layer model: Layer 1 (core/ — static, cached), Layer 2 (skills/ — one per task domain), Layer 3 (memory/ + wiki/ — filtered, dynamic). Total budget: 2,800 tokens.
**Consequences:** 75–88% token reduction vs monolithic AGENT.md. Prompt caching on Layer 1 gives additional 50–97x savings on repeated calls. Skills must cover all task domains exhaustively.
**DO NOT re-open** unless a task type genuinely requires >2,800 tokens of context to complete correctly.
