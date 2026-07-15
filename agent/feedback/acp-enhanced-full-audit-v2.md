# ACP Enhanced — Full External Audit Report
> **Source**: Perplexity AI | **Date**: 2026-05-11 | **Repo**: `ssucipto/acp-enhanced` | **Branch**: `mainline` | **Version**: 6.6.0
> **Scope**: Full file-level audit — all commands, scripts, memory, routing, dispatch, wiki, domain model, test suites, bootstrap, validate tooling, changelog, AGENT.md, and design docs.
> **Format**: ACP-native feedback — suitable for `/acp-feedback`, injection into `agent/memory/audit-carryovers.md`, or as a standalone audit report in `agent/reports/`.

---

## Executive Summary

ACP Enhanced is a **production-quality, actively maintained AI coding workflow system** at v6.6.0 with 40+ completed milestones, 31 E2E test files, 8 unit test files, a working TypeScript dispatch engine, a 57K-character cross-platform shell library, and a genuine incident-driven memory loop. This is not a prototype. The system is architecturally sound and directly addresses real developer productivity problems.

**Overall verdict: HIGH VALUE. Develop further with confidence.** The critical path is fixing 4 bugs and 3 structural gaps before expanding new features.

| Category | Verdict | Files Read |
|---|---|---|
| Core architecture (3-layer context) | ✅ Sound and coherent | `identity.yml`, `constraints.yml`, `routing.yml` |
| Memory system | ✅ Working, battle-tested | `sessions.md`, `lessons.md`, `patterns.md`, `audit-carryovers.md` |
| Routing + taxonomy | ✅ Cost-optimised, complete | `taxonomy.yml`, `rules.md`, `config.yml` |
| Dispatch script | ✅ Production TypeScript | `scripts/acp-dispatch.ts` |
| Validate script | ✅ Real quality gate | `scripts/acp-validate.ts` |
| Shell library | ✅ Cross-platform, disciplined | `acp.common.sh`, `acp.install.sh` |
| YAML parser | ✅ Pure bash, 32K, tested | `acp.yaml-parser.sh`, `tests/acp.yaml-parser.test.sh` |
| E2E test coverage | ✅ 31 suites — NOT empty | `e2e/*.test.sh` |
| Unit test coverage | ✅ 8 suites | `tests/*.test.sh` |
| Bootstrap script | ✅ Full install automation | `scripts/acp-bootstrap.sh` |
| Wiki (architecture + domain) | ✅ Populated, maintained | `architecture.md`, `domain.yml` |
| Command surface (60 commands) | ⚠️ 4 missing, 1 miscount | `agent/commands/` |
| `sessions.md` integrity | 🔴 Malformed YAML entry | `agent/memory/sessions.md` |
| TypeScript entry point | ⚠️ `package.json` in `scripts/` only | `scripts/package.json` |
| `HTTP-Referer` placeholder | 🔴 Hardcoded in dispatch script | `scripts/acp-dispatch.ts` |
| `git_workflow` feature | ⚠️ Opt-in, not discoverable | `identity.yml` |
| `AGENTS.md` / `CLAUDE.md` sync | ⚠️ Two copies, manual sync | Both files |
| Windows/WSL support | ⚠️ Undocumented | No file |

---

## Section 1 — What Works (Verified, File-by-File)

### 1.1 Dispatch Script (`scripts/acp-dispatch.ts`) ✅

The dispatch script is clean, complete TypeScript (9,472 bytes). Every advertised feature is implemented:

- Reads task frontmatter via `gray-matter`; resolves executor from `taxonomy.yml` via `js-yaml`
- **Cache-optimised prompt assembly**: Layer 1 (identity + constraints + routing + one skill) is assembled as a static system prefix — identical bytes across calls triggers provider-side cache hits. Dynamic user message (last 3 sessions + filtered lessons + task content + taxonomy context_required sections) is assembled fresh per call
- **Token budget enforcer**: If `estimateTokens(system) + estimateTokens(user) > 6,500`, wiki sections are dropped and sessions reduced to 2 — hard fallback, not silent overflow
- **Streaming with usage**: Uses `stream_options: { include_usage: true }` for accurate post-stream token counts
- **Ledger append**: Every dispatch appends a `| date | task_id | task_type | executor | input_tokens | output_tokens | $cost | |` row to `agent/routing/ledger.md`
- **Routing state update**: Writes `session.executor` and `session.model` to `agent/core/routing.yml` before every call so context always reflects current executor
- `getFilteredLessons()` correctly filters by `task_type: [type]`, `task_type: all`, OR `priority: high` — loads max 5 entries

