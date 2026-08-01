#!/usr/bin/env python3
"""ACP single-pass preference resolver (M85 task-301).

Replaces four bash `yaml_get` calls (each a full `$( )` subshell re-parse —
see agent/scripts/acp.preferences.sh:get_preference) with one process that
reads all four layer files once and returns the resolved value.

PyYAML is NOT installed in this environment (several `integrity-v2` tests
already skip for that reason), so this vendors a minimal reader instead of
depending on it. It is a line-for-line reimplementation of the same
indentation-based subset parser in agent/scripts/acp.yaml-parser.sh
(yaml_parse/yaml_query) — not a general YAML parser. It matches that
parser's exact behaviour, including its simplifications (naive `:` and `#`
splitting, space-only indent counting), because this resolver must return
byte-identical results to the bash path, not "more correct" ones.

Precedence, replicated from get_preference() exactly (do not infer):
  1. project file       — key `{ns}.{pref_path}`,        flat-dot fallback
  2. workspace file      — key `{ns}.{pref_path}`,        flat-dot fallback
  3. user file            — key `{ns}.{pref_path}`,        flat-dot fallback
  4. configurables file  — key `{ns}.{pref_path}.default`, NO flat-dot fallback

No network access, no writes, no os.system — this runs on every preference read.

Usage:
  acp.pref-resolve.py <namespace> <pref_path> \\
      <project_file> <workspace_file> <user_file> <configurables_file>

Prints the resolved value on stdout and nothing else. Exit 0 = found,
exit 1 = not found at any level, exit 2 = usage error.
"""

import os
import re
import sys

_YAML_SPACE_TAB = " \t"


class _Node:
    __slots__ = ("type", "key", "value", "children")

    def __init__(self, type_, key, value):
        self.type = type_
        self.key = key
        self.value = value
        self.children = []  # list[int] — indices into the parse's node list


def _yaml_parse(path):
    """Mirrors yaml_parse() in acp.yaml-parser.sh. Returns a node list (index 0
    is the root map) or None if the file can't be read."""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            raw_lines = f.read().split("\n")
    except OSError:
        return None

    nodes = [_Node("map", "", "")]

    def create_node(type_, key, value):
        nodes.append(_Node(type_, key, value))
        return len(nodes) - 1

    parent_stack = [0]
    indent_stack = [-1]
    current_parent = 0
    prev_indent = -1
    last_key_node = -1

    for line in raw_lines:
        if line == "":
            continue
        if line.startswith("#"):
            continue
        if "#" in line:
            line = line.split("#", 1)[0]

        stripped_lead = line.lstrip(" ")
        indent = len(line) - len(stripped_lead)
        trimmed = stripped_lead
        if trimmed == "":
            continue

        while prev_indent >= 0 and indent <= prev_indent:
            parent_stack.pop()
            indent_stack.pop()
            current_parent = parent_stack[-1] if parent_stack else 0
            prev_indent = indent_stack[-1] if indent_stack else -1
            last_key_node = -1

        is_array_item = trimmed.startswith("- ") or trimmed.startswith("-\t") or trimmed == "-"

        if is_array_item:
            item_content = trimmed[1:].lstrip(_YAML_SPACE_TAB)

            if last_key_node >= 0:
                nodes[last_key_node].type = "array"
                current_parent = last_key_node
                last_key_node = -1

            if ":" in item_content:
                obj_idx = create_node("map", "", "")
                nodes[current_parent].children.append(obj_idx)

                key_part, _, val_part = item_content.partition(":")
                key = key_part.rstrip(_YAML_SPACE_TAB)
                value = val_part.lstrip(_YAML_SPACE_TAB)

                field_idx = create_node("scalar", key, value)
                nodes[obj_idx].children.append(field_idx)

                parent_stack.append(obj_idx)
                indent_stack.append(indent)
                current_parent = obj_idx
                prev_indent = indent
            else:
                item_idx = create_node("scalar", "", item_content)
                nodes[current_parent].children.append(item_idx)
        elif ":" in trimmed:
            key_part, _, val_part = trimmed.partition(":")
            key = key_part.rstrip(_YAML_SPACE_TAB)
            value = val_part.lstrip(_YAML_SPACE_TAB)

            if value == "":
                node_idx = create_node("map", key, "")
                nodes[current_parent].children.append(node_idx)
                parent_stack.append(node_idx)
                indent_stack.append(indent)
                current_parent = node_idx
                prev_indent = indent
                last_key_node = node_idx
            else:
                if value == "[]":
                    node_idx = create_node("array", key, "")
                elif value == "{}":
                    node_idx = create_node("map", key, "")
                else:
                    node_idx = create_node("scalar", key, value)
                nodes[current_parent].children.append(node_idx)
        # else: line has neither ':' nor is an array item — yaml_parse ignores it too.

    return nodes


