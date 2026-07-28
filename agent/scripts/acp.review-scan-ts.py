#!/usr/bin/env python3
"""TS/JS rule engine for acp.review-scan.sh (M83 task-282).

Emits TSV lines: line\\trule\\tmessage\\tseverity
Neutralises comments/strings before non-secret rules (F-103-01).
SC-01 uses comment-only stripping so string secrets remain visible.
EH-01 uses token-boundary \\btry\\b / \\.catch\\s*( (F-103-02).

Lexer limitation (F-105-02): char-walker neutralisation only — not AST/tree-sitter.
Cannot reason about scope, types, or control flow; see acp.review.md § Scanner limitations.
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

EXPORT_FUNCTION_RE = re.compile(
    r"^[ \t]*export\s+(?:default\s+)?(?:async\s+)?function\b", re.M
)
EXPORT_ARROW_RE = re.compile(
    r"^[ \t]*export\s+(?:const|let|var)\s+[A-Za-z_$][A-Za-z0-9_$]*", re.M
)
FUNCTION_BLOCK_PATTERNS = (
    re.compile(
        r"(?:^|[^\w$])(?:export\s+)?(?:default\s+)?(?:async\s+)?function(?:\s+[A-Za-z_$][A-Za-z0-9_$]*)?[^{;]*\{",
        re.M,
    ),
    re.compile(
        r"(?:^|[^\w$])(?:export\s+)?(?:const|let|var)\s+[A-Za-z_$][A-Za-z0-9_$]*\s*=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][A-Za-z0-9_$]*)\s*=>\s*\{",
        re.M,
    ),
)
SC_SECRET_NAME = (
    r"(?:secret|token|credential|password|passphrase|api[_-]?key|"
    r"access[_-]?key|private[_-]?key|client[_-]?secret|"
    r"jwtSecret|databasePassword)"
)
SC_PREFIX_PATTERNS = (
    re.compile(r"\bgh(?:p|o|u|s|r)_[A-Za-z0-9_]{12,}\b"),
    re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b"),
    re.compile(r"\bxox(?:a|b|p|r|s)-[A-Za-z0-9-]{10,}\b"),
    re.compile(r"\bsk-[A-Za-z0-9_-]{10,}\b"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
)
SC_ASSIGN_PATTERNS = (
    re.compile(
        rf"(?i)\b{SC_SECRET_NAME}\b(?:\s*:\s*[^=\n]+)?\s*=\s*([\"'`])[^\"'`\n]{{4,}}\1"
    ),
    re.compile(rf"(?i)\b{SC_SECRET_NAME}\b\s*:\s*([\"'`])[^\"'`\n]{{4,}}\1"),
)


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


def offset_to_line(text: str, offset: int) -> int:
    return text[:offset].count("\n") + 1


def is_sc01_line(line: str) -> bool:
    if any(pattern.search(line) for pattern in SC_PREFIX_PATTERNS):
        return True
    return any(pattern.search(line) for pattern in SC_ASSIGN_PATTERNS)


def normalize_path(path: str) -> str:
    file_path = Path(path)
    try:
        return file_path.resolve().relative_to(Path.cwd().resolve()).as_posix()
    except ValueError:
        return file_path.as_posix()


def find_matching_brace(text: str, brace_start: int) -> int | None:
    depth = 0
    for idx in range(brace_start, len(text)):
        if text[idx] == "{":
            depth += 1
        elif text[idx] == "}":
            depth -= 1
            if depth == 0:
                return idx
    return None


def iter_blocks(text: str, pattern: re.Pattern[str]) -> list[tuple[re.Match[str], int, int, str]]:
    blocks: list[tuple[re.Match[str], int, int, str]] = []
    for match in pattern.finditer(text):
        brace_start = text.find("{", match.start(), match.end())
        if brace_start < 0:
            continue
        brace_end = find_matching_brace(text, brace_start)
        if brace_end is None:
            continue
        blocks.append((match, brace_start, brace_end, text[brace_start + 1 : brace_end]))
    return blocks


def has_explanatory_comment(raw_lines: list[str], line_index: int) -> bool:
    for idx in (line_index - 1, line_index):
        if idx < 0 or idx >= len(raw_lines):
            continue
        line = raw_lines[idx]
        if re.search(r"//|/\*|\*/|\*", line) and re.search(
            r"because|intentional|legacy|safe|guarantee|nonnull|non-null|cast|hook|task-\d+",
            line,
            re.I,
        ):
            return True
    return False


def is_cli_allowlisted(path: str) -> bool:
    if "/scripts/" in path or path.startswith("scripts/"):
        return True
    if path.startswith(("tests/fixtures/review-corpus/", "tests/fixtures/review-scan/")):
        return False
    return path.startswith(("scripts/", "tests/", "e2e/", "agent/benchmarks/"))


def is_config_allowlisted(path: str) -> bool:
    base = Path(path).name.lower()
    if is_cli_allowlisted(path):
        return True
    if "/config/" in path or base.startswith(("config.", "env.", "settings.")):
        return True
    return False


def extract_signature(text: str, start: int, kind: str) -> tuple[str, int | None]:
    """Collect an export signature, including multiline parameter lists."""
    i = start
    seen_paren = False
    paren_depth = 0
    param_close: int | None = None
    end_tokens = {"function": "{", "arrow": "=>"}
    max_len = 4000

    while i < len(text) and (i - start) < max_len:
        ch = text[i]
        nxt = text[i : i + 2]
        if ch == "(":
            seen_paren = True
            paren_depth += 1
        elif ch == ")" and paren_depth > 0:
            paren_depth -= 1
            if paren_depth == 0:
                param_close = i - start

        if kind == "arrow":
            if nxt == end_tokens[kind] and (not seen_paren or paren_depth == 0):
                return text[start : i + 2], param_close
        elif ch == end_tokens[kind] and seen_paren and paren_depth == 0:
            return text[start : i + 1], param_close
        i += 1

    return text[start:i], param_close


def has_explicit_return(signature: str, kind: str, param_close: int | None) -> bool:
    lhs, _, rhs = signature.partition("=")
    lhs_norm = " ".join(lhs.split())
    if re.search(r"\b(?:const|let|var)\s+[A-Za-z_$][A-Za-z0-9_$]*\s*:\s*.+$", lhs_norm):
        return True
    if param_close is None:
        return False

    tail_norm = " ".join(signature[param_close + 1 :].split())
    if kind == "function":
        return bool(re.match(r"^:\s*.+\{$", tail_norm))
    return bool(re.match(r"^:\s*.+=>$", tail_norm))


def scan_export_return_types(text: str) -> list[tuple[int, str, str, str]]:
    findings: list[tuple[int, str, str, str]] = []
    for pattern, kind in ((EXPORT_FUNCTION_RE, "function"), (EXPORT_ARROW_RE, "arrow")):
        for match in pattern.finditer(text):
            signature, param_close = extract_signature(text, match.start(), kind)
            if kind == "arrow" and "=>" not in signature:
                continue
            if has_explicit_return(signature, kind, param_close):
                continue
            findings.append(
                (
                    offset_to_line(text, match.start()),
                    "TS-02",
                    "exported function missing return type",
                    "HIGH",
                )
            )
    return findings


def scan_unused_imports(raw_text: str, code: str) -> list[tuple[int, str, str, str]]:
    findings: list[tuple[int, str, str, str]] = []
    import_re = re.compile(
        r"^\s*import\s+(?!type\b)(.+?)\s+from\s+['\"][^'\"]+['\"]\s*;?\s*$",
        re.M,
    )
    for match in import_re.finditer(raw_text):
        clause = match.group(1).strip()
        body = code[match.end() :]
        names: list[str] = []
        if clause.startswith("{"):
            named = clause.strip("{} ")
            names.extend(
                part.split(" as ")[-1].strip()
                for part in named.split(",")
                if part.strip()
            )
        elif clause.startswith("* as "):
            names.append(clause[5:].strip())
        elif "," in clause:
            default_name, rest = clause.split(",", 1)
            if default_name.strip():
                names.append(default_name.strip())
            rest = rest.strip()
            if rest.startswith("{"):
                named = rest.strip("{} ")
                names.extend(
                    part.split(" as ")[-1].strip()
                    for part in named.split(",")
                    if part.strip()
                )
        elif clause:
            names.append(clause)

        for name in names:
            if name and not re.search(rf"\b{re.escape(name)}\b", body):
                findings.append(
                    (
                        offset_to_line(raw_text, match.start()),
                        "CH-07",
                        f"imported identifier '{name}' is never used",
                        "LOW",
                    )
                )
    return findings


def scan_filename_rule(path: str) -> list[tuple[int, str, str, str]]:
    findings: list[tuple[int, str, str, str]] = []
    stem = Path(path).stem
    suffix = Path(path).suffix.lower()
    if suffix in {".tsx", ".jsx"}:
        if not re.match(r"^[A-Z][A-Za-z0-9]*$", stem):
            findings.append((1, "NC-04", "React component filename should be PascalCase", "LOW"))
    elif suffix in {".ts", ".js", ".mjs", ".cjs"}:
        if not re.match(r"^[a-z0-9]+(?:-[a-z0-9]+)*$", stem):
            findings.append((1, "NC-04", "module filename should be kebab-case", "LOW"))
    return findings


def scan_blocks(text: str, code: str) -> list[tuple[int, str, str, str]]:
    findings: list[tuple[int, str, str, str]] = []

    for pattern in FUNCTION_BLOCK_PATTERNS:
        for match, _brace_start, brace_end, _body in iter_blocks(code, pattern):
            start_line = offset_to_line(text, match.start())
            end_line = offset_to_line(text, brace_end)
            if (end_line - start_line + 1) > 50:
                findings.append((start_line, "CH-03", "function exceeds 50 lines", "MEDIUM"))

    for match, _brace_start, _brace_end, body in iter_blocks(
        code, re.compile(r"catch\s*\([^)]*\)\s*\{")
    ):
        line = offset_to_line(text, match.start())
        if not body.strip():
            findings.append((line, "EH-02", "empty catch block", "HIGH"))
            continue
        trimmed = re.sub(r"console\.(?:log|error|warn)\s*\([^;]*\)\s*;?", "", body)
        trimmed = re.sub(r"[\s;]+", "", trimmed)
        if (
            re.search(r"console\.(?:log|error|warn)\s*\(", body)
            and "throw" not in body
            and "return" not in body
            and not trimmed
        ):
            findings.append((line, "EH-03", "catch block only logs error", "HIGH"))

    try_tok = re.compile(r"\btry\b")
    catch_tok = re.compile(r"\.catch\s*\(")
    for match, _brace_start, _brace_end, body in iter_blocks(
        code, re.compile(r"async\s+function\s+\w+[^{]*\{")
    ):
        if not try_tok.search(body) and not catch_tok.search(body):
            findings.append(
                (
                    offset_to_line(text, match.start()),
                    "EH-01",
                    "async without try/catch",
                    "HIGH",
                )
            )

    for match, _brace_start, _brace_end, body in iter_blocks(
        code, re.compile(r"finally\s*\{")
    ):
        if re.search(r"\breturn\b", body):
            findings.append(
                (
                    offset_to_line(text, match.start()),
                    "EH-07",
                    "finally block returns and masks errors",
                    "MEDIUM",
                )
            )

    for match, _brace_start, _brace_end, body in iter_blocks(
        code, re.compile(r"class\s+[A-Za-z_$][A-Za-z0-9_$]*\s+extends\s+Error\s*\{")
    ):
        if "this.name" not in body:
            findings.append(
                (
                    offset_to_line(text, match.start()),
                    "EH-08",
                    "custom error class missing this.name assignment",
                    "LOW",
                )
            )

    hook_call = re.compile(r"\buse[A-Z][A-Za-z0-9_]*\s*\(")
    hook_patterns = (
        re.compile(r"export\s+function\s+([A-Za-z_$][A-Za-z0-9_$]*)[^{;]*\{", re.M),
        re.compile(
            r"export\s+(?:const|let|var)\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][A-Za-z0-9_$]*)\s*=>\s*\{",
            re.M,
        ),
    )
    for pattern in hook_patterns:
        for match, _brace_start, _brace_end, body in iter_blocks(code, pattern):
            name = match.group(1)
            if not name.startswith("use") and hook_call.search(body):
                findings.append(
                    (
                        offset_to_line(text, match.start()),
                        "NC-09",
                        f"hook-like exported function '{name}' should start with use",
                        "MEDIUM",
                    )
                )

    promise_all = re.compile(r"Promise\.all\s*\(")
    for pattern in FUNCTION_BLOCK_PATTERNS:
        for _match, brace_start, _brace_end, body in iter_blocks(code, pattern):
            for promise_match in promise_all.finditer(body):
                snippet = body[promise_match.start() : promise_match.start() + 200]
                prev = body[max(0, promise_match.start() - 200) : promise_match.start()]
                if ".catch(" in snippet or re.search(r"\btry\b", prev):
                    continue
                findings.append(
                    (
                        offset_to_line(text, brace_start + 1 + promise_match.start()),
                        "EH-04",
                        "Promise.all without try/catch or .catch",
                        "HIGH",
                    )
                )

    return findings


def scan(text: str, path: str) -> list[tuple[int, str, str, str]]:
    findings: list[tuple[int, str, str, str]] = []
    code = neutralize(text, strip_strings=True)
    code_sc = neutralize(text, strip_strings=False)
    raw_lines = text.splitlines()
    sc_lines = code_sc.splitlines()
    code_lines = code.splitlines()

    ts01 = re.compile(
        r":\s*any\b|as\s+any\b|\b[A-Za-z_$][A-Za-z0-9_$.]*\s*<[^>\n]*\bany\b[^>\n]*>"
    )
    ap01_res = re.compile(r"res\.(?:status\([^)]*\)\.)?(json|send)\([^)]*\)")
    ap01_env = re.compile(r'(\{\s*data\b|data\s*:|"data"\s*:)')
    nc01 = re.compile(r"^[ \t]*(const|let|var) [a-z]+_[a-z0-9_]*\s*=")
    sc03 = re.compile(
        r"\beval\s*\(|\bnew\s+Function\s*\(|\bset(?:Timeout|Interval)\s*\(\s*['\"`]"
    )
    sc08 = re.compile(
        r"origin\s*:\s*['\"]\*['\"]|Access-Control-Allow-Origin\s*['\"]?\s*[:=,]\s*['\"]\*['\"]"
    )
    sc10 = re.compile(r"\bprocess\.env(?:\.[A-Za-z0-9_]+|\[[^\]]+\])")
    sc13 = re.compile(r"\b(err|error)\.stack\b|__dirname|process\.cwd\s*\(")
    sc16 = re.compile(
        r"\b(md5|sha1|sha256)\b|\bcreateHash\s*\(\s*['\"](?:md5|sha1|sha256)['\"]"
    )
    sc18 = re.compile(r"http://(?!localhost|127\.0\.0\.1|0\.0\.0\.0)")
    ap09 = re.compile(r"[?&](?:token|access_token)=")
    ch01 = re.compile(r"(//|/\*+|\*)\s*(TODO|FIXME)\b", re.I)
    ch06 = re.compile(r"\bconsole\.(log|debug)\s*\(")
    ts03 = re.compile(r"\bas\s+any\b")
    ts04 = re.compile(
        r"\b[A-Za-z_$][A-Za-z0-9_$]*(?:\[[^\]]+\]|\([^)]*\))?![.\[);,:]"
    )
    ts06 = re.compile(r"^\s*(?:export\s+)?enum\s+[A-Za-z_$][A-Za-z0-9_$]*\b")
    ts07 = re.compile(r"catch\s*\(\s*[A-Za-z_$][A-Za-z0-9_$]*\s*\)")
    nc02 = re.compile(
        r"^\s*(?:export\s+)?(class|interface|type)\s+([A-Za-z_$][A-Za-z0-9_$]*)\b"
    )
    nc06_decl = re.compile(r"^\s*(?:const|let|var)\s+([A-Za-z])\b")

    for line_num, (raw_line, raw_sc, raw_code) in enumerate(
        zip(raw_lines, sc_lines, code_lines), start=1
    ):
        if is_sc01_line(raw_sc):
            findings.append((line_num, "SC-01", "hardcoded secret pattern", "CRITICAL"))
        if ts01.search(raw_code):
            findings.append((line_num, "TS-01", "any type usage", "HIGH"))
        if ap01_res.search(raw_code) and not ap01_env.search(raw_code):
            findings.append((line_num, "AP-01", "response missing data envelope", "HIGH"))
        if nc01.match(raw_code):
            findings.append((line_num, "NC-01", "snake_case variable in TS/JS", "MEDIUM"))
        if sc03.search(raw_code) or (
            "dangerouslySetInnerHTML" in raw_code and "sanitize" not in raw_code
        ):
            findings.append((line_num, "SC-03", "dangerous sink usage", "HIGH"))
        if sc08.search(raw_sc):
            findings.append((line_num, "SC-08", "CORS wildcard configuration", "HIGH"))
        if sc10.search(raw_code) and not is_config_allowlisted(path):
            findings.append(
                (
                    line_num,
                    "SC-10",
                    "direct process.env access outside config module",
                    "MEDIUM",
                )
            )
        if sc13.search(raw_sc) and "res." in raw_code:
            findings.append((line_num, "SC-13", "error response leaks stack or internal path", "HIGH"))
        if sc16.search(raw_line) and re.search(r"password|passwd|pwd", raw_line, re.I):
            findings.append((line_num, "SC-16", "weak password hashing", "CRITICAL"))
        if sc18.search(raw_line):
            findings.append((line_num, "SC-18", "cleartext HTTP target", "HIGH"))
        if ap09.search(raw_sc):
            findings.append((line_num, "AP-09", "auth token present in query string", "HIGH"))
        if ch01.search(raw_line) and not re.search(r"task-\d+", raw_line, re.I):
            findings.append((line_num, "CH-01", "TODO/FIXME missing linked task id", "MEDIUM"))
        if ch06.search(raw_code) and not is_cli_allowlisted(path):
            findings.append((line_num, "CH-06", "console.log/debug in production path", "LOW"))
        if ts03.search(raw_code) and not has_explanatory_comment(raw_lines, line_num - 1):
            findings.append((line_num, "TS-03", "as any without explanatory comment", "MEDIUM"))
        if ts04.search(raw_code) and not has_explanatory_comment(raw_lines, line_num - 1):
            findings.append(
                (
                    line_num,
                    "TS-04",
                    "non-null assertion without explanatory comment",
                    "MEDIUM",
                )
            )
        if ts06.search(raw_code):
            findings.append((line_num, "TS-06", "plain enum used instead of const enum or union", "LOW"))
        if ts07.search(raw_code) and path.endswith((".ts", ".tsx")):
            findings.append((line_num, "TS-07", "catch clause should type error as unknown", "MEDIUM"))
        nc02_match = nc02.match(raw_code)
        if nc02_match:
            name = nc02_match.group(2)
            if not re.match(r"^[A-Z][A-Za-z0-9]*$", name):
                findings.append(
                    (
                        line_num,
                        "NC-02",
                        f"{nc02_match.group(1)} '{name}' should be PascalCase",
                        "MEDIUM",
                    )
                )
        if nc06_decl.match(raw_code):
            findings.append((line_num, "NC-06", "single-character identifier outside for-loop index", "LOW"))
        if re.search(r"function\b.*\(([A-Za-z])\)\s*\{", raw_code):
            findings.append((line_num, "NC-06", "single-character function parameter", "LOW"))

    findings.extend(scan_export_return_types(code))
    findings.extend(scan_blocks(text, code))
    findings.extend(scan_unused_imports(text, code))
    findings.extend(scan_filename_rule(path))
    findings.sort(key=lambda item: (item[0], item[1], item[2]))
    return findings


def main() -> int:
    file_path = os.environ.get("ACP_REVIEW_FILE")
    if not file_path:
        print("ACP_REVIEW_FILE required", file=sys.stderr)
        return 2
    text = Path(file_path).read_text(encoding="utf-8", errors="replace")
    rel_path = normalize_path(file_path)
    for line_num, rule, message, severity in scan(text, rel_path):
        print(f"{line_num}\t{rule}\t{message}\t{severity}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