**One confirmed bug** (see BUG-002): `HTTP-Referer` header is a hardcoded placeholder.

---

### 1.2 Validate Script (`scripts/acp-validate.ts`) ✅

At 9,684 bytes, `acp-validate.ts` is a real structural integrity checker:

- **Placeholder scan**: Checks command docs on lines 3–4 for unresolved `{PLACEHOLDER}` patterns (skips fenced code blocks)
- **Command registry sync**: Verifies all commands listed in `domain.yml` exist on disk; catches 404s before they break routing
- **Script-command binding**: Cross-checks `package.yaml` scripts arrays against actual `.sh` files in `agent/scripts/`
- Uses `ACP_COMMANDS_DIR` env var override for testability in CI
- Outputs structured `ValidationError` objects with file, line, message, severity — not just exit codes

**This is the reason the repo has not drifted.** Run it after every milestone.

---

### 1.3 Bootstrap Script (`scripts/acp-bootstrap.sh`) ✅

At 37,679 bytes, `acp-bootstrap.sh` is a complete 7-step installer:

1. Creates full `agent/` directory tree (core, skills, memory, wiki, routing, tasks, milestones, drafts)
2. Copies `AGENTS.md` from ACP Enhanced template (or generates minimal fallback)
3. Copies `CLAUDE.md` and `.github/copilot-instructions.md` from `AGENTS.md`
4. Scaffolds `agent/core/identity.yml`, `constraints.yml`, `routing.yml` with project-specific prompts
5. Copies all 60 command docs to target project's `agent/commands/`
6. Copies all shell scripts to target project's `agent/scripts/`
7. Copies skills, schemas, routing config, and validates install

The bootstrap uses `trap ERR` with a line-number error message, copies skill files using the Bash 3.2-safe `local.*` exclusion pattern (documented in `patterns.md`), and writes a post-install checklist. **This is a deployable install tool, not a placeholder.**

---

### 1.4 E2E Test Suite ✅ (Corrected — NOT Empty)

**Previous assessment was wrong.** The `e2e/` directory has **31 test files** covering the full command surface:

| Test file | Size | Coverage area |
|---|---|---|
| `acp.index.test.sh` | 20,364 | Index system |
| `acp.template-files.test.sh` | 18,487 | Template file management |
| `acp.project-workflow.test.sh` | 18,742 | End-to-end project lifecycle |
| `acp.projects-sync.test.sh` | 10,222 | Project registry sync |
| `acp.experimental-features.test.sh` | 10,855 | Feature flags |
| `acp.script-command-binding.test.sh` | 12,565 | Script-command integrity |
| `acp.package-install-list.test.sh` | 8,175 | Package install and list |
| `acp.meta-scan.test.sh` | 7,992 | Metadata scanning |
| `acp.plan-with-preferences.test.sh` | 7,196 | Planning + preferences |
| `acp.package-info.test.sh` | 6,994 | Package info display |
| `acp.package-list.test.sh` | 6,981 | Package listing |
| `acp.driver-yaml.test.sh` | 6,381 | Driver YAML parsing |
| `acp.command-docs.test.sh` | 6,181 | Command doc validation |
| `acp.sessions.test.sh` | 9,601 | Session management |
| `acp.preferences-cli.test.sh` | 5,351 | Preferences CLI |
| *(+16 more)* | | |

**Unit tests** (`tests/`): 8 files including `acp.yaml-parser.test.sh` (28,277 bytes — comprehensive), `acp.preferences.test.sh` (10,675 bytes), `tests/common.sh` test harness (10,652 bytes).

**YAML parser test** (`tests/acp.yaml-parser.test.sh`) is the most thorough single test file in the repo at 28K — it validates every path expression, CRUD operation, array handling, and edge case in the pure-bash parser. This is production-grade test coverage.

---

### 1.5 Memory System ✅ (Incident-Driven, Not Theoretical)

