import matter from "gray-matter";
import yaml from "js-yaml";
import { readFileSync, existsSync, readdirSync, statSync } from "fs";
import { execSync, execFileSync } from "child_process";
import path from "path";
import { fileURLToPath } from "url";
import { createHash } from "crypto";

// ── Repo root (D1 — cwd-independent) ─────────────────────────
const _SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
export const REPO_ROOT = path.resolve(_SCRIPT_DIR, "..");

export function getRepoRoot(): string {
  return process.env["ACP_REPO_ROOT"] ?? REPO_ROOT;
}

function repoPath(...parts: string[]): string {
  return path.join(getRepoRoot(), ...parts);
}

export function resolveProgressPointerPath(pointerPath: string): string {
  return path.isAbsolute(pointerPath) ? pointerPath : repoPath(pointerPath);
}

// ── Shared types ─────────────────────────────────────────────
export interface ValidationError {
  file: string;
  line: number;
  message: string;
  severity: "error" | "warning";
}

/** Subset of agent/routing/taxonomy.yml used by validateTaskFile / staleness checks */
interface YamlTaxonomy {
  last_updated?: string;
  task_types?: Record<string, Record<string, unknown>>;
}

/** Subset of agent/routing/config.yml used by executor / model freshness checks */
interface YamlRoutingConfig {
  models?: Record<string, { last_verified?: string }>;
}

/** Subset of agent/core/constraints.yml used by AGENTS.md size validation */
interface YamlConstraints {
  agents_md_rules?: {
    max_bytes?: number;
    warn_at_bytes?: number;
    files_to_check?: string[];
  };
}

/** Milestone block inside agent/progress.yaml */
interface MilestoneProgressEntry {
  status?: string;
  file?: string;
  tasks_total?: number;
}

/** Subset of agent/progress.yaml used by consistency / pointer checks */
interface ProgressYaml {
  milestones?: Record<string, MilestoneProgressEntry>;
  active_handoff?: {
    path?: string;
    git_commit?: string;
  };
}

export function assertRepoRoot(): ValidationError[] {
  const marker = repoPath("agent", "commands");
  if (!existsSync(marker)) {
    return [
      {
        file: getRepoRoot(),
        line: 0,
        message: `Not an ACP repo root — missing ${marker}. Run from repo root or fix ACP_REPO_ROOT.`,
        severity: "error",
      },
    ];
  }
  return [];
}

// ── Placeholder detection ─────────────────────────────────────
// Env var ACP_COMMANDS_DIR overrides default — used in tests
const COMMANDS_DIR =
  process.env["ACP_COMMANDS_DIR"] ?? repoPath("agent", "commands");

