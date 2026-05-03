---
id: task-001
title: Unify command invocation syntax to /acp-<command>
task_type: design-document
milestone: none
complexity: high
executor: claude-sonnet
context_required:
  - wiki/architecture.md
  - wiki/domain.yml#commands
  - memory/decisions.md
files_affected:
  - agent/commands/*.md            # all 51 command files — invocation directive lines
  - AGENT.md                        # 176 @acp. references — primary onboarding doc
  - agent/scripts/acp.common.sh    # display_available_commands() — 20 @acp. refs printed to terminal
  - agent/scripts/acp.install.sh   # 2 @acp.init refs in terminal output
  - agent/scripts/acp.version-update.sh  # 2 @acp.init refs in terminal output
  - README.md                              # 77 @acp. references — GitHub repo landing page
  - scripts/acp-bootstrap.sh               # developer bootstrap script
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - scripts/AGENTS.md
  - docs/USAGE.md
  - docs/README.md
  - .agent/wiki/architecture.md
  - scripts/PRD-MAIN.md
tokens_est: 18000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed:
override_reason:
precedes: task-002  # must complete before directory migration
---

## Context

Two invocation patterns currently coexist in the codebase:

| Pattern | Where used | Examples |
|---|---|---|
| `@acp.<command>` | 51 command docs, USAGE.md, README, architecture | `@acp.init`, `@acp.plan`, `@acp.package-install` |
| `/acp-<command>` | AGENTS.md, CLAUDE.md, copilot-instructions.md | `/acp-commit`, `/acp-route`, `/acp-decide` |

The `/acp-commit` entry in AGENTS.md even lists both as aliases: "When developer runs /acp-commit or @acp.commit" — evidence this duality was already acknowledged but never resolved.

**Decision: Standardize on `/acp-<command>` as the single canonical invocation syntax.**

---

## Scope of Change

### Layer 1 — Command file internal directives (53 files, mechanical)
Every `agent/commands/*.md` file opens with:
```
> **🤖 Agent Directive**: If you are reading this file, the command `@acp.X` has been invoked.
```
All `@acp.X` references inside command files must be updated to `/acp-X`.

The file names themselves (`acp.package-install.md`) are **not renamed** — they are an internal
implementation detail, not user-facing syntax. Only the invocation syntax changes.

### Layer 2 — Context loading protocol (4 files)
- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `scripts/AGENTS.md`

Remove the `@acp.commit` alias. All meta-commands already use `/acp-*`; remove the dual-alias lines.

### Layer 3 — User-facing documentation (3 files)
- `docs/USAGE.md` — all `@acp.*` usage examples
- `docs/README.md` — command references
- `.agent/wiki/architecture.md` — example invocations in data-flow diagrams

### Layer 4 — Internal/planning docs (1 file, low priority)
- `scripts/PRD-MAIN.md` — historical references; update for consistency

### Layer 5 — AGENT.md (176 references — the primary developer doc)
`AGENT.md` is the human-readable onboarding document and the file agents read at `@acp.init` /
`/acp-init`. It contains 176 `@acp.*` references in command tables, directory structure diagrams,
sample prompts, and usage examples. Every occurrence must be updated to `/acp-*` syntax.
This is the highest-visibility file in the project — leaving it on old syntax defeats the purpose.

### Layer 6 — Shell script terminal output (3 files)
`agent/scripts/acp.common.sh` contains `display_available_commands()` — printed to the
terminal after every install or update. It lists all commands using `@acp.*`. This is the
first thing a developer sees after running the install script. Must use `/acp-*`.

`agent/scripts/acp.install.sh` and `agent/scripts/acp.version-update.sh` each contain
2 direct `@acp.init` references in their completion messages.

---

## Acceptance Criteria

- [ ] Every `@acp.<command>` reference in `agent/commands/*.md` replaced with `/acp-<command>`
- [ ] The directive line in each command file reads: `the command \`/acp-X\` has been invoked`
- [ ] `AGENT.md` — all 176 `@acp.*` references updated to `/acp-*`
- [ ] `agent/scripts/acp.common.sh` `display_available_commands()` — all `@acp.*` updated to `/acp-*`
- [ ] `agent/scripts/acp.install.sh` and `acp.version-update.sh` — `@acp.init` completion message updated
- [ ] `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `scripts/AGENTS.md` — `/acp-commit or @acp.commit` collapsed to `/acp-commit` only
- [ ] `docs/USAGE.md` updated to `/acp-*` syntax throughout
- [ ] `docs/README.md` updated to `/acp-*` syntax
- [ ] `.agent/wiki/architecture.md` example flows updated
- [ ] `scripts/PRD-MAIN.md` updated
- [ ] `README.md` updated to `/acp-*` syntax (77 references)
- [ ] `scripts/acp-bootstrap.sh` updated
- [ ] `acp.script-command-binding.test.sh` still passes (file naming unchanged, only invocation text)
- [ ] ADR logged in `.agent/memory/decisions.md`

---

## Implementation Plan

### Phase 1 — ADR first (non-reversible decision)
Run `/acp-decide` to record this as an architectural decision before any file changes.

### Phase 2 — Mechanical sed pass on command files
```bash
# Dry-run: count occurrences
grep -rh "@acp\." agent/commands/ | wc -l

# Apply (macOS-safe sed):
for f in agent/commands/*.md; do
  sed -i '' 's|`@acp\.\([a-z-]*\)`|`/acp-\1`|g' "$f"
done
```
**Note**: Command names with dots in namespace (e.g. `@acp.package-install`) map to `/acp-package-install`.
The dot separator becomes a hyphen only for the namespace-command boundary (`acp.X` → `acp-X`).
Intra-command hyphens are preserved (`package-install` stays `package-install`).

### Phase 3 — Shell scripts and AGENT.md
```bash
# acp.common.sh — display_available_commands()
sed -i '' 's|`@acp\.\([a-z-]*\)`|`/acp-\1`|g' agent/scripts/acp.common.sh

# acp.install.sh and acp.version-update.sh
sed -i '' "s|@acp\.init|/acp-init|g" agent/scripts/acp.install.sh
sed -i '' "s|@acp\.init|/acp-init|g" agent/scripts/acp.version-update.sh

# AGENT.md — 176 references (backtick-wrapped and bare)
sed -i '' 's|`@acp\.\([a-z-]*\)`|`/acp-\1`|g' AGENT.md
# Bare references like @acp.init in text (not in backticks)
sed -i '' 's|@acp\.\([a-z-]*\)|/acp-\1|g' AGENT.md
```

### Phase 4 — Protocol file cleanup
Remove dual-alias lines (`/acp-commit or @acp.commit` → `/acp-commit`) in all 4 protocol files.

### Phase 4 — Docs update
Update `docs/USAGE.md` and `docs/README.md` — search and replace `@acp.` → `/acp-`.

### Phase 5 — Run binding test
```bash
bash e2e/acp.script-command-binding.test.sh
```
Expected: all tests pass (file names unchanged, only text inside files updated).

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| git.* commands also use `@git.*` prefix | Medium | Check `agent/commands/git.*.md` separately; keep `@git.*` or rename to `/git-*` as separate decision |
| sed regex misses multi-line or escaped @acp refs | Low | Manual grep verification after pass |
| External packages using `@acp.*` in their command files | Low | Out-of-scope; document in ADR |

**Note on `git.*` commands**: `git.commit.md` and `git.init.md` use `@git.*` not `@acp.*`.
These are a separate namespace and a separate decision — do NOT change in this task.
