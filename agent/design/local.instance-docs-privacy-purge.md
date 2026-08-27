# Design: Instance-docs privacy purge (M88)

<!-- @acp.meta.design
topic: privacy, instance-docs, milestones, tasks, sessions, docs, git-filter-repo, public-repo, ADR-28
description: Remove instance milestone/task/session docs and one field-feedback file from public remotes including history
status: active
updated: 2026-08-27
decisions: D1..D10
@acp.meta.end -->

**Version**: 1.0.0  
**Date**: 2026-08-27  
**Source**: maintainer Option C after ADR-27; ADR-28  
**ADR**: ADR-28 (supersedes M87 design D5 for instance docs only)  
**Target release**: v6.34.0  
**Depends on**: [local.public-repo-privacy-purge.md](local.public-repo-privacy-purge.md) (ADR-27 keepers stay)

---

## Problem

Public remotes still track this repo’s **dogfood instance**: milestone bodies, task bodies, `agent/sessions/{date}-{slug}.md`, and `docs/acp-enhanced-dev-team-feedback-consolidated.md`. Those files name consumer projects and local backup layout. They are **not** what `acp.install.sh` ships (templates only).

ADR-27 emptied reports/feedback only. M87 design **D5** required `agent/tasks` to stay addable/tracked. That is unsafe for a public protocol remote. A HEAD-only `git rm` does not remove GitHub history.

M87 missed: `cp -r agent/` in E2E copies gitignored bodies (Windows timeout); Unicode in printed script output; `--invert-paths` drops keepers (F-119-10). M88 must not repeat those.

---

## KEEP vs PURGE (all four trees — do not improvise)

### D1: `docs/` is not a directory purge

| Path | Remote |
|------|--------|
| `docs/USAGE.md` | **KEEP** (product guide; E2E copies it) |
| `docs/acp-fork-upgrade-checklist.md` | **KEEP** |
| `docs/README.md` | **KEEP** (Pages browser) |
| `docs/index.html` | **KEEP** |
| `docs/acp-enhanced-dev-team-feedback-consolidated.md` | **PURGE** (file path only) |

**Wrong:** `git filter-repo --invert-paths --path docs/`  
**Right:** `--path docs/acp-enhanced-dev-team-feedback-consolidated.md` only.

### D2: `agent/milestones/` — templates + keepers only

| Path | Remote |
|------|--------|
| `agent/milestones/.gitkeep` | **KEEP** |
| `agent/milestones/README.md` | **KEEP** (short; no instance narrative) |
| `agent/milestones/milestone-1-{title}.template.md` | **KEEP** (install copies this) |
| `agent/milestones/milestone-*.md` instance bodies (including `milestone-9-template-source-files.md`, M87, **this M88 file after rewrite**) | **PURGE** |

`*.template.md` is the keep glob. `milestone-9-template-source-files.md` is an **instance** file — it does **not** match.

### D3: `agent/tasks/` — templates + keepers only

| Path | Remote |
|------|--------|
| `agent/tasks/.gitkeep` | **KEEP** |
| `agent/tasks/README.md` | **KEEP** |
| `agent/tasks/task-1-{title}.template.md` | **KEEP** |
| `agent/tasks/task-*.md` (root orphans) | **PURGE** |
| `agent/tasks/milestone-*/**` | **PURGE** |

**Out of path:** `agent/routing/tasks/` (route files stay). `agent/benchmarks/**/agent/tasks/` (fixtures stay). Never `--path-glob '**/tasks/'`.

### D4: `agent/sessions/` — keepers only

| Path | Remote |
|------|--------|
| `agent/sessions/.gitkeep` | **KEEP** |
| `agent/sessions/README.md` | **KEEP** |
| `agent/sessions/{date}-{slug}.md` | **PURGE** |

**Out of path:** `agent/memory/sessions.md` (compact YAML ledger — **stays tracked**). `agent/sessions.template.yaml` lives at `agent/` root — **KEEP** (do not invert it).

ADR-9 dual-store still **writes** session documents on disk. ADR-28 forbids **committing** them.

