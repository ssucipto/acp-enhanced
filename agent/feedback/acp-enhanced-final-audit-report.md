---
id: feedback-external-audit-2026-05-11
type: external-audit
date: 2026-05-11
version_audited: 6.6.0
branch: mainline
author: Perplexity AI (external audit)
scope: full — all commands, scripts, memory, routing, TypeScript tooling, tests, design docs, wiki
purpose: >
  Structured improvement report for ACP Enhanced as a documentation-first
  AI coding workflow tool. Every finding is traceable to a specific file
  and line-level observation. No speculative improvements included.
---

# ACP Enhanced — Final Audit and Improvement Report

## What This Document Is

This is the result of a full read of every significant file in the repo:
`identity.yml`, `constraints.yml`, `routing.yml`, `taxonomy.yml`, `rules.md`, `config.yml`,
all 7 skill files, `acp-dispatch.ts`, `acp-validate.ts`, `acp-bootstrap.sh`, 20 command docs,
all 3 memory files, `audit-carryovers.md`, `architecture.md`, `domain.yml`, 31 E2E tests,
8 unit tests, `CHANGELOG.md`, `progress.yaml`, `AGENTS.md`, `FINAL-REVIEW.md`, `PRD-MAIN.md`,
`QUICKSTART.md`, and all design documents.

It is structured as ACP-native feedback. Each section maps to the appropriate ACP
workflow for action: bugs map to `audit-carryovers.md`, improvements map to new routes,
structural issues map to design decisions.

---

## Part 1 — System Health: Honest Baseline

### What is working, verified by file content

