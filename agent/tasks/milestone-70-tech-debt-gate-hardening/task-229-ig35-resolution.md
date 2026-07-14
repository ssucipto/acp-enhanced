---
id: task-229
milestone: M70
title: "IG-35 implement or wiki descope (F-086-01)"
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-218
audit_findings: [F-086-01]
depends_on: []
---

## Objective

Resolve IG-35 phantom rule — either implement in git-provenance or remove from integrity-rules.md.

## Steps

1. Read IG-35 definition in `agent/wiki/integrity-rules.md`
2. If implementable in <2h: add to `acp.git-provenance.sh`
3. Else: mark IG-35 as "documented, not enforced" in wiki + skill
4. E2E fixture if implemented

## Verification

- [ ] Wiki and script headers agree on IG-35 status
- [ ] F-086-01 carryover fixed
