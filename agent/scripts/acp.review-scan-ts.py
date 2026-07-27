#!/usr/bin/env python3
"""TS/JS rule engine for acp.review-scan.sh (M83 task-282).

Emits TSV lines: line\\trule\\tmessage\\tseverity
Neutralises comments/strings before non-secret rules (F-103-01).
SC-01 uses comment-only stripping so string secrets remain visible.
EH-01 uses token-boundary \\btry\\b / \\.catch\\s*( (F-103-02).
"""
from __future__ import annotations

import os
import re
import sys


def neutralize(src: str, *, strip_strings: bool) -> str:
    """Replace comments (and optionally strings) with spaces; keep newlines/length."""
    out: list[str] = []
    i = 0
    n = len(src)
    while i < n:
        ch = src[i]
        nxt = src[i + 1] if i + 1 < n else ""

        if ch == "/" and nxt == "/":
            out.extend((" ", " "))
            i += 2
            while i < n and src[i] != "\n":
                out.append(" ")
                i += 1
            continue

        if ch == "/" and nxt == "*":
            out.extend((" ", " "))
            i += 2
            while i < n:
                if src[i] == "*" and i + 1 < n and src[i + 1] == "/":
                    out.extend((" ", " "))
                    i += 2
                    break
                out.append("\n" if src[i] == "\n" else " ")
                i += 1
            continue

        if strip_strings and ch in ("'", '"', "`"):
            quote = ch
            out.append(" ")
            i += 1
            while i < n:
                c = src[i]
                if c == "\\" and i + 1 < n:
                    out.extend((" ", " "))
                    i += 2
                    continue
                if c == quote:
                    out.append(" ")
                    i += 1
                    break
                # Keep ${...} interpolation as code (real tokens may appear there)
                if quote == "`" and c == "$" and i + 1 < n and src[i + 1] == "{":
                    out.extend((" ", " "))
                    i += 2
                    depth = 1
                    while i < n and depth > 0:
                        if src[i] == "{":
                            depth += 1
                            out.append(src[i])
                            i += 1
                        elif src[i] == "}":
                            depth -= 1
                            out.append(src[i] if depth > 0 else " ")
                            i += 1
                        elif src[i] == "\n":
                            out.append("\n")
                            i += 1
                        else:
                            out.append(src[i])
                            i += 1
                    continue
                out.append("\n" if c == "\n" else " ")
                i += 1
            continue

        out.append(ch)
        i += 1
    return "".join(out)


def scan(text: str) -> None:
    code = neutralize(text, strip_strings=True)
    code_sc = neutralize(text, strip_strings=False)

    sc_pat1 = re.compile(
        r'(API_KEY|api[_-]?key|jwtSecret|databasePassword)\s*=\s*["\'][^"\']+["\']'
    )
    sc_pat2 = re.compile(r'(password|secret)\s*:\s*["\'][^"\']+["\']', re.I)
    ts01 = re.compile(r":\s*any\b|as\s+any\b")
    ts02_export = re.compile(r"^export (async )?function [a-zA-Z0-9_]+\([^)]*\)\s*\{")
    ts02_ret = re.compile(r"\)\s*:\s*[A-Za-z{\[]")
    ap01_res = re.compile(r"res\.(json|send)\([^)]*\)")
    ap01_env = re.compile(r'(data\s*:|"data"\s*:)')
    nc01 = re.compile(r"^(const|let|var) [a-z]+_[a-z0-9_]*\s*=")

    sc_lines = code_sc.splitlines()
    code_lines = code.splitlines()
    for line_num, (raw_sc, raw_code) in enumerate(zip(sc_lines, code_lines), start=1):
        if sc_pat1.search(raw_sc) or sc_pat2.search(raw_sc):
            print(f"{line_num}\tSC-01\thardcoded secret pattern\tCRITICAL")
        if ts01.search(raw_code):
            print(f"{line_num}\tTS-01\tany type usage\tHIGH")
        if ts02_export.match(raw_code) and not ts02_ret.search(raw_code):
            print(f"{line_num}\tTS-02\texported function missing return type\tHIGH")
        if ap01_res.search(raw_code) and not ap01_env.search(raw_code):
            print(f"{line_num}\tAP-01\tresponse missing data envelope\tHIGH")
        if nc01.match(raw_code):
            print(f"{line_num}\tNC-01\tsnake_case variable in TS/JS\tMEDIUM")

    for m in re.finditer(r"catch\s*\([^)]*\)\s*\{", code):
        start = m.end() - 1
        depth = 0
        i = start
        while i < len(code):
            if code[i] == "{":
                depth += 1
            elif code[i] == "}":
                depth -= 1
                if depth == 0:
                    body = code[start + 1 : i]
                    if not body.strip():
                        line = text[: m.start()].count("\n") + 1
                        print(f"{line}\tEH-02\tempty catch block\tHIGH")
                    break
            i += 1

    try_tok = re.compile(r"\btry\b")
    catch_tok = re.compile(r"\.catch\s*\(")
    for m in re.finditer(r"async\s+function\s+\w+[^{]*\{", code):
        start = m.end() - 1
        depth = 0
        i = start
        while i < len(code):
            if code[i] == "{":
                depth += 1
            elif code[i] == "}":
                depth -= 1
                if depth == 0:
                    body = code[start + 1 : i]
                    if not try_tok.search(body) and not catch_tok.search(body):
                        line = text[: m.start()].count("\n") + 1
                        print(f"{line}\tEH-01\tasync without try/catch\tHIGH")
                    break
            i += 1


def main() -> int:
    path = os.environ.get("ACP_REVIEW_FILE")
    if not path:
        print("ACP_REVIEW_FILE required", file=sys.stderr)
        return 2
    text = open(path, encoding="utf-8", errors="replace").read()
    scan(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