export function validatePlaceholders(filePath: string): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(filePath)) return errors;

  const lines = readFileSync(filePath, "utf8").split("\n");
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track fenced code blocks
    if (/^```/.test(line)) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    // Only check lines 3 and 4 (0-indexed: 2 and 3)
    if (i === 2 || i === 3) {
      const placeholderPattern = /\{[A-Za-z_][A-Za-z0-9_]*\}/g;
      const matches = line.match(placeholderPattern);
      if (matches) {
        for (const match of matches) {
          errors.push({
            file: filePath,
            line: i + 1,
            message: `Unresolved placeholder: ${match}`,
            severity: "error",
          });
        }
      }
    }
  }

  return errors;
}

function runPlaceholderScan(): void {
  if (!existsSync(COMMANDS_DIR)) {
    console.log(`Placeholder check: ${COMMANDS_DIR} not found — skipped`);
    return;
  }

  const commandFiles = readdirSync(COMMANDS_DIR)
    .filter((f) => f.endsWith(".md") && !f.endsWith(".template.md"))
    .map((f) => path.join(COMMANDS_DIR, f));

  let totalErrors = 0;
  const allErrors: ValidationError[] = [];

  for (const file of commandFiles) {
    const errs = validatePlaceholders(file);
    allErrors.push(...errs);
    totalErrors += errs.length;
  }

  if (totalErrors === 0) {
    console.log(
      `Placeholder check: ${commandFiles.length} files checked, 0 errors found ✓`
    );
  } else {
    console.error(
      `Placeholder check: ${commandFiles.length} files checked, ${totalErrors} errors found`
    );
    for (const err of allErrors) {
      console.error(`  ✗ ${err.file}:${err.line} — ${err.message}`);
    }
    process.exitCode = 1;
  }
}

// ── Frontmatter field validation ──────────────────────────────
// Command files use inline bold markers: **Namespace**: acp
const REQUIRED_FRONTMATTER_FIELDS = ["Namespace", "Version", "Status", "Scripts"];

export function validateFrontmatter(filePath: string): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(filePath)) return errors;

  const content = readFileSync(filePath, "utf8");

  for (const field of REQUIRED_FRONTMATTER_FIELDS) {
    // Match inline bold marker pattern: **Field**:
    if (!new RegExp(`^\\*\\*${field}\\*\\*:`, "m").test(content)) {
      errors.push({
        file: filePath,
        line: 1,
        message: `Missing required field: **${field}**:`,
        severity: "warning",
      });
    }
  }

  return errors;
}

function runFrontmatterScan(): void {
  if (!existsSync(COMMANDS_DIR)) {
    console.log(`Frontmatter check: ${COMMANDS_DIR} not found — skipped`);
    return;
  }

  const commandFiles = readdirSync(COMMANDS_DIR)
    .filter((f) => f.endsWith(".md") && !f.endsWith(".template.md"))
    .map((f) => path.join(COMMANDS_DIR, f));

  const allErrors: ValidationError[] = [];

  for (const file of commandFiles) {
    const errs = validateFrontmatter(file);
    allErrors.push(...errs);
  }

  const warningCount = allErrors.filter((e) => e.severity === "warning").length;

  if (warningCount === 0) {
    console.log(
      `Frontmatter check: ${commandFiles.length} files checked, 0 warnings ✓`
    );
  } else {
    console.warn(
      `Frontmatter check: ${commandFiles.length} files checked, ${warningCount} warnings`
    );
    for (const err of allErrors) {
      console.warn(`  ⚠ ${err.file}:${err.line} — ${err.message}`);
    }
  }
}

// ── Five-surface parity check (D5) ────────────────────────────
const PROMPTS_DIR =
  process.env["ACP_PROMPTS_DIR"] ?? repoPath(".github", "prompts");
const OPENCODE_DIR =
  process.env["ACP_OPENCODE_DIR"] ?? repoPath(".opencode", "commands");
const CURSOR_DIR =
  process.env["ACP_CURSOR_DIR"] ?? repoPath(".cursor", "commands");
const CLAUDE_DIR =
  process.env["ACP_CLAUDE_DIR"] ?? repoPath(".claude", "commands");

function commandStem(filename: string): { prefix: "acp" | "git"; stem: string } | null {
  const m = filename.match(/^(acp|git)\.(.+)\.md$/);
  if (!m || filename.endsWith(".template.md")) return null;
  return { prefix: m[1] as "acp" | "git", stem: m[2] };
}

function hyphenWrapperName(prefix: "acp" | "git", stem: string): string {
  return `${prefix}-${stem}`;
}

function listDirSafe(dir: string): string[] {
  return existsSync(dir) ? readdirSync(dir) : [];
}

function detectDotStrays(dir: string, label: string): ValidationError[] {
  const errors: ValidationError[] = [];
  for (const f of listDirSafe(dir)) {
    if (/^acp\.[^/]+\.(md|prompt\.md)$/.test(f)) {
      errors.push({
        file: path.join(dir, f),
        line: 0,
        message: `Dot-form stray wrapper in ${label}: ${f} (use hyphen form acp-name.md)`,
        severity: "error",
      });
    }
  }
  return errors;
}

export function validateParityCheck(options?: {
  commandsDir?: string;
  promptsDir?: string;
  opencodeDir?: string;
  cursorDir?: string;
  claudeDir?: string;
}): ValidationError[] {
  const errors: ValidationError[] = [];
  const commandsDir = options?.commandsDir ?? COMMANDS_DIR;
  const promptsDir = options?.promptsDir ?? PROMPTS_DIR;
  const opencodeDir = options?.opencodeDir ?? OPENCODE_DIR;
  const cursorDir = options?.cursorDir ?? CURSOR_DIR;
  const claudeDir = options?.claudeDir ?? CLAUDE_DIR;

  const commandFiles = listDirSafe(commandsDir).filter((f) => commandStem(f) !== null);

  if (commandFiles.length === 0) {
    errors.push({
      file: commandsDir,
      line: 0,
      message: "Zero command docs found — vacuous parity pass forbidden (D2)",
      severity: "error",
    });
    return errors;
  }

  for (const [dir, label] of [
    [promptsDir, "prompts"],
    [opencodeDir, "opencode"],
    [cursorDir, "cursor"],
    [claudeDir, "claude"],
  ] as const) {
    errors.push(...detectDotStrays(dir, label));
  }

  const acpCommands: string[] = [];
  const gitCommands: string[] = [];
  for (const f of commandFiles) {
    const parsed = commandStem(f);
    if (!parsed) continue;
    if (parsed.prefix === "acp") acpCommands.push(parsed.stem);
    else gitCommands.push(parsed.stem);
  }

  const promptSet = new Set(
    listDirSafe(promptsDir)
      .filter((f) => f.startsWith("acp-") && f.endsWith(".prompt.md"))
      .map((f) => f.replace(/^acp-/, "").replace(/\.prompt\.md$/, ""))
  );
  const opencodeSet = new Set(
    listDirSafe(opencodeDir)
      .filter((f) => f.startsWith("acp-") && f.endsWith(".md"))
      .map((f) => f.replace(/^acp-/, "").replace(/\.md$/, ""))
  );
  const cursorSet = new Set(
    listDirSafe(cursorDir)
      .filter((f) => (f.startsWith("acp-") || f.startsWith("git-")) && f.endsWith(".md"))
      .map((f) => f.replace(/^(acp|git)-/, "").replace(/\.md$/, ""))
  );
  const claudeSet = new Set(
    listDirSafe(claudeDir)
      .filter((f) => (f.startsWith("acp-") || f.startsWith("git-")) && f.endsWith(".md"))
      .map((f) => f.replace(/^(acp|git)-/, "").replace(/\.md$/, ""))
  );

  const requireSurface = (
    stem: string,
    prefix: "acp" | "git",
    surface: Set<string>,
    surfaceLabel: string,
    relPath: string
  ) => {
    if (!surface.has(stem)) {
      errors.push({
        file: relPath,
        line: 0,
        message: `Parity: ${prefix}.${stem}.md missing ${surfaceLabel} wrapper`,
        severity: "error",
      });
    }
  };

  for (const stem of acpCommands) {
    requireSurface(stem, "acp", promptSet, "prompt", path.join(promptsDir, `acp-${stem}.prompt.md`));
    requireSurface(stem, "acp", opencodeSet, "opencode", path.join(opencodeDir, `acp-${stem}.md`));
    requireSurface(stem, "acp", cursorSet, "cursor", path.join(cursorDir, `acp-${stem}.md`));
    requireSurface(stem, "acp", claudeSet, "claude", path.join(claudeDir, `acp-${stem}.md`));
  }

  for (const stem of gitCommands) {
    requireSurface(stem, "git", cursorSet, "cursor", path.join(cursorDir, `git-${stem}.md`));
    requireSurface(stem, "git", claudeSet, "claude", path.join(claudeDir, `git-${stem}.md`));
  }

  // Orphan wrappers (hyphen form without command doc)
  const allCommandStems = new Set([...acpCommands, ...gitCommands]);
  for (const name of promptSet) {
    if (!acpCommands.includes(name)) {
      errors.push({
        file: path.join(promptsDir, `acp-${name}.prompt.md`),
        line: 0,
        message: `Orphan prompt wrapper — no agent/commands/acp.${name}.md`,
        severity: "error",
      });
    }
  }
  for (const name of opencodeSet) {
    if (!acpCommands.includes(name)) {
      errors.push({
        file: path.join(opencodeDir, `acp-${name}.md`),
        line: 0,
        message: `Orphan opencode wrapper — no agent/commands/acp.${name}.md`,
        severity: "error",
      });
    }
  }

  return errors;
}

function runParityCheck(): boolean {
  const errors = validateParityCheck();
  const blocking = errors.filter((e) => e.severity === "error");
  const commandCount = listDirSafe(COMMANDS_DIR).filter((f) => commandStem(f) !== null).length;

  if (blocking.length === 0) {
    console.log(`✅ Parity: ${commandCount} commands × 5 surfaces — all matched`);
    return true;
  }
  console.error(`❌ Parity: ${blocking.length} mismatch(es) across 5 surfaces`);
  for (const err of blocking) {
    console.error(`  ❌ ${err.file}: ${err.message}`);
  }
  return false;
}

export function validateInstructionFileHash(root?: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const base = root ?? getRepoRoot();
  const relFiles = ["AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md"];
  const contents: { rel: string; hash: string; lines: string[] }[] = [];

  for (const rel of relFiles) {
    const abs = path.join(base, rel);
    if (!existsSync(abs)) {
      errors.push({
        file: rel,
        line: 0,
        message: "Instruction file missing for hash sync check",
        severity: "error",
      });
      return errors;
    }
    const text = readFileSync(abs, "utf8");
    contents.push({
      rel,
      hash: createHash("sha256").update(text).digest("hex"),
      lines: text.split("\n"),
    });
  }

  const ref = contents[0];
  for (let i = 1; i < contents.length; i++) {
    const cur = contents[i];
    if (cur.hash !== ref.hash) {
      let diffLine = 1;
      const max = Math.max(ref.lines.length, cur.lines.length);
      for (let ln = 0; ln < max; ln++) {
        if (ref.lines[ln] !== cur.lines[ln]) {
          diffLine = ln + 1;
          break;
        }
      }
      errors.push({
        file: cur.rel,
        line: diffLine,
        message: `Content hash mismatch with ${ref.rel} (first diff line ${diffLine})`,
        severity: "error",
      });
    }
  }

  if (errors.length === 0) {
    console.log("✅ Instruction files: SHA-256 content hash identical (AGENTS/CLAUDE/copilot)");
  }
  return errors;
}

export function validatePackageYamlVersion(root?: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const base = root ?? getRepoRoot();
  const identityPath = path.join(base, "agent", "core", "identity.yml");
  const packagePath = path.join(base, "package.yaml");

  if (!existsSync(identityPath) || !existsSync(packagePath)) {
    errors.push({
      file: packagePath,
      line: 0,
      message: "package.yaml or identity.yml missing for version check",
      severity: "error",
    });
    return errors;
  }

  const identity = yaml.load(readFileSync(identityPath, "utf-8")) as { version?: string };
  const pkg = yaml.load(readFileSync(packagePath, "utf-8")) as { version?: string };
  const idVer = String(identity.version ?? "").trim();
  const pkgVer = String(pkg.version ?? "").trim();

  if (!pkgVer) {
    errors.push({
      file: packagePath,
      line: 0,
      message: "package.yaml missing version field",
      severity: "error",
    });
  } else if (idVer && pkgVer !== idVer) {
    errors.push({
      file: packagePath,
      line: 0,
      message: `package.yaml version ${pkgVer} != identity.yml version ${idVer}`,
      severity: "error",
    });
  } else if (idVer) {
    console.log(`✅ package.yaml version: ${pkgVer} matches identity.yml`);
  }

  return errors;
}

export function validateScriptRegistration(root?: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const base = root ?? getRepoRoot();
  const scriptsDir = path.join(base, "agent", "scripts");
  const packagePath = path.join(base, "package.yaml");
  const manifestPath = path.join(base, "agent", "integrity-manifest.yaml");

  if (!existsSync(scriptsDir) || !existsSync(packagePath)) return errors;

  const pkg = yaml.load(readFileSync(packagePath, "utf-8")) as {
    contents?: { scripts?: { name: string }[] };
  };
  const registered = new Set((pkg.contents?.scripts ?? []).map((s) => s.name));

  const manifestPaths = new Set<string>();
  if (existsSync(manifestPath)) {
    const manifest = yaml.load(readFileSync(manifestPath, "utf-8")) as {
      files?: { path: string }[];
    };
    for (const entry of manifest.files ?? []) {
      manifestPaths.add(entry.path);
    }
  }

  const onDisk = readdirSync(scriptsDir).filter((f) => f.endsWith(".sh"));
  for (const script of onDisk) {
    if (!registered.has(script)) {
      errors.push({
        file: packagePath,
        line: 0,
        message: `agent/scripts/${script} not registered in package.yaml contents.scripts`,
        severity: "error",
      });
    }
    const manifestKey = `agent/scripts/${script}`;
    if (manifestPaths.size > 0 && !manifestPaths.has(manifestKey)) {
      errors.push({
        file: manifestPath,
        line: 0,
        message: `${manifestKey} not listed in integrity-manifest.yaml`,
        severity: "warning",
      });
    }
  }

  if (errors.length === 0) {
    console.log(`✅ Script registration: ${onDisk.length} scripts in package.yaml`);
  }
  return errors;
}

export function validateProtocolDirAddability(root?: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const base = root ?? getRepoRoot();
  const probeDirs = ["agent/reports", "agent/feedback", "agent/memory", "agent/tasks"];

  for (const dir of probeDirs) {
    const probe = path.join(base, dir, "__acp_addability_probe__.md");
    try {
      execSync(`git check-ignore -q "${probe}"`, {
        cwd: base,
        stdio: ["pipe", "pipe", "pipe"],
      });
      errors.push({
        file: path.join(dir, ".gitignore"),
        line: 0,
        message: `Protocol dir ${dir}/ rejects new files (git check-ignore probe)`,
        severity: "error",
      });
    } catch {
      // not ignored — good
    }
  }

  for (const dir of ["agent/reports", "agent/feedback"]) {
    const absDir = path.join(base, dir);
    if (!existsSync(absDir)) continue;
    const walk = (sub: string) => {
      for (const entry of readdirSync(sub, { withFileTypes: true })) {
        const full = path.join(sub, entry.name);
        if (entry.isDirectory()) walk(full);
        else {
          if (entry.name.startsWith(".") || entry.name === ".DS_Store") continue;
          const rel = path.relative(base, full).replace(/\\/g, "/");
          try {
            const tracked = execSync(`git ls-files --error-unmatch "${rel}"`, {
              cwd: base,
              encoding: "utf8",
              stdio: ["pipe", "pipe", "pipe"],
            });
            if (!tracked.trim()) {
              errors.push({
                file: rel,
                line: 0,
                message: `Untracked evidence file in ${dir}/ (D9)`,
                severity: "error",
              });
            }
          } catch {
            errors.push({
              file: rel,
              line: 0,
              message: `Untracked evidence file in ${dir}/ (D9)`,
              severity: "error",
            });
          }
        }
      }
    };
    walk(absDir);
  }

  if (errors.length === 0) {
    console.log("✅ Protocol dirs: addability probe passed; evidence files tracked");
  }
  return errors;
}

function runInstructionAndPackageChecks(): boolean {
  let ok = true;
  for (const err of validateInstructionFileHash()) {
    console.error(`❌ ${err.file}:${err.line} — ${err.message}`);
    if (err.severity === "error") ok = false;
  }
  for (const err of validatePackageYamlVersion()) {
    console.error(`❌ ${err.file}: ${err.message}`);
    if (err.severity === "error") ok = false;
  }
  for (const err of validateScriptRegistration()) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") ok = false;
  }
  for (const err of validateProtocolDirAddability()) {
    console.error(`❌ ${err.file}: ${err.message}`);
    if (err.severity === "error") ok = false;
  }
  return ok;
}

// ============================================================
// ACP Enhanced — Task Validator
// Usage: npx ts-node scripts/acp-validate.ts agent/routing/tasks/task-NNN.md
// Exits 0 if valid, exits 1 with errors if not.
// ============================================================

const AGENT_DIR = ".agent";
const TAXONOMY_PATH = path.join(AGENT_DIR, "routing", "taxonomy.yml");
const CONFIG_PATH = path.join(AGENT_DIR, "routing", "config.yml");

const REQUIRED_FIELDS = [
  "id",
  "title",
  "task_type",
  "executor",
  "complexity",
  "tokens_est",
  "created",
];

const VALID_COMPLEXITIES = ["low", "medium", "high"];

function loadYaml<T>(filePath: string): T | null {
  if (!existsSync(filePath)) return null;
  return yaml.load(readFileSync(filePath, "utf-8")) as T;
}

function validateTaskFile(taskFilePath: string): string[] {
  const errors: string[] = [];

  if (!existsSync(taskFilePath)) {
    return [`File not found: ${taskFilePath}`];
  }

  const raw = readFileSync(taskFilePath, "utf-8");
  const { data: meta } = matter(raw);

  // ── Required fields ──────────────────────────────────────
  for (const field of REQUIRED_FIELDS) {
    if (meta[field] === undefined || meta[field] === null || meta[field] === "") {
      errors.push(`Missing required field: ${field}`);
    }
  }

  // ── id format ────────────────────────────────────────────
  if (meta.id && !/^task-\d{3,}$/.test(String(meta.id))) {
    errors.push(`Invalid id format: "${meta.id}" — expected "task-NNN" (e.g. task-001)`);
  }

  // ── created date ─────────────────────────────────────────
  if (meta.created && !/^\d{4}-\d{2}-\d{2}$/.test(String(meta.created))) {
    errors.push(`Invalid created date: "${meta.created}" — expected YYYY-MM-DD`);
  }

  // ── complexity ────────────────────────────────────────────
  if (meta.complexity && !VALID_COMPLEXITIES.includes(meta.complexity)) {
    errors.push(
      `Invalid complexity: "${meta.complexity}" — expected one of: ${VALID_COMPLEXITIES.join(", ")}`
    );
  }

  // ── tokens_est ───────────────────────────────────────────
  if (meta.tokens_est !== undefined && typeof meta.tokens_est !== "number") {
    errors.push(`tokens_est must be a number, got: ${typeof meta.tokens_est}`);
  }

  // ── task_type must exist in taxonomy ────────────────────
  if (meta.task_type) {
    const taxonomy = loadYaml<YamlTaxonomy>(TAXONOMY_PATH);
    if (taxonomy) {
      const knownTypes = Object.keys(taxonomy.task_types ?? {});
      if (!knownTypes.includes(meta.task_type)) {
        errors.push(
          `Unknown task_type: "${meta.task_type}" — known types: ${knownTypes.join(", ")}`
        );
      }
    } else {
      errors.push(`Cannot load taxonomy at ${TAXONOMY_PATH} — cannot validate task_type`);
    }
  }

  // ── executor must be a valid model name ──────────────────
  if (meta.executor && meta.executor !== "local-script") {
    const config = loadYaml<YamlRoutingConfig>(CONFIG_PATH);
    if (config) {
      const knownModels = Object.keys(config.models ?? {});
      if (!knownModels.includes(meta.executor)) {
        errors.push(
          `Unknown executor: "${meta.executor}" — known models: ${knownModels.join(", ")}`
        );
      }
    } else {
      errors.push(`Cannot load config at ${CONFIG_PATH} — cannot validate executor`);
    }
  }

  return errors;
}

// ── Staleness checks (ROUTING-003) ───────────────────────────
function checkStaleness(): boolean {
  const TAXONOMY_PATH_LOCAL = repoPath("agent", "routing", "taxonomy.yml");
  const CONFIG_PATH_LOCAL = repoPath("agent", "routing", "config.yml");
  const DAY_MS = 1000 * 60 * 60 * 24;
  const now = Date.now();
  let hasWarnings = false;

  // taxonomy.yml last_updated check (warn after 90 days)
  if (!existsSync(TAXONOMY_PATH_LOCAL)) {
    console.warn("⚠️  taxonomy.yml: file not found — staleness unknown");
    hasWarnings = true;
  } else {
    const taxonomy = yaml.load(readFileSync(TAXONOMY_PATH_LOCAL, "utf-8")) as YamlTaxonomy;
    const lastUpdated: string | undefined = taxonomy?.last_updated;
    if (!lastUpdated) {
      console.warn("⚠️  taxonomy.yml: no last_updated field — staleness unknown");
      hasWarnings = true;
    } else {
      const d = new Date(lastUpdated);
      if (isNaN(d.getTime())) {
        console.warn(`⚠️  taxonomy.yml: invalid last_updated value "${lastUpdated}"`);
        hasWarnings = true;
      } else {
        const days = Math.floor((now - d.getTime()) / DAY_MS);
        if (days > 90) {
          console.warn(`⚠️  taxonomy.yml: last_updated is ${days} days ago — verify task types are current`);
          hasWarnings = true;
        } else {
          // will include in summary below
        }
      }
    }
  }

  // config.yml model last_verified check (warn after 180 days)
  const modelWarnings: string[] = [];
  const modelOk: string[] = [];
  if (!existsSync(CONFIG_PATH_LOCAL)) {
    console.warn("⚠️  routing/config.yml: file not found — model freshness unknown");
    hasWarnings = true;
  } else {
    const config = yaml.load(readFileSync(CONFIG_PATH_LOCAL, "utf-8")) as YamlRoutingConfig;
    const models = config?.models;
    if (models) {
      for (const [modelName, modelData] of Object.entries(models)) {
        const lastVerified: string | undefined = modelData?.last_verified;
        if (!lastVerified) {
          modelWarnings.push(`  ⚠️  ${modelName}: no last_verified date`);
          hasWarnings = true;
        } else {
          const d = new Date(lastVerified);
          if (isNaN(d.getTime())) {
            modelWarnings.push(`  ⚠️  ${modelName}: invalid last_verified "${lastVerified}"`);
            hasWarnings = true;
          } else {
            const days = Math.floor((now - d.getTime()) / DAY_MS);
            if (days > 180) {
              modelWarnings.push(`  ⚠️  routing/config.yml: ${modelName} last_verified ${days} days ago — check pricing/availability`);
              hasWarnings = true;
            } else {
              modelOk.push(modelName);
            }
          }
        }
      }
    }
  }

  for (const w of modelWarnings) {
    console.warn(w);
  }

  if (!hasWarnings) {
    const taxonomy2 = yaml.load(readFileSync(TAXONOMY_PATH_LOCAL, "utf-8")) as YamlTaxonomy;
    const lu = taxonomy2?.last_updated ?? "unknown";
    const d2 = new Date(lu);
    const days2 = isNaN(d2.getTime()) ? "?" : Math.floor((now - d2.getTime()) / DAY_MS);
    console.log(`✅ Staleness: taxonomy.yml ${days2} days old, all models verified within 180 days`);
  }
  return !hasWarnings;
}

// ── Validate AGENTS.md / CLAUDE.md byte size (VALIDATE-001) ─
function validateAgentsMdSize(): boolean {
  const constraintsPath = repoPath("agent", "core", "constraints.yml");
  if (!existsSync(constraintsPath)) {
    console.warn("⚠️  constraints.yml not found — skipping AGENTS.md size check");
    return true;
  }

  const constraints = yaml.load(readFileSync(constraintsPath, "utf-8")) as YamlConstraints;
  const rules = constraints?.agents_md_rules;
  if (!rules) {
    console.warn("⚠️  constraints.yml: agents_md_rules not defined — skipping size check");
    return true;
  }

  const maxBytes: number = rules.max_bytes ?? 15000;
  const warnBytes: number = rules.warn_at_bytes ?? 12000;
  const filesToCheck: string[] = rules.files_to_check ?? ["AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md"];

  let allOk = true;
  for (const file of filesToCheck) {
    const absFile = path.isAbsolute(file) ? file : repoPath(file);
    if (!existsSync(absFile)) {
      console.warn(`⚠️  ${file}: not found — skipping size check`);
      continue;
    }
    const size = statSync(absFile).size;
    if (size > maxBytes) {
      console.error(`❌ ${file}: ${size} bytes — exceeds ${maxBytes} byte limit`);
      allOk = false;
    } else if (size > warnBytes) {
      console.warn(`⚠️  ${file}: ${size} bytes — approaching ${maxBytes} byte limit`);
    } else {
      console.log(`✅ ${file}: ${size} bytes`);
    }
  }
  return allOk;
}

// ── Validate sessions.md YAML structure (MEMORY-002) ─────────
function validateSessionsMemory(): boolean {
  const sessionsPath = repoPath("agent", "memory", "sessions.md");
  if (!existsSync(sessionsPath)) {
    console.warn("⚠️  sessions.md: file not found — skipping structure check");
    return true;
  }

  const raw = readFileSync(sessionsPath, "utf-8");
  // Strip leading YAML comments/blank lines before splitting
  const stripped = raw.replace(/^(#[^\n]*\n|\s*\n)*/m, "");
  if (stripped.trim() === "") {
    console.log("✅ sessions.md: 0 entries (empty)");
    return true;
  }

  // Split on `\n- date:` — same pattern as getLastNSessions() in acp-dispatch.ts
  const parts = stripped.split(/\n(?=- date:)/);
  const entries = parts.filter((p) => p.trim().startsWith("- date:"));

  const requiredKeys = ["date:", "executor:", "tasks:", "done:"];
  const datePattern = /^\d{4}-\d{2}-\d{2}$/;
  let hasErrors = false;

  for (let i = 0; i < entries.length; i++) {
    const entry = entries[i];
    for (const key of requiredKeys) {
      if (!entry.includes(key)) {
        console.error(`❌ sessions.md: Entry #${i + 1} missing required key: ${key.replace(":", "")}`);
        hasErrors = true;
      }
    }
    // Warn on malformed date
    const dateMatch = entry.match(/date:\s*([^\n]+)/);
    if (dateMatch) {
      const dateVal = dateMatch[1].trim();
      if (!datePattern.test(dateVal)) {
        console.warn(`⚠️  sessions.md: Entry #${i + 1} has non-standard date format: "${dateVal}"`);
      }
    }
  }

  if (!hasErrors) {
    console.log(`✅ sessions.md: ${entries.length} ${entries.length === 1 ? "entry" : "entries"} — all valid`);
  }
  return !hasErrors;
}

