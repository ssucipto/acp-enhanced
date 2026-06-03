<skill name="schemas" mention="@{schemas}">
<rules>
- All ACP schemas live in `agent/schemas/*.yaml` (not .yml)
- Schema files use JSON Schema-compatible structure validated by acp.yaml-validate.sh
- Every schema must have: `$schema`, `$id`, `title`, `description`, `type: object`
- Required fields must be listed in the top-level `required:` array
- Use `pattern:` for constrained string fields (e.g. version, namespace, name)
- Use `enum:` for fields with a fixed set of valid values
- Provide `examples:` on complex fields to guide authors
- Schema validator (acp.yaml-validate.sh) uses pure bash — no additionalProperties support
- Namespace validation: reserved names are `acp`, `local`, `core`, `system`, `global`
- Version strings must match semver: `^[0-9]+\.[0-9]+\.[0-9]+$`
- Package name pattern: `^[a-z][a-z0-9-]*$` (lowercase, hyphens, starts with letter)
</rules>

<patterns>
Schema file header:
```yaml
# agent/schemas/foo.schema.yaml
# Schema for ACP foo files
# Validated by: agent/scripts/acp.yaml-validate.sh

$schema: "https://json-schema.org/draft/2020-12/schema"
$id: "acp:schemas:foo"
title: "ACP Foo Schema"
description: "Validates foo.yaml files used by the ACP package system"
type: object

required:
  - name
  - version
  - description

properties:
  name:
    type: string
    pattern: "^[a-z][a-z0-9-]*$"
    description: "Package name — lowercase, hyphens only"
  version:
    type: string
    pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+$"
    description: "Semantic version string"
```

Configurable schema entry (for configurables.yaml):
```yaml
properties:
  my_preference:
    type: string
    enum: [option-a, option-b, option-c]
    default: option-a
    description: "What this preference controls"
    scope: [user, workspace, project]
```
</patterns>

<anti_patterns>
- NEVER use additionalProperties: false — the validator does not support it
- NEVER put validation logic in the schema that belongs in the script
- NEVER add properties without descriptions — every field needs a description
- NEVER use $ref across schema files — keep schemas self-contained
</anti_patterns>
</skill>
