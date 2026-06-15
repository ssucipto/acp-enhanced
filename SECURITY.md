# Security Policy

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in ACP Enhanced,
please **do not** open a public issue.

### Preferred: GitHub Private Security Advisories

1. Go to the [Security](https://github.com/ssucipto/acp-enhanced/security) tab
2. Click **"Report a vulnerability"**
3. Fill in the details — include reproduction steps, affected versions, and impact assessment

### Fallback Contact

If private advisories are unavailable, email the maintainer directly.
The email address is listed in `agent/core/identity.yml → team_members`.

**Note**: If the vulnerability is sensitive, please use encrypted email. The maintainer's
key is available via the standard keyserver at the team email address.

## Supported Versions

Only the latest release receives security fixes. We do not backport patches to older
versions.

| Version | Supported          |
|---------|--------------------|
| latest  | :white_check_mark: |
| < latest | :x:                |

## Scope

### In-Scope

Security issues in components that execute code or operate on untrusted input:

- Bootstrap and installation scripts (`agent/scripts/acp.install.sh`, `agent/scripts/acp.bootstrap.sh`)
- TypeScript dispatch engine (`scripts/acp-dispatch.ts`) — handles API keys, network requests, routing
- TypeScript validator (`scripts/acp-validate.ts`) — parses untrusted YAML
- Bash scanners (`agent/scripts/acp.*.sh` — Unicode, entropy, git-provenance, dependency-diff, network-whitelist)
- Command documents that execute scripts (`agent/commands/*.md` — Agent Directives invoked at runtime)
- CI/CD workflows (`.github/workflows/`) — exposed to repository events and PR contents
- The `/acp-integrity` security rule catalogue itself

See `agent/wiki/integrity-rules.md` for the full internal security baseline.

### Out-of-Scope

- Instance data or configuration stored in `~/.acp/` (user-managed)
- Third-party dependencies tracked by Dependabot (`.github/dependabot.yml`)
- Cosmetic issues in markdown documentation that do not execute code

## Response Targets

| Phase | Target |
|-------|--------|
| Acknowledgement | Within 5 business days |
| Triage / severity assessment | Within 10 business days |
| Fix shipped | Within 30 days for critical, 90 days for high |

## Disclosure Policy

- We follow **coordinated disclosure**: the reporter and maintainer agree on a public disclosure timeline after the fix is shipped.
- Credit is given to the reporter (with permission) in the release notes.
- No bounty program is in place at this time.

```text
Version: 6.20.9
```
