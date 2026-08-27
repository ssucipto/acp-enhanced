# Design: Public-repo privacy purge (M87)

<!-- @acp.meta.design
topic: privacy, reports, feedback, git-filter, public-repo, D9
description: Remove agent/reports and agent/feedback from public remotes including git history; keep local writes + encrypted pack
status: active
updated: 2026-08-27
decisions: D1..D8
@acp.meta.end -->

**Version**: 1.0.0  
**Date**: 2026-08-27  
**Source**: audit-118 (findings F-118-01..08); maintainer override — reports/audits **off remote**  
**ADR**: ADR-27  
**Target release**: v6.33.0  

---

## Problem

ACP Enhanced’s public remotes currently track **171 report files** and **37 feedback files** (`origin/mainline` at `b0334bb`; `develop` is **ahead** with M87 plan commits). audit-118 found:

- Vendor account identifiers in CodeRabbit raw dumps
- A full consumer application design spec
- Port-inbox copies of another project’s CI plus absolute `$HOME` paths

M72 **D9** required those directories to be tracked. That is unsafe for a public clone. Deleting files in a new commit does **not** remove blobs from GitHub history.

## Solution

**D1: Empty on remotes.** Public trees may keep `agent/reports/.gitkeep`, `agent/feedback/.gitkeep`, and a 10-line README each. No audit/review/handoff/inbox bodies.

**D2: Local writers stay.** `/acp-audit`, `/acp-report`, `/acp-review --report`, `/acp-integrity --report` still write under those dirs. Gitignore them (same class as drafts/clarifications).

**D3: Backup before start.** Before any other M87 task: (0a) rsync the whole worktree (including untracked reports), (0b) local `git clone --mirror` from **this** clone (not GitHub), (1) encrypted reports/feedback archive. Restore-test all three. A second local mirror is taken again immediately before `filter-repo`. No rewrite without those restores.

**D4: History rewrite is the security control.** `git filter-repo` (or `git filter-branch` equivalent) drops `agent/reports/**` and `agent/feedback/**` (except `.gitkeep`/README if re-added on the tip). Then force-push **both** `develop` and `mainline` only after the operator confirms.

**D5: D9 superseded here.** `validateProtocolDirAddability` must treat reports/feedback like drafts: ignored is **correct**; untracked-on-disk is **not** an error. Memory and tasks stay tracked.

**D6: Public ledger without bodies.** Carryover IDs (`F-118-01`) and CHANGELOG bullets remain. Do not paste consumer spec text or vendor UUIDs into remaining tracked files (including this design).

**D7: identity.yml email stays.** IG-37 team allowlist. No extra personal addresses.

**D8: Transport.** `agent/scripts/acp.private-pack.sh` packs gitignored dirs (`reports`, `feedback`, `clarifications`, `drafts`, `preferences`, `private/`) to an age/gpg archive. Never push the archive.

### Rejected

- Class A in git / Class B local (audit-118 default) — maintainer rejected; too easy to leak again.
- HEAD `git rm` only — insufficient for a public repo.
- Auto force-push from `/acp-proceed` — forbidden.

## Implementation order

1. **Local backups GATE (333 → 334 → 323)** — worktree rsync, local git mirror, encrypted content. Restore tests required.
2. Citation map (322) — only after backups restore.
3. Gitignore + validator + E2E/command docs + pattern/install.
4. Redact leftovers in files that **remain** tracked.
5. `git rm --cached` current tree (keep keepers).
6. Second local mirror + `filter-repo` + operator-confirmed force-push (branches **and** tags).
7. Fresh-clone + tag proof.
8. Stamp F-118-* after that proof — not after local `git rm`.

## Anti-shortcuts

