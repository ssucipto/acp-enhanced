#!/usr/bin/env python3
"""
ACP Marker Backfill -- Batch add @acp.meta.* markers to design, task, and pattern files.

Usage:
    python scripts/acp-backfill-markers.py [--dry-run] [--area design|tasks|patterns|all]

Extracts metadata from prose frontmatter (headings, **Status:**, **Created:**, etc.)
and inserts an @acp.meta.* marker block after the first '# ' heading.
Also strips superseded prose fields.
"""

import argparse
import os
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATS = {"added": 0, "skipped": 0, "errors": 0}

# Avoid Unicode on Windows CP1252
CHECK = "[OK]"
CROSS = "[X]"
ARROW = "->"
SKIP = "--"
SEP = "=" * 50


def has_marker(content: str) -> bool:
    return any("@acp.meta" in line for line in content.split("\n")[:20])


def is_template(path: Path) -> bool:
    return ".template." in path.name


def first_heading(content: str) -> str:
    for line in content.split("\n"):
        if line.startswith("# ") and not line.startswith("##"):
            return line[2:].strip()
    # Fallback to first ## heading (for YAML-frontmatter files)
    for line in content.split("\n"):
        if line.startswith("## ") and not line.startswith("###"):
            return line[3:].strip()
    return ""


def yaml_frontmatter_field(content: str, field: str) -> str:
    """Extract a field from YAML frontmatter block (`--- ... ---`)."""
    lines = content.split("\n")
    if not lines or lines[0].strip() != "---":
        return ""
    in_fm = True
    for line in lines[1:]:
        if line.strip() == "---":
            break
        m = re.match(r"^" + re.escape(field) + r":\s*(.*)", line)
        if m:
            return m.group(1).strip()
    return ""


def prose_field(content: str, field: str) -> str:
    lines = content.split("\n")[:30]
    pattern = re.compile(r"^\*\*" + re.escape(field) + r"\*\*:\s*(.*)", re.MULTILINE)
    m = pattern.search("\n".join(lines))
    return m.group(1).strip() if m else ""


def to_keywords(title: str) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9\s-]", "", title)
    return ", ".join(cleaned.lower().split())


def extract_description(content: str) -> str:
    concept = prose_field(content, "Concept")
    if concept:
        return concept[:150]
    parts = content.split("## Overview")
    if len(parts) > 1:
        para = parts[1].strip().split("\n\n")[0]
        para = re.sub(r"^#+\s*", "", para).strip()
        para = re.sub(r"\*\*.*?\*\*", "", para).strip()
        if para:
            return para[:150]
    # Try YAML frontmatter title
    title = yaml_frontmatter_field(content, "title")
    if title:
        return title[:150]
    return first_heading(content)[:150]


def extract_status(content: str) -> str:
    s = prose_field(content, "Status").lower()
    if "implement" in s or "active" in s:
        return "active"
    if "complete" in s:
        return "completed"
    if "in progress" in s or "in_progress" in s:
        return "in_progress"
    return "draft"


def extract_updated(content: str) -> str:
    for field in ("Last Updated", "Created"):
        val = prose_field(content, field)
        if val and re.match(r"\d{4}-\d{2}-\d{2}", val):
            return val
    # YAML frontmatter created date
    yaml_created = yaml_frontmatter_field(content, "created")
    if yaml_created and re.match(r"\d{4}-\d{2}-\d{2}", yaml_created):
        return yaml_created
    return date.today().isoformat()


def milestone_from_path(path: Path) -> str:
    for part in path.parts:
        m = re.search(r"milestone-(\d+)", part)
        if m:
            return f"M{m.group(1)}"
    return ""


def gen_design_marker(content: str) -> str:
    h = first_heading(content)
    lines = [
        "",
        "<!-- @acp.meta.design",
        f"topic: {to_keywords(h)}",
        f"description: {extract_description(content)}",
        f"status: {extract_status(content)}",
        f"updated: {extract_updated(content)}",
        "@acp.meta.end -->",
    ]
    return "\n".join(lines)


def gen_task_marker(content: str, path: Path) -> str:
    h = first_heading(content)
    h_clean = re.sub(r"^Task\s+\d+:\s*", "", h)
    # For YAML-frontmatter files, prefer title: field over generic headings like "Objective"
    yaml_title = yaml_frontmatter_field(content, "title") or ""
    if yaml_title and (not h_clean or h_clean.lower() in ("objective", "overview", "context", "implementation", "goal")):
        h_clean = yaml_title
    ms = milestone_from_path(path)
    if not ms:
        ms = yaml_frontmatter_field(content, "milestone") or ""
    yaml_status = yaml_frontmatter_field(content, "status") or ""
    pstatus = extract_status(content)
    if not pstatus or pstatus == "draft":
        pstatus = yaml_status if yaml_status in ("active", "completed", "in_progress", "draft") else pstatus
    lines = [
        "",
        "<!-- @acp.meta.task",
        f"topic: {to_keywords(h_clean)}",
        f"description: {extract_description(content) or h_clean}",
        f"milestone: {ms}",
        f"status: {pstatus}",
        f"updated: {extract_updated(content)}",
        "@acp.meta.end -->",
    ]
    return "\n".join(lines)