The memory layer is fully operational with a real incident feedback loop:

**feedback-001 → M38 chain (verified in sessions.md)**:
- TikrFlow: 3 sessions lost to context overflow (audit-40: 14 findings, audit-41: 19 findings, 6 ADRs, 8 patterns)
- → audit-008: 6 findings, 5 decisions R1–R4 adopted (R5 rejected), 7 WAL triggers defined
- → constraints.yml: 6 new `knowledge_preservation` rules added
- → `acp.commit.md` v1.0.0 → v1.1.0 → v1.2.0 (two iterations)
- → audit-009: caught that the fix itself violated process (>5-file commit without sessions.md entry)
- → All violations retroactively fixed

This is a **self-correcting engineering culture** encoded into the repo's own memory. The system learned from its failures and encoded those lessons as hard constraints.

`patterns.md` contains real, tested code templates:
- `tanstack-start-v1-server-fn`: `createAPIFileRoute` does not exist in `@tanstack/react-start/api` — use `createServerFn` with `.inputValidator()` (NOT `.input()`)
- `local-star-exclusion-case-loop`: Bash 3.2-safe `local.*` file exclusion with glob safety guard
- `legacy-dir-migration-create-*` pattern (partial — confirm full entry)

---

### 1.6 Wiki Layer ✅ (Fully Populated)

`architecture.md` (7,691 bytes) documents:
- Command→Script binding model
- Package system data flow (full sequence diagram in markdown)
- YAML parser dependency chain
- Global `~/.acp/` directory structure
- 3-layer context model (Layer 1: ~180 tokens cached, Layer 2: ~400 tokens, Layer 3: ~1,200 tokens filtered)
- Step 1b git branch safety check (M39)
- Step 4.4 audit carryover check (M40)
- 7-trigger WAL session memory protocol
- Dispatch script flow diagram

`domain.yml` (26,761 bytes) — last verified 2026-05-05 — covers all 58 commands with category breakdowns, purpose descriptions, scripts, schemas, memory files, routing task format, and test suite inventory. Updated in M29 to fix a count discrepancy (51→58).

---

### 1.7 YAML Parser (`agent/scripts/acp.yaml-parser.sh`) ✅

At 32,857 bytes, this is a pure-bash YAML parser with no external dependencies (`no jq, no yq, no python` as required by `identity.yml`). The test suite (`tests/acp.yaml-parser.test.sh`) at 28,277 bytes validates path expressions, CRUD operations, array handling, nested structures, and edge cases. This is the foundational dependency for all other shell scripts and is the most-tested component in the entire repo.

---

### 1.8 `scripts/QUICKSTART.md` ✅ (Exists — Not Documented in README)

A full 6-step quickstart guide exists at `scripts/QUICKSTART.md` with estimated times:
- Step 1: Run bootstrap (5 min)
- Step 2: Fill in project identity (10 min)
- Step 3: Bootstrap domain knowledge with `/acp-init` (20 min)
- Step 4: Write 3 foundational ADRs (20 min)
- Step 5: Configure dispatch script — Persona B/C only (30 min)
- Step 6: Validate the full loop (30 min)

**Total: 3–4 hours to full setup.** This is a realistic, honest time estimate.

**The problem**: This file lives in `scripts/` and is not linked from the root `README.md`. New users will not find it.

---

### 1.9 `scripts/FINAL-REVIEW.md` — Honest Self-Audit ✅

The repo contains its own honest UX audit at `scripts/FINAL-REVIEW.md`. Key findings it already acknowledges:

- **What requires zero effort**: AGENTS.md auto-loading, cache hits, ledger logging, sessions compaction
- **What requires one command**: `/acp-route` before each task, `/acp-commit` after each session
- **The honest UX failure points**:
  1. Dispatch script breaks in-IDE flow for Persona B — mitigation: use Cline/Continue.dev for in-IDE, dispatch for out-of-IDE tasks only
  2. `/acp-commit` compliance is the system's single point of failure — pre-commit git hook is the only mitigation
  3. Taxonomy accuracy starts at ~70%, improves to ~85% over 4 weeks — first two weeks expect routing overrides

This document demonstrates genuine product maturity and honesty about tradeoffs.

---