---

## Solution

**D5: Local writers stay.** `/acp-plan`, `/acp-task-create`, `/acp-commit` step 2b, `/acp-session-sync` still write instance files locally. Gitignore them. Do not `git add -f`.

**D6: Public ledger without bodies.** `agent/progress.yaml` `file:` pointers, CHANGELOG, `agent/memory/sessions.md`, `agent/memory/audit-carryovers.md`, ADR-28 stay. `validateFilePointers` must not ERROR when a `file:` path is gitignored and absent (CI clone). Local clones with bodies still pass because files exist.

**D7: Addability.** `validateProtocolDirAddability` probeDirs = `["agent/memory"]` only. Drop `agent/tasks` (supersedes M87 D5).

**D8: Backup before start.** Fresh backups **after** this plan is committed (M87 backups are stale). Worktree rsync, local git mirror from `$(pwd)`, encrypted archive of the four trees **plus** existing gitignored reports/feedback. Restore-test all three. Second local mirror immediately before `filter-repo`.

**D9: History rewrite is the security control.** `filter-repo --invert-paths` on the three dirs + the one docs file, then restore keepers+templates on the tip (F-119-10). Force-push `develop`, `mainline`, **and tags** only after a **new** exact phrase (do not reuse the M87 phrase).

**D10: Rehearse the CI tip before rewrite.** After `git rm --cached`, export the **index** to a temp tree and run validate + a targeted E2E. Assert: USAGE.md present, both templates present, instance body count 0, no Unicode arrows in new print() lines. Do not treat dry-run or exit-0-only as pass (FG-3, FG-6).

### Rejected

- Option A (feedback file only) / Option B (gitignore, leave history) — maintainer rejected; ADR-28 Option C.
- Invert entire `docs/`.
- Include `agent/patterns/*.md` or `agent/design/local.*` (out of ADR-28).
- Auto force-push from `/acp-proceed`.
- Reuse M87 confirmation phrase.
- M87 backups as the only backup.

---

## Implementation order

1. **GATE (335 → 336 → 337)** — rsync, local mirror, encrypted four-tree archive. Restore tests required.
2. Citation + KEEP/PURGE inventory + test/CI corpus (338) — blocked on 337.
3. Gitignore + validator **one commit** (339); commands/E2E/wiki (340); pattern/install/pack (341).
4. Redact leftovers in files that **remain** tracked (342).
5. `git rm --cached` instance bodies; keep templates+keepers+public docs (343).
6. **CI-clone rehearsal** on the index (344) — blocked on 339+340+343.
7. Second local mirror + `filter-repo` + operator phrase (345) — blocked on 337+336+343+**344**.
8. Fresh-clone + tag proof (346).
9. Closure v6.34.0 (347). Stamp nothing as “history-clean” before 346.

---

## Anti-shortcuts

- First `/acp-proceed` is **335**, not 338/339.
- Never invert `docs/`. Never invert `agent/routing/tasks/`. Never invert `agent/memory/`.
- Never `git rm` without `--cached`. Never `git add -f` instance bodies.
- Force-push only after exact phrase including **tags** (CB-4). Phrase is **not** the M87 phrase.
- `--yes` is not consent. Do not force-push from the daily worktree.
- `git clone` of a local mirror **without** `--no-local` aborts filter-repo.
- Do not skip 344 rehearsal (M87 Windows timeout class).
- F-R006-* out of scope.
- Do not commit audit report bodies.
- After rewrite, this milestone/task set is local-only; the public record is ADR-28 + CHANGELOG + progress.yaml.

---

## Success

A stranger cloning origin (including tags) sees public `docs/` (minus the one file), milestone/task **templates** + keepers, session keepers, and compact ledgers. They cannot read instance milestone/task/session bodies from history. The operator restores them from `${HOME}/acp-enhanced-private/` without GitHub. CI is green on that clone.

---

## Operator cookbook (copy-paste — do not improvise)

Canonical commands for M88. Tasks cite **CB-N**. Check syntax by reading this block immediately before running.

