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

ACP Enhanced’s public `develop` and `mainline` (same tip) currently track **171 report files** and **37 feedback files**. audit-118 found:

- Vendor account identifiers in CodeRabbit raw dumps
- A full consumer application design spec
- Port-inbox copies of another project’s CI plus absolute `$HOME` paths

M72 **D9** required those directories to be tracked. That is unsafe for a public clone. Deleting files in a new commit does **not** remove blobs from GitHub history.

## Solution

**D1: Empty on remotes.** Public trees may keep `agent/reports/.gitkeep`, `agent/feedback/.gitkeep`, and a 10-line README each. No audit/review/handoff/inbox bodies.

**D2: Local writers stay.** `/acp-audit`, `/acp-report`, `/acp-review --report`, `/acp-integrity --report` still write under those dirs. Gitignore them (same class as drafts/clarifications).

**D3: Backup before destroy.** Encrypted local archive (or unpushed `git bundle`) of current `reports/` + `feedback/` **before** `git rm` or `filter-repo`. No rewrite without a restore test.

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

1. ADR-27 + this design (no secrets in the ADR).
2. Local archive + restore dry-run.
3. Gitignore + validator + E2E/command docs + pattern/install.
4. Redact `$HOME` / consumer internals in files that **remain** tracked.
5. `git rm` current tree (keep keepers).
6. `filter-repo` + operator-confirmed force-push.
7. Fresh-clone proof: `git log --all -- agent/reports` has no bodies.
8. Stamp F-118-* after the clone proof — not after local `git rm`.

## Anti-shortcuts

- Do not mark F-118-01..03 fixed after HEAD delete only.
- Do not commit new `audit-*.md` to origin during M87.
- Do not put FIFOZ/ChoreHive product internals into M87 docs.
- Do not skip the backup restore test.
- Review-006 (js-yaml, bootstrap, dispatch) is **out of scope**.

## Success

A stranger cloning `origin/mainline` cannot read historical or current audit/feedback bodies. The operator can restore them on another machine from the private pack.

---

## Operator cookbook (copy-paste — do not improvise)

Canonical commands for M87. Tasks cite **CB-N**. Check syntax by reading this block immediately before running. Do **not** substitute `git add -f`, `git rm` (without `--cached`), `git push --force-with-lease` after a rewrite, or `git clone --depth=1` for history proof.

### CB-1 — Content archive (task-323)

Run from the **repo root**. Write the ciphertext **outside** the clone. `age -p` prompts for a passphrase; do not put it in git.

```bash
BACKUP_DIR="${HOME}/acp-enhanced-private"
mkdir -p "${BACKUP_DIR}"
STAMP="$(date +%Y%m%d)"
TAR="/tmp/acp-rf-${STAMP}.tar.gz"
tar -C "$(pwd)" -czf "${TAR}" agent/reports agent/feedback
age -p -o "${BACKUP_DIR}/acp-reports-feedback-${STAMP}.tar.gz.age" "${TAR}"
rm -f "${TAR}"
```

Restore dry-run (must pass before 328/330):

```bash
STAMP="$(date +%Y%m%d)"   # use the stamp you actually wrote
RESTORE="/tmp/acp-restore-test"
rm -rf "${RESTORE}"
mkdir -p "${RESTORE}"
age -d -o "/tmp/acp-rf-restored.tar.gz" "${HOME}/acp-enhanced-private/acp-reports-feedback-${STAMP}.tar.gz.age"
tar -C "${RESTORE}" -xzf "/tmp/acp-rf-restored.tar.gz"
test -d "${RESTORE}/agent/reports"
test -d "${RESTORE}/agent/feedback"
find "${RESTORE}/agent/reports" | wc -l
find "${RESTORE}/agent/feedback" | wc -l
rm -f "/tmp/acp-rf-restored.tar.gz"
```

Expected counts (as of 2026-08-27 tip): **171** tracked report files + **37** tracked feedback files, plus any untracked local reports. Compare `git ls-files agent/reports | wc -l` **before** 328.

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
**Right:** `--cached` only, after CB-1 restore proof:

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

Mirror backup (outside GitHub):

```bash
git clone --mirror git@github.com:ssucipto/acp-enhanced.git "${HOME}/acp-enhanced-private/acp-enhanced-pre-rewrite.git"
```

Throwaway rewrite clone:

```bash
git clone git@github.com:ssucipto/acp-enhanced.git /tmp/acp-rewrite
cd /tmp/acp-rewrite
git fetch origin mainline
git branch mainline origin/mainline
# install once: brew install git-filter-repo
git filter-repo --invert-paths --path agent/reports/ --path agent/feedback/
# origin was removed; re-add
git remote add origin git@github.com:ssucipto/acp-enhanced.git
```

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
git clone git@github.com:ssucipto/acp-enhanced.git /tmp/acp-fresh
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

- `git add -f agent/reports/` or `git add -f agent/feedback/`
- `git rm` without `--cached` on those dirs
- `git push --force` without the exact confirmation phrase
- `git push --force-with-lease` after `filter-repo`
- Stamp F-118-01..03 after local `git rm` only
- Commit `agent/reports/audit-*.md` (including this milestone’s pre-impl report)
- Paste vendor org IDs, `$HOME` paths, or consumer spec bodies into remaining tracked files