def _find_child_by_key(nodes, parent_idx, key):
    for child_idx in nodes[parent_idx].children:
        if nodes[child_idx].key == key:
            return child_idx
    return None


def _yaml_query(nodes, dotted_path):
    """Mirrors yaml_query(). Returns the resolved string, or None if the path
    doesn't resolve (mirrors yaml_query returning nothing + exit 1)."""
    path = dotted_path[1:] if dotted_path.startswith(".") else dotted_path
    if path == "":
        return None

    current = 0
    for segment in path.split("."):
        if "[" in segment:
            key = segment.split("[", 1)[0]
            indices = re.findall(r"\[(\d*)\]", segment)
            index_str = indices[-1] if indices else ""
            current = _find_child_by_key(nodes, current, key)
            if current is None:
                return None
            if index_str == "" or not index_str.isdigit():
                return None
            index = int(index_str)
            children = nodes[current].children
            if index < 0 or index >= len(children):
                return None
            current = children[index]
        else:
            current = _find_child_by_key(nodes, current, segment)
            if current is None:
                return None

    node = nodes[current]
    if node.type in ("map", "array"):
        lines = []
        for child_idx in node.children:
            child = nodes[child_idx]
            if child.type == "scalar" and child.key == "":
                lines.append(child.value)
            else:
                lines.append(f"{child.key}:")
        return "\n".join(lines)
    return node.value


def yaml_get(file_path, dotted_path):
    """Mirrors yaml_get(): parse then query. Empty string on any failure —
    matches `$(yaml_get ... 2>/dev/null || true)` in the bash caller, where a
    failed/erroring call is indistinguishable from an empty result."""
    if not os.path.isfile(file_path):
        return ""
    nodes = _yaml_parse(file_path)
    if nodes is None:
        return ""
    result = _yaml_query(nodes, dotted_path)
    return result if result is not None else ""


def flat_dot_get(file_path, pref_path):
    """Mirrors _flat_dot_get(): grep -E "^[[:space:]]+<escaped path>:" | head -1
    | sed 's/^[^:]*:[[:space:]]*//' | tr -d "'\"" | tr -d '[:space:]'.

    Only the literal '.' characters are escaped, matching the bash
    `${pref_path//./\\.}` substitution exactly — not a full regex-escape."""
    if not os.path.isfile(file_path):
        return ""
    escaped = pref_path.replace(".", r"\.")
    pattern = re.compile(r"^[ \t]+" + escaped + r":")
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.rstrip("\n")
                if pattern.match(line):
                    value = line.split(":", 1)[1]
                    value = value.lstrip(" \t\r\n\v\f")
                    value = value.replace("'", "").replace('"', "")
                    value = re.sub(r"\s", "", value)
                    return value
    except OSError:
        return ""
    return ""


def _resolve_explicit_layer(file_path, namespace, pref_path):
    """Layers 1-3 (project/workspace/user): nested lookup, flat-dot fallback."""
    if not os.path.isfile(file_path):
        return None
    value = yaml_get(file_path, f"{namespace}.{pref_path}")
    if value == "":
        value = flat_dot_get(file_path, pref_path)
    return value if value != "" else None


def _resolve_configurables_layer(file_path, namespace, pref_path):
    """Layer 4 (configurables): nested lookup with `.default` suffix, NO
    flat-dot fallback — see get_preference() lines 124-133."""
    if not os.path.isfile(file_path):
        return None
    value = yaml_get(file_path, f"{namespace}.{pref_path}.default")
    return value if value != "" else None


def get_preference(namespace, pref_path, project_file, workspace_file, user_file, configurables_file):
    for layer_file in (project_file, workspace_file, user_file):
        value = _resolve_explicit_layer(layer_file, namespace, pref_path)
        if value is not None:
            return value
    return _resolve_configurables_layer(configurables_file, namespace, pref_path)


def main(argv):
    if len(argv) != 7:
        print(
            "Usage: acp.pref-resolve.py <namespace> <pref_path> "
            "<project_file> <workspace_file> <user_file> <configurables_file>",
            file=sys.stderr,
        )
        return 2

    namespace, pref_path = argv[1], argv[2]
    project_file, workspace_file, user_file, configurables_file = argv[3:7]

    result = get_preference(namespace, pref_path, project_file, workspace_file, user_file, configurables_file)
    if result is None:
        return 1
    sys.stdout.write(result + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
