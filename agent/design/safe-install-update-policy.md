# Safe Install & Update File Tier Policy

<!-- @acp.meta.design
topic: install, update, version-update, safety, overwrite
description: Tiered file policy for acp.install, acp.version-update, and bootstrap — prevents destructive overwrites of project-owned state
status: accepted
updated: 2026-07-15
@acp.meta.end -->

**Status**: Accepted (M68 design)  
**Source**: audit-080, audit-081 (pre-impl), route-079 (reopened), FIFOZ field report  
**Target version**: v6.24.0  
**Amended**: 2026-07-15 (audit-081 findings folded in)

---

## Problem

`/acp-version-update` and reinstall paths **blind-copy** framework files over project-owned configuration (`identity.yml`, `domain.yml`, `taxonomy.yml`, etc.). M47 route-079 guards were documented and marked complete but **never implemented in shell**. Consumers require `git restore` after update — unacceptable for production adoption (FIFOZ M67 handoff blocker).

---

## Industry alignment

| Pattern | Source | ACP adoption |
|---------|--------|--------------|
| **Conffile prompt** | Debian `dpkg` — ask before replacing modified config | Default: skip Tier B if local ≠ upstream; prompt on TTY |
| **Checksum skip** | `acp.package-update.sh` `--skip-modified` | Reuse `calculate_checksum()` + upstream hash compare |
| **Dry-run preview** | Helm `helm diff`, npm `npm update --dry-run` | `--diff` flag on version-update |
| **Explicit force** | Homebrew `--force`, apt `--force-confnew` | `--force` overwrites all Tier B |
| **Merge not replace** | Kubernetes strategic merge, lockfile merge | `manifest.yaml` Tier D — acp-core block only |
| **Idempotent bootstrap** | Terraform `create_before_destroy` mindset | `create-if-absent` for all Tier B stubs |

---

## File tiers

### Tier A — Never overwrite (project-owned)

Create-if-absent only. Update scripts must **never** `cp`, `cat >`, or `sed` these paths.

| Path pattern | Rationale |
|--------------|-----------|
| `agent/progress.yaml` | Milestone + task state |
| `agent/memory/*` | Sessions, lessons, ADRs, patterns |
| `agent/routing/tasks/route-*.md` | User routing tasks |
| `agent/routing/ledger.md` | Cost ledger |
| `agent/design/*.md` (non-`*.template.md`) | Project designs |
| `agent/milestones/*.md` (non-template) | Project milestones |
| `agent/patterns/local.*` | Local skill extensions |
| `agent/preferences/**` | Preference overrides |
| `agent/drafts/**`, `agent/clarifications/**` | Working docs |
| `agent/artifacts/**`, `agent/specs/**` (non-template) | Research + specs |
| `agent/index/local.*` | Project index extensions |
| `agent/commands/{namespace}.*.md` where namespace ≠ `acp` and ≠ `git` | Third-party / custom commands |

### Tier B — Preserve if modified (compare to upstream default)

**Default behavior**: If local file SHA-256 ≠ upstream framework file in clone → **skip** (log `⊘ preserved`).  
**`--force`**: overwrite.  
**Interactive TTY**: optional per-file confirm before overwrite.

| Path | Notes |
|------|-------|
| `agent/core/identity.yml` | **Never overwrite without `--force`** even if hash matches (project name check: not `YOUR_PROJECT_NAME`) |
| `agent/core/constraints.yml` | Preserve if customized |
| `agent/core/routing.yml` | Preserve session customizations (`context_modes`, `command_suggestions`) |
| `agent/wiki/domain.yml` | Heavily customized per project |
| `agent/wiki/architecture.md` | Project architecture |
| `agent/wiki/integrations.md` | Service integrations |
| `agent/routing/taxonomy.yml` | Project task types |
| `agent/routing/rules.md` | Routing rules prose |
| `agent/routing/config.yml` | Model config (may customize costs) |
| `agent/skills/local.*.md` | Already skipped in install; add to update |

### Tier C — Always overwrite (framework artifacts)

Safe to refresh on every update.

| Path pattern |
|--------------|
| `agent/commands/acp.*.md`, `agent/commands/git.*.md` |
| `agent/scripts/*.sh` |
| `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` (triple-sync) |
| `agent/skills/*.md` except `local.*` |
| `agent/*.template.*`, `agent/**/**.template.md` |
| `agent/schemas/*` |
| `agent/index/acp.*.yaml` (bundled, not `local.*`) |
| `.opencode/commands/acp-*.md`, `.cursor/commands/acp-*.md` (regenerated) |
| `agent/benchmarks/**` (framework fixtures) |

### Tier D — Merge only

| Path | Rule |
|------|------|
| `agent/manifest.yaml` | Update `packages.acp-core.package_version` + `updated_at` only; **never** `cat >` whole file |

---

## Comparison algorithm

