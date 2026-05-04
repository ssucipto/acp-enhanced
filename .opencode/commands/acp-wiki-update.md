---
description: Update a wiki file section after architectural or domain changes
---

Update wiki for: {{input}}

1. Determine which wiki file is affected:
   - ACP command structure / architecture changes → `.agent/wiki/architecture.md`
   - Domain entities (command types, task types, patterns) → `.agent/wiki/domain.yml`
   - Package/script integration patterns → `.agent/wiki/architecture.md`
2. Read the CURRENT content of the relevant section only
3. Update ONLY the affected section — do not rewrite other sections
4. Update `last_verified` date in the file header
5. Confirm: "[ACP] Wiki updated: [file] | section: [section] | [date]"
