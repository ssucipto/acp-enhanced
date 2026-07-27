---
id: task-286
milestone: M83
title: "Tier C rules — security batch (SC-03/08/10/13/14/15/16/18, AP-09)"
status: planned
priority: 5
complexity: high
estimated_hours: 6
created: 2026-07-27
started: null
completed: null
phase: 3
depends_on: [task-283, task-284]
audit_findings: []
files_affected:
  - agent/scripts/acp.review-scan.sh
  - tests/fixtures/review-corpus/
  - agent/wiki/coderabbit-policy-map-lite.md
---

## Objective

Ship the highest-severity Tier C deterministic rules first: dangerous sinks, CORS, config access, error leakage, dependency CVEs, lockfiles, weak hashing, cleartext transport, and token placement.

## Context

audit-102 Gap Analysis Tier C. **Gated on tasks 283 + 284** — these rules go onto the lexed foundation and each needs a corpus entry before it ships (binding sequencing rule).

Deliberately excluded from this batch: SC-01 secrets (task-290 decides strategy — do **not** grow hand-rolled regexes here).

## Steps

Implement, each with lexing applied and positive/negative corpus entries:

1. **SC-03** HIGH — `eval(`, `new Function(`, `setTimeout("…")`, `dangerouslySetInnerHTML` without sanitisation
2. **SC-08** HIGH — CORS wildcard: `origin: '*'` / `Access-Control-Allow-Origin: *`
3. **SC-10** MEDIUM — direct `process.env` access outside a config module (allowlist the config module path)
4. **SC-13** HIGH — `err.stack` / internal paths in a response body
5. **SC-14** HIGH — `npm audit --json | jq '.metadata.vulnerabilities'`; emit on high/critical > 0 (verified working)
6. **SC-15** HIGH — lockfile present and tracked (`git ls-files`); honour the framework/protocol qualifier already in `acp.review.md:239`
7. **SC-16** CRITICAL — `md5`/`sha1`/`sha256` used for password hashing
8. **SC-18** HIGH — `http://` targets excluding `localhost`/`127.0.0.1`/`0.0.0.0`
9. **AP-09** HIGH — auth token in a query string (`?token=`, `&access_token=`)

Then update the policy map with owners for each new rule.

## Verification

- [ ] Each rule has positive + negative corpus entries; aggregate precision ≥ 90%
- [ ] SC-14 handles no-lockfile and no-npm cases gracefully (no crash, no false finding)
- [ ] SC-15 does not fire on this repo — **because `scripts/package-lock.json` is tracked in git** (verified), not because of the framework/protocol qualifier (F-104-05)
- [ ] SC-10 allowlist prevents flagging the config module itself
- [ ] `--ci` still exits 1 only on CRITICAL/HIGH
- [ ] Policy map rows added

## User-Observable Acceptance

`/acp-review --rules security` reports 9 additional deterministic rule classes with measured precision.