During update, `$TEMP_DIR` holds upstream clone. For each Tier B file `rel_path`:

```
1. If --preserve-project-core (default ON for agent/CI): skip Tier B copies entirely
2. If file missing locally → copy from upstream (first install path)
3. If SHA256(local) == SHA256(upstream) → copy (refresh identical)
4. If SHA256(local) != SHA256(upstream):
   a. If --force → copy
   b. If TTY && !--yes → prompt Overwrite? (y/N)
   c. Else → skip, log preserved path
5. identity.yml extra guard: if project != YOUR_PROJECT_NAME → always skip unless --force
```

**`--diff` mode**: Run steps 1–4 logic but only print actions; exit 0 without writes.

---

## Shared helpers (`acp.common.sh`)

New functions (route-198):

| Function | Purpose |
|----------|---------|
| `acp_upstream_root` | Echo `$TEMP_DIR` when set |
| `acp_sha256_file path` | Wrapper around `calculate_checksum` |
| `acp_file_differs_from_upstream rel` | Compare local vs `$TEMP_DIR/rel` |
| `acp_identity_is_customized` | Grep `YOUR_PROJECT_NAME` / empty project field |
| `acp_copy_framework_file rel tier` | Tier-aware copy with logging |
| `acp_merge_manifest_acp_core version` | Tier D manifest merge |

**Critical implementation note (P-081-07)**: Do **not** use `is_file_modified()` for acp-core Tier B files — it requires per-file manifest checksums that acp-core does not populate. Use `acp_file_differs_from_upstream()` (SHA-256 local vs `$TEMP_DIR/rel`) instead.

**Environment**: Callers must `export TEMP_DIR` before invoking tier helpers (P-081-08).

Registry file (optional): `agent/schemas/install-tier-registry.yaml` listing paths per tier for validate + docs.

---

## Script responsibilities

| Script | Changes |
|--------|---------|
| `acp.version-update.sh` | Full flag parsing; replace blind `cp` blocks; AGENTS.md OR AGENT.md entry; schemas Tier C; **acp/git commands only** (P-081-01); skip `local.*` skills (P-081-02) |
| `acp.install.sh` | Tier B on reinstall; manifest merge; xargs → while-read |
| `acp-bootstrap.sh` | `create-if-absent` for all Tier B stubs |
| `acp.version-update.md` | Fix `domain.yml` path (`agent/wiki/` not `agent/core/`) |

---

## Flags (`acp.version-update.sh`)

| Flag | Behavior |
|------|----------|
| (default) | Tier A never; Tier B skip if modified; Tier C refresh; Tier D merge |
| `--diff` | Dry-run report only |
| `--preserve-project-core` | Skip all Tier B (explicit alias for default safe mode) |
| `--force` | Overwrite Tier B without prompt |
| `--yes` / `-y` | Auto-confirm prompts (CI) |

**Agent invocation default**: When command doc is executed by an agent, pass `--preserve-project-core` unless user explicitly requests full overwrite.

---

## Testing requirements

| Test | Platform |
|------|----------|
| `e2e/acp.version-update-preserve.test.sh` | macOS + Linux CI |
| `e2e/acp.install-preserve.test.sh` | macOS + Linux + Windows CI |
| Customized `identity.yml` survives default update | Required |
| `progress.yaml` untouched | Required (F-080-13) |
| Third-party command namespace preserved | Required (P-081-01) |
| `local.*` skill preserved on update | Required (P-081-02) |
| `manifest.yaml` retains non-acp-core packages after reinstall | Required |
| Windows Git Bash: manifest generation without `xargs` | windows-latest CI |
| **Offline upstream** via `ACP_UPSTREAM_ROOT` env | Required — no live `git clone` in CI (P-081-03) |

---

## Non-goals (M68)

- Three-way merge UI for conflict resolution
- Automatic backup `.bak` files (git is the backup; document in command output)
- Global `~/.acp/` package install tier changes

---

## Verification

Milestone M68 exit requires:

- [ ] route-079 acceptance criteria pass **in shell** (not doc-only — SC-080-01)
- [ ] audit-080 F-080-01..12 closed
- [ ] audit-081 P-081-01..03 closed
- [ ] route-204 validate guard passes before v6.24.0 tag (SC-080-03)
- [ ] FIFOZ can run `/acp-version-update` without `git restore`
- [ ] `npx tsx scripts/acp-validate.ts` — 0 errors

## Anti-shortcut register

| ID | Prevention |
|----|------------|
| SC-080-01 | No route-079 `completed:` until route-202 E2E green |
| SC-080-02 | CHANGELOG v6.24.0 notes v6.9.0 doc-only gap |
| SC-080-03 | `acp_copy_framework_file()` + validate guard |
| SC-080-04 | Tier D manifest merge only |
| SC-080-05 | Single tier table in command doc (no contradicting lists) |
| SC-080-06 | Behavioral E2E ≥12 assertions, not syntax-only |
