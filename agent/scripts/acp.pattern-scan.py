"""Pattern scanner for /acp-integrity — exfiltration & persistence rules (M64)."""
import os
import re
import sys
from pathlib import Path

NETWORK = re.compile(r"fetch\s*\(|axios\.|http\.request|WebSocket|XMLHttpRequest|request\s*\(", re.I)
ENV = re.compile(r"process\.env|os\.environ|getenv\s*\(", re.I)
READ_FILE = re.compile(r"fs\.readFile|readFileSync|open\s*\(.*['\"]r", re.I)
CLIPBOARD = re.compile(r"clipboard|navigator\.clipboard|pyperclip", re.I)
STORAGE = re.compile(r"localStorage|sessionStorage|getItem\s*\(", re.I)
EVAL_NET = re.compile(r"eval\s*\(.*fetch|eval\s*\(.*axios|eval\s*\(.*request", re.I)
DNS_ENV = re.compile(r"dns\.(resolve|lookup).*process\.env|dns\.(resolve|lookup).*environ", re.I)
TOKEN_LOG = re.compile(
    r"(console\.(log|info|debug)|logger\.|print\s*\().*(token|api[_-]?key|password|secret|bearer)", re.I
)
TOKEN_URL = re.compile(r"https?://[^\s\"']*(token|api[_-]?key|password|secret)=", re.I)
PII_BODY = re.compile(r"(email|ssn|social.security|credit.card).*(fetch|axios|post|send)", re.I)
SCREENSHOT = re.compile(r"(html2canvas|screenshot|capturePage|getDisplayMedia)", re.I)
EXEC_DYN = re.compile(r"(child_process\.)?exec\s*\(|spawn\s*\(|system\s*\(", re.I)
WRITE_SYS = re.compile(r"writeFile(Sync)?\s*\([^)]*['\"](/etc/|/usr/|C:\\Windows|System32)", re.I)
CRON = re.compile(r"node-cron|cron\.schedule|crontab|schtasks", re.I)
SELF_MOD = re.compile(r"eval\s*\(|Function\s*\(|new Function", re.I)
DYN_IMPORT = re.compile(r"(require|import)\s*\(\s*[^\"']", re.I)
INJECT = re.compile(r"(ptrace|LD_PRELOAD|CreateRemoteThread|process\.inject)", re.I)
DYN_CMD = re.compile(r"\$\{|`\$\{|\+\s*[^\"']", re.I)

SKIP = {"node_modules", ".git"}
EXT = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".py"}


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


def scan_file(path: Path, findings: list):
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return
    block = "\n".join(lines)

    for i, line in enumerate(lines, 1):
        if EVAL_NET.search(line):
            findings.append((str(path), i, "IG-04", "eval of network-fetched content pattern"))
        if DNS_ENV.search(line):
            findings.append((str(path), i, "IG-05", "DNS lookup from environment variable"))
        if EXEC_DYN.search(line) and DYN_CMD.search(line):
            findings.append((str(path), i, "IG-21", "child_process.exec with dynamic command"))
        if WRITE_SYS.search(line):
            findings.append((str(path), i, "IG-22", "fs.writeFile to system path"))
        if CRON.search(line):
            findings.append((str(path), i, "IG-23", "cron or scheduled task creation"))
        if SELF_MOD.search(line) and "test" not in line.lower():
            findings.append((str(path), i, "IG-24", "self-modifying code pattern"))
        if DYN_IMPORT.search(line):
            findings.append((str(path), i, "IG-25", "dynamic require/import"))
        if INJECT.search(line):
            findings.append((str(path), i, "IG-26", "process injection pattern"))
        if TOKEN_LOG.search(line):
            findings.append((str(path), i, "IG-11", "auth token in log output"))
        if TOKEN_URL.search(line):
            findings.append((str(path), i, "IG-11", "auth token in URL"))
        if PII_BODY.search(line):
            findings.append((str(path), i, "IG-12", "PII in request without encryption wrapper"))
        if SCREENSHOT.search(line) and "test" not in path.name.lower():
            findings.append((str(path), i, "IG-13", "screenshot API usage"))

    if ENV.search(block) and NETWORK.search(block):
        findings.append((str(path), 1, "IG-07", "process.env access with network call in file"))
    if READ_FILE.search(block) and NETWORK.search(block):
        findings.append((str(path), 1, "IG-08", "fs.readFile with network call in file"))
    if CLIPBOARD.search(block) and NETWORK.search(block):
        findings.append((str(path), 1, "IG-09", "clipboard access with network call in file"))
    if STORAGE.search(block) and NETWORK.search(block):
        findings.append((str(path), 1, "IG-10", "storage read with network call in file"))


def main():
    target = Path(os.environ.get("ACP_TARGET", "."))
    findings = []
    if target.is_file():
        scan_file(target, findings)
    else:
        for fp in iter_files(target):
            scan_file(fp, findings)
    for file, line, rule, msg in findings:
        print(f"{file}:{line}:{rule}:{msg}")
    print(f"ACP_FINDING_COUNT={len(findings)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
