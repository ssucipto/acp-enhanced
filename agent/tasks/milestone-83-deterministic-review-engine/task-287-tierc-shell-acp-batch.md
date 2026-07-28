---
id: task-287
milestone: M83
title: "Tier C rules — shell portability + ACP hygiene (SH-02/04, ACP-01/03, YM-01/02)"
status: completed
priority: 4
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 3
depends_on: [task-283, task-284]
audit_findings: []
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-corpus/
---

## Objective

Ship the shell-portability and ACP-hygiene Tier C rules, all of which need **context awareness** rather than naive pattern matching.

## Context

audit-102 empirically showed naive regex produces false positives on exactly these rules:

- `sed -i` at `acp.common.sh:8` and `acp.yaml-parser.sh:18` is already correctly OS-guarded — must **not** flag
- `trap 'rm -f "$TMP"' EXIT` at `acp.atomic-write.sh:21` is cleared by `trap - EXIT` at `:30` — must **not** flag

These are the cases that distinguish a usable scanner from a noisy one.

## Steps

1. **SH-02** HIGH — `sed -i` without a BSD/GNU guard. Recognise the existing guard idiom (OS-conditional wrapper function) and `sed -i.bak` as safe.
2. **SH-04** CRITICAL — `trap … EXIT` inside a sourced function library. Recognise `trap - EXIT` clearing and skip executables; use the same sourced-library detection as the SH-01 allowlist (F-M82-05).
3. **ACP-01** MEDIUM — command docs in `agent/commands/*.md` missing the `🤖 Agent Directive` header.
4. **ACP-03** LOW — scripts not matching `acp.{name}.sh` naming.
5. **YM-01** HIGH — YAML files that fail to parse (reuse the js-yaml path already in `acp-validate.ts`; do not duplicate).
6. **YM-02** MEDIUM — Markdown frontmatter that fails to parse as YAML.

## Verification

- [x] Guarded `sed -i` in `acp.common.sh` / `acp.yaml-parser.sh` produces **no** SH-02 finding
- [x] `acp.atomic-write.sh` trap-then-clear produces **no** SH-04 finding
- [x] A genuine unguarded `sed -i ''` fixture **is** flagged
- [x] A sourced library with an uncleared EXIT trap **is** flagged CRITICAL
- [x] YM-01/YM-02 reuse existing parse infrastructure rather than reimplementing
- [x] Zero false positives across the whole repo for all six rules

## User-Observable Acceptance

Running `--self` on this repo produces no false positives from these six rules.
