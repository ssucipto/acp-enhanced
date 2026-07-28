---
id: task-291
milestone: M83
title: "ADR-23 — local deterministic analyzers, detection-as-consent, assisted install"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 4
depends_on: []
audit_findings: []
blocks: [task-292, task-293]
files_affected:
  - agent/memory/decisions.md
  - agent/patterns/local.optional-external-tool.md
---

## Objective

Write ADR-23 establishing three governance positions that tasks 290, 292, and 293 depend on, and amend the optional-external-tool pattern to document the new variant.

## Context

Three decisions surfaced in the 2026-07-27 discussion, none covered by existing ADRs:

**1. Local deterministic analyzers are outside the ADR-19 gate.** ADR-19/21/22 gate CodeRabbit and Aikido — cloud services whose output shape cannot be known without live adoption. dupehound, gitleaks, and shellcheck are local, offline, deterministic, and their output is verifiable today. This is a **carve-out for a category the gate never contemplated**, not a re-open of ADR-19 (which is DO NOT re-open).

**2. Detection-as-consent variant of Gate 1.** `local.optional-external-tool.md:44` states *"Opt-in is authoritative. Even when the tool is present, do nothing unless the user enabled it."* The maintainer chose **auto-enable on detection** for dupehound. This is defensible **only** for tools with no egress: Gate 1's strictness for CodeRabbit is substantially about not shipping source to a third party. dupehound has no network at all. The eligibility test must be explicit: **offline + read-only + no egress**.

**3. Assisted install boundary.** ACP may install third-party binaries **with explicit consent, via trusted package managers only**. ACP never downloads a binary itself (today it fetches only text — `acp.version-check-for-updates.sh:52`), and never installs a language toolchain.

## Steps

1. Append ADR-23 to `agent/memory/decisions.md` in the established format (Status / Context / Options considered / Decision / Consequences / DO NOT re-open).
2. State all three decisions with the reasoning above; cite audit-102, audit-103, and the 2026-07-27 discussion.
3. Record the eligibility test for the detection-as-consent variant so it cannot be applied to a cloud tool by analogy.
4. Amend `local.optional-external-tool.md`:
   - keep the existing strict contract as **Variant A (opt-in authoritative)** — CodeRabbit remains the reference
   - add **Variant B (detection-as-consent)** with its eligibility test and the mandatory explicit-`false` escape hatch
   - add the never-download-binaries rule
5. Confirm ADR-19/21/22 remain in force for CodeRabbit and Aikido; state that explicitly.

## Verification

- [ ] ADR-23 passes `decisions.schema.yaml` validation (`--memory`)
- [ ] Pattern doc shows both variants with a clear eligibility test
- [ ] No wording implies ADR-19/21/22 are superseded or re-opened
- [ ] Explicit-`false` escape hatch documented as mandatory for Variant B
- [ ] `npx tsx scripts/acp-validate.ts --memory` clean

## User-Observable Acceptance

A future contributor reading the pattern doc can tell which variant applies to a new tool, and why, without re-deriving the argument.