`STAMP`: `date +%Y%m%dT%H%M%S` (not day-only). Destination: `${HOME}/acp-enhanced-private/` — **never** inside the clone.

### CB-0a — Worktree rsync (task-335) — FIRST

Captures untracked files and `.git`. Run from repo root.

```bash
command -v rsync
BACKUP_DIR="${HOME}/acp-enhanced-private"
mkdir -p "${BACKUP_DIR}"
STAMP="$(date +%Y%m%dT%H%M%S)"
echo "${STAMP}" > "${BACKUP_DIR}/M88_LAST_STAMP.txt"
DEST="${BACKUP_DIR}/worktree-m88-${STAMP}"
rsync -a "$(pwd)/" "${DEST}/"
test -f "${DEST}/docs/USAGE.md"
test -f "${DEST}/docs/acp-enhanced-dev-team-feedback-consolidated.md"
test -f "${DEST}/agent/milestones/milestone-1-{title}.template.md"
test -d "${DEST}/agent/tasks"
test -d "${DEST}/agent/sessions"
test -f "${DEST}/agent/core/identity.yml"
test "$(git rev-parse HEAD)" = "$(git -C "${DEST}" rev-parse HEAD)"
printf '%s\n' "worktree backup OK ${DEST}"
```

Restore dry-run (do **not** rsync back onto the live clone):

```bash
STAMP="$(cat "${HOME}/acp-enhanced-private/M88_LAST_STAMP.txt")"
DEST="${HOME}/acp-enhanced-private/worktree-m88-${STAMP}"
test -f "${DEST}/docs/USAGE.md"
test -f "${DEST}/docs/acp-enhanced-dev-team-feedback-consolidated.md"
git -C "${DEST}" rev-parse HEAD
```

### CB-0b — Local git mirror (task-336) — from this clone, not GitHub

```bash
BACKUP_DIR="${HOME}/acp-enhanced-private"
STAMP="$(cat "${BACKUP_DIR}/M88_LAST_STAMP.txt")"
MIRROR="${BACKUP_DIR}/acp-enhanced-m88-${STAMP}.git"
git clone --mirror "$(pwd)" "${MIRROR}"
git --git-dir="${MIRROR}" rev-parse HEAD
test "$(git rev-parse HEAD)" = "$(git --git-dir="${MIRROR}" rev-parse HEAD)"
git --git-dir="${MIRROR}" bundle create "${BACKUP_DIR}/acp-enhanced-m88-${STAMP}.bundle" --all
printf '%s\n' "mirror OK ${MIRROR}"
```

### CB-1 — Encrypted archive of the four trees (task-337)

Pack **instance** paths that must survive a machine move. Include existing gitignored reports/feedback so one archive restores local privacy dirs. Never put the archive inside the clone. Never pass passphrase on argv.

```bash
BACKUP_DIR="${HOME}/acp-enhanced-private"
STAMP="$(cat "${BACKUP_DIR}/M88_LAST_STAMP.txt")"
OUT="${BACKUP_DIR}/acp-m88-instance-${STAMP}.tar.gz.gpg"
# Use acp.private-pack.sh once 341 extends PACK_REL_DIRS; until then tar the four trees + reports/feedback.
# After 341:
#   bash agent/scripts/acp.private-pack.sh pack --output "${OUT}"
test -f "${OUT}"
# Restore-test to a temp dir (not the live clone). Confirm USAGE.md was NOT the only docs file packed;
# the purge target file must be in the archive; USAGE.md must still exist in the live clone.
test -f docs/USAGE.md
printf '%s\n' "archive OK ${OUT}"
```

### CB-2 — Gitignore (task-339) — syntax before commit

Append to `agent/.gitignore` (**last match wins**; do not ignore parent dirs so keepers can be re-included):

```gitignore
# ADR-28 — instance milestone/task/session bodies local; templates + keepers tracked
milestones/**
!milestones/.gitkeep
!milestones/README.md
!milestones/*.template.md
tasks/**
!tasks/.gitkeep
!tasks/README.md
!tasks/*.template.md
sessions/**
!sessions/.gitkeep
!sessions/README.md
```

