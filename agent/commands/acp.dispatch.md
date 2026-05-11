# Command: dispatch

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-dispatch` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-dispatch` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-11  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: `scripts/acp-dispatch.ts`  

---

**Purpose**: Invoke the ACP dispatch engine to execute a routing task with a configured LLM executor (Persona B/C workflow)  
**Category**: Workflow  
**Frequency**: Per task (Persona B/C only)  

---

## Persona Guide

| Persona | Description | Uses dispatch? |
|---------|-------------|----------------|
| **A — Copilot only** | GitHub Copilot Pro in VS Code. All work via Copilot chat. | ❌ No |
| **B — DeepSeek/OpenRouter** | Continue.dev or Cline with DeepSeek models. Dispatch sends tasks to OpenRouter API. | ✅ Yes |
| **C — Mixed** | Copilot for planning/commits, DeepSeek for heavy implementation. | ✅ Yes |

If you are Persona A, you do not need this command. Use `/acp-proceed` directly in Copilot chat instead.

---

## Arguments

**CLI-Style Arguments**:
- `<route-NNN>` (positional) — the route file to dispatch (e.g. `route-034`)
- `--dry-run` — preview the assembled prompt without sending to the LLM
- `--model <model-id>` — override the executor model for this run only (e.g. `deepseek-v4-flash`)

**Natural Language**:
- `/acp-dispatch route-034` — dispatch route-034 to its configured executor
- `/acp-dispatch route-034 --dry-run` — preview what would be sent

---

## What This Command Does

Dispatches a routing task to an external LLM via OpenRouter. The script:
1. Reads the route file's YAML frontmatter to determine executor and model
2. Assembles a context-optimised prompt (identity.yml + constraints + skill + sessions + task)
3. Sends the prompt to the configured model via OpenRouter API
4. Streams the response to stdout
5. Writes token usage and cost to `agent/routing/ledger.md`
6. Updates `agent/core/routing.yml` with the executor used

---

## Prerequisites

- [ ] `node` and `npm` installed (v18+ recommended)
- [ ] `scripts/` directory has been set up: `cd scripts && npm install`
- [ ] `OPENROUTER_API_KEY` environment variable set
- [ ] Route file exists in `agent/routing/tasks/`

**One-time setup** (run once per machine):
```bash
cd scripts
npm install
```

**Set API key** (add to shell profile):
```bash
export OPENROUTER_API_KEY="sk-or-..."
```

---

## Steps

### Step 0 — Display Header

```
🚀 /acp-dispatch
  Execute routing task via OpenRouter LLM dispatch (Persona B/C)
```

### Step 1 — Parse Arguments

Resolve the route file path:
- If argument is `route-034` → expand to `agent/routing/tasks/route-034.md`
- If argument is a full path → use as-is
- If no argument → list pending routes and prompt user to pick one

### Step 2 — Pre-Flight Checks

Verify before dispatching:
1. Route file exists and has YAML frontmatter with `executor:` field
2. `agent/core/identity.yml` is present (required for context assembly)
3. `agent/core/routing.yml` is present
4. `OPENROUTER_API_KEY` environment variable is set (non-empty)
5. `scripts/node_modules/` exists — if not, prompt: `Run: cd scripts && npm install`

If any check fails → display specific error and halt.

### Step 3 — Preview (--dry-run mode)

If `--dry-run` flag is set:
- Assemble the prompt (system + user messages)
- Display:
  ```
  [DRY RUN] Route: route-{NNN} | Executor: {executor} | Model: {model}
  System tokens: ~{N}
  User tokens: ~{N}
  [Prompt preview — first 500 chars of user message]:
  {preview}
  ```
- Exit without sending to API

### Step 4 — Execute Dispatch

Run the dispatch script from the project root:

```bash
npx ts-node scripts/acp-dispatch.ts agent/routing/tasks/{route-NNN}.md
```

The script will:
- Stream the LLM response to stdout in real-time
- Log token usage and cost to `agent/routing/ledger.md`
- Update `agent/core/routing.yml` with current executor

Watch for:
- `[ACP] Context: ~X system + ~Y user tokens` — prompt size info
- `[ACP] Dispatching route-NNN → executor (model)` — dispatch started
- `[ACP] Cost: $X.XXXX` — task cost after completion
- `ERROR:` or `[ACP] Error:` — halt and report

### Step 5 — After Dispatch

After the LLM completes the task:
1. Review the output for the expected deliverables (files created/modified)
2. Verify the output matches the route's acceptance criteria
3. If satisfied, run `/acp-commit` to write the session entry

```
✅ /acp-dispatch complete
  Route: route-{NNN}
  Executor: {executor}
  Cost: ${cost}
  Ledger: agent/routing/ledger.md

  Next: review output → /acp-commit
```
