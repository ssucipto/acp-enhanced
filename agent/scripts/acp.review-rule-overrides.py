#!/usr/bin/env python3
"""Load merged review.rule_overrides for acp.integrity-output.sh (M84 / F-105-01)."""

from __future__ import annotations

import json
import os
import sys


def load_yaml(path: str) -> dict:
    if not path or not os.path.isfile(path):
        return {}
    try:
        import yaml  # type: ignore
    except ImportError:
        if path.endswith((".yaml", ".yml")):
            print(
                f"[ACP] warning: PyYAML required to read rule_overrides from {path}; "
                "use IG_RULE_OVERRIDES_JSON or a .json override file",
                file=sys.stderr,
            )
        return {}
    with open(path, encoding="utf-8") as fh:
        data = yaml.safe_load(fh) or {}
    return data if isinstance(data, dict) else {}


def extract_overrides(data: dict) -> dict:
    if not isinstance(data, dict):
        return {}
    acp = data.get("acp") or {}
    review = acp.get("review") or {}
    overrides = review.get("rule_overrides") or {}
    if not isinstance(overrides, dict):
        return {}
    if "id" in overrides and "type" in overrides:
        default = overrides.get("default") or {}
        return default if isinstance(default, dict) else {}
    return overrides


def merge_rule(rule_id: str, cfg: dict, merged: dict) -> None:
    if not isinstance(cfg, dict):
        return
    rule = str(rule_id).upper()
    entry = merged.setdefault(rule, {})
    if "enabled" in cfg:
        enabled = cfg["enabled"]
        if isinstance(enabled, bool):
            entry["enabled"] = enabled
        else:
            entry["enabled"] = str(enabled).lower() not in {"false", "0", "no", "off"}
    if cfg.get("severity"):
        sev = str(cfg["severity"]).upper()
        if sev in {"CRITICAL", "HIGH", "MEDIUM", "LOW"}:
            entry["severity"] = sev


def main() -> int:
    prefs_root = sys.argv[1] if len(sys.argv) > 1 else "."
    override_file = sys.argv[2] if len(sys.argv) > 2 else ""
    override_json = os.environ.get("IG_RULE_OVERRIDES_JSON", "")

    merged: dict[str, dict] = {}

    for path in (
        os.path.join(prefs_root, "agent/configurables/acp.configurables.yaml"),
        os.path.expanduser("~/.acp/agent/preferences/acp.default.yaml"),
        os.path.join(prefs_root, ".vscode/preferences/acp.yaml"),
        os.path.join(prefs_root, "agent/preferences/acp.default.yaml"),
    ):
        overrides = extract_overrides(load_yaml(path))
        for rule_id, cfg in overrides.items():
            merge_rule(rule_id, cfg, merged)

    if override_file:
        if override_file.endswith(".json"):
            with open(override_file, encoding="utf-8") as fh:
                data = json.load(fh)
            if isinstance(data, dict) and "acp" in data:
                overrides = extract_overrides(data)
                for rule_id, cfg in overrides.items():
                    merge_rule(rule_id, cfg, merged)
            elif isinstance(data, dict):
                for rule_id, cfg in data.items():
                    merge_rule(rule_id, cfg, merged)
        else:
            overrides = extract_overrides(load_yaml(override_file))
            for rule_id, cfg in overrides.items():
                merge_rule(rule_id, cfg, merged)

    if override_json:
        try:
            payload = json.loads(override_json)
        except json.JSONDecodeError:
            payload = {}
        if isinstance(payload, dict):
            for rule_id, cfg in payload.items():
                merge_rule(rule_id, cfg, merged)

    for rule, cfg in sorted(merged.items()):
        if cfg.get("enabled") is False:
            print(f"DISABLED:{rule}")
        severity = cfg.get("severity")
        if severity:
            print(f"SEVERITY:{rule}|{severity}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
