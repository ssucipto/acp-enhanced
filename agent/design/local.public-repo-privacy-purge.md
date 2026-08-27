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
