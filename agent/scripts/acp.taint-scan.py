"""Taint source/sink extractor for /acp-integrity Phase 2 (M58)."""
import os
import re
import sys
from pathlib import Path

SKIP = {"node_modules", ".git"}
EXT = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs"}

SOURCES = [
    (re.compile(r"req\.(query|body|params|headers)\b"), "SOURCE", "req"),
    (re.compile(r"process\.env\b"), "SOURCE", "process.env"),
    (re.compile(r"process\.argv\b"), "SOURCE", "process.argv"),
    (re.compile(r"window\.location\b"), "SOURCE", "window.location"),
]

SINKS = [
    (re.compile(r"\b(db|pool|connection)\.(query|raw|execute)\s*\("), "SINK", "db.query"),
    (re.compile(r"\b(child_process\.)?(exec|execSync|spawn|spawnSync)\s*\("), "SINK", "exec"),
    (re.compile(r"\bfs\.(readFile|readFileSync|writeFile|writeFileSync)\s*\("), "SINK", "fs"),
    (re.compile(r"\bres\.redirect\s*\("), "SINK", "redirect"),
    (re.compile(r"\beval\s*\("), "SINK", "eval"),
    (re.compile(r"\bfetch\s*\("), "SINK", "fetch"),
]

HEURISTICS = [
    (re.compile(r"(SELECT|INSERT|UPDATE|DELETE).*\+\s*(req\.|id\b)"), "IG-45", "user input concatenated into SQL"),
    (re.compile(r"(exec|spawn)\s*\(\s*[`'\"].*\$\{"), "IG-46", "shell command with dynamic interpolation"),
    (re.compile(r"readFile(Sync)?\s*\([^)]*req\.(query|body|params)"), "IG-47", "file path from user input"),
    (re.compile(r"path\.join\([^)]*req\.(query|body|params)"), "IG-47", "file path built from user input"),
    (re.compile(r"redirect\s*\(\s*req\.(query|body|params)"), "IG-48", "redirect from user input"),
    (re.compile(r"fetch\s*\(\s*process\.env"), "IG-49", "network call using raw environment URL"),
    (re.compile(r"(isAdmin|isTrusted|verified|authorized)\s*=\s*external"), "IG-50", "security decision trusts external output"),
]


def iter_files(root: Path):
    if root.is_file():
        yield root
        return
    for p in root.rglob("*"):
        if not p.is_file() or p.suffix.lower() not in EXT:
            continue
        if any(part in SKIP for part in p.parts):
            continue
        yield p


def scan(path: Path, markers: list, findings: list):
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()
    except OSError:
        return
    has_user_input = bool(re.search(r"req\.(query|body|params)", text))
    has_env = bool(re.search(r"process\.env", text))
    for i, line in enumerate(lines, 1):
        for pat, kind, label in SOURCES + SINKS:
            if pat.search(line):
                markers.append((str(path), i, kind, label))
        for pat, rule, msg in HEURISTICS:
            if pat.search(line):
                findings.append((str(path), i, rule, msg))
    if has_user_input and re.search(r"(SELECT|INSERT|UPDATE|DELETE).+\+", text, re.I):
        if not any(f[2] == "IG-45" for f in findings):
            findings.append((str(path), 1, "IG-45", "user input may flow to SQL concatenation"))
    if has_user_input and re.search(r"fs\.(readFile|readFileSync)", text):
        sanitized = bool(re.search(r"ALLOWED", text) and re.search(r"path\.resolve", text))
        if not sanitized and re.search(r"path\.join", text):
            if not any(f[2] == "IG-47" for f in findings):
                ln = next((i + 1 for i, l in enumerate(lines) if "readFile" in l), 1)
                findings.append((str(path), ln, "IG-47", "file path may derive from user input"))
    if has_user_input and re.search(r"res\.redirect", text):
        allowlisted = bool(re.search(r"ALLOWED_HOSTS|allowlist", text, re.I)) and bool(
            re.search(r"new URL", text)
        )
        if not allowlisted:
            if not any(f[2] == "IG-48" for f in findings):
                ln = next((i + 1 for i, l in enumerate(lines) if re.search(r"res\.redirect", l)), 1)
                findings.append((str(path), ln, "IG-48", "redirect may use unvalidated user URL"))
    if re.search(r"req\.session\.(isAdmin|isTrusted)|\.isAdmin\s*=\s*true", text):
        external = bool(re.search(r"result\.(valid|authorized|trusted)|checkLicense|vendor-", text))
        local_verify = bool(
            re.search(r"verifyAdminEntitlement|revalid|local.*policy|verify.*Entitlement", text, re.I)
        )
        if external and not local_verify:
            if not any(f[2] == "IG-50" for f in findings):
                ln = next(
                    (i + 1 for i, l in enumerate(lines) if "isAdmin" in l or "result.valid" in l),
                    1,
                )
                findings.append((str(path), ln, "IG-50", "security decision may trust external output"))
    if has_env and re.search(r"fetch\s*\(", text):
        validated = bool(
            re.search(
                r"isAllowed|allowlist|ALLOWED|validate.*[Uu]rl|\.protocol\s*===|endsWith\s*\(",
                text,
            )
        )
        if not validated and not any(f[2] == "IG-49" for f in findings):
            findings.append((str(path), 1, "IG-49", "network call may use unvalidated environment URL"))


def main():
    target = Path(os.environ.get("ACP_TARGET", "."))
    if not target.exists():
        print(f"Error: {target} not found", file=sys.stderr)
        sys.exit(2)

    markers = []
    findings = []
    for fp in iter_files(target):
        scan(fp, markers, findings)

    for f, ln, kind, label in markers:
        print(f"{f}:{ln} {kind} {label}")
    for f, ln, rule, msg in findings:
        print(f"{f}:{ln}:{rule}:{msg}")
    print(f"ACP_FINDING_COUNT={len(findings)}")
    print(f"ACP_MARKER_COUNT={len(markers)}")
    sys.exit(0)


if __name__ == "__main__":
    main()
