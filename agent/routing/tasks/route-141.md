---
id: route-141
title: Add acp-review entry to package.yaml
task_type: yaml-schema
milestone: M55
complexity: low
executor: copilot
context_required: [package.yaml, milestones/milestone-55-acp-review-command.md]
files_affected: [package.yaml]
tokens_est: 1500
tokens_actual:
created: 2026-06-07
completed:
override_reason: "audit-051 F-003 — command must be registered in package.yaml for installation and discovery"
---

# Route 141: Add package.yaml entry for /acp-review

Add acp-review entry to `package.yaml` commands section:

```yaml
  acp-review:
    name: acp-review
    description: Standards enforcement for code quality, security, and consistency
    directory: commands
    experimental: false
    requires: []
    scripts: []
```

This enables:
- `/acp-package-install` to discover the command
- `/acp-package-validate` to verify it
- `/acp-package-list` to display it
- Users to install the command as a standalone package