## Section 2 — Critical Bugs (Fix Before Next Development)

### 🔴 BUG-001: Malformed YAML entry in `agent/memory/sessions.md`

**Location**: `agent/memory/sessions.md` — one entry block is missing its `- date:` header

**Details**: A session block covering `tasks: [task-156, task-157, task-158]` (M29 upstream sync work) begins with `executor: copilot` without the required `- date: YYYY-MM-DD` list marker. The block immediately preceding it also appears to end mid-sentence.

**Impact**: `acp-dispatch.ts` `getLastNSessions()` splits on `\n- date:` — this orphaned entry will either be silently skipped or concatenated into an adjacent entry, corrupting session context for every dispatch call.

**Fix**:
```bash
# Verify the correct date from git log
git log --oneline --after="2026-05-04" --before="2026-05-07" | head -10
# Then prepend the missing header to the orphaned block in sessions.md:
# - date: 2026-05-05   ← insert this line
#   executor: copilot
#   tasks: [task-156, task-157, task-158]
```

**Priority**: CRITICAL

---

### 🔴 BUG-002: Hardcoded placeholder `HTTP-Referer` in `scripts/acp-dispatch.ts`

**Location**: `scripts/acp-dispatch.ts`, `defaultHeaders` block

**Found**:
```typescript
"HTTP-Referer": "https://github.com/your-handle/your-repo",
"X-Title": "ACP Enhanced Dispatch",
```

**Impact**: OpenRouter uses `HTTP-Referer` for usage attribution, rate limit grouping, and in some cases model access tiers. Every consumer project that installs ACP Enhanced and runs dispatch will send this placeholder header. This was missed in all previous reviews.