// ── Duplicate key detection in memory-layer entries (MEMORY-003, G-107-02) ────
/**
 * Return the top-level keys that appear more than once inside a single YAML
 * list entry.
 *
 * Why this exists: an agent edit that deletes the *following* entry's `- date:`
 * header merges two entries into one block. Every key-presence check still
 * passes (`entry.includes("done:")` is true), the entry count silently absorbs
 * the merge, and YAML last-wins semantics means the earlier entry's `done:` and
 * `key_fact:` are shadowed — the session is lost with no error anywhere. This is
 * the second duplicate-key incident in this repo after the 191-key
 * progress.yaml failure (audit-107 G-107-02).
 *
 * `indent` is the column at which the list marker sits (0 for a top-level list
 * like sessions.md, 2 for a nested list like audit-carryovers.md). Nested list
 * items (`    - foo`) and folded-scalar continuation lines are indented deeper
 * than their key and so never match.
 */
export function findDuplicateEntryKeys(entry: string, indent = 0): string[] {
  const pad = " ".repeat(indent);
  const keyLine = new RegExp(`^(?:${pad}- |${pad}  )([a-z_][a-z0-9_]*):`);
  const counts = new Map<string, number>();
  for (const line of entry.split("\n")) {
    const m = line.match(keyLine);
    if (m) counts.set(m[1], (counts.get(m[1]) ?? 0) + 1);
  }
  return [...counts.entries()].filter(([, n]) => n > 1).map(([k]) => k);
}