- Do not mark F-118-01..03 fixed after HEAD delete only.
- Do not commit new `audit-*.md` to origin during M87.
- Do not put FIFOZ/ChoreHive product internals into M87 docs.
- Do not skip the backup restore tests (333, 334, **and** 323).
- Do not start 322/324 until those three restores pass.
- Do not `git clone --mirror` from GitHub as the **only** backup (misses untracked + unpushed).
- Review-006 (js-yaml, bootstrap, dispatch) is **out of scope**.

## Success

A stranger cloning `origin/mainline` cannot read historical or current audit/feedback bodies. The operator can restore them on another machine from the private pack.

---

## Operator cookbook (copy-paste — do not improvise)

Canonical commands for M87. Tasks cite **CB-N**. Check syntax by reading this block immediately before running. Do **not** substitute `git add -f`, `git rm` (without `--cached`), `git push --force-with-lease` after a rewrite, `git clone --depth=1` for history proof, or `git clone --mirror git@github.com:...` as the **only** backup.

`STAMP`: `date +%Y%m%dT%H%M%S` (not day-only). Destination: `${HOME}/acp-enhanced-private/` — **never** inside the clone.

### CB-0a — Worktree rsync (task-333) — FIRST

Captures **untracked** reports (audit-118/119) and `.git`. Run from repo root.

```bash
command -v rsync
BACKUP_DIR="${HOME}/acp-enhanced-private"
mkdir -p "${BACKUP_DIR}"
STAMP="$(date +%Y%m%dT%H%M%S)"
echo "${STAMP}" > "${BACKUP_DIR}/LAST_STAMP.txt"
DEST="${BACKUP_DIR}/worktree-${STAMP}"
rsync -a "$(pwd)/" "${DEST}/"
test -d "${DEST}/agent/reports"
test -f "${DEST}/agent/core/identity.yml"
test "$(git rev-parse HEAD)" = "$(git -C "${DEST}" rev-parse HEAD)"
test -f agent/reports/audit-119-m87-pre-impl-readiness.md && test -f "${DEST}/agent/reports/audit-119-m87-pre-impl-readiness.md"
printf '%s\n' "worktree backup OK ${DEST}"
```

Restore dry-run (do **not** rsync back onto the live clone):

```bash
STAMP="$(cat "${HOME}/acp-enhanced-private/LAST_STAMP.txt")"
DEST="${HOME}/acp-enhanced-private/worktree-${STAMP}"
test -d "${DEST}/agent/reports"
git -C "${DEST}" rev-parse HEAD
```

### CB-0b — Local git mirror (task-334) — from this clone, not GitHub

```bash
BACKUP_DIR="${HOME}/acp-enhanced-private"
STAMP="$(cat "${BACKUP_DIR}/LAST_STAMP.txt")"
MIRROR="${BACKUP_DIR}/acp-enhanced-${STAMP}.git"
git clone --mirror "$(pwd)" "${MIRROR}"
git --git-dir="${MIRROR}" rev-parse develop
git --git-dir="${MIRROR}" bundle create "${BACKUP_DIR}/acp-enhanced-${STAMP}.bundle" --all
rm -rf /tmp/acp-from-mirror
git clone "${MIRROR}" /tmp/acp-from-mirror
test "$(git -C /tmp/acp-from-mirror rev-parse HEAD)" = "$(git rev-parse HEAD)"
```

### CB-1 — Encrypted reports + feedback (task-323)

After CB-0a/0b restore tests. Prefer `age` if present; **if `age` is missing, use gpg** (this Mac has gpg only). Trap removes the plaintext tar.

```bash
BACKUP_DIR="${HOME}/acp-enhanced-private"
STAMP="$(date +%Y%m%dT%H%M%S)"
TAR="/tmp/acp-rf-${STAMP}.tar.gz"
tar -C "$(pwd)" -czf "${TAR}" agent/reports agent/feedback
cleanup() { rm -f "${TAR}"; }
trap cleanup EXIT
if command -v age >/dev/null 2>&1; then
  age -p -o "${BACKUP_DIR}/acp-reports-feedback-${STAMP}.tar.gz.age" "${TAR}"
  echo "encrypted: ${BACKUP_DIR}/acp-reports-feedback-${STAMP}.tar.gz.age"
else
  command -v gpg
  gpg --symmetric --cipher-algo AES256 -o "${BACKUP_DIR}/acp-reports-feedback-${STAMP}.tar.gz.gpg" "${TAR}"
  echo "encrypted: ${BACKUP_DIR}/acp-reports-feedback-${STAMP}.tar.gz.gpg"
fi
```