**Fix**: Read from `identity.yml` dynamically:
```typescript
const identity = yaml.load(readAgent("core/identity.yml")) as any;
const repoUrl = identity?.homepage ?? `https://github.com/${identity?.repo ?? "ssucipto/acp-enhanced"}`;
const projectName = identity?.project ?? "ACP Enhanced";
// Use in client defaultHeaders:
defaultHeaders: {
  "HTTP-Referer": repoUrl,
  "X-Title": projectName,
}
```

**Priority**: CRITICAL for package distribution

---

### 🔴 BUG-003: Four commands return 404 — missing from `agent/commands/`

**Missing**: `acp.task.md`, `acp.install.md`, `acp.feedback.md`, `acp.dispatch.md`

**Impact per missing command**:

| Command | Impact |
|---|---|
| `acp.task.md` | Referenced in `domain.yml` category `core`, daily workflow uses routing tasks but no command doc exists to invoke task creation |
| `acp.install.md` | `package.yaml` lists it as a core command; `acp.install.sh` has no agent-invocable companion — install must be done by bootstrap script only |
| `acp.feedback.md` | The feedback system that produced feedback-001 (TikrFlow postmortem) has no command doc — developers cannot invoke the feedback loop reliably or know what format it expects |
| `acp.dispatch.md` | No human-readable guide for when/how to run `acp-dispatch.ts`; Persona B/C users have no command to invoke the routing engine from inside their IDE |

**Fix**: Create each using the standard command directive format. Minimum viable version for each:
- `acp.task.md` — create, read, list, and update routing task files in `agent/routing/tasks/`
- `acp.install.md` — invokes `acp.install.sh`; documents options (`--global`, `--local`, `--upgrade`)
- `acp.feedback.md` — captures structured developer feedback; writes to `agent/feedback/feedback-NNN.md`; triggers postmortem protocol
- `acp.dispatch.md` — explains Persona B/C dispatch flow; wraps `npx ts-node scripts/acp-dispatch.ts task-NNN.md` with pre-checks

**Priority**: HIGH

---

### 🔴 BUG-004: `domain.yml` reports 58 commands but `package.yaml` commands section lists 60

**Found**: `domain.yml` `commands.count: 58`, `identity.yml` version shows 6.6.0, sessions reference "58 slash commands" then "60 commands" in different entries.

**Impact**: `/acp-validate` cross-references these counts — a mismatch will either silently pass or fail depending on which source it trusts. The gap of 2 unaccounted commands may include the missing `acp.task.md` and `acp.install.md` — or there may be undocumented commands in the registry.

**Fix**: Run `/acp-validate` and check the command registry output. Reconcile `domain.yml` count with actual `.md` files in `agent/commands/`. Update `domain.yml` `commands.count` to the verified number.

**Priority**: MEDIUM-HIGH

---

## Section 3 — High Priority Gaps (Expand / Develop Next)

### ⚠️ GAP-001: `package.json` is in `scripts/` — not in project root

**Current state**: `scripts/package.json` exists (correctly configured with `openai`, `gray-matter`, `js-yaml`, `ts-node`, `typescript`). But the dispatch command in `package.json` is `"dispatch": "ts-node acp-dispatch.ts"` — this is a **relative path** that only works when run from inside the `scripts/` directory.

**Impact**: New users following the README will try `npm run dispatch` from the project root and get an error. The correct invocation is `cd scripts && npm install && npx ts-node acp-dispatch.ts ../agent/routing/tasks/task-NNN.md` — but this path nuance is not documented at the root level.

**There are two `package.json` files**: `scripts/package.json` and `scripts/scripts-package.json` with nearly identical content. The duplication should be resolved — keep one, remove the other.

**Fix**:
1. Remove `scripts/scripts-package.json` (duplicate)
2. Add a root-level `package.json` that wraps the scripts directory:
```json
{
  "scripts": {
    "acp:dispatch": "cd scripts && npx ts-node acp-dispatch.ts",
    "acp:validate": "cd scripts && npx ts-node acp-validate.ts"
  }
}
```
Or document in README that `cd scripts && npm install` is required before first use.

---

### ⚠️ GAP-002: `QUICKSTART.md` is buried in `scripts/` — not linked from root README

**Current state**: `scripts/QUICKSTART.md` is a complete, well-written 6-step setup guide with realistic time estimates (3–4 hours total). It is not referenced anywhere in the root `README.md`.

**Impact**: Every new user who installs ACP Enhanced starts from the root `README.md`. They will not find the quickstart guide and will attempt to reverse-engineer setup from `AGENT.md` (90K bytes) — a document not designed for onboarding.

**Fix**: Add to root `README.md`:
```markdown
## Quick Start
→ See [scripts/QUICKSTART.md](scripts/QUICKSTART.md) — full setup in 3–4 hours.
```
Or move `QUICKSTART.md` to the repo root and add a prominent link in the README hero section.

---

### ⚠️ GAP-003: `git_workflow` feature is opt-in but completely undiscoverable

**Current state**: The git branch safety system (Step 1b) is fully implemented across `AGENTS.md`, `CLAUDE.md`, `architecture.md`, and `acp.commit.md`. However, `identity.yml` ships with the `git_workflow:` block commented out with only "uncomment to enable" as guidance — no README section, no quickstart mention, no install-time prompt.

**Impact**: The single most common AI coding mistake — committing directly to `main` — is exactly what this feature prevents. New users will not enable it because they do not know it exists until they read deep into `architecture.md`.

**Fix**:
1. Add a `## Branch Safety` section to `README.md` and `QUICKSTART.md`
2. Add a Step 0 check in `/acp-init`: "Is `git_workflow:` configured? Run `/acp-decide` to set your branch model."
3. Consider shipping with a default commented example that is clearer:
```yaml
# git_workflow:                    # ← Uncomment for branch safety (recommended)
#   default_working_branch: main   # ← Branch you commit to daily
#   production_branch: main        # ← Branch that deploys to prod (same if trunk-based)
#   branch_model: trunk            # ← trunk | gitflow-lite | github-flow
```

---

### ⚠️ GAP-004: `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` are manual copies

**Current state**: Three files must stay in sync: `AGENTS.md` (root), `CLAUDE.md` (root), `.github/copilot-instructions.md`. The bootstrap script copies them correctly on install but future updates must be propagated manually. `scripts/QUICKSTART.md` documents the sync command:
```bash
cp AGENTS.md CLAUDE.md && cp AGENTS.md .github/copilot-instructions.md
```

**Impact**: When a developer updates `AGENTS.md` (e.g. adding a new step to the context protocol), they may forget to sync. Different IDEs will then load different protocol versions, causing inconsistent agent behaviour — exactly the problem ACP is designed to prevent.