function validateMemoryDuplicateKeys(): boolean {
  // Split on ANY list item at the entry indent, not on a specific first key.
  // sessions.md legitimately mixes `- date:` entries with `- type: weekly-summary`
  // compaction blocks; splitting only on `- date:` folds the summary blocks into
  // the preceding entry and reports their repeated keys as false duplicates.
  const targets = [
    { file: "sessions.md", indent: 0 },
    { file: "lessons.md", indent: 0 },
    { file: "patterns.md", indent: 0 },
    { file: "audit-carryovers.md", indent: 2 },
  ];

  let hasErrors = false;
  let checked = 0;

  for (const { file, indent } of targets) {
    const filePath = repoPath("agent", "memory", file);
    if (!existsSync(filePath)) continue;

    const raw = readFileSync(filePath, "utf-8");
    const pad = " ".repeat(indent);
    const splitRe = new RegExp(`\\n(?=${pad}- [a-z_][a-z0-9_]*:)`);
    const itemRe = new RegExp(`^${pad}- [a-z_][a-z0-9_]*:`);
    const entries = raw.split(splitRe).filter((p) => itemRe.test(p));

    for (let i = 0; i < entries.length; i++) {
      const dupes = findDuplicateEntryKeys(entries[i], indent);
      if (dupes.length > 0) {
        const label = entries[i].split("\n")[0].trim().slice(0, 60);
        console.error(
          `❌ ${file}: Entry #${i + 1} (${label}) has duplicate keys: ${dupes.join(", ")} — ` +
            `two entries were likely merged; the earlier values are silently shadowed`,
        );
        hasErrors = true;
      }
      checked++;
    }
  }

  if (!hasErrors) {
    console.log(`✅ Memory duplicate-key check: ${checked} entries, no duplicate keys`);
  }
  return !hasErrors;
}