def gen_pattern_marker(content: str) -> str:
    h = first_heading(content)
    lines = [
        "",
        "<!-- @acp.meta.pattern",
        f"topic: {to_keywords(h)}",
        f"description: {extract_description(content)}",
        "applies_to: testing, quality",
        "status: active",
        f"updated: {date.today().isoformat()}",
        "@acp.meta.end -->",
    ]
    return "\n".join(lines)


def strip_marker_block(content: str) -> str:
    """Remove existing @acp.meta.* marker block.
    Only matches actual marker comment blocks: <!-- @acp.meta.<kind> ... @acp.meta.end -->
    Does NOT match arbitrary text containing @acp.meta.task (body prose).
    """
    lines = content.split("\n")
    result = []
    skip = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("<!-- @acp.meta."):
            skip = True
        if not skip:
            result.append(line)
        if "@acp.meta.end" in stripped and skip:
            skip = False
    return "\n".join(result)


def insert_after_heading(content: str, marker: str) -> str:
    """Insert marker block after the first # heading, or after YAML frontmatter closure."""
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("# ") and not line.startswith("##"):
            lines.insert(i + 1, marker)
            return "\n".join(lines)
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], 1):
            if line.strip() == "---":
                lines.insert(i + 1, marker)
                return "\n".join(lines)
    lines.insert(1, marker)
    return "\n".join(lines)


def strip_superseded_fields(content: str) -> str:
    in_frontmatter = True
    result = []
    for line in content.split("\n"):
        if line.strip() == "---" and in_frontmatter:
            in_frontmatter = False
            result.append(line)
            continue
        if in_frontmatter and re.match(r"^\*\*Status\*\*:", line):
            continue
        result.append(line)
    return "\n".join(result)


def process_area(kind: str, label: str, glob_pattern: str, dry_run: bool, force: bool = False):
    print(f"--- {label} ---")
    files = sorted(ROOT.glob(glob_pattern))
    to_process = []

    for f in files:
        if "benchmarks" in f.parts:
            continue
        if is_template(f):
            print(f"  {SKIP} {f.name} (template)")
            STATS["skipped"] += 1
            continue
        content = f.read_text(encoding="utf-8")
        if not force and has_marker(content):
            print(f"  {SKIP} {f.name} (already has marker)")
            STATS["skipped"] += 1
            continue
        to_process.append((f, content))

    print(f"  Found {len(to_process)} files to process")

    for f, content in to_process:
        rel = f.relative_to(ROOT)
        print(f"  {ARROW} {rel}")
        if not dry_run:
            try:
                if force:
                    content = strip_marker_block(content)
                if kind == "design":
                    marker = gen_design_marker(content)
                elif kind == "task":
                    marker = gen_task_marker(content, f)
                elif kind == "pattern":
                    marker = gen_pattern_marker(content)
                new_content = insert_after_heading(content, marker)
                new_content = strip_superseded_fields(new_content)
                f.write_text(new_content, encoding="utf-8")
            except Exception as e:
                print(f"  {CROSS} ERROR: {e}")
                STATS["errors"] += 1
                continue
        STATS["added"] += 1


def main():
    parser = argparse.ArgumentParser(description="ACP Marker Backfill")
    parser.add_argument("--dry-run", action="store_true", help="Show changes without modifying")
    parser.add_argument("--force", action="store_true", help="Overwrite existing markers")
    parser.add_argument("--area", choices=["design", "tasks", "patterns", "all"], default="all")
    args = parser.parse_args()

    print(SEP)
    print("  ACP Marker Backfill")
    print(f"  Mode: {'DRY RUN' if args.dry_run else 'LIVE'} | Area: {args.area}")
    print(SEP)
    print()

    os.chdir(ROOT)
    if args.area in ("all", "design"):
        process_area("design", "Design files", "agent/design/*.md", args.dry_run, args.force)
    if args.area in ("all", "tasks"):
        process_area("task", "Task files", "agent/tasks/**/*.md", args.dry_run, args.force)
    if args.area in ("all", "patterns"):
        process_area("pattern", "Pattern files", "agent/patterns/*.md", args.dry_run, args.force)

    print()
    print(SEP)
    print(f"  Summary: Added={STATS['added']}  Skipped={STATS['skipped']}  Errors={STATS['errors']}")
    print(SEP)
    if args.dry_run:
        print("  Dry run complete. Run without --dry-run to apply.")
    return 1 if STATS["errors"] > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
