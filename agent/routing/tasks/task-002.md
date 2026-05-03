---
id: task-002
title: Migrate agent/ to agent/ — unify directory layout
task_type: bash-script-refactor
milestone: none
complexity: high
executor: claude-sonnet
context_required:
  - wiki/architecture.md
  - wiki/domain.yml
  - memory/decisions.md
files_affected:
  # Directories moved
  - agent/core/          → agent/core/
  - agent/memory/        → agent/memory/
  - agent/routing/       → agent/routing/
  - agent/skills/        → agent/skills/
  - agent/routing/tasks/         → agent/routing/tasks/
  - agent/wiki/          → agent/wiki/
  # Reference updates (~142 occurrences, 13 files)
  - .github/copilot-instructions.md    # 103-line protocol — 30+ agent/ refs
  - AGENTS.md                           # mirrors copilot-instructions.md
  - CLAUDE.md                           # mirrors copilot-instructions.md
  - scripts/AGENTS.md                   # mirrors copilot-instructions.md
  - .github/prompts/acp-commit.prompt.md
  - .github/prompts/acp-decide.prompt.md
  - .github/prompts/acp-memory-sync.prompt.md
  - .github/prompts/acp-route.prompt.md
  - .github/prompts/acp-wiki-update.prompt.md
  - scripts/acp-dispatch.ts
  - scripts/acp-validate.ts
  - scripts/PRD-MAIN.md
  - agent/wiki/architecture.md         # self-references the layer structure
tokens_est: 12000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed:
override_reason:
depends_on: task-001  # prefer completing syntax unification first (simpler rollback)
---

## Recommendation & Rationale

**Merge `agent/` into `agent/` — YES, proceed. Here is why:**

The original ACP project uses a single `agent/` directory for all protocol content.
ACP Enhanced introduced `agent/` as a hidden "meta-layer" to separate its additions
from the upstream protocol. This made sense in a fork context but creates ongoing confusion:

- Developers must remember which layer (`agent/` vs `agent/`) a file lives in
- The dot-prefix hides the directory from casual `ls` and GitHub web UI
- The distinction between "protocol" (`agent/`) and "meta" (`agent/`) is not intuitive
- ACP Enhanced's whole value proposition is *enhancement on top*, which should be visible

**The unified layout makes ACP Enhanced additions first-class citizens of the `agent/` tree,
which is precisely the signal this project wants to send.**

---

## Conflict Analysis

| `agent/` subdir | `agent/` conflict? | Resolution |
| --- | --- | --- |
| `core/` | None | Direct move → `agent/core/` |
| `memory/` | None | Direct move → `agent/memory/` |
| `routing/` | None | Direct move → `agent/routing/` |
| `skills/` | None | Direct move → `agent/skills/` |
| `wiki/` | None | Direct move → `agent/wiki/` |
| `tasks/` | **YES** — `agent/tasks/` already exists (project task files) | Move to `agent/routing/tasks/` |

`agent/tasks/` contains project milestone task files (`task-1-commands-infrastructure.md`, etc.)
`agent/routing/tasks/` contains ACP Enhanced routing tasks (`task-001.md`, `task-002.md`).
These are conceptually different. Placing routing tasks under `agent/routing/tasks/` is semantically
correct — they are part of the routing subsystem, not project work items.

---

## Final Directory Layout (after migration)

```
agent/
  commands/          ← original ACP (unchanged)
  scripts/           ← original ACP (unchanged)
  schemas/           ← original ACP (unchanged)
  tasks/             ← original ACP project tasks (unchanged)
  patterns/          ← original ACP (unchanged)
  [... other original dirs]
  core/              ← ACP Enhanced: identity, constraints, routing session state
  memory/            ← ACP Enhanced: sessions, lessons, decisions, patterns
  routing/           ← ACP Enhanced: taxonomy, rules, ledger, config
    tasks/           ← ACP Enhanced: routing task files (was agent/routing/tasks/)
  skills/            ← ACP Enhanced: per-domain skill files
  wiki/              ← ACP Enhanced: domain.yml, architecture.md
```

This layout makes the ACP Enhanced additions transparent and navigable alongside the original
protocol files — exactly the "enhancement on top" model the project aims for.

---