// ── Version consistency (identity.yml ↔ AGENTS.md ↔ CLAUDE.md ↔ CHANGELOG) ────
export function validateVersionConsistency(root?: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const base = root ?? getRepoRoot();
  const identityPath = path.join(base, "agent", "core", "identity.yml");
  const files: Record<string, string> = {};

  // Extract version from identity.yml
  if (existsSync(identityPath)) {
    const identity = yaml.load(readFileSync(identityPath, "utf-8")) as Record<string, unknown>;
    const ver = String(identity.version ?? "").trim();
    if (ver) files["identity.yml"] = ver;
  }

  // AGENTS.md first line
  const agentsPath = path.join(base, "AGENTS.md");
  if (existsSync(agentsPath)) {
    const raw = readFileSync(agentsPath, "utf8");
    const match = raw.match(/^> v([\d.]+)/m);
    if (match) files["AGENTS.md"] = match[1];
  }

  // AGENT.md `**Version**:` field — a DIFFERENT file from AGENTS.md, and the one
  // tests/acp.security.test.sh compares against progress.yaml. It was absent from
  // this check, so a v6.29.3 bump that updated AGENTS.md but not AGENT.md passed
  // acp-validate and only failed in CI (audit-111). Validator gaps that E2E catches
  // get closed in the validator too.
  const agentPath = path.join(base, "AGENT.md");
  if (existsSync(agentPath)) {
    const raw = readFileSync(agentPath, "utf8");
    const match = raw.match(/^\*\*Version\*\*:\s*([\d.]+)/m);
    if (match) files["AGENT.md"] = match[1];
  }

  // CLAUDE.md first line
  const claudePath = path.join(base, "CLAUDE.md");
  if (existsSync(claudePath)) {
    const raw = readFileSync(claudePath, "utf8");
    const match = raw.match(/^> v([\d.]+)/m);
    if (match) files["CLAUDE.md"] = match[1];
  }

  // CHANGELOG.md first release entry
  const changelogPath = path.join(base, "CHANGELOG.md");
  if (existsSync(changelogPath)) {
    const raw = readFileSync(changelogPath, "utf8");
    const match = raw.match(/^## \[([\d.]+)\]/m);
    if (match) files["CHANGELOG.md"] = match[1];
  }

  // agent/progress.yaml project.version (audit-099 F-099-02: this field was
  // previously unchecked, so a stale progress.yaml version passed validate while
  // cross-file E2E checks caught it. Include it so a bump can't skip it.)
  const progressPath = path.join(base, "agent", "progress.yaml");
  if (existsSync(progressPath)) {
    const prog = yaml.load(readFileSync(progressPath, "utf-8")) as
      | { project?: { version?: string } }
      | undefined;
    const ver = String(prog?.project?.version ?? "").trim();
    if (ver) files["progress.yaml"] = ver;
  }

  const versions = Object.entries(files);
  if (versions.length < 2) return errors;

  const [refFile, refVersion] = versions[0];
  for (let i = 1; i < versions.length; i++) {
    const [file, ver] = versions[i];
    if (ver !== refVersion) {
      errors.push({
        file,
        line: 1,
        message: `Version inconsistency: ${refFile}=v${refVersion}, ${file}=v${ver}`,
        severity: "error",
      });
    }
  }

  if (errors.length === 0) {
    console.log(`✅ Version header: AGENTS.md v${files["AGENTS.md"] || "?"} matches identity.yml`);
  }

  return errors;
}

// ── Cross-layer status consistency (route-186) ─────────────────
// FAIL if a milestone doc's **Status**: disagrees with progress.yaml
const PROGRESS_PATH = repoPath("agent", "progress.yaml");

/**
 * Fail the run when agent/progress.yaml does not parse as strict YAML.
 *
 * `loadProgressSafe()` below deliberately swallows a parse failure and falls
 * back to line-based extraction so the remaining checks can still run. That
 * resilience is useful, but on its own it means the exact failure this repo
 * already suffered — 191 duplicate keys in progress.yaml — degrades to a
 * console warning with a green exit code, so the file could silently rot again.
 * js-yaml raises on a duplicated mapping key, so this gate turns that back into
 * a hard error while leaving the fallback intact for everything else.
 * (audit-108 recommendation 2.)
 */
function validateProgressYamlParses(): boolean {
  if (!existsSync(PROGRESS_PATH)) return true;
  const raw = readFileSync(PROGRESS_PATH, "utf-8").replace(/\r/g, "");
  try {
    yaml.load(raw);
    console.log("✅ progress.yaml: parses as strict YAML (no duplicate keys)");
    return true;
  } catch (err) {
    const first = (err as Error).message.split("\n")[0];
    console.error(`❌ progress.yaml: strict YAML parse failed — ${first}`);
    console.error(
      "   A duplicate mapping key silently shadows the earlier value. " +
        "Fix the duplicate; do not rely on the line-based fallback.",
    );
    return false;
  }
}

/**
 * ADR-20: `hooks.<phase>` in constraints.yml is a list of `{ task_id, description }`
 * entries whose `task_id` MUST resolve to a `recurring_tasks[].id` in progress.yaml.
 * The ADR explicitly says validation "can enforce that every hook task_id resolves
 * to a real recurring_task" — but nothing did, so 3 of 4 pre_commit hooks pointed at
 * ids that were never created (audit-110). A dangling hook silently fires nothing.
 */
function validateHookTaskBindings(): boolean {
  const constraintsPath = repoPath("agent", "core", "constraints.yml");
  if (!existsSync(constraintsPath) || !existsSync(PROGRESS_PATH)) return true;

  let hooks: Record<string, Array<{ task_id?: string }>> = {};
  let ids = new Set<string>();
  try {
    const constraints = yaml.load(readFileSync(constraintsPath, "utf-8")) as {
      hooks?: Record<string, Array<{ task_id?: string }>>;
    };
    hooks = constraints?.hooks ?? {};
    const progress = yaml.load(readFileSync(PROGRESS_PATH, "utf-8")) as {
      recurring_tasks?: Array<{ id?: string }>;
    };
    ids = new Set((progress?.recurring_tasks ?? []).map((t) => t.id).filter(Boolean) as string[]);
  } catch {
    // progress.yaml strict-parse failures are reported by validateProgressYamlParses().
    return true;
  }

  const dangling: string[] = [];
  let total = 0;
  for (const [phase, entries] of Object.entries(hooks)) {
    for (const entry of entries ?? []) {
      total++;
      if (!entry?.task_id || !ids.has(entry.task_id)) {
        dangling.push(`hooks.${phase} → ${entry?.task_id ?? "(no task_id)"}`);
      }
    }
  }

  if (dangling.length > 0) {
    for (const d of dangling) {
      console.error(
        `❌ constraints.yml: ${d} does not resolve to a recurring_tasks[].id (ADR-20)`,
      );
    }
    return false;
  }
  console.log(`✅ Hook bindings: ${total} hook(s) resolve to recurring_tasks (ADR-20)`);
  return true;
}

function loadProgressSafe(): ProgressYaml | null {
  if (!existsSync(PROGRESS_PATH)) return null;
    const raw = readFileSync(PROGRESS_PATH, "utf-8").replace(/\r/g, "");
  try {
    return yaml.load(raw) as ProgressYaml;
  } catch {
    console.warn("⚠️  progress.yaml: YAML parse failed (duplicate keys suspected) — using line-based fallback");
    const milestones: Record<string, MilestoneProgressEntry> = {};
    const lines = raw.split("\n");
    let currentMid: string | null = null;
    let currentBlock: string[] = [];
    for (const line of lines) {
      // M100+ milestones exist; {1,2} wrongly dropped M999 in E2E V3 probes
      const mKeyMatch = line.match(/^\s{2}(M\d+):\s*$/);
      if (mKeyMatch) {
        if (currentMid) {
          const block = currentBlock.join("\n");
          const statusMatch = block.match(/^\s{4}status:\s*(.+)/m);
          const fileMatch = block.match(/^\s{4}file:\s*(.+)/m);
          const tasksTotalMatch = block.match(/^\s{4}tasks_total:\s*(\d+)/m);
          milestones[currentMid] = {
            status: statusMatch ? statusMatch[1].trim() : undefined,
            file: fileMatch ? fileMatch[1].trim() : undefined,
            tasks_total: tasksTotalMatch ? parseInt(tasksTotalMatch[1]) : undefined,
          };
        }
        currentMid = mKeyMatch[1];
        currentBlock = [];
      } else if (currentMid) {
        currentBlock.push(line);
      }
    }
    if (currentMid && currentBlock.length > 0) {
      const block = currentBlock.join("\n");
      const statusMatch = block.match(/^\s{4}status:\s*(.+)/m);
      const fileMatch = block.match(/^\s{4}file:\s*(.+)/m);
      const tasksTotalMatch = block.match(/^\s{4}tasks_total:\s*(\d+)/m);
      milestones[currentMid] = {
        status: statusMatch ? statusMatch[1].trim() : undefined,
        file: fileMatch ? fileMatch[1].trim() : undefined,
        tasks_total: tasksTotalMatch ? parseInt(tasksTotalMatch[1]) : undefined,
      };
    }
    return { milestones };
  }
}

function validateStatusConsistency(): boolean {
  const progressYaml = loadProgressSafe();
  if (!progressYaml) {
    console.warn("⚠️  Status consistency: cannot parse progress.yaml — skipped");
    return true;
  }

  const milestones = progressYaml.milestones;
  if (!milestones || Object.keys(milestones).length === 0) {
    console.warn("⚠️  Status consistency: no milestones in progress.yaml — skipped");
    return true;
  }

  let allOk = true;

  for (const [mid, mdata] of Object.entries(milestones)) {
    if (!mdata || typeof mdata !== "object") continue;
    const pyStatus = mdata.status as string | undefined;
    const docFile = mdata.file as string | undefined;
    if (!pyStatus || !docFile) continue;
    const resolvedDocFile = resolveProgressPointerPath(docFile);
    if (!existsSync(resolvedDocFile)) continue; // handled by validateFilePointers

    const docContent = readFileSync(resolvedDocFile, "utf-8");
    const statusMatch = docContent.match(/^\*\*Status\*\*:\s*(.+)/m);
    if (!statusMatch) continue;

    const docStatus = statusMatch[1].trim().toLowerCase();
    let normalisedDoc = docStatus;
    if (/implemented|completed/.test(normalisedDoc)) normalisedDoc = "completed";
    else if (/design specification|design proposal|proposal|draft|reference|planned/.test(normalisedDoc)) normalisedDoc = "planned";
    else if (/in.progress|in_progress|active/.test(normalisedDoc)) normalisedDoc = "in_progress";

    const normalisedPy = pyStatus === "active" ? "in_progress" : pyStatus;

    if (normalisedDoc !== normalisedPy) {
      console.error(
        `❌ Status desync: ${docFile} **Status**: "${docStatus}" (→${normalisedDoc}) != progress.yaml M${mid.replace(/^M/, "")} status: "${pyStatus}" (→${normalisedPy})`
      );
      allOk = false;
    }
  }

  if (allOk) {
    console.log(`✅ Status consistency: all milestone docs agree with progress.yaml`);
  }
  return allOk;
}

// ── Memory-layer schema enforcement ────────────────────────────
// F-M82-01: relative ACP_SCHEMAS_DIR must resolve from repo root (CI runs from scripts/)
const _schemasDirOverride = process.env["ACP_SCHEMAS_DIR"];
const SCHEMAS_DIR =
  _schemasDirOverride === undefined
    ? repoPath("agent", "schemas")
    : path.isAbsolute(_schemasDirOverride)
      ? _schemasDirOverride
      : repoPath(_schemasDirOverride);
// Map schema files to data files they validate
const SCHEMA_DATA_MAP: Record<string, string> = {
  "progress.schema.yaml": "agent/progress.yaml",
  "session.schema.yaml": "agent/memory/sessions.md",
  "lessons.schema.yaml": "agent/memory/lessons.md",
  "decisions.schema.yaml": "agent/memory/decisions.md",
  "audit-carryovers.schema.yaml": "agent/memory/audit-carryovers.md",
  "patterns.schema.yaml": "agent/memory/patterns.md",
  // milestone.schema.yaml validates route-task frontmatter (id/title/status), not progress.yaml milestones map
};

const USAGE_PATH = repoPath("docs", "USAGE.md");
const CARRYOVERS_PATH = repoPath("agent", "memory", "audit-carryovers.md");
const PATTERNS_PATH = repoPath("agent", "memory", "patterns.md");
const SESSIONS_PATH = repoPath("agent", "memory", "sessions.md");

function splitYamlListEntries(raw: string, entryMarker: RegExp): string[] {
  const stripped = raw.replace(/^(#[^\n]*\n|\s*\n)*/m, "");
  if (stripped.trim() === "") return [];
  return stripped.split(entryMarker).filter((p) => p.trim().startsWith("- "));
}

/** True when CRIT-065-002 is explicitly deferred (e.g. GitHub Free — manual merge discipline). */
export function isBranchProtectionDeferred(
  carryoversPath: string = CARRYOVERS_PATH
): boolean {
  if (!existsSync(carryoversPath)) return false;
  const raw = readFileSync(carryoversPath, "utf8");
  const idx = raw.indexOf("finding_id: CRIT-065-002");
  if (idx === -1) return false;
  const slice = raw.slice(idx, idx + 800);
  return /status:\s*deferred/.test(slice);
}

/**
 * Parse owner/repo from a git remote URL (F-M82-02).
 * Accepts github.com HTTPS/SSH and common SSH host aliases.
 * Rejects owner/repo segments that are not safe path tokens (blocks shell metacharacters).
 */
export function parseGithubOwnerRepo(url: string): string | null {
  const trimmed = url.trim();
  let owner = "";
  let repo = "";

  const ssh = trimmed.match(/^git@([^:]+):([^/]+)\/([^/\s]+?)(?:\.git)?$/i);
  if (ssh) {
    owner = ssh[2];
    repo = ssh[3];
  } else {
    try {
      const normalized = trimmed.includes("://") ? trimmed : `https://${trimmed}`;
      const u = new URL(normalized);
      const parts = u.pathname.replace(/^\/+/, "").replace(/\.git$/i, "").split("/");
      if (parts.length < 2) return null;
      owner = parts[0];
      repo = parts[1];
    } catch {
      return null;
    }
  }

  // Safe path tokens only — never pass unvalidated strings into gh argv
  if (!/^[A-Za-z0-9_.-]+$/.test(owner) || !/^[A-Za-z0-9_.-]+$/.test(repo)) return null;
  if (owner === "." || owner === ".." || repo === "." || repo === "..") return null;
  return `${owner}/${repo}`;
}

function resolveOriginGithubRepo(): string | null {
  if (!commandExists("git")) return null;
  try {
    const url = execFileSync("git", ["remote", "get-url", "origin"], {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
    return parseGithubOwnerRepo(url);
  } catch {
    return null;
  }
}

/** M70 task-220: warn when branch protection checklist in USAGE.md is incomplete */
export function validateBranchProtectionDocs(): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(USAGE_PATH)) {
    errors.push({
      file: USAGE_PATH,
      line: 0,
      message: "USAGE.md missing — cannot verify branch protection checklist",
      severity: "warning",
    });
    return errors;
  }

  const raw = readFileSync(USAGE_PATH, "utf8");
  if (!raw.includes("## Git Branch Protection")) {
    errors.push({
      file: USAGE_PATH,
      line: 0,
      message: "Missing § Git Branch Protection section",
      severity: "warning",
    });
    return errors;
  }

  if (!raw.includes("### Protection checklist")) {
    errors.push({
      file: USAGE_PATH,
      line: 0,
      message: "Missing ### Protection checklist under Git Branch Protection",
      severity: "warning",
    });
  }

  if (commandExists("gh") && !isBranchProtectionDeferred()) {
    try {
      const repo = resolveOriginGithubRepo();
      if (repo) {
        // F-M82-02: never shell-interpolate owner/repo into a command string
        execFileSync("gh", ["api", `repos/${repo}/branches/mainline/protection`], {
          encoding: "utf8",
          stdio: ["pipe", "pipe", "pipe"],
        });
      }
    } catch {
      errors.push({
        file: USAGE_PATH,
        line: 0,
        message:
          "GitHub mainline branch protection not detected (gh api 404) — enable via Settings or acp.branch-protection-setup.sh",
        severity: "warning",
      });
    }
  } else if (isBranchProtectionDeferred()) {
    // CRIT-065-002 deferred — skip live gh api gate (documented in carryovers)
  }

  return errors;
}

function commandExists(cmd: string): boolean {
  try {
    execSync(`command -v ${cmd}`, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

/** M70 task-222: field-level lint for sessions.md and patterns.md (--memory) */
export function validateMemoryFieldLint(): ValidationError[] {
  const errors: ValidationError[] = [];

  for (const [filePath, requiredKeys] of [
    [SESSIONS_PATH, ["date:", "executor:", "done:"] as string[]],
    [PATTERNS_PATH, ["date:", "name:"] as string[]],
  ] as const) {
    if (!existsSync(filePath)) continue;
    const raw = readFileSync(filePath, "utf8");
    const entries = splitYamlListEntries(raw, /\n(?=- date:)/);

    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      for (const key of requiredKeys) {
        if (!entry.includes(key)) {
          errors.push({
            file: filePath,
            line: 0,
            message: `Entry #${i + 1} missing required field ${key.replace(":", "")}`,
            severity: "error",
          });
        }
      }
      if (filePath === PATTERNS_PATH && entry.includes("name:")) {
        const nameMatch = entry.match(/name:\s*([^\n]+)/);
        if (nameMatch && !/^[a-z0-9][a-z0-9-]*$/.test(nameMatch[1].trim())) {
          errors.push({
            file: filePath,
            line: 0,
            message: `Entry #${i + 1} name must be kebab-case`,
            severity: "warning",
          });
        }
      }
    }
  }

  return errors;
}

/** M70 task-223: flag pending carryovers whose fix_target file already exists */
export function validateCarryoverFreshness(
  carryoversPath: string = CARRYOVERS_PATH
): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(carryoversPath)) return errors;

  const raw = readFileSync(carryoversPath, "utf8");
  const blocks = raw.split(/\n  - audit_id:/).slice(1);

  for (const block of blocks) {
    if (!/status:\s*pending/.test(block)) continue;

    const findingId = block.match(/finding_id:\s*(\S+)/)?.[1] ?? "?";
    const fixTarget = block.match(/fix_target:\s*"([^"]+)"/)?.[1] ?? "";

    const fileMatch = fixTarget.match(/([a-zA-Z0-9_./-]+\.(ts|sh|yaml|md))/);
    if (!fileMatch) continue;

    const targetFile = fileMatch[1];
    const absTarget = path.isAbsolute(targetFile)
      ? targetFile
      : path.join(getRepoRoot(), targetFile);
    if (existsSync(absTarget)) {
      const snippet = fixTarget.match(/:\s*(.+)$/)?.[1];
      if (snippet) {
        try {
          const content = readFileSync(absTarget, "utf8");
          if (content.includes(snippet.slice(0, 40))) {
            errors.push({
              file: carryoversPath,
              line: 0,
              message: `${findingId}: pending carryover may be stale — fix_target pattern found in ${targetFile}`,
              severity: "warning",
            });
          }
        } catch {
          // skip unreadable
        }
      }
    }
  }

  return errors;
}

/** M73 task-248: detect false audit-093 stamps on pre-M72 fixes */
export function validateCarryoverAuditStamps(
  carryoversPath: string = CARRYOVERS_PATH
): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(carryoversPath)) return errors;

  const raw = readFileSync(carryoversPath, "utf8");
  const blocks = raw.split(/\n  - audit_id:/).slice(1);
  const m72ClosureDay = "2026-07-15";

  for (const block of blocks) {
    const findingId = block.match(/finding_id:\s*(\S+)/)?.[1] ?? "?";
    const verified = block.match(/verified_in_audit:\s*(\S+)/)?.[1] ?? "";
    const fixDate = block.match(/fix_applied_date:\s*(\S+)/)?.[1] ?? "";

    if (verified !== "audit-093") continue;

    if (fixDate && fixDate < m72ClosureDay) {
      errors.push({
        file: carryoversPath,
        line: 0,
        message: `${findingId}: verified_in_audit audit-093 on pre-M72 fix (${fixDate}) — restore from git history`,
        severity: "error",
      });
    }
  }

  return errors;
}

