---
id: route-183
title: Integrity script robustness — YAML parser, git-date staleness, IG-37 explicit-skip, manifest dir-enumeration, sha fallback
task_type: bash-script-refactor
milestone: M64
complexity: medium
executor: copilot
context_required:
  - skills/scripts.md
  - reports/audit-070-m55-m58-gateway-deep-dive.md
files_affected:
  - agent/scripts/acp.network-whitelist-validate.sh
  - agent/scripts/acp.git-provenance.sh
  - agent/scripts/acp.dependency-diff.sh
  - agent/scripts/acp.manifest-hash.sh
  - agent/scripts/acp.yaml-parser.sh
tokens_est: 9000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Eliminate the correctness/reproducibility defects that make integrity findings unreliable across environments: grep-as-YAML (fail-open whitelist), mtime-based staleness (broken in git checkouts), the silent IG-37 no-op, manifest tamper-detection that can't see added files, and single-tool hash dependency.

## Context

audit-070: F-070-09 (MED) grep/sed YAML parsing — `acp.network-whitelist-validate.sh:45–50` grabs ANY `- ` list item (not scoped to `approved_hosts:`), so a list elsewhere in the file is treated as approved domains (fail-open); same class in git-provenance (team_members) and manifest verify. F-070-10 (MED) IG-31 uses file mtime (reset on clone). F-070-11 (MED) IG-37 is a no-op because `identity.yml` ships `team_members: []` and the check is guarded behind a non-empty test → silent pass. F-070-12 (MED) manifest tracks a hardcoded 7-file list (IG-41 undetectable) and `--generate` prints to stdout instead of writing the file. F-070-15 (LOW) `shasum -a 256` only.

## Steps

1. **F-070-09 — YAML via parser**: source `agent/scripts/acp.yaml-parser.sh`; read `approved_hosts` with `yaml_get_array approved_hosts` (scoped to the key) in network-whitelist; read `team_members` with `yaml_get_array team_members` in git-provenance; read manifest entries via the parser (or `shasum -c`-style) in manifest-hash. Remove the grep/sed extraction.
2. **F-070-10 — git-date staleness**: in `acp.dependency-diff.sh` IG-31, replace `stat -f %m`/`stat -c %Y` with `git log -1 --format=%ct -- <file>` for both `package.json` and the lockfile; fall back to mtime only outside a git repo (documented).
3. **F-070-11 — IG-37 explicit skip**: in `acp.git-provenance.sh`, when `team_members` is empty, emit `[LOW] identity.yml:0 IG-37 — SKIPPED: team_members unset (author verification disabled)` instead of silently passing; document first-run setup in the command doc.
4. **F-070-12 — manifest**:
   - `--generate` writes to `agent/manifest.yaml` by default; add `--stdout` to opt out.
   - Enumerate tracked directories (`agent/core/`, plus the fixed top-level files) by globbing so IG-41 (new file in `agent/core/` not in manifest) is detectable: on `--verify`, any current `agent/core/*.yml` not present in the manifest is a finding.
5. **F-070-15 — hash fallback**: add a `hash_cmd` resolver preferring `sha256sum`, then `shasum -a 256`, then `openssl dgst -sha256`; fail with a clear message only if none exist.
6. Emit all new findings in the route-182 canonical format.

## Expected Output

### Files Modified
- network-whitelist, git-provenance, dependency-diff, manifest-hash — robustness fixes
- (possibly) `agent/scripts/acp.yaml-parser.sh` — add `yaml_get_array` if missing

## Verification (double-verify)

- [ ] **Automated**: route-184 fixtures — a `network_whitelist.yml` with a decoy list under another key does NOT whitelist those values; a fresh clone's IG-31 uses commit dates; an extra `agent/core/zz-extra.yml` triggers IG-41
- [ ] **Manual**: `acp.git-provenance.sh` on default `team_members: []` prints the IG-37 SKIPPED line (not a silent pass)
- [ ] **Manual**: `acp.manifest-hash.sh --generate` creates/updates `agent/manifest.yaml`; `--verify` then reports OK
- [ ] **Manual**: hashing works on a box with only `sha256sum` (no `shasum`)
- [ ] No grep-based YAML extraction remains (`grep -nE "grep .*(approved_hosts|team_members|sha256)" agent/scripts/*.sh` → only parser calls)
- [ ] `shellcheck --severity=error` clean

## User-Observable Acceptance

- Whitelist can't be bypassed by unrelated YAML lists; staleness/manifest checks behave correctly in CI and on fresh clones; provenance check tells you when it's disabled.

## Addresses

audit-070 F-070-09 (MED), F-070-10 (MED), F-070-11 (MED), F-070-12 (MED), F-070-15 (LOW); also resolves audit-067 LOW-067-004 at the source
