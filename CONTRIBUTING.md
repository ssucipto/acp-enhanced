# Contributing to ACP Enhanced

Thanks for your interest in contributing. ACP Enhanced is a documentation-first
development methodology that gives AI agents structured, persistent project memory
across sessions. This project is the ACP protocol itself — it builds and maintains
the command documents, shell scripts, YAML schemas, and E2E tests that power the
framework.

## Branch Model

We use **gitflow-lite** (`develop` → `mainline`):

- **`develop`** — default working branch. All feature/fix work happens here or on
  feature branches off `develop`.
- **`mainline`** — production branch. PRs merge `develop` → `mainline`.

```
mainline ← PR ← develop ← feature/my-feature
```

- Never commit directly to `mainline`.
- All PRs target `develop`.
- `mainline` is updated via periodic PRs from `develop`.

## Before Opening a PR

Every PR must pass these checks:

1. **E2E suite green** — run `bash run-e2e-tests.sh` and confirm 100% pass rate.
2. **`/acp-validate`** — no status desyncs, no dangling file pointers, no schema violations.
3. **CHANGELOG entry** — add a concise entry under the next unreleased version or bump the
   version and add the entry yourself. Follow [Keep a Changelog](https://keepachangelog.com/)
   conventions.

### CI Pipeline

CI runs on every push and PR to `develop` and `mainline`. It executes the full E2E suite
and validation pipeline. A green CI run is required before merging.

## Command Document Conventions

Command documents live in `agent/commands/acp.<name>.md`. Every command document must have:

- **Agent Directive** — a `> **🤖 Agent Directive**` block that tells the AI agent how to
  execute the command.
- **`## Steps`** — numbered, actionable steps the agent follows.
- **`## Verification`** — checklist of assertions that verify correctness.
- **`## Expected Output`** — what files are created/modified.
- **`**Namespace**: acp`** — every command must declare its namespace.

See [`agent/skills/commands.md`](agent/skills/commands.md) for the full skill reference.

## Shell Script Conventions

Shell scripts live in `agent/scripts/*.sh`. Every script must:

- Start with `#!/usr/bin/env bash`
- Set `set -euo pipefail` (exit on error, undefined variable, pipe failures)
- Trap `ERR` for cleanup with `trap cleanup ERR`
- Be cross-platform: work on both macOS (BSD sed) and Linux (GNU)
- Use `mktemp -d` for temporary directories, never hardcoded `/tmp`
- Source `tests/common.sh` in E2E tests for assertion functions

See [`agent/skills/scripts.md`](agent/skills/scripts.md) for the full skill reference.

## YAML Schema Conventions

Every YAML file must have:

- No duplicate keys — duplicates silently shadow earlier values.
- Consistent indentation (2 spaces).
- Schema validation via `/acp-validate`.

## Project Structure

```
agent/
├── commands/         # Command directive files (acp.<name>.md)
├── core/             # Core static files (identity.yml, constraints.yml, routing.yml)
├── memory/           # Session memory, lessons learned, decisions
├── milestones/       # Milestone documents
├── routing/          # Task taxonomy, routing rules, task files
│   └── tasks/        # Individual route files (route-NNN.md)
├── scripts/          # Shell scripts (cross-platform bash 4+)
├── skills/           # Agent skill files for task types
├── wiki/             # Long-form reference (domain.yml, architecture.md)
└── patterns/         # Reusable patterns learned during development

e2e/                  # End-to-end test suites
tests/                # Shared test utilities (common.sh)
scripts/              # TypeScript tooling (acp-validate.ts, acp-dispatch.ts)
```

## Code of Conduct

- Be respectful and constructive.
- Follow the conventions above — they exist for reproducibility across AI agents.
- When in doubt, run `/acp-validate` and fix all findings before submitting.

## Security

For vulnerability disclosure, see [SECURITY.md](./SECURITY.md).

## Questions?

Open an issue or discussion on the repository. If you're new to ACP, run `/acp-init`
to load the full project context before contributing.