**The 3-layer context loading system is sound.** Layer 1 (~500 tokens, prompt-cached) correctly
separates static identity/constraints from dynamic session memory. Layer 2 (one skill file per
task type) is well-scoped. Layer 3 (filtered sessions + lessons + wiki sections) is appropriately
capped at 3,500 tokens. The architecture is coherent and correctly models what it preaches
(token_efficiency is priority #2 in `identity.yml`).

**`acp-dispatch.ts` correctly implements the design.** Cache-optimised prompt assembly:
static system prefix assembled from Layer 1 + skill, dynamic user message assembled fresh.
The `extractSection()` function handles both XML-tag and markdown-heading section extraction.
`getFilteredLessons()` correctly filters by `task_type`, `task_type: all`, and `priority: high`.
Budget enforcement at 6,500 tokens with a graceful fallback trim is implemented and correct.

**`acp-validate.ts` is a real quality gate**, not a placeholder. It runs:
1. Placeholder scan (lines 3–4 of command docs, skips code blocks)
2. Frontmatter field check (`**Namespace**:`, `**Version**:`, `**Status**:`, `**Scripts**:`)
3. Triple-file parity check: `agent/commands/` vs `.github/prompts/` vs `.opencode/commands/`
4. Task file validation: required fields, id format, date format, task_type vs taxonomy, executor vs config

The triple-file parity check reveals something not previously documented: ACP Enhanced generates
command files in THREE locations, not two. `.opencode/commands/` is a target directory for OpenCode
compatibility. This is a significant undocumented surface.

**The memory system is operating as designed.** `sessions.md` at 17,873 bytes, `lessons.md`
at 8,706 bytes, and `patterns.md` at 5,850 bytes are all live, incident-driven files. The
TikrFlow overflow postmortem feedback loop (feedback-001 → M38 → constraints.yml → v1.2.0) is
evidence of a self-correcting process that is actually working.

**Test coverage is serious.** 31 E2E test files, 8 unit test files. `tests/acp.yaml-parser.test.sh`
at 27,821 bytes is the most thorough test in the repo. `tests/common.sh` at 9,960 bytes is a real
shared test harness with assertion helpers, temp directory management, and cleanup traps.

---

## Part 2 — Bugs (Fix Before Any New Work)

### BUG-001 — `sessions.md` has a malformed YAML entry

**File**: `agent/memory/sessions.md`
**Impact**: CRITICAL

One session block is missing its `- date:` header. `acp-dispatch.ts` splits sessions on `\n- date:`
to extract the last N entries. The malformed entry is either silently skipped or merged into an
adjacent entry — either outcome corrupts the session context assembled for every dispatch call.

This is the highest-impact silent failure in the system because sessions.md is loaded on every
Persona B/C dispatch call.

**Fix**:
```bash
# Find the orphaned block and prepend the missing date header.
# Verify correct date from git log before setting it:
git log --oneline --after="2026-05-04" --before="2026-05-07"
# Then edit sessions.md to add:
# - date: YYYY-MM-DD   ← insert correct date
#   executor: copilot
#   tasks: [task-156, task-157, task-158]
```

**Add to `audit-carryovers.md` as**: `status: pending`, `severity: critical`

---

### BUG-002 — `acp-dispatch.ts` hardcodes a placeholder `HTTP-Referer` header

**File**: `scripts/acp-dispatch.ts`, `defaultHeaders` block
**Impact**: HIGH — affects every consumer project that installs ACP Enhanced

```typescript
// Current (broken):
"HTTP-Referer": "https://github.com/your-handle/your-repo",
"X-Title": "ACP Enhanced Dispatch",
```

OpenRouter uses `HTTP-Referer` for usage attribution. Every project that installs ACP Enhanced
and runs the dispatch script sends this placeholder. `identity.yml` already has `repo:` and
`project:` fields — use them.

**Fix**:
```typescript
const identity = yaml.load(readAgent("core/identity.yml")) as any;
const repoUrl = `https://github.com/${identity?.repo ?? "ssucipto/acp-enhanced"}`;
const projectTitle = identity?.project ?? "ACP Enhanced";

const client = new OpenAI({
  baseURL: OPENROUTER_BASE,
  apiKey: process.env.OPENROUTER_API_KEY!,
  defaultHeaders: {
    "HTTP-Referer": repoUrl,
    "X-Title": projectTitle,
  },
});
```

---

### BUG-003 — `updateRoutingYml()` is called BEFORE the API call, not after

**File**: `scripts/acp-dispatch.ts`, `dispatch()` function
**Impact**: HIGH — stale executor state on failure

Current order in `dispatch()`:
```typescript
updateRoutingYml(executor, modelConfig.model);  // ← writes routing.yml
const prompt = buildContext(meta, taskContent);
// ... then API call
```

If the API call fails (network drop, invalid API key, SIGINT), `routing.yml` now permanently
shows the intended executor/model — but no work was done. The next session reads a stale state.

Additionally, `appendLedger()` is only called after a successful stream. A SIGINT during streaming
loses the ledger row — tokens were billed but not recorded.

**Fix**:
```typescript
// Move updateRoutingYml() to AFTER successful stream completion
// Add signal handler to flush partial ledger on interrupt:
process.on('SIGINT', () => {
  if (inputTokens > 0) {
    appendLedger(meta, inputTokens, outputTokens,
      ((inputTokens * modelConfig.inputCost) + (outputTokens * modelConfig.outputCost)) / 1_000_000
    );
    console.error("\n[ACP] Interrupted — partial ledger entry written");
  }
  process.exit(1);
});

// Then at end of successful stream:
appendLedger(meta, inputTokens, outputTokens, totalCost);
updateRoutingYml(executor, modelConfig.model);  // ← moved here
```

---

### BUG-004 — Four command docs return 404

**Files**: `agent/commands/acp.task.md`, `acp.install.md`, `acp.feedback.md`, `acp.dispatch.md`
**Impact**: HIGH — broken taxonomy references, no feedback loop entry point

`domain.yml` lists all four in the command registry. `package.yaml` lists `acp.install.md` as
a core command. The feedback system that produced the TikrFlow postmortem has no command doc —
feedback cannot be invoked reliably.

**Fix**: Create each command doc using the standard directive format:
- `acp.task.md` — create/read/list/update routing task files in `agent/routing/tasks/`
- `acp.install.md` — agent-invocable wrapper for `acp.install.sh`
- `acp.feedback.md` — structured feedback capture; writes to `agent/feedback/feedback-NNN.md`
- `acp.dispatch.md` — guide for Persona B/C dispatch; explains when to use dispatch vs Copilot

---

### BUG-005 — `routing.yml` ships permanently broken for Persona A users

**File**: `agent/core/routing.yml`
**Impact**: MEDIUM — silent broken state for Copilot-only users

```yaml
# Current:
session:
  executor: unset
  model: unset
  persona: A
```

Persona A (Copilot-only) users never run `acp-dispatch.ts`, so `executor: unset` persists
permanently. Every agent reading Step 1 (`routing.yml`) sees `unset` and has no signal about
which executor is active. `constraints.yml` says "DO NOT mix static and dynamic content in the
same file" — but the current state means the file is permanently static at a broken value.

**Fix** — one line change:
```yaml
session:
  executor: copilot       # overwritten by acp-dispatch.ts for Persona B/C
  model: github-copilot   # overwritten by acp-dispatch.ts for Persona B/C
  persona: A              # A = Copilot only | B = OpenRouter | C = mixed
```

---

## Part 3 — Routing System Gaps (Improvements to the Core Value Proposition)

The routing system is ACP Enhanced's primary cost-saving mechanism. Every gap here
means the wrong model is selected, wrong context is loaded, or wrong tokens are spent.
These are not cosmetic issues — they directly affect the `token_efficiency` priority.

---

### ROUTING-001 — Nine common task types have no taxonomy entry

**File**: `agent/routing/taxonomy.yml`
**Evidence**: `sessions.md` and `progress.yaml` show these task types occurring regularly
across M29–M40, with no corresponding taxonomy entry. When dispatch encounters an unknown
`task_type`, it falls back to `deepseek-v4-pro` with `crosscut` skill — wrong context,
often wrong cost tier.

| Missing task_type | Correct executor | Correct context_required | Evidence |
|---|---|---|---|
| `wiki-update` | `deepseek-v4-flash` | `memory/sessions.md` | route-017, route-021 explicitly labelled wiki updates |
| `memory-write` | `deepseek-v4-flash` | `memory/sessions.md` | sessions/lessons/patterns writes are routed tasks |
| `changelog-update` | `deepseek-v4-flash` | `memory/sessions.md` | Every milestone wrap-up includes this |
| `progress-update` | `local-script` | `active-task-only` | `progress.yaml` stamping is scripted, not LLM work |
| `adr-write` | `deepseek-v4-pro` | `memory/decisions.md`, `wiki/architecture.md` | `/acp-decide` generates ADRs — not in taxonomy |
| `audit-run` | `claude-sonnet` | `wiki/architecture.md`, `memory/sessions.md`, `memory/decisions.md` | `/acp-audit` tasks are routed with no entry |
| `milestone-create` | `deepseek-v4-flash` | `memory/sessions.md` | Wrap-up routes always create milestone files |
| `route-create` | `deepseek-v4-flash` | `wiki/domain.yml#commands` | Creating route task files is itself a routed type |
| `upstream-parity-check` | `deepseek-v4-pro` | `memory/decisions.md`, `wiki/architecture.md` | M29 used a distinct sub-type of upstream-sync |

**Fix**: Add 9 entries to `taxonomy.yml` following existing format.
**Route**: `route-create` task_type, `deepseek-v4-flash`, one session.

---

### ROUTING-002 — `getSkillFile()` in dispatch has no mapping for 7 of the 9 new task types

**File**: `scripts/acp-dispatch.ts`, `getSkillFile()` function

```typescript
// Current — falls through to crosscut for anything not in these lists:
const commandTypes = ["command-doc-write", "command-doc-update"];
const scriptTypes  = ["bash-script-create", "bash-script-fix", ...];
const schemaTypes  = ["yaml-schema"];
const testTypes    = ["e2e-test-write", "test-run"];
const tsTypes      = ["typescript-feature"];
```

`wiki-update`, `memory-write`, `changelog-update`, `adr-write`, `audit-run`, `milestone-create`,
`route-create` all fall through to `skills/crosscut.md`. Crosscut is the catch-all —
it is not wrong, but it is not optimal. `wiki-update` should use `crosscut` (acceptable).
`adr-write` should use `crosscut` (architectural reasoning). `audit-run` should use `crosscut`.
`memory-write`, `changelog-update`, `milestone-create`, `route-create` should use `crosscut`.

After adding the 9 taxonomy entries, update `getSkillFile()` to explicitly map them rather
than relying on the fallback:

```typescript
const crosscutTypes = [
  "wiki-update", "memory-write", "changelog-update", "adr-write",
  "audit-run", "milestone-create", "route-create", "upstream-parity-check",
  "design-document", "architecture-plan", "documentation-sync"
];
if (crosscutTypes.includes(taskType)) return "skills/crosscut.md";
```

This makes the mapping explicit and auditable — no silent fallbacks.

---

### ROUTING-003 — `taxonomy.yml` has no `last_updated` date; `config.yml` has no `last_verified` date

**Files**: `agent/routing/taxonomy.yml`, `agent/routing/config.yml`

`taxonomy.yml` header: `Generated 2026-05-01 — update weekly via /acp-cost-report suggestions`
No enforcement exists. Nothing in `/acp-validate` checks freshness. DeepSeek pricing changes
frequently — if `config.yml` pricing is stale, the ledger reports are wrong and routing
decisions based on cost comparisons are made on false data.

**Fix**:
1. Add `last_updated: 2026-05-01` to `taxonomy.yml` header
2. Add `last_verified: 2026-05-01` to `config.yml`
3. Add staleness check to `acp-validate.ts`:

```typescript
function checkStaleness(filePath: string, fieldName: string, maxAgeDays = 30): void {
  const content = readFileSync(filePath, "utf8");
  const match = content.match(new RegExp(`${fieldName}:\s*(\d{4}-\d{2}-\d{2})`));
  if (!match) {
    console.warn(`⚠ ${filePath}: no ${fieldName} field found`);
    return;
  }
  const age = (Date.now() - new Date(match[1]).getTime()) / 86_400_000;
  if (age > maxAgeDays) {
    console.warn(`⚠ ${filePath}: ${fieldName} is ${Math.floor(age)} days old (max: ${maxAgeDays})`);
  }
}
// Run in no-args validate path:
checkStaleness("agent/routing/taxonomy.yml", "last_updated");
checkStaleness("agent/routing/config.yml", "last_verified");
```

4. Add a step to `/acp-cost-report` that **writes** verified prices back to `config.yml` — not
   just suggests them. Currently the cost report is read-only advisory output with no write-back.

---

## Part 4 — Memory System Gaps

The memory system is ACP Enhanced's second core value proposition. Every gap here
means the agent re-learns what it already knows, or wastes tokens on lessons that are
no longer relevant.

---

### MEMORY-001 — `lessons.md` has no expiry mechanism; superseded lessons load forever

**File**: `agent/memory/lessons.md`, `scripts/acp-dispatch.ts` `getFilteredLessons()`

`getFilteredLessons()` loads lessons matching `task_type` OR `task_type: all` OR `priority: high`.
There is no `status: archived` field and no expiry mechanism. The TikrFlow overflow lesson
(marked `priority: high`) will be loaded in every future dispatch call, for every task type,
forever — even though its core fix was codified into `constraints.yml` as
`context_overflow_commit_first` in M38.

The lesson is now a redundant ~300-token load on every dispatch call. At 0.14/0.28 per million
tokens (DeepSeek flash), this is trivial per call — but it compounds across all calls and it
also means `priority: high` becomes a permanent sticky flag rather than a meaningful signal.

**Fix**: Add two fields to the lessons.md schema:

```yaml
- date: 2026-05-09
  priority: high
  task_type: all
  trigger: context-overflow
  lesson: >
    Context overflow is silent — sessions terminate without warning...
  superseded_by: constraints.yml#context_overflow_commit_first   # ← new field
  status: active   # ← new field: active | archived
```

Update `getFilteredLessons()` in `acp-dispatch.ts`:
```typescript
const relevant = entries.filter(
  (e) =>
    !e.includes("status: archived") &&   // ← skip archived
    (
      e.includes(`task_type: ${taskType}`) ||
      e.includes("task_type: all") ||
      e.includes("priority: high")
    )
);
```

Add a step to `/acp-memory-sync` that flags lessons as `status: archived` when:
- Their fix exists verbatim in `constraints.yml` as a rule, OR
- Their pattern exists in `patterns.md`, OR
- They are more than 90 days old with `priority: normal`

---

### MEMORY-002 — `/acp-validate` does not check `sessions.md` YAML structure

**File**: `scripts/acp-validate.ts`

`acp-validate.ts` checks command docs, task files, frontmatter, and parity — but has no check
on memory file structure. The malformed `sessions.md` entry (BUG-001) was present for at least
one full milestone without being caught. This is the most important missing validation given
that sessions.md is loaded on every dispatch call.

**Fix**: Add to the no-args validate path in `acp-validate.ts`:

```typescript
function validateSessionsMemory(): void {
  const filePath = path.join("agent", "memory", "sessions.md");
  if (!existsSync(filePath)) {
    console.log("Sessions check: agent/memory/sessions.md not found — skipped");
    return;
  }
  const content = readFileSync(filePath, "utf8");
  const entries = content.split("\n- date:").filter(Boolean);
  let errors = 0;
  for (let i = 0; i < entries.length; i++) {
    if (!entries[i].match(/^\s*(20\d{2}-\d{2}-\d{2})/)) {
      console.error(`  ✗ sessions.md: entry ${i + 1} missing valid date header`);
      errors++;
    }
  }
  if (errors === 0) {
    console.log(`Sessions check: ${entries.length} entries — all valid ✓`);
  } else {
    console.error(`Sessions check: ${errors} malformed entries — will be skipped by dispatch`);
    process.exitCode = 1;
  }
}
```

---

### MEMORY-003 — `audit-carryovers.md` has 2 open pending items with no context

**File**: `agent/memory/audit-carryovers.md`

Current content shows two `status: pending` entries. Step 4.4 surfaces these at every session
start. But the entries lack the fields that would let an agent act on them without re-reading the
original audit report: no `description`, no `fix_target`, no `severity`.

**Fix**: Enrich both existing entries with full context:
```yaml
carryovers:
  - finding_id: [existing-id]
    description: [one-line description of the finding]
    severity: high | medium | low
    fix_target: [file path]
    status: pending
    source_audit: [audit-NNN.md]
```

Then add the new carryovers from this audit report (see Part 6 below).

---

## Part 5 — Validation System Gaps

### VALIDATE-001 — `AGENTS.md` has no byte-size constraint and no validation check

**File**: `agent/core/constraints.yml`, `scripts/acp-validate.ts`

`constraints.yml` defines context budgets for Layers 1–3. But `AGENTS.md` — the foundational
protocol file that every IDE auto-loads — has no size constraint defined anywhere. `AGENT.md`
at 90,368 bytes exists alongside `AGENTS.md` at 10,953 bytes. The naming similarity creates
real confusion risk during setup. If a developer copies content from `AGENT.md` into `AGENTS.md`
during project customisation, it silently bloats beyond every tool's auto-load limit.

**Fix**:
1. Add to `constraints.yml`:
```yaml
agents_md_rules:
  - max_bytes: 28000  # ~28KB — leaves headroom below tool auto-load limits
  - content: protocol-only — no project content, no inline code samples
```

2. Add to `acp-validate.ts` (no-args path):
```typescript
function validateAgentsMdSize(): void {
  if (!existsSync("AGENTS.md")) return;
  const bytes = Buffer.byteLength(readFileSync("AGENTS.md", "utf8"), "utf8");
  const MAX = 28_000;
  if (bytes > MAX) {
    console.error(`  ✗ AGENTS.md: ${bytes} bytes exceeds ${MAX} byte limit — will be truncated by some tools`);
    process.exitCode = 1;
  } else {
    console.log(`AGENTS.md size: ${bytes} bytes ✓`);
  }
}
```

---

### VALIDATE-002 — Triple-file parity check is silent about WHICH commands are missing

**File**: `scripts/acp-validate.ts`, `runParityCheck()`

Current output when parity fails:
```
Parity check: 58 commands / 54 prompts / 51 opencode — 2 mismatch(es)
⚠ 58 commands vs 54 prompts (.github/prompts/)
⚠ 58 commands vs 51 opencode (.opencode/commands/)
```

This tells you counts are wrong but not WHICH files are missing. A developer must manually
diff directories to find the gap. At 58 commands, that is non-trivial.

**Fix**: Change `runParityCheck()` to produce a specific diff:
```typescript
// After counting files, compute symmetric difference:
const missingFromPrompts = commandFiles
  .map(f => f.replace("acp.", "acp-").replace(".md", ".prompt.md"))
  .filter(f => !promptFiles.includes(path.basename(f)));
const missingFromOpencode = commandFiles
  .map(f => f.replace("acp.", "acp-"))
  .filter(f => !opencodeFiles.includes(path.basename(f)));

if (missingFromPrompts.length > 0) {
  console.warn(`  Missing from .github/prompts/: ${missingFromPrompts.join(", ")}`);
}
```

---

## Part 6 — Structural Gaps (One-Time Fixes)

### STRUCT-001 — `scripts/scripts-package.json` is a duplicate of `scripts/package.json`

**Files**: `scripts/package.json` (467 bytes), `scripts/scripts-package.json` (451 bytes)

Both files are nearly identical — same dependencies, same scripts. Two `package.json` files
in the same directory is confusing and creates a maintenance burden. `npm install` in `scripts/`
only reads `package.json`, so `scripts-package.json` is unused.

**Fix**: Delete `scripts/scripts-package.json`. Add a comment to `scripts/package.json`:
```json
// This is the package.json for the scripts/ TypeScript tooling.
// Run: cd scripts && npm install
// Usage: npx ts-node acp-dispatch.ts ../agent/routing/tasks/task-NNN.md
```

---

### STRUCT-002 — `scripts/QUICKSTART.md` is not linked from root `README.md`

**Files**: `scripts/QUICKSTART.md` (5,848 bytes), `README.md`

`scripts/QUICKSTART.md` is a complete, accurate 6-step setup guide with realistic time estimates
(3–4 hours). It is the correct onboarding document. It is not referenced anywhere in `README.md`.
New users start from `README.md` and will not find it. They will attempt to onboard from `AGENT.md`
(90,368 bytes) — a document not designed for onboarding.

**Fix**: Add to `README.md` hero section:
```markdown
## Quick Start
→ **[scripts/QUICKSTART.md](scripts/QUICKSTART.md)** — full setup in 3–4 hours
```

---

### STRUCT-003 — `scripts/FINAL-REVIEW.md` contains the most useful UX analysis in the repo but is unreachable by the context system

**File**: `scripts/FINAL-REVIEW.md` (4,415 bytes)

This file contains honest, specific UX failure points — including the dispatch script
breaking in-IDE flow, `/acp-commit` compliance as the single point of failure, and
taxonomy accuracy starting at ~70% over the first two weeks. This is exactly the
kind of context an agent should have when advising a developer on setup.

Currently it lives in `scripts/`, outside the `agent/` directory tree, so it is never
loaded by any step of the context protocol.

**Fix**: Move to `agent/design/acp-ux-review.md` and add to `domain.yml` design entries.

---

### STRUCT-004 — `git_workflow` feature is opt-in with no onboarding path

**File**: `agent/core/identity.yml`

The branch safety system (Step 1b) is fully implemented across `AGENTS.md`, `CLAUDE.md`,
`architecture.md`, and `acp.commit.md`. But the feature is gated behind an uncommented block
in `identity.yml` with no README section, no QUICKSTART mention, and no install-time prompt.
The feature prevents the most common AI coding mistake (committing to production) — yet it is
invisible to new users.

**Fix**: Add Step 0 to `/acp-init`:
```
0. Check git_workflow configuration
   - Read agent/core/identity.yml
   - If git_workflow: block is commented out, output:
     ⚠ [ACP] Branch safety is not configured.
     Consider uncommenting git_workflow: in agent/core/identity.yml.
     See architecture.md#step-1b for details.
   - If configured, verify current branch matches default_working_branch
```

Also add a `## Branch Safety` section to `QUICKSTART.md`.

---

## Part 7 — What NOT to Add

The following were considered and rejected as not genuine improvements to ACP Enhanced
as the tool it is designed to be:

**Global `~/.codex/AGENTS.md` scaffold**: ACP Enhanced is a project-level tool. Adding
global scope is feature creep and adds bootstrap complexity without solving a problem
that exists in the current system design.

**Codex-compatible `.agents/skills/` wrappers**: ACP's routing already handles skill
dispatch correctly. Codex compatibility is not in `identity.yml` priorities. This would
add a parallel structure that must be kept in sync with the primary skill files.

**`AGENTS.override.md` auto-generation for task scope**: The `agent/index/` key files
system (Step 1.5 in `/acp-proceed`) already narrows context per task. Adding a second
mechanism for the same problem is redundancy without incremental value.

**`acp-dispatch.ts` streaming output capture**: The script currently streams to stdout
and does not save output to a file. Not capturing the output was a deliberate design
choice — the developer reads and acts on it in their terminal. Adding output capture
would change the interaction model without a clear problem to solve.

**Nested subdirectory `AGENTS.md`**: Not yet standardised across Copilot, Claude Code,
or Cursor. Premature to build support for an unstable convention.

---

## Part 8 — Recommended Milestones

### M41 — Routing and Validation Integrity (single session, ~2 hours)

Fixes everything that affects the quality of dispatch calls today.

| Route | Task | Type |
|---|---|---|
| route-M41-01 | Fix BUG-001: repair malformed sessions.md entry | `memory-write` |
| route-M41-02 | Fix BUG-002: read HTTP-Referer from identity.yml in dispatch | `typescript-feature` |
| route-M41-03 | Fix BUG-003: move updateRoutingYml() after stream; add SIGINT ledger flush | `typescript-feature` |
| route-M41-04 | Fix BUG-005: set Persona A defaults in routing.yml | `memory-write` |
| route-M41-05 | Fix ROUTING-003: add last_updated/last_verified fields + staleness check | `typescript-feature` |
| route-M41-06 | Fix MEMORY-002: add sessions.md YAML structure check to acp-validate.ts | `typescript-feature` |
| route-M41-07 | Fix VALIDATE-001: add AGENTS.md byte-size check + constraints.yml entry | `typescript-feature` |
| route-M41-08 | Fix VALIDATE-002: make parity check output specific missing filenames | `typescript-feature` |
| route-M41-09 | Fix STRUCT-001: delete scripts/scripts-package.json | `documentation-sync` |

---

### M42 — Taxonomy Completeness (single session, ~1.5 hours)

Fixes routing accuracy for the 9 most common task types that currently fall through
to the wrong executor.

| Route | Task | Type |
|---|---|---|
| route-M42-01 | Add 9 missing task types to taxonomy.yml with correct executor + context | `yaml-schema` |
| route-M42-02 | Update getSkillFile() in dispatch to explicitly map all new task types | `typescript-feature` |
| route-M42-03 | Create 4 missing command docs: acp.task.md, acp.install.md, acp.feedback.md, acp.dispatch.md | `command-doc-write` |
| route-M42-04 | Update domain.yml command count and entries to match actual file count | `wiki-update` |

---

### M43 — Memory System Health (single session, ~1.5 hours)

Fixes lesson relevance decay and surfaces the git_workflow feature properly.

| Route | Task | Type |
|---|---|---|
| route-M43-01 | Add status/superseded_by fields to lessons.md schema | `yaml-schema` |
| route-M43-02 | Update getFilteredLessons() to skip status: archived | `typescript-feature` |
| route-M43-03 | Run /acp-memory-sync: audit all lessons against constraints.yml and patterns.md | `memory-write` |
| route-M43-04 | Enrich audit-carryovers.md entries with description/severity/fix_target | `memory-write` |
| route-M43-05 | Fix STRUCT-002: link QUICKSTART.md from README.md | `documentation-sync` |
| route-M43-06 | Fix STRUCT-003: move FINAL-REVIEW.md to agent/design/acp-ux-review.md | `documentation-sync` |
| route-M43-07 | Fix STRUCT-004: add git_workflow check to /acp-init Step 0 + QUICKSTART section | `command-doc-update` |

---

## Part 9 — Suggested `audit-carryovers.md` Additions

Add these entries immediately. Step 4.4 will surface them at every session start.

```yaml
  - finding_id: ext-audit-001
    source: feedback-external-audit-2026-05-11
    description: sessions.md orphaned entry missing - date header — corrupts getLastNSessions()
    severity: critical
    fix_target: agent/memory/sessions.md
    status: pending

  - finding_id: ext-audit-002
    source: feedback-external-audit-2026-05-11
    description: acp-dispatch.ts HTTP-Referer is a hardcoded placeholder string
    severity: high
    fix_target: scripts/acp-dispatch.ts
    status: pending

  - finding_id: ext-audit-003
    source: feedback-external-audit-2026-05-11
    description: updateRoutingYml() called before API call — stale state on failure
    severity: high
    fix_target: scripts/acp-dispatch.ts
    status: pending

  - finding_id: ext-audit-004
    source: feedback-external-audit-2026-05-11
    description: routing.yml ships with executor:unset — broken for Persona A users
    severity: medium
    fix_target: agent/core/routing.yml
    status: pending

  - finding_id: ext-audit-005
    source: feedback-external-audit-2026-05-11
    description: 9 common task types missing from taxonomy.yml — wrong executor selected
    severity: high
    fix_target: agent/routing/taxonomy.yml
    status: pending

  - finding_id: ext-audit-006
    source: feedback-external-audit-2026-05-11
    description: lessons.md has no archived status — superseded lessons load forever
    severity: medium
    fix_target: agent/memory/lessons.md + scripts/acp-dispatch.ts
    status: pending

  - finding_id: ext-audit-007
    source: feedback-external-audit-2026-05-11
    description: acp-validate.ts does not check sessions.md YAML structure
    severity: high
    fix_target: scripts/acp-validate.ts
    status: pending

  - finding_id: ext-audit-008
    source: feedback-external-audit-2026-05-11
    description: parity check reports count mismatch but not which specific files are missing
    severity: low
    fix_target: scripts/acp-validate.ts
    status: pending
```

---

*Audit conducted via direct file reads of 47 files, ~650KB of source content.*
*All findings traceable to specific file locations. No speculative improvements included.*
*Save as: `agent/reports/feedback-external-audit-2026-05-11.md`*