/** M70 task-229: IG-35 route files_affected drift (warn-only in validate) */
export function validateIg35RouteDrift(): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!commandExists("git")) return errors;

  let changedFiles: string[] = [];
  try {
    const out = execSync("git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --name-only", {
      encoding: "utf8",
    });
    changedFiles = out.split("\n").map((f) => f.trim()).filter(Boolean);
  } catch {
    return errors;
  }

  if (changedFiles.length === 0) return errors;

  let commitMsg = "";
  try {
    commitMsg = execSync("git log -1 --format=%s", { encoding: "utf8" }).trim();
  } catch {
    return errors;
  }

  const routeMatch = commitMsg.match(/route-(\d+)/);
  if (!routeMatch) return errors;

  const routeFile = path.join("agent", "routing", "tasks", `route-${routeMatch[1]}.md`);
  if (!existsSync(routeFile)) return errors;

  const routeRaw = readFileSync(routeFile, "utf8");
  const declared: string[] = [];
  const faBlock = routeRaw.match(/files_affected:\s*\n((?:\s+-\s+.+\n?)*)/);
  if (faBlock) {
    for (const line of faBlock[1].split("\n")) {
      const m = line.match(/^\s+-\s+(.+)$/);
      if (m) declared.push(m[1].trim());
    }
  }

  if (declared.length === 0) return errors;

  for (const f of changedFiles) {
    const normalized = f.replace(/^\.\//, "");
    const covered = declared.some(
      (d) => normalized === d || normalized.startsWith(d.replace(/\*$/, ""))
    );
    if (!covered && normalized.startsWith("agent/")) {
      errors.push({
        file: routeFile,
        line: 0,
        message: `IG-35: ${normalized} changed but not in files_affected for ${routeMatch[0]}`,
        severity: "warning",
      });
    }
  }

  return errors;
}

function runMemoryValidation(): boolean {
  let allOk = true;
  const fieldErrors = validateMemoryFieldLint();
  for (const err of fieldErrors) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }
  if (fieldErrors.length === 0) {
    console.log("✅ Memory field lint: sessions.md + patterns.md valid");
  }
  return allOk;
}

function runM70Guards(): boolean {
  let allOk = true;

  const bp = validateBranchProtectionDocs();
  for (const err of bp) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }
  if (bp.length === 0) {
    console.log("✅ Branch protection docs: checklist complete");
  }

  const cf = validateCarryoverFreshness();
  for (const err of cf) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }
  if (cf.length === 0) {
    console.log("✅ Carryover freshness: no stale pending patterns detected");
  }

  const cas = validateCarryoverAuditStamps();
  for (const err of cas) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }
  if (cas.length === 0) {
    console.log("✅ Carryover audit stamps: no false audit-093 pointers");
  }

  const ig35 = validateIg35RouteDrift();
  for (const err of ig35) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }

  return allOk;
}

function splitCarryoverEntries(raw: string): string[] {
  const idx = raw.indexOf("carryovers:");
  if (idx < 0) return [];
  const body = raw.slice(idx);
  return body
    .split(/\n  - audit_id:/)
    .slice(1)
    .map((block) => `  - audit_id:${block}`);
}

/** M71 task-233: per-entry schema validation for YAML list memory documents */
export function validateSchemaListEntries(
  entryTexts: string[],
  schema: Record<string, unknown>,
  filePath: string,
  fieldAliases: Record<string, string> = {}
): ValidationError[] {
  const requiredFields = schema["required_fields"] as string[] | undefined;
  if (!requiredFields) return [];

  const errors: ValidationError[] = [];

  for (let i = 0; i < entryTexts.length; i++) {
    const entryText = entryTexts[i];
    let record: Record<string, unknown> = {};
    try {
      const loaded = yaml.load(entryText);
      if (loaded && typeof loaded === "object" && !Array.isArray(loaded)) {
        record = loaded as Record<string, unknown>;
      }
    } catch {
      // fall through to line-based checks
    }

    for (const rf of requiredFields) {
      const alias = fieldAliases[rf];
      const hasField =
        rf in record ||
        (alias !== undefined && alias in record) ||
        entryText.includes(`${rf}:`) ||
        (alias !== undefined && entryText.includes(`${alias}:`));
      if (!hasField) {
        errors.push({
          file: filePath,
          line: 0,
          message: `Entry #${i + 1} missing required field: ${rf}`,
          severity: "error",
        });
      }
    }
  }

  return errors;
}

function validateDecisionsAdrEntries(
  filePath: string,
  schema: Record<string, unknown>
): { errors: ValidationError[]; entryCount: number } {
  const raw = readFileSync(filePath, "utf8");
  const blocks = raw.split(/\n(?=## ADR-\d+)/).filter((b) => /^## ADR-/.test(b));
  const requiredFields = schema["required_fields"] as string[] | undefined;
  const errors: ValidationError[] = [];
  if (!requiredFields) return { errors, entryCount: blocks.length };

  for (let i = 0; i < blocks.length; i++) {
    const block = blocks[i];
    const header = block.match(/^## (ADR-\d+) \| (\d{4}-\d{2}-\d{2}) \|/);
    const statusMatch = block.match(/\*\*Status:\*\*\s*(\S+)/);
    const entry: Record<string, string> = {
      id: header?.[1] ?? "",
      date: header?.[2] ?? "",
      status: statusMatch?.[1] ?? "",
    };

    if (!header) {
      errors.push({
        file: filePath,
        line: 0,
        message: `ADR block #${i + 1} missing id/date header`,
        severity: "warning",
      });
      continue;
    }

    for (const rf of requiredFields) {
      if (!entry[rf]) {
        errors.push({
          file: filePath,
          line: 0,
          message: `${entry.id} missing required field: ${rf}`,
          severity: "error",
        });
      }
    }
  }

  return { errors, entryCount: blocks.length };
}

function validateYamlAgainstSchema(
  dataYaml: unknown,
  schema: Record<string, unknown>,
  filePath: string
): ValidationError[] {
  const errors: ValidationError[] = [];
  const requiredFields = schema["required_fields"] as string[] | undefined;
  const fields = schema["fields"] as Record<string, Record<string, unknown>> | undefined;

  if (!fields) return errors;

  // Check required top-level fields
  if (requiredFields) {
    if (typeof dataYaml !== "object" || dataYaml === null || Array.isArray(dataYaml)) {
      // For array-type documents (sessions.md), validate each entry
      return errors;
    }
    for (const rf of requiredFields) {
      if (!(rf in (dataYaml as Record<string, unknown>))) {
        errors.push({
          file: filePath,
          line: 0,
          message: `Missing required field: ${rf}`,
          severity: "error",
        });
      }
    }
  }

  // Check field types
  for (const [fieldName, fieldDef] of Object.entries(fields)) {
    if (typeof dataYaml === "object" && dataYaml !== null && fieldName in (dataYaml as Record<string, unknown>)) {
      const val = (dataYaml as Record<string, unknown>)[fieldName];
      const expectedType = fieldDef["type"] as string | undefined;
      if (expectedType) {
        const actualType = Array.isArray(val) ? "array" : typeof val;
        if (actualType !== expectedType) {
        errors.push({
          file: filePath,
          line: 0,
          message: `Field "${fieldName}" expected type ${expectedType}, got ${actualType}`,
          severity: "warning",
        });
        }
      }
    }
  }

  return errors;
}

function runSchemaEnforcement(): boolean {
  if (!existsSync(SCHEMAS_DIR)) {
    console.log(`⚠️  Schema enforcement: ${SCHEMAS_DIR} not found — skipping`);
    return true;
  }

  const schemaFiles = readdirSync(SCHEMAS_DIR).filter((f) => f.endsWith(".schema.yaml"));
  let allOk = true;

  for (const schemaFile of schemaFiles) {
    const dataFile = SCHEMA_DATA_MAP[schemaFile];
    if (!dataFile) continue;

    try {
      const schemaPath = path.join(SCHEMAS_DIR, schemaFile);
      const schemaContent = readFileSync(schemaPath, "utf8");
      const schema = yaml.load(schemaContent) as Record<string, unknown>;

      const resolvedDataFile = path.isAbsolute(dataFile) ? dataFile : repoPath(dataFile);
      if (!existsSync(resolvedDataFile)) {
        console.log(`⚠️  Schema ${schemaFile}: data file ${dataFile} not found — skipping`);
        continue;
      }

      const dataContent = readFileSync(resolvedDataFile, "utf8");
      let schemaErrors: ValidationError[] = [];
      let entryCount = 0;

      if (schemaFile === "decisions.schema.yaml") {
        const result = validateDecisionsAdrEntries(resolvedDataFile, schema);
        schemaErrors = result.errors;
        entryCount = result.entryCount;
      } else if (
        schemaFile === "lessons.schema.yaml" ||
        schemaFile === "session.schema.yaml" ||
        schemaFile === "patterns.schema.yaml"
      ) {
        const entries = splitYamlListEntries(dataContent, /\n(?=- date:)/);
        entryCount = entries.length;
        schemaErrors = validateSchemaListEntries(entries, schema, resolvedDataFile);
      } else if (schemaFile === "audit-carryovers.schema.yaml") {
        const entryTexts = splitCarryoverEntries(dataContent);
        entryCount = entryTexts.length;
        schemaErrors = validateSchemaListEntries(entryTexts, schema, dataFile, {
          description: "finding",
        });
      } else {
        let dataYaml: unknown;
        try {
          dataYaml = yaml.load(dataContent);
        } catch {
          console.log(`⚠️  Schema ${schemaFile}: YAML parse failed for ${dataFile} — skipping`);
          continue;
        }

        if (!dataYaml) continue;

        if (Array.isArray(dataYaml)) {
          entryCount = dataYaml.length;
          const parts = (dataYaml as Record<string, unknown>[]).map((e) => yaml.dump(e));
          schemaErrors = validateSchemaListEntries(parts, schema, dataFile);
        } else {
          schemaErrors = validateYamlAgainstSchema(dataYaml, schema, dataFile);
        }
      }

      if (schemaErrors.length > 0) {
        for (const err of schemaErrors) {
          const prefix = err.severity === "error" ? "❌" : "⚠️";
          console.log(`${prefix} ${err.file}: ${err.message}  [schema: ${schemaFile}]`);
          if (err.severity === "error") allOk = false;
        }
      } else {
        const label =
          entryCount > 0 ? `${entryCount} entries valid` : `${dataFile} valid`;
        console.log(`✅ Schema ${schemaFile}: ${label}`);
      }
    } catch (err) {
      console.error(`❌ Schema enforcement error: ${schemaFile} — ${err instanceof Error ? err.message : err}`);
      allOk = false;
    }
  }

  return allOk;
}

// ── Cross-file Consistency Validators (route-178) ──────────────

const IDENTITY_PATH = repoPath("agent", "core", "identity.yml");

export function validateNextStepsFreshness(): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(PROGRESS_PATH)) return errors;

  try {
    const raw = readFileSync(PROGRESS_PATH, "utf8");
    const progress = yaml.load(raw) as Record<string, unknown>;
    const currentMilestone = (progress["current_milestone"] as string) || "";
    const nextSteps = progress["next_steps"] as string[] | undefined;

    if (!nextSteps || nextSteps.length === 0) {
      errors.push({
        file: PROGRESS_PATH,
        line: 0,
        message: "next_steps is empty — should reference the next active milestone",
        severity: "warning",
      });
    } else if (currentMilestone && nextSteps[0].includes(currentMilestone)) {
      errors.push({
        file: PROGRESS_PATH,
        line: 0,
        message: `next_steps[0] references current milestone "${currentMilestone}" — should point to the next milestone`,
        severity: "warning",
      });
    }
  } catch {
    // Parse error silently — other validators cover this
  }
  return errors;
}

export function validateMilestoneDocVersion(): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(IDENTITY_PATH)) return errors;

  const identityRaw = readFileSync(IDENTITY_PATH, "utf8");
  const idMatch = identityRaw.match(/^version:\s*([0-9.]+)/m);
  if (!idMatch) return errors;
  const identityVer = idMatch[1];

  const milestonesDir = repoPath("agent", "milestones");
  if (!existsSync(milestonesDir)) return errors;

  const milestoneFiles = readdirSync(milestonesDir).filter(
    (f) => f.startsWith("milestone-") && f.endsWith(".md")
  );

  for (const mf of milestoneFiles) {
    const filePath = path.join(milestonesDir, mf);
    const raw = readFileSync(filePath, "utf8");
    const tvMatch = raw.match(/\*\*Target version\*\*:\s*([0-9.]+)/);
    if (!tvMatch) continue;

    const docVer = tvMatch[1];
    if (docVer !== identityVer) {
      // Only warn for past milestones (Target version < identity version)
      const cmp = docVer.localeCompare(identityVer, undefined, { numeric: true });
      errors.push({
        file: filePath,
        line: 3,
        message: cmp < 0
          ? `Stale target version: doc says v${docVer}, identity.yml is v${identityVer}`
          : `Target version mismatch: doc says v${docVer}, identity.yml is v${identityVer}`,
        severity: cmp < 0 ? "warning" : "error",
      });
    }
  }

  return errors;
}