**Fix**: Add a pre-commit hook to the bootstrap:
```bash
# .git/hooks/pre-commit
if git diff --cached --name-only | grep -q "^AGENTS.md$"; then
  cp AGENTS.md CLAUDE.md
  cp AGENTS.md .github/copilot-instructions.md
  git add CLAUDE.md .github/copilot-instructions.md
  echo "[ACP] CLAUDE.md and copilot-instructions.md synced from AGENTS.md"
fi
```
`acp-bootstrap.sh` should install this hook automatically.

---

### ⚠️ GAP-005: No Windows / WSL install documentation

**Current state**: `identity.yml` documents `bash_compat: macOS (BSD sed) + Linux (GNU)`. `acp.common.sh` handles the macOS/Linux split carefully. No Windows path exists anywhere in the repo.

**Impact**: The primary developer's machine is Windows 11 + VS Code. Any new developer on Windows hitting the install instructions will fail at the first `bash scripts/acp-bootstrap.sh` call with no guidance.

**Fix**: Add to `QUICKSTART.md` and `README.md`:
```markdown
### Windows Users
Shell scripts require Bash 4+. Use WSL2 (Ubuntu 22.04 recommended):
  wsl --install -d Ubuntu-22.04

TypeScript tooling (dispatch, validate) runs natively on Windows — no WSL required.
Run from WSL terminal: bash scripts/acp-bootstrap.sh
Run dispatch from Windows terminal: cd scripts && npx ts-node acp-dispatch.ts
```

---

## Section 4 — Medium Observations

### 📝 OBS-001: `scripts/FINAL-REVIEW.md` should be promoted to `agent/design/`

This file contains the most honest and useful UX analysis in the entire repo — including the exact failure modes, automation ceiling, and mitigation strategies. It currently lives in `scripts/` where it will not be loaded by ACP's context system. Move it to `agent/design/acp-ux-review.md` and reference it from `AGENT.md`.

---

### 📝 OBS-002: `routing/config.yml` model pricing needs a freshness date

`config.yml` lists model costs without a `last_verified:` date. DeepSeek pricing changes frequently (V4 flash has already dropped since initial publication). `/acp-cost-report` should check this file's age and warn if it is more than 30 days old.

---

### 📝 OBS-003: `audit-carryovers.md` has open pending items

**Current content** (1,699 bytes):
```yaml
carryovers:
  - finding_id: carryover-001
    status: pending   ← open item
  - finding_id: carryover-002
    status: pending   ← open item
```
Step 4.4 will surface these at every session start. Verify whether these findings are still relevant or should be marked `fixed` after M40 work. If they are stale, clear them — otherwise they will create noise every session.

---

### 📝 OBS-004: `agent/core/routing.yml` ships with `executor: unset`

For Persona A (Copilot-only) users, the dispatch script is never run — meaning `routing.yml` permanently shows `executor: unset`. The context protocol reads `routing.yml` at Step 1 and an agent seeing `executor: unset` will not know which model it is.

**Fix**: Ship `routing.yml` with a Persona A default:
```yaml
session:
  executor: copilot
  model: github-copilot
  persona: A  # A = Copilot only
```
Persona B/C users will have this overwritten by the dispatch script.

---

### 📝 OBS-005: `agent/design/` has too many `local.*` files — namespace discipline

`agent/design/` contains 16 `local.*` files alongside 10 non-local files. The `local.*` convention (documented in `patterns.md`) is supposed to mark project-instance files that should not be overwritten during ACP upgrades. However, having more local files than non-local files in `design/` suggests the distinction may be losing meaning. Audit which `local.*` design files should be promoted to non-local standard docs.

---

## Section 5 — Strategic Direction

### 5.1 Immediate (this sprint — before any new features)

| # | Action | File(s) |
|---|---|---|
| 1 | Fix malformed sessions.md YAML entry | `agent/memory/sessions.md` |
| 2 | Fix HTTP-Referer placeholder in dispatch | `scripts/acp-dispatch.ts` |
| 3 | Create 4 missing command docs | `agent/commands/acp.task.md`, `acp.install.md`, `acp.feedback.md`, `acp.dispatch.md` |
| 4 | Reconcile command count (58 vs 60) | `agent/wiki/domain.yml` |
| 5 | Resolve `package.json` duplication | `scripts/package.json`, `scripts/scripts-package.json` |
| 6 | Review `audit-carryovers.md` pending items | `agent/memory/audit-carryovers.md` |
| 7 | Set Persona A default in `routing.yml` | `agent/core/routing.yml` |

