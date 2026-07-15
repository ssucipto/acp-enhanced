---
id: task-240
milestone: M72
title: "Drift closures — versions, instruction-file sync, script registrations"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15T01:16:00Z
completed: 2026-07-15
completed_date: 2026-07-15T01:30:00Z
route: route-229
audit_findings: [F-091-01, F-091-02, F-091-14, F-092-03, F-092-04]
depends_on: []
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Fix the two high-severity drift findings from audit-091 — the *fix half* only. Per guardrail #1 these carryovers are NOT stamped `fixed` until task-241 lands the matching enforcement.

## Context (inlined from audit-091)

- `.github/copilot-instructions.md` header reads **v6.24.0**; AGENTS.md/CLAUDE.md read v6.26.0. The pre-commit sync hook that `acp-bootstrap.sh` installs for consumers is absent from this repo's `.git/hooks/`.
- `package.yaml` reads **version: 6.21.1** vs canonical 6.26.0 (identity.yml).
- Unregistered in `package.yaml` contents AND `agent/integrity-manifest.yaml`: `acp.cursor-commands-sync.sh`, `acp.claude-commands-sync.sh`, `acp.post-milestone-sweep.sh`.
- F-091-14 + F-092-03 (audit-092 amendment): `agent/.gitignore` bare `reports/` rule overrides the root `!agent/reports/` whitelist — **61 of 88 reports untracked** (incl. audit-078..090 closure evidence); `feedback/` similarly at 25 of 28 untracked (incl. feedback-007 cited by carryover F-086-02). Per design D9: track `reports/` + `feedback/`; `clarifications/`, `drafts/**`, `preferences/` stay ignored BY DESIGN (acp.plan.md Step 10) — fix surgically, never blanket-remove the file. Per patterns.md `install-script-gitignore-heredoc-sync`: after fixing, grep agent/scripts/ AND agent/commands/ for embedded gitignore heredocs and apply the same fix there.

## Steps

1. `cp AGENTS.md .github/copilot-instructions.md` (byte-identical; verify with `md5 -q` triple match)
2. Set `package.yaml → version: 6.26.0` (current shipped version; task-247 bumps to 6.27.0 at release)
3. Install the AGENTS.md sync pre-commit hook block (same block `acp-bootstrap.sh` step 8 writes) into `.git/hooks/pre-commit`, appending if a hook exists (design D6)
4. Register the 3 scripts in `package.yaml` contents (fields: `name` + `description` + `type` — F-092-04 correction, there is no `version` field; match existing entries) and in `agent/integrity-manifest.yaml` (via `acp.manifest-hash.sh` regeneration, D10)
5. Fix `agent/.gitignore` per D9: delete (or `!`-whitelist) the `reports/` and `feedback/` lines ONLY — leave `clarifications/`, `drafts/**`, `preferences/` ignored; then `git add agent/reports/ agent/feedback/` (≈61 + 25 files); grep agent/scripts/ + agent/commands/ for embedded gitignore heredocs mirroring the old rule and fix those too

## Verification

- [ ] `md5 -q AGENTS.md CLAUDE.md .github/copilot-instructions.md` — three identical hashes
- [ ] `grep "^version:" package.yaml` → 6.26.0
- [ ] `grep -c "commands-sync\|post-milestone-sweep" package.yaml` ≥ 3; same for integrity-manifest.yaml
- [ ] `.git/hooks/pre-commit` contains the ACP sync marker and is executable
- [ ] `git check-ignore agent/reports/probe.md agent/feedback/probe.md` → neither ignored; `git check-ignore agent/clarifications/probe.md` → still ignored (D9 preserved)
- [ ] `git ls-files agent/reports agent/feedback` covers all on-disk files in both dirs
- [ ] Carryovers F-091-01/02/14 remain `pending` (stamped only with task-241, per guardrail #1)

## User-Observable Acceptance

Editing AGENTS.md and committing auto-updates CLAUDE.md + copilot-instructions.md in the same commit.