Root `.gitignore` (file only — never `docs/`):

```gitignore
# ADR-28 — field-feedback notes local
docs/acp-enhanced-dev-team-feedback-consolidated.md
```

Syntax check **before** commit:

```bash
touch agent/milestones/milestone-dummy.md
touch agent/tasks/task-dummy.md
mkdir -p agent/tasks/milestone-dummy agent/sessions
touch agent/tasks/milestone-dummy/task-dummy.md
touch agent/sessions/2026-01-01-dummy.md
git check-ignore -v agent/milestones/milestone-dummy.md
git check-ignore -v agent/tasks/task-dummy.md
git check-ignore -v agent/tasks/milestone-dummy/task-dummy.md
git check-ignore -v agent/sessions/2026-01-01-dummy.md
git check-ignore -v docs/acp-enhanced-dev-team-feedback-consolidated.md
# keepers and public docs must NOT be ignored (check-ignore exit 1):
git check-ignore -v agent/milestones/milestone-1-{title}.template.md; echo "ms_tmpl_exit=$?"
git check-ignore -v agent/tasks/task-1-{title}.template.md; echo "tk_tmpl_exit=$?"
git check-ignore -v docs/USAGE.md; echo "usage_exit=$?"
git check-ignore -v agent/routing/tasks/route-template.md; echo "route_exit=$?"
git check-ignore -v agent/memory/sessions.md; echo "mem_sess_exit=$?"
git check-ignore -v agent/sessions.template.yaml; echo "sess_yaml_exit=$?"
rm -f agent/milestones/milestone-dummy.md agent/tasks/task-dummy.md
rm -rf agent/tasks/milestone-dummy
rm -f agent/sessions/2026-01-01-dummy.md
```

Required: dummies ignored (exit 0); templates, USAGE.md, routing tasks, `memory/sessions.md`, `sessions.template.yaml` **not** ignored (exit 1).

**Same commit** as validator: `validateFilePointers` skips missing paths that `git check-ignore -q` matches; `validateProtocolDirAddability` probeDirs = `["agent/memory"]` only.

### CB-3 — Tip purge without deleting the working copy (task-343)

**Wrong:** `git rm -r agent/milestones` — deletes instance files from disk (and would require care not to delete the template).  
**Right:** `--cached` only, after **335, 336, and 337** restore proofs:

```bash
# Untrack instance bodies; keep templates/keepers in the index.
git ls-files agent/milestones agent/tasks agent/sessions docs/acp-enhanced-dev-team-feedback-consolidated.md > /tmp/m88-ls-before.txt
git rm --cached -r agent/milestones agent/tasks agent/sessions
git rm --cached -- docs/acp-enhanced-dev-team-feedback-consolidated.md || true
# Restore keepers + templates to the index (working tree files remain).
git add agent/milestones/.gitkeep agent/milestones/README.md "agent/milestones/milestone-1-{title}.template.md"
git add agent/tasks/.gitkeep agent/tasks/README.md "agent/tasks/task-1-{title}.template.md"
git add agent/sessions/.gitkeep agent/sessions/README.md
git add docs/USAGE.md docs/acp-fork-upgrade-checklist.md docs/README.md docs/index.html
test -f docs/USAGE.md
test -f "agent/milestones/milestone-1-{title}.template.md"
test -f docs/acp-enhanced-dev-team-feedback-consolidated.md
```

Do **not** `git add -f` instance bodies. Confirm local files still exist on disk.

### CB-3b — CI-clone rehearsal (task-344) — before filter-repo

Export the **index** (what CI checks out at this tip), not the dirty worktree:

```bash
REHEARSE="/tmp/acp-m88-rehearse"
rm -rf "${REHEARSE}"
mkdir -p "${REHEARSE}"
git checkout-index -a --prefix="${REHEARSE}/"
test -f "${REHEARSE}/docs/USAGE.md"
test -f "${REHEARSE}/agent/milestones/milestone-1-{title}.template.md"
test -f "${REHEARSE}/agent/tasks/task-1-{title}.template.md"
test ! -f "${REHEARSE}/docs/acp-enhanced-dev-team-feedback-consolidated.md"
test ! -f "${REHEARSE}/agent/milestones/milestone-87-public-repo-privacy-purge.md"
# instance session bodies must be absent from the index export
find "${REHEARSE}/agent/sessions" -type f ! -name '.gitkeep' ! -name 'README.md' | wc -l
cd "${REHEARSE}"
# run validate from this tree (install scripts deps as CI does)
```

Pass: validate green; USAGE.md + both templates exist; instance body count 0. Fail: skipping this because “local validate already passed” (local tree still has bodies).

### CB-4 — History rewrite (task-345)

**Never run `git filter-repo` in the daily worktree.** `filter-repo` strips `origin`.

Mirror immediately before rewrite — **from this clone**, not GitHub:

```bash
STAMP="$(date +%Y%m%dT%H%M%S)"
git clone --mirror "$(pwd)" "${HOME}/acp-enhanced-private/acp-enhanced-m88-pre-rewrite-${STAMP}.git"
```

Throwaway clone **must** use `--no-local`:

```bash
MIRROR="${HOME}/acp-enhanced-private/acp-enhanced-m88-pre-rewrite-${STAMP}.git"
DAILY="$(pwd)"
git clone --no-local "${MIRROR}" /tmp/acp-rewrite-m88
cd /tmp/acp-rewrite-m88
git filter-repo --invert-paths \
  --path agent/milestones/ \
  --path agent/tasks/ \
  --path agent/sessions/ \
  --path docs/acp-enhanced-dev-team-feedback-consolidated.md
git remote add origin "$(git -C "${DAILY}" remote get-url origin)"
```

`--invert-paths` removes keepers/templates from every commit. Re-add keepers + **templates** on the rewritten tip (F-119-10), commit, then **STOP**.

Confirm public docs still exist on the tip: `test -f docs/USAGE.md`.

Operator must type exactly:

```
force-push instance-docs develop mainline tags: yes
```

Then (not `--force-with-lease`):

```bash
git push --force origin develop
git push --force origin mainline
git push --force origin --tags
```

### CB-5 — Fresh-clone proof (task-346)

Full clone, **not** `--depth=1`:

```bash
DAILY="$(pwd)"
git clone "$(git -C "${DAILY}" remote get-url origin)" /tmp/acp-fresh-m88
cd /tmp/acp-fresh-m88
test -f docs/USAGE.md
test -f docs/acp-fork-upgrade-checklist.md
test -f "agent/milestones/milestone-1-{title}.template.md"
test -f "agent/tasks/task-1-{title}.template.md"
test ! -f docs/acp-enhanced-dev-team-feedback-consolidated.md
git ls-files agent/milestones agent/tasks agent/sessions
git log --all --full-history --oneline -- agent/milestones/milestone-87-public-repo-privacy-purge.md
git log --all --full-history --oneline -- docs/acp-enhanced-dev-team-feedback-consolidated.md
```

Pass: `ls-files` is keepers + templates only; history has no instance body paths (or only keepers). Repeat for `mainline` and a tag that previously contained bodies.

### CB-6 — Never

- Start 338/339 before 335+336+337 restore tests pass
- Invert `docs/` or `agent/routing/tasks/` or `agent/memory/`
- `git add -f` instance milestone/task/session bodies or the purge-target docs file
- `git rm` without `--cached` on those trees
- `git clone --mirror` from GitHub as the **only** backup
- `git clone "${MIRROR}"` without `--no-local` before `filter-repo`
- Skip 344 because local validate was green
- Force-push from the daily unre-written worktree
- `git push --force` without the M88 confirmation phrase
- Reuse `force-push develop mainline tags: yes` (M87 phrase — insufficient for M88)
- Treat F-R006-* as in-scope
- Mark history-clean after 343 only
