# ACP Enhanced — Quick Start Guide
**Time to complete: 3–4 hours | Maintenance: ~5 min/day**

---

## Step 0 — Platform Setup (Windows only)

**macOS / Linux**: Skip this step. Bash is already available.

**Windows**: Shell scripts require Bash 4+. Use WSL2:
```bash
# From Windows terminal (PowerShell or cmd) — one-time install
wsl --install -d Ubuntu-22.04
```
Then run all bootstrap and shell script commands from the **WSL terminal**.

TypeScript tooling (`acp-dispatch.ts`, `acp-validate.ts`) runs natively on Windows — no WSL required:
```bash
# From a regular Windows terminal (cmd or PowerShell)
cd scripts && npm install
npx ts-node acp-dispatch.ts agent/routing/tasks/route-NNN.md
```

---

## What You Have After Bootstrap

```
AGENTS.md                          ← Auto-loaded by Copilot, Cursor, Claude Code
CLAUDE.md                          ← Copy of AGENTS.md (Claude Code auto-load)
.github/copilot-instructions.md    ← Copy of AGENTS.md (Copilot priority 1)
agent/core/                       ← Permanent cached context (Layer 1)
agent/skills/                     ← Task-specific instructions (Layer 2)
agent/memory/                     ← Session memory, corrections, patterns
agent/wiki/                       ← Project reference knowledge
agent/routing/                    ← Model config, taxonomy, cost ledger
agent/commands/                    ← All ACP command docs (69 acp.* + 2 git.*)
agent/scripts/                     ← All ACP bash scripts (36 scripts)
agent/schemas/                     ← YAML validation schemas
scripts/acp-dispatch.ts            ← Routing engine (Persona B/C only)
```

> **Note**: `CLAUDE.md` and `.github/copilot-instructions.md` are file copies (not symlinks).
> When you update `AGENTS.md`, sync them: `cp AGENTS.md CLAUDE.md && cp AGENTS.md .github/copilot-instructions.md`

---

## Step 1 — Run Bootstrap (5 minutes)

```bash
# From your project root
bash scripts/acp-bootstrap.sh
```

---

## Step 2 — Fill in Your Project Identity (10 minutes)

Edit `agent/core/identity.yml`:
```yaml
project: YourProject
type: mobile-app
stack:
  - language: TypeScript
  - framework: React Native + Expo EAS
  - backend: Firebase Auth + Firestore + Cloud Run
  - deployment: Expo EAS + Google Cloud Run
team: solo-developer
priorities: [code-quality, cost-efficiency, mobile-performance]
repo: github.com/your-handle/yourproject
```

**Recommended**: Enable branch safety by uncommenting the `git_workflow:` block in `agent/core/identity.yml`:
```yaml
git_workflow:
  default_working_branch: mainline   # branch you commit to daily
  production_branch: main            # branch that deploys to prod
  branch_model: trunk                # trunk | gitflow-lite | github-flow
```
When configured, ACP checks your git branch at the start of every session and warns if you're on the production branch before any work begins.

---

## Step 3 — Bootstrap Domain Knowledge (20 minutes)

In Copilot chat or Claude Code:
```
/acp-init
```
AI reads your src/ directory and populates:
- `agent/wiki/domain.yml` (entities, screens, operations)
- `agent/wiki/integrations.md` (Firebase, Expo, Cloud Run config)

Review the output. Fix any obvious errors. That's it.

---

## Step 4 — Write 3 Foundational ADRs (20 minutes)

Your most important decisions that you never want the AI to re-debate:
```
/acp-decide Use Firebase over Supabase for backend
/acp-decide Use React Native + Expo over Flutter
/acp-decide Use Zustand for local state management
```
Each takes 3–5 minutes. The AI drafts the ADR; you confirm.

---

## Step 5 — Configure the Dispatch Script (Persona B/C only, 30 minutes)

```bash
cd scripts
npm install

# Add your API key to .env (never commit this)
echo "OPENROUTER_API_KEY=your_key_here" >> ../.env
```

Test with a real task:
```bash
# First create a task via /acp-route in Copilot chat
/acp-route "Add loading skeleton to ChoreList screen"

# Then dispatch it
npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/task-001.md
```

---

## Step 6 — Validate the Full Loop (30 minutes)

1. `/acp-route "Add loading skeleton to ChoreList screen"`
   → Check: `agent/routing/tasks/task-001.md` created with executor and frontmatter

2. Do the work (via Copilot chat or dispatch script)

3. `/acp-commit`
   → Check: `agent/memory/sessions.md` has a new YAML entry

4. `/acp-cost-report`
   → Check: ledger has a row with token counts

If all four steps work, ACP Enhanced is fully operational.

---

## Daily Workflow (muscle memory)

```
Morning   → Open VS Code. Copilot already has context. Start coding.
New task  → /acp-route "[description]" (90 seconds)
Work      → Code normally. Copilot/Continue have full project context.
Correction→ "That's wrong. [explain]. Log it." (30 seconds)
EOD       → /acp-commit (90 seconds). Git commit. Done.
```

## Weekly Workflow (Fridays, 10 minutes)

```
/acp-cost-report
→ Review 3 taxonomy suggestions
→ Accept/reject each
→ Done
```

## Monthly Workflow (First Friday, 30 minutes)

```
/acp-memory-sync
→ Review stale pattern warnings
→ Verify wiki/architecture.md is still accurate
→ Done
```

---

## Persona-Specific Notes

### Persona A — GitHub Copilot Pro Only
- The executor field in tasks is a RECOMMENDATION for which Copilot model to select
- Select model manually from Copilot's model dropdown in VS Code
- Skip the dispatch script setup entirely
- Focus: memory layer + ADRs + session commits = 20–30% token savings
- Main benefit: far fewer clarification turns = fewer premium requests burned

### Persona B — DeepSeek Multi-Model (Continue.dev / Cline)
- Install Continue.dev extension in VS Code
- Configure multi-model setup in .vscode/settings.json (see acp-dispatch.ts comments)
- Use dispatch script for explicit routing control
- Main benefit: 50–65% cost reduction via model routing + prompt caching

### Persona C — Copilot Pro + DeepSeek (Recommended)
- Use Copilot for: tab completion, PR review, inline suggestions
- Use DeepSeek via dispatch script for: chat tasks, architecture, heavy coding
- AGENTS.md feeds both tools from one source
- Main benefit: each tool used for its genuine strength; ACP bridges context loss

---

## Troubleshooting

**AI keeps loading wrong wiki files?**
→ Add a correction to lessons.md: "Log this: for [task_type] tasks, only load [correct file]"

**Dispatch script fails?**
→ Check OPENROUTER_API_KEY is set: `echo $OPENROUTER_API_KEY`
→ Check task file has valid YAML frontmatter: `head -20 agent/routing/tasks/task-NNN.md`

**sessions.md getting too long?**
→ Run `/acp-memory-sync` — it compacts automatically

**Wrong executor being assigned?**
→ Add `override_executor: claude-sonnet` to the task frontmatter
→ After 2–3 overrides for same task type, update taxonomy.yml via `/acp-cost-report`

**Context budget warnings?**
→ Dispatch script auto-trims; if quality drops, check which wiki sections are loading
→ Split the task into smaller tasks with focused context_required fields