Restore dry-run (gpg; use `age -d` if the file is `.age`):

```bash
# set STAMP to the pack filename stamp
RESTORE="/tmp/acp-restore-test"
rm -rf "${RESTORE}"
mkdir -p "${RESTORE}"
gpg --decrypt -o "/tmp/acp-rf-restored.tar.gz" "${HOME}/acp-enhanced-private/acp-reports-feedback-${STAMP}.tar.gz.gpg"
tar -C "${RESTORE}" -xzf "/tmp/acp-rf-restored.tar.gz"
test -d "${RESTORE}/agent/reports"
test -d "${RESTORE}/agent/feedback"
find "${RESTORE}/agent/reports" | wc -l
find "${RESTORE}/agent/feedback" | wc -l
rm -f "/tmp/acp-rf-restored.tar.gz"
```

Expected: **171** tracked report files + **37** tracked feedback files, plus untracked local reports. Compare `git ls-files agent/reports | wc -l` **before** 328.

### CB-2 — Gitignore keepers (task-324)

`agent/.gitignore` is relative to `agent/`. Copy the **drafts** pattern (`**`, not `*`). Nested files are **not** ignored by `reports/*`.

Append (keep existing clarifications/drafts/preferences blocks):

```gitignore
# ADR-27 — report/feedback bodies local; keepers tracked
reports/**
!reports/.gitkeep
!reports/README.md
feedback/**
!feedback/.gitkeep
!feedback/README.md
```

Root `.gitignore` must keep **both** of these (the first would otherwise ignore `agent/reports/` entirely):

```gitignore
reports/
!agent/reports/
```

Syntax check **before** commit (dummy must be ignored; keepers must not):

```bash
touch agent/reports/audit-dummy.md agent/feedback/feedback-dummy.md
git check-ignore -v agent/reports/audit-dummy.md
git check-ignore -v agent/feedback/feedback-dummy.md
git check-ignore -v agent/reports/.gitkeep; echo "gitkeep_exit=$?"
# gitkeep: check-ignore exit 1 = not ignored (required)
rm -f agent/reports/audit-dummy.md agent/feedback/feedback-dummy.md
```

**Same commit** as validator changes: `validateProtocolDirAddability` probeDirs must drop `agent/reports` and `agent/feedback` (keep `agent/memory`, `agent/tasks`); delete the D9 walk loop for those two dirs; `validateGitignoreConflicts` trackedPaths must not include `agent/reports/` (use `agent/reports/.gitkeep` if a keeper check is needed).

### CB-3 — Tip purge without deleting the working copy (task-328)

**Wrong:** `git rm -r agent/reports` — deletes 171 files from disk.  
**Right:** `--cached` only, after **333, 334, and 323** restore proofs:

```bash
git rm --cached -r agent/reports agent/feedback
# working tree files remain; 324 makes them ignored
printf '%s\n' '# Local ACP reports (ADR-27). Bodies are gitignored.' > agent/reports/README.md
printf '%s\n' '# Local ACP feedback (ADR-27). Bodies are gitignored.' > agent/feedback/README.md
touch agent/reports/.gitkeep agent/feedback/.gitkeep
git add agent/reports/.gitkeep agent/reports/README.md agent/feedback/.gitkeep agent/feedback/README.md
git status --short | grep -E 'reports/|feedback/' | grep -v gitkeep | grep -v README || true
```

Do **not** `git add -f` any `audit-*.md`. Confirm local files still exist: `test -d agent/reports && ls agent/reports | head`.

