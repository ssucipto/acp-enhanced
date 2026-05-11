---
id: route-033
title: M41b — Add Windows/WSL install documentation (GAP-005)
task_type: documentation-sync
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - README.md
  - scripts/QUICKSTART.md
files_affected:
  - README.md
  - scripts/QUICKSTART.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add Windows/WSL2 installation documentation to `README.md` and `scripts/QUICKSTART.md`. Currently `identity.yml` documents `bash_compat: macOS (BSD sed) + Linux (GNU)` and the README Requirements section mentions only "Linux or macOS". TypeScript tooling (dispatch, validate) runs natively on Windows but shell scripts require Bash. Without WSL2 guidance, Windows developers cannot install ACP Enhanced. Closes GAP-005 from audit-014.

## Acceptance Criteria

- [ ] `README.md` Requirements section updated to include Windows note:
  ```
  **Windows**: Shell scripts require Bash 4+. Use WSL2 (Ubuntu 22.04 recommended).
  TypeScript tooling (`acp-dispatch.ts`, `acp-validate.ts`) runs natively on Windows — no WSL required.
  ```
- [ ] `scripts/QUICKSTART.md`: new prerequisite block or Step 0 "Platform Setup":
  ```markdown
  ### Windows Users
  Shell scripts require Bash 4+. Use WSL2:
    wsl --install -d Ubuntu-22.04
  
  TypeScript tooling runs natively on Windows — no WSL required.
  Run bootstrap from WSL terminal: bash scripts/acp-bootstrap.sh
  Run dispatch from Windows terminal: cd scripts && npx ts-node acp-dispatch.ts
  ```
- [ ] No changes to scripts themselves — documentation only
- [ ] macOS and Linux sections unaffected

## Implementation Notes

Keep the Windows section concise. Developers on Windows will know how to install WSL2 — we just need to confirm that it's required and that TypeScript runs natively. Do not add WSL2 setup instructions beyond the one-liner.