---

### 5.2 Next milestone (stabilisation)

| # | Action |
|---|---|
| 1 | Add `QUICKSTART.md` link to root README hero section |
| 2 | Add `Branch Safety` section to README + QUICKSTART |
| 3 | Add pre-commit hook to bootstrap for AGENTS.md sync |
| 4 | Add Windows/WSL install path to QUICKSTART |
| 5 | Move `scripts/FINAL-REVIEW.md` → `agent/design/acp-ux-review.md` |
| 6 | Add `last_verified:` field to `routing/config.yml` |

---

### 5.3 Cross-project validation (proves external value)

Before M36 (SaaS platform benchmark) and before productising:

1. **Install ACP Enhanced on TikrFlow or ChoreHive** using the bootstrap script — validate that install works end-to-end on a real project repo
2. **Measure baseline**: session context-loss incidents per week, repeated clarification rounds per session, time to first useful output per session
3. **Run for 2 weeks**, compare against pre-ACP baseline
4. **Productise only if**: setup takes under 15 minutes, daily workflow requires no reading beyond QUICKSTART, and at least one measurable metric improves

---

### 5.4 Productisation gate checklist

Before shipping to other developers:

- [ ] Clean install from zero works in under 15 minutes on macOS, Linux, and WSL2
- [ ] Root README links directly to QUICKSTART
- [ ] All 4 missing command docs exist
- [ ] `/acp-validate` passes clean — zero errors, zero warnings
- [ ] `sessions.md` malformed entry fixed — `getLastNSessions()` parses correctly
- [ ] `HTTP-Referer` reads from `identity.yml` dynamically
- [ ] Pre-commit hook installs automatically via bootstrap
- [ ] `git_workflow` enabled or prominently documented
- [ ] E2E tests pass on macOS CI and Linux CI (GitHub Actions already configured per M13)
- [ ] `audit-carryovers.md` pending items resolved

---

## Appendix — Complete File Audit Table

