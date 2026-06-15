---
id: route-160
title: Add 13 missing commands to package.yaml + CI count-guard check
task_type: yaml-schema
milestone: M59
complexity: low
executor: copilot
context_required:
  - wiki/architecture.md#package-system-data-flow
files_affected:
  - package.yaml
  - scripts/ci-validate.sh
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Add the 13 command docs absent from `package.yaml` so `/acp-package-install` distributes a complete framework, and add a CI guard that fails when `package.yaml` command count diverges from the command-file count.

## Context

`package.yaml` declares 63 commands; 68 files exist. The 13 missing include core verbs: `acp.commit`, `acp.decide`, `acp.dispatch`, `acp.route`, `acp.task`, `acp.feedback`, `acp.visualize`, `acp.wiki-update`, `acp.carryover-query`, `acp.cost-report`, `acp.memory-sync`, `acp.pattern-sync`, `acp.session-sync`. A package install would ship a non-functional framework. Found in audit-067 (HIGH-067-001).

## Steps

1. Read `package.yaml` `contents.commands[]` and the binding format (name + scripts array).
2. For each of the 13 missing commands, add an entry with correct `scripts:` (most are `None` → empty/omit, but verify each command doc's `**Scripts**:` field).
3. Add a check to `scripts/ci-validate.sh`:
   - Count `agent/commands/acp.*.md` (excluding templates) vs command entries in package.yaml.
   - Exit 1 with a clear message if they differ.
4. Run the check locally to confirm parity after the additions.

## Expected Output

### Files Modified
- `package.yaml` — 13 command entries added
- `scripts/ci-validate.sh` — command↔package.yaml count guard

## Verification (double-verify)

- [ ] **Automated**: ci-validate.sh count-guard passes after additions; FAILS if a command is removed from package.yaml
- [ ] **Manual**: `diff` of listed-vs-actual command names is empty (use the audit-067 PowerShell/bash one-liner)
- [ ] Each added entry's `scripts:` matches the command doc's `**Scripts**:` field

## User-Observable Acceptance

- package.yaml command count == 68 (matches `agent/commands/acp.*.md` count)
- `bash scripts/ci-validate.sh` reports the new guard passing

## Addresses

audit-067 HIGH-067-001 (consolidated register H8)