### CB-4 — History rewrite (task-330)

**Never run `git filter-repo` in the daily worktree.** `filter-repo` strips the `origin` remote. Tags at `v6.32.4` still contain **171** report files until rewritten and force-pushed.

`develop` and `mainline` **diverged** after the M87 plan commit (`develop` ahead of `origin/mainline`). Rewrite a clone that has **both** branches, then force-push both **and** tags.

Mirror backup immediately before rewrite — **from this clone**, not GitHub (GitHub lacks unpushed `develop` and untracked files):

```bash
STAMP="$(date +%Y%m%dT%H%M%S)"
git clone --mirror "$(pwd)" "${HOME}/acp-enhanced-private/acp-enhanced-pre-rewrite-${STAMP}.git"
```

Throwaway rewrite clone from that **local** mirror. **Must use `--no-local`**: a default `git clone` of a path/file mirror hardlinks objects, and `filter-repo` then aborts with “not a fresh clone”. Do not `--force` that abort.

```bash
MIRROR="${HOME}/acp-enhanced-private/acp-enhanced-pre-rewrite-${STAMP}.git"
DAILY="$(pwd)"   # this repo’s worktree — the clone you did not rewrite
git clone --no-local "${MIRROR}" /tmp/acp-rewrite
cd /tmp/acp-rewrite
git branch -a
# install once: brew install git-filter-repo
git filter-repo --invert-paths --path agent/reports/ --path agent/feedback/
# filter-repo strips remotes. Copy THIS machine’s origin (may be a named SSH host, not git@github.com).
git remote add origin "$(git -C "${DAILY}" remote get-url origin)"
```

**Canonical push clone:** `/tmp/acp-rewrite` only. If a second copy exists (e.g. `acp-rewrite-ready`), trees can match while tip SHAs differ — force-push from **one** clone after replaying any later daily commits onto it.

`--invert-paths` removes those directories from **every** commit, including keepers from 328. Re-add keepers on the rewritten tip, commit, then **STOP**.

Operator must type exactly: `force-push develop mainline tags: yes`

Then (not `--force-with-lease` — lease fails after rewrite):

```bash
git push --force origin develop
git push --force origin mainline
git push --force origin --tags
```

### CB-5 — Fresh-clone proof (task-331)

Full clone, **not** `--depth=1`:

```bash
DAILY="$(pwd)"   # daily worktree, after force-push + re-clone
git clone "$(git -C "${DAILY}" remote get-url origin)" /tmp/acp-fresh
cd /tmp/acp-fresh
git ls-files agent/reports agent/feedback
git log --all --full-history --oneline -- agent/reports/ agent/feedback/
git fetch origin mainline
git checkout mainline
git ls-files agent/reports agent/feedback
git log --all --full-history --oneline -- agent/reports/ agent/feedback/
```

Pass: keepers only in `ls-files`; log has no historical body paths (or only `.gitkeep`/`README.md`). Repeat for a tag that previously leaked (e.g. `git checkout v6.32.4` **after** tag rewrite) — must not restore 171 files.

### CB-6 — Never

- Start 322/324/327 before 333+334+323 restore tests pass
- `git add -f agent/reports/` or `git add -f agent/feedback/`
- `git rm` without `--cached` on those dirs
- `git clone --mirror git@github.com:...` as the **only** backup
- `git clone "${MIRROR}"` **without** `--no-local` before `filter-repo` (hardlink abort)
- Force-push from the daily unre-written worktree, or from a second rewrite clone with a different tip SHA
- `git push --force` without the exact confirmation phrase
- `git push --force-with-lease` after `filter-repo`
- Stamp F-118-01..03 after local `git rm` only
- Commit `agent/reports/audit-*.md` (including this milestone’s pre-impl report)
- Paste vendor org IDs, `$HOME` paths, or consumer spec bodies into remaining tracked files