| File | Size (bytes) | Status | Notes |
|---|---|---|---|
| `agent/core/identity.yml` | 1,754 | ✅ | `git_workflow:` commented out by design |
| `agent/core/constraints.yml` | 2,802 | ✅ | 6 knowledge-preservation rules from feedback-001 |
| `agent/core/routing.yml` | 330 | ⚠️ | Ships with `executor: unset` — needs Persona A default |
| `agent/routing/taxonomy.yml` | 3,954 | ✅ | Full task-type → executor mapping |
| `agent/routing/rules.md` | 1,362 | ✅ | Ambiguity resolution rules clear |
| `agent/routing/config.yml` | 1,225 | ⚠️ | No `last_verified:` date |
| `agent/wiki/architecture.md` | 7,691 | ✅ | Fully populated, last verified 2026-05-04 |
| `agent/wiki/domain.yml` | 26,761 | ✅ | 58 commands catalogued, last verified 2026-05-05 |
| `agent/memory/sessions.md` | 17,873 | 🔴 | Malformed YAML entry (missing `- date:` header) |
| `agent/memory/lessons.md` | 8,706 | ✅ | Real incident log — feedback-001, upstream sync |
| `agent/memory/patterns.md` | 5,850 | ✅ | Concrete tested templates |
| `agent/memory/audit-carryovers.md` | 1,699 | ⚠️ | 2 pending items — verify if stale |
| `agent/commands/acp.init.md` | 22,481 | ✅ | Comprehensive, `--quick` and `--skip` flags |
| `agent/commands/acp.commit.md` | 5,867 | ✅ | v1.2.0, proactive WAL triggers, branch guard |
| `agent/commands/acp.proceed.md` | 56,620 | ✅ | Full task lifecycle engine |
| `agent/commands/acp.audit.md` | 17,935 | ✅ | `--pre-impl` mode solid, 4-phase readiness check |
| `agent/commands/acp.validate.md` | 25,446 | ✅ | Real quality gate |
| `agent/commands/acp.package-create.md` | 26,365 | ✅ | Fully documented |
| `agent/commands/acp.package-install.md` | 17,452 | ✅ | Implemented |
| `agent/commands/acp.cost-report.md` | 3,592 | ✅ | Present |
| `agent/commands/acp.status.md` | 8,494 | ✅ | Present |
| `agent/commands/acp.memory-sync.md` | 3,100 | ✅ | Present |
| `agent/commands/acp.task.md` | — | 🔴 | 404 — missing |
| `agent/commands/acp.install.md` | — | 🔴 | 404 — missing |
| `agent/commands/acp.feedback.md` | — | 🔴 | 404 — missing |
| `agent/commands/acp.dispatch.md` | — | 🔴 | 404 — missing |
| `agent/scripts/acp.common.sh` | 57,338 | ✅ | Cross-platform, disciplined, `set -euo pipefail` |
| `agent/scripts/acp.install.sh` | 18,576 | ✅ | Bash 3.2-safe, `local.*` exclusion |
| `agent/scripts/acp.yaml-parser.sh` | 32,857 | ✅ | Pure bash, zero external deps |
| `scripts/acp-dispatch.ts` | 9,472 | 🔴 | Hardcoded HTTP-Referer placeholder |
| `scripts/acp-validate.ts` | 9,684 | ✅ | Real structural validator |
| `scripts/acp-bootstrap.sh` | 37,679 | ✅ | Full 7-step installer |
| `scripts/package.json` | 467 | ⚠️ | In `scripts/` only, duplicate exists |
| `scripts/scripts-package.json` | 451 | ⚠️ | Duplicate of `package.json` — remove |
| `scripts/QUICKSTART.md` | 5,948 | ✅ | Complete 6-step guide — not linked from README |
| `scripts/FINAL-REVIEW.md` | 4,511 | ✅ | Honest UX audit — should move to `agent/design/` |
| `scripts/PRD-MAIN.md` | 17,448 | ✅ | Full PRD — referenced in design |
| `AGENTS.md` | 10,953 | ⚠️ | Manual sync required with CLAUDE.md |
| `CLAUDE.md` | 10,952 | ⚠️ | Manual sync required with AGENTS.md |
| `AGENT.md` | 90,368 | ✅ | Comprehensive — not for onboarding |
| `package.yaml` | 12,171 | ✅ | 60 commands listed (verify vs domain.yml 58) |
| `CHANGELOG.md` | 156,606 | ✅ | Full history from M1 to M40 |
| `e2e/` (31 files) | ~200K total | ✅ | Full command surface coverage |
| `tests/` (8 files) | ~80K total | ✅ | YAML parser + preferences + validate |

---

## Appendix — Suggested `audit-carryovers.md` Additions

Add these immediately after running `/acp-commit` on this audit:

```yaml
carryovers:
  - finding_id: ext-audit-001
    source: perplexity-external-audit-2026-05-11
    description: Malformed YAML entry in sessions.md missing - date header
    severity: critical
    status: pending
    fix_target: agent/memory/sessions.md

  - finding_id: ext-audit-002
    source: perplexity-external-audit-2026-05-11
    description: HTTP-Referer placeholder in scripts/acp-dispatch.ts
    severity: critical
    status: pending
    fix_target: scripts/acp-dispatch.ts

  - finding_id: ext-audit-003
    source: perplexity-external-audit-2026-05-11
    description: Four missing command docs - acp.task.md, acp.install.md, acp.feedback.md, acp.dispatch.md
    severity: high
    status: pending
    fix_target: agent/commands/

  - finding_id: ext-audit-004
    source: perplexity-external-audit-2026-05-11
    description: scripts/QUICKSTART.md not linked from root README
    severity: medium
    status: pending
    fix_target: README.md

  - finding_id: ext-audit-005
    source: perplexity-external-audit-2026-05-11
    description: scripts/scripts-package.json is duplicate of scripts/package.json
    severity: low
    status: pending
    fix_target: scripts/scripts-package.json
```

---

*Full audit conducted via direct file content reads of 40+ files. All verdicts are based on actual file contents — no surface-level structure inference.*
*Total content read: ~600K bytes across commands, scripts, memory, wiki, tests, design, changelog.*