## Implementation Plan

### Phase 1 — ADR (run before any changes)

Run `/acp-decide`:
- Decision: Merge `agent/` hidden directory into `agent/` for visibility and consistency
- Trigger to re-open: If ACP Enhanced is ever used as an installable package overlaid on a
  separate project's `agent/` directory (multi-repo use case)

### Phase 2 — Move directories (5 direct, 1 redirect)

```bash
cd /path/to/acp-enhanced

# Direct moves (no conflicts)
git mv agent/core    agent/core
git mv agent/memory  agent/memory
git mv agent/routing agent/routing
git mv agent/skills  agent/skills
git mv agent/wiki    agent/wiki

# Routing tasks — move into routing subsystem, not project tasks
mkdir -p agent/routing/tasks
git mv agent/routing/tasks/task-template.md agent/routing/tasks/task-template.md
git mv agent/routing/tasks/task-001.md      agent/routing/tasks/task-001.md
git mv agent/routing/tasks/task-002.md      agent/routing/tasks/task-002.md

# Remove now-empty agent/
rmdir agent/tasks
rmdir .agent
```

### Phase 3 — Update all `agent/` path references

**sed pass (macOS-safe):**
```bash
FILES=(
  .github/copilot-instructions.md
  AGENTS.md
  CLAUDE.md
  scripts/AGENTS.md
  .github/prompts/acp-commit.prompt.md
  .github/prompts/acp-decide.prompt.md
  .github/prompts/acp-memory-sync.prompt.md
  .github/prompts/acp-route.prompt.md
  .github/prompts/acp-wiki-update.prompt.md
  scripts/acp-dispatch.ts
  scripts/acp-validate.ts
  scripts/PRD-MAIN.md
)

for f in "${FILES[@]}"; do
  # Replace agent/routing/tasks/ → agent/routing/tasks/ FIRST (more specific pattern)
  sed -i '' 's|\agent/routing/tasks/|agent/routing/tasks/|g' "$f"
  # Replace remaining agent/ → agent/
  sed -i '' 's|\agent/|agent/|g' "$f"
done
```

**Manual update required in `agent/wiki/architecture.md`** — the Layer Structure diagram
references `agent/` paths inline. Update the diagram to show `agent/` paths:
```
LAYER 1 — CORE   agent/core/identity.yml, constraints.yml, routing.yml
LAYER 2 — SKILLS agent/skills/*.md
LAYER 3 — MEMORY agent/memory/sessions.md, lessons.md, decisions.md
           WIKI   agent/wiki/domain.yml, architecture.md
```

### Phase 4 — Update `acp-dispatch.ts` task path detection

`acp-dispatch.ts` currently expects tasks at `agent/routing/tasks/task-NNN.md`.
Update the usage comment and any path resolution logic to `agent/routing/tasks/task-NNN.md`.

### Phase 5 — Verify

```bash
# No agent/ refs should remain (except .github/ dir name itself)
grep -r "\agent/" . \
  --exclude-dir=.git \
  --include="*.md" --include="*.yml" --include="*.yaml" --include="*.ts" \
  | grep -v "\.github/"

# Confirm agent/ subdirs are present
ls agent/core agent/memory agent/routing agent/routing/tasks agent/skills agent/wiki
```

---

## Acceptance Criteria

- [ ] `agent/` directory is fully removed from the repo
- [ ] `agent/core/`, `agent/memory/`, `agent/routing/`, `agent/skills/`, `agent/wiki/` all exist
- [ ] `agent/routing/tasks/` contains task-template.md and routing task files
- [ ] `agent/tasks/` (project tasks) is unchanged
- [ ] Zero remaining `agent/` references in all tracked files (excluding `.github/` dir name)
- [ ] `scripts/acp-dispatch.ts` invocation still works: `npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-NNN.md`
- [ ] `agent/wiki/architecture.md` layer diagram updated to new paths
- [ ] ADR logged in `agent/memory/decisions.md`

---

## Sequencing Note

**Run task-001 (syntax unification) before this task.**
Reason: task-001 changes text inside files only. This task moves files. Running in this order
gives clean, reviewable git commits — one commit changes invocation syntax, the next changes
directory structure. Mixing them makes the diff harder to review and roll back.