export function validateVerificationGates(): ValidationError[] {
  const errors: ValidationError[] = [];
  const milestonesDir = repoPath("agent", "milestones");
  if (!existsSync(milestonesDir)) return errors;

  const milestoneFiles = readdirSync(milestonesDir).filter(
    (f) => f.startsWith("milestone-") && f.endsWith(".md")
  );

  for (const mf of milestoneFiles) {
    const filePath = path.join(milestonesDir, mf);
    const raw = readFileSync(filePath, "utf8");

    // Find the verification gate section
    const gateMatch = raw.match(/## Industry-Standard Verification[\s\S]*?(?=\n## |$)/);
    if (!gateMatch) continue;

    const gateSection = gateMatch[0];
    const bullets = gateSection.match(/^- .+$/gm);
    if (!bullets) continue;

    for (const bullet of bullets) {
      const trimmed = bullet.replace(/^- /, "");
      // Check if bullet has a status marker
      if (!/^(✅|❌|⏳)/.test(trimmed) && trimmed.length > 0) {
        errors.push({
          file: filePath,
          line: 0,
          message: `Verification gate item is blank (no ✅/❌/⏳): "${trimmed.substring(0, 60)}..."`,
          severity: "warning",
        });
      }
    }
  }

  return errors;
}

export function validateGitTagsExist(): ValidationError[] {
  const errors: ValidationError[] = [];
  if (!existsSync(IDENTITY_PATH)) return errors;

  const identityRaw = readFileSync(IDENTITY_PATH, "utf8");
  const idMatch = identityRaw.match(/^version:\s*([0-9.]+)/m);
  if (!idMatch) return errors;

  const version = idMatch[1];
  try {
    const output = execSync(`git tag --list "v${version}"`, {
      cwd: process.cwd(),
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    if (!output) {
      errors.push({
        file: IDENTITY_PATH,
        line: 0,
        message: `Missing git tag for v${version}. Run: git tag -a v${version} -m "..." HEAD`,
        severity: "error",
      });
    }
  } catch {
    errors.push({
      file: IDENTITY_PATH,
      line: 0,
      message: "Failed to check git tags — is this a git repository?",
      severity: "warning",
    });
  }

  return errors;
}

export function validateGitignoreConflicts(): ValidationError[] {
  const errors: ValidationError[] = [];
  // Check known tracked paths that have had .gitignore conflicts
  const trackedPaths = ["agent/reports/", "scripts/package-lock.json"];

  for (const tp of trackedPaths) {
    try {
      execSync(`git check-ignore "${tp}"`, {
        cwd: getRepoRoot(),
        encoding: "utf8",
        stdio: ["pipe", "pipe", "pipe"],
      });
      // If exit 0, file is ignored
      errors.push({
        file: ".gitignore",
        line: 0,
        message: `Tracked path "${tp}" is blocked by .gitignore — add !pattern to whitelist`,
        severity: "warning",
      });
    } catch {
      // exit 1 = not ignored (good), or git unavailable
    }
  }

  return errors;
}

export function validateGitattributesCoverage(): ValidationError[] {
  const errors: ValidationError[] = [];
  const attrPath = repoPath(".gitattributes");
  if (!existsSync(attrPath)) {
    errors.push({
      file: attrPath,
      line: 0,
      message: ".gitattributes missing — should enforce LF for cross-platform scripts",
      severity: "error",
    });
    return errors;
  }

  const raw = readFileSync(attrPath, "utf8");
  const requiredPatterns = [
    { pattern: /\*\.sh\s+text\s+eol=lf/, label: "*.sh text eol=lf" },
    { pattern: /\*\.yml\s+text\s+eol=lf/, label: "*.yml text eol=lf" },
    { pattern: /\*\.ts\s+text\s+eol=lf/, label: "*.ts text eol=lf" },
    { pattern: /\*\.json\s+text\s+eol=lf/, label: "*.json text eol=lf" },
  ];

  for (const rp of requiredPatterns) {
    if (!rp.pattern.test(raw)) {
      errors.push({
        file: attrPath,
        line: 0,
        message: `Missing LF enforcement: ${rp.label} — add to .gitattributes`,
        severity: "warning",
      });
    }
  }

  return errors;
}

function runConsistencyScan(): boolean {
  let allOk = true;

  const checks: [string, () => ValidationError[]][] = [
    ["version consistency", validateVersionConsistency],
    ["next steps freshness", validateNextStepsFreshness],
    ["milestone doc version", validateMilestoneDocVersion],
    ["verification gates", validateVerificationGates],
    ["git tags", validateGitTagsExist],
    ["gitignore conflicts", validateGitignoreConflicts],
    ["gitattributes coverage", validateGitattributesCoverage],
  ];

  for (const [name, fn] of checks) {
    try {
      const errors = fn();
      if (errors.length === 0) {
        console.log(`✅ Consistency: ${name} — OK`);
      } else {
        for (const err of errors) {
          const prefix = err.severity === "error" ? "❌" : "⚠️";
          console.log(`${prefix} ${err.file}: ${err.message}`);
          if (err.severity === "error") allOk = false;
        }
      }
    } catch (err) {
      console.error(`❌ Consistency check "${name}" failed: ${err instanceof Error ? err.message : err}`);
      allOk = false;
    }
  }

  return allOk;
}

function validateFilePointers(): boolean {
  const progressYaml = loadProgressSafe();
  if (!progressYaml) {
    console.warn("⚠️  File pointer check: cannot parse progress.yaml — skipped");
    return true;
  }

  const milestones = progressYaml.milestones;
  if (!milestones || Object.keys(milestones).length === 0) {
    console.warn("⚠️  File pointer check: no milestones in progress.yaml — skipped");
    return true;
  }

  let allOk = true;
  const seen = new Set<string>();

  for (const [mid, mdata] of Object.entries(milestones)) {
    if (!mdata || typeof mdata !== "object") continue;
    const docFile = mdata.file as string | undefined;
    const tasksTotal = mdata.tasks_total as number | undefined;
    const status = mdata.status as string | undefined;

    if (docFile) {
      if (seen.has(docFile)) continue;
      seen.add(docFile);
      const resolvedDocFile = resolveProgressPointerPath(docFile);
      if (!existsSync(resolvedDocFile)) {
        console.error(`❌ Dangling pointer: M${mid.replace(/^M/, "")} file: "${docFile}" does not exist`);
        allOk = false;
      }
    }

    if (tasksTotal === 0 && status && /active|in_progress/.test(status)) {
      console.error(
        `❌ Inconsistency: M${mid.replace(/^M/, "")} status: "${status}" but tasks_total: 0`
      );
      allOk = false;
    }
  }

  if (allOk) {
    console.log(`✅ File pointers: all progress.yaml file: references exist`);
  }
  return allOk;
}

// ── Active handoff validation (M67 route-198) ─────────────────
export function validateActiveHandoff(strict = false): ValidationError[] {
  const errors: ValidationError[] = [];
  const progressYaml = loadProgressSafe();
  if (!progressYaml) return errors;

  const activeHandoff = progressYaml.active_handoff as Record<string, unknown> | undefined;
  if (!activeHandoff || !activeHandoff.path) return errors;

  const handoffPath = String(activeHandoff.path);
  const resolvedHandoffPath = resolveProgressPointerPath(handoffPath);
  if (!existsSync(resolvedHandoffPath)) {
    errors.push({
      file: PROGRESS_PATH,
      line: 0,
      message: `active_handoff.path "${handoffPath}" does not exist`,
      severity: "error",
    });
    return errors;
  }

  const gitCommit = activeHandoff.git_commit ? String(activeHandoff.git_commit) : "";
  if (strict && gitCommit) {
    try {
      execSync(`git merge-base --is-ancestor ${gitCommit} HEAD`, {
        cwd: getRepoRoot(),
        encoding: "utf8",
        stdio: ["pipe", "pipe", "pipe"],
      });
    } catch {
      errors.push({
        file: PROGRESS_PATH,
        line: 0,
        message: `active_handoff.git_commit "${gitCommit}" is not an ancestor of HEAD`,
        severity: "warning",
      });
    }
  }

  return errors;
}

// ── Install/update destructive-pattern guard (M68 route-204) ───
const DESTRUCTIVE_INSTALL_UPDATE_PATTERNS: Array<{ pattern: RegExp; message: string }> = [
  {
    pattern: /cp\s+["']?\$TEMP_DIR\/agent\/core\/["']?\*\.yml/,
    message: "blind cp of agent/core/*.yml — use acp_copy_framework_file()",
  },
  {
    pattern: /cat\s+>\s*["']?\$TARGET_DIR\/agent\/manifest\.yaml\s*<<\s*EOF[\s\S]{0,400}acp-core:/,
    message: "cat > manifest.yaml with acp-core block wipes packages — use acp_install_manifest_acp_core()",
  },
  {
    pattern: /find\s+["']?\$TEMP_DIR\/agent\/commands["']?[^;]*-exec\s+cp/,
    message: "blind find commands -exec cp — copy acp.* and git.* only",
  },
];

export function validateInstallUpdateSafety(): ValidationError[] {
  const errors: ValidationError[] = [];
  const targets = [
    "agent/scripts/acp.version-update.sh",
    "agent/scripts/acp.install.sh",
  ];
  for (const rel of targets) {
    const full = path.join(process.cwd(), rel);
    if (!existsSync(full)) continue;
    const content = readFileSync(full, "utf8");
    if (content.includes("acp_copy_framework_file") || content.includes("acp_merge_manifest_acp_core")) {
      // expected — still scan for forbidden patterns
    }
    for (const { pattern, message } of DESTRUCTIVE_INSTALL_UPDATE_PATTERNS) {
      if (pattern.test(content)) {
        errors.push({
          file: rel,
          line: 0,
          message,
          severity: "error",
        });
      }
    }
  }
  return errors;
}

const COMMAND_E2E_COVERAGE_FILE = repoPath("agent", "schemas", "command-e2e-coverage.yaml");

export interface CommandE2eCoverageOptions {
  commandsDir?: string;
  repoRoot?: string;
}

export function validateCommandE2eCoverage(
  coverageFile: string = COMMAND_E2E_COVERAGE_FILE,
  options: CommandE2eCoverageOptions = {}
): ValidationError[] {
  const errors: ValidationError[] = [];
  const repoRoot = options.repoRoot ?? getRepoRoot();
  const commandsDir = options.commandsDir ?? path.join(repoRoot, "agent", "commands");
  if (!existsSync(coverageFile)) {
    errors.push({
      file: coverageFile,
      line: 0,
      message: "missing command E2E coverage registry (M63)",
      severity: "error",
    });
    return errors;
  }

  let doc: { commands?: Record<string, { suites?: string[]; tier?: number }> };
  try {
    doc = yaml.load(readFileSync(coverageFile, "utf8")) as typeof doc;
  } catch {
    errors.push({
      file: coverageFile,
      line: 0,
      message: "invalid YAML in command E2E coverage registry",
      severity: "error",
    });
    return errors;
  }

  const registry = doc.commands ?? {};
  if (!existsSync(commandsDir)) {
    errors.push({
      file: commandsDir,
      line: 0,
      message: "missing commands directory for E2E coverage check",
      severity: "error",
    });
    return errors;
  }
  const commandFiles = readdirSync(commandsDir).filter(
    (f) => f.startsWith("acp.") && f.endsWith(".md") && f !== "command.template.md"
  );

  for (const file of commandFiles) {
    const cmd = file.replace(/\.md$/, "");
    const entry = registry[cmd];
    if (!entry) {
      errors.push({
        file: coverageFile,
        line: 0,
        message: `no E2E coverage entry for ${cmd}`,
        severity: "error",
      });
      continue;
    }
    const suites = entry.suites ?? [];
    if (suites.length === 0) {
      errors.push({
        file: coverageFile,
        line: 0,
        message: `${cmd} has empty suites list`,
        severity: "error",
      });
    }
    for (const suite of suites) {
      const suitePath = path.isAbsolute(suite) ? suite : path.join(repoRoot, suite);
      if (!existsSync(suitePath)) {
        errors.push({
          file: suitePath,
          line: 0,
          message: `missing E2E suite for ${cmd}: ${suite}`,
          severity: "error",
        });
      }
    }
  }

  for (const cmd of Object.keys(registry)) {
    if (!existsSync(path.join(commandsDir, `${cmd}.md`))) {
      errors.push({
        file: coverageFile,
        line: 0,
        message: `orphan coverage entry ${cmd} — no command doc`,
        severity: "warning",
      });
    }
  }

  return errors;
}

function runCommandE2eCoverageValidation(): boolean {
  const repoRoot = getRepoRoot();
  const errors = validateCommandE2eCoverage(COMMAND_E2E_COVERAGE_FILE, { repoRoot });
  const blocking = errors.filter((e) => e.severity === "error");
  if (blocking.length === 0) {
    const commandsDir = path.join(repoRoot, "agent", "commands");
    const cmdCount = readdirSync(commandsDir).filter(
      (f) => f.startsWith("acp.") && f.endsWith(".md") && f !== "command.template.md"
    ).length;
    console.log(`✅ Command E2E coverage: ${cmdCount} commands mapped (0 untested)`);
    for (const err of errors.filter((e) => e.severity === "warning")) {
      console.log(`⚠️  ${err.file}: ${err.message}`);
    }
    return true;
  }
  for (const err of blocking) {
    console.log(`❌ ${err.file}: ${err.message}`);
  }
  return false;
}

function runInstallUpdateSafetyValidation(): boolean {
  const errors = validateInstallUpdateSafety();
  if (errors.length === 0) {
    console.log("✅ Install/update safety: no destructive blind-copy patterns");
    return true;
  }
  for (const err of errors) {
    console.log(`❌ ${err.file}: ${err.message}`);
  }
  return false;
}

function runActiveHandoffValidation(): boolean {
  const strict =
    process.env["ACP_VALIDATE_STRICT"] === "true" || process.argv.includes("--strict");
  const errors = validateActiveHandoff(strict);
  if (errors.length === 0) {
    const progressYaml = loadProgressSafe();
    const hasHandoff = Boolean(
      progressYaml &&
        (progressYaml.active_handoff as Record<string, unknown> | undefined)?.path
    );
    if (hasHandoff) {
      console.log("✅ Active handoff: path exists");
    } else {
      console.log("✅ Active handoff: none configured — skipped");
    }
    return true;
  }

  let allOk = true;
  for (const err of errors) {
    const prefix = err.severity === "error" ? "❌" : "⚠️";
    console.log(`${prefix} ${err.file}: ${err.message}`);
    if (err.severity === "error") allOk = false;
  }
  return allOk;
}

// ── CLI entry (skip when imported by tests) ───────────────────
function isDirectExecution(): boolean {
  const entry = process.argv[1] ?? "";
  return entry.replace(/\\/g, "/").endsWith("acp-validate.ts");
}

// ── Main ───────────────────────────────────────────────────
const args = process.argv.slice(2);
const memoryMode = args.includes("--memory");
const taskFileArgs = args.filter((a) => !a.startsWith("--"));

if (isDirectExecution()) {
if (taskFileArgs.length === 0) {
  // No args: run all command-file scans
  const rootErrors = assertRepoRoot();
  if (rootErrors.length > 0) {
    for (const err of rootErrors) {
      console.error(`❌ ${err.file}: ${err.message}`);
    }
    process.exit(1);
  }
  runPlaceholderScan();
  runFrontmatterScan();
  const parityOk = runParityCheck();
  const instructionOk = runInstructionAndPackageChecks();
  const sizeOk = validateAgentsMdSize();
  const sessionsValid = validateSessionsMemory();
  const memoryDupesOk = validateMemoryDuplicateKeys();
  const progressParsesOk = validateProgressYamlParses();
  const hookBindingsOk = validateHookTaskBindings();
  const versionOk = validateVersionConsistency().length === 0;
  const statusOk = validateStatusConsistency();
  const pointersOk = validateFilePointers();
  const handoffOk = runActiveHandoffValidation();
  const installUpdateOk = runInstallUpdateSafetyValidation();
  const commandE2eOk = runCommandE2eCoverageValidation();
  const schemasOk = runSchemaEnforcement();
  const m70Ok = runM70Guards();
  const memoryOk = memoryMode ? runMemoryValidation() : true;
  const consistencyOk = runConsistencyScan();
  checkStaleness(); // informational — non-blocking, does not affect exit code
  process.exit(
    parityOk &&
      instructionOk &&
      sizeOk &&
      sessionsValid &&
      memoryDupesOk &&
      progressParsesOk &&
      hookBindingsOk &&
      versionOk &&
      statusOk &&
      pointersOk &&
      handoffOk &&
      installUpdateOk &&
      commandE2eOk &&
      schemasOk &&
      m70Ok &&
      memoryOk &&
      consistencyOk &&
      (process.exitCode ?? 0) === 0
      ? 0
      : 1
  );
}

let overallFailed = false;

for (const taskFile of taskFileArgs) {
  const errors = validateTaskFile(taskFile);
  if (errors.length === 0) {
    console.log(`✓ ${taskFile}`);
  } else {
    overallFailed = true;
    console.error(`✗ ${taskFile}`);
    for (const err of errors) {
      console.error(`  - ${err}`);
    }
  }
}

process.exit(overallFailed ? 1 : 0);
}
