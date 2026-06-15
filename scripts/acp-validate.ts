import matter from "gray-matter";
import yaml from "js-yaml";
import { readFileSync, existsSync, readdirSync, statSync } from "fs";
import path from "path";

// ── Shared types ─────────────────────────────────────────────
interface ValidationError {
  file: string;
  line: number;
  message: string;
  severity: "error" | "warning";
}

// ── Placeholder detection ─────────────────────────────────────
// Env var ACP_COMMANDS_DIR overrides default — used in tests
const COMMANDS_DIR = process.env["ACP_COMMANDS_DIR"] ?? path.join("agent", "commands");

function validatePlaceholders(filePath: string): ValidationError[] {
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

function validateFrontmatter(filePath: string): ValidationError[] {
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

// ── Triple-file parity check ──────────────────────────────────
// Env vars ACP_PROMPTS_DIR / ACP_OPENCODE_DIR override defaults — used in tests
const PROMPTS_DIR = process.env["ACP_PROMPTS_DIR"] ?? path.join(".github", "prompts");
const OPENCODE_DIR = process.env["ACP_OPENCODE_DIR"] ?? path.join(".opencode", "commands");

function runParityCheck(): void {
  const commandFiles = existsSync(COMMANDS_DIR)
    ? readdirSync(COMMANDS_DIR).filter(
        (f) => f.startsWith("acp.") && f.endsWith(".md") && !f.endsWith(".template.md")
      )
    : [];

  const promptFiles = existsSync(PROMPTS_DIR)
    ? readdirSync(PROMPTS_DIR).filter(
        (f) => f.startsWith("acp-") && f.endsWith(".prompt.md")
      )
    : [];

  const opencodeFiles = existsSync(OPENCODE_DIR)
    ? readdirSync(OPENCODE_DIR).filter(
        (f) => f.startsWith("acp-") && f.endsWith(".md")
      )
    : [];

  // Build normalized name sets (strip prefix/suffix for comparison)
  const commandsSet = new Set(
    commandFiles.map((f) => f.replace(/^\.?acp\./, "").replace(/\.md$/, ""))
  );
  const promptsSet = new Set(
    promptFiles.map((f) => f.replace(/^acp-/, "").replace(/\.prompt\.md$/, ""))
  );
  const opencodeSet = new Set(
    opencodeFiles.map((f) => f.replace(/^acp-/, "").replace(/\.md$/, ""))
  );

  const missingItems: string[] = [];

  // Commands missing prompt or opencode companion
  for (const name of commandsSet) {
    if (!promptsSet.has(name)) {
      missingItems.push(
        `❌ Parity: acp.${name}.md has no prompt companion (.github/prompts/acp-${name}.prompt.md)`
      );
    }
    if (!opencodeSet.has(name)) {
      missingItems.push(
        `❌ Parity: acp.${name}.md has no opencode companion (.opencode/commands/acp-${name}.md)`
      );
    }
  }

  // Prompts with no matching command doc
  for (const name of promptsSet) {
    if (!commandsSet.has(name)) {
      missingItems.push(
        `❌ Parity: .github/prompts/acp-${name}.prompt.md has no command doc (agent/commands/acp.${name}.md)`
      );
    }
  }

  // Opencode files with no matching command doc
  for (const name of opencodeSet) {
    if (!commandsSet.has(name)) {
      missingItems.push(
        `❌ Parity: .opencode/commands/acp-${name}.md has no command doc (agent/commands/acp.${name}.md)`
      );
    }
  }

  const cc = commandFiles.length;
  const pc = promptFiles.length;
  const oc = opencodeFiles.length;

  if (missingItems.length === 0) {
    console.log(`✅ Parity: ${cc} commands × 3 surfaces — all matched`);
  } else {
    console.warn(`Parity check: ${cc} commands / ${pc} prompts / ${oc} opencode — ${missingItems.length} mismatch(es)`);
    for (const m of missingItems) {
      console.warn(`  ${m}`);
    }
  }
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
    const taxonomy = loadYaml<any>(TAXONOMY_PATH);
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
    const config = loadYaml<any>(CONFIG_PATH);
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
  const TAXONOMY_PATH_LOCAL = path.join("agent", "routing", "taxonomy.yml");
  const CONFIG_PATH_LOCAL = path.join("agent", "routing", "config.yml");
  const DAY_MS = 1000 * 60 * 60 * 24;
  const now = Date.now();
  let hasWarnings = false;

  // taxonomy.yml last_updated check (warn after 90 days)
  if (!existsSync(TAXONOMY_PATH_LOCAL)) {
    console.warn("⚠️  taxonomy.yml: file not found — staleness unknown");
    hasWarnings = true;
  } else {
    const taxonomy = yaml.load(readFileSync(TAXONOMY_PATH_LOCAL, "utf-8")) as Record<string, any>;
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
    const config = yaml.load(readFileSync(CONFIG_PATH_LOCAL, "utf-8")) as Record<string, any>;
    const models = config?.models as Record<string, any> | undefined;
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
    const taxonomy2 = yaml.load(readFileSync(TAXONOMY_PATH_LOCAL, "utf-8")) as Record<string, any>;
    const lu = taxonomy2?.last_updated ?? "unknown";
    const d2 = new Date(lu);
    const days2 = isNaN(d2.getTime()) ? "?" : Math.floor((now - d2.getTime()) / DAY_MS);
    console.log(`✅ Staleness: taxonomy.yml ${days2} days old, all models verified within 180 days`);
  }
  return !hasWarnings;
}

// ── Validate AGENTS.md / CLAUDE.md byte size (VALIDATE-001) ─
function validateAgentsMdSize(): boolean {
  const constraintsPath = path.join("agent", "core", "constraints.yml");
  if (!existsSync(constraintsPath)) {
    console.warn("⚠️  constraints.yml not found — skipping AGENTS.md size check");
    return true;
  }

  const constraints = yaml.load(readFileSync(constraintsPath, "utf-8")) as Record<string, any>;
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
    if (!existsSync(file)) {
      console.warn(`⚠️  ${file}: not found — skipping size check`);
      continue;
    }
    const size = statSync(file).size;
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
  const sessionsPath = path.join("agent", "memory", "sessions.md");
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

// ── Version consistency (identity.yml ↔ AGENTS.md header) ────
function validateVersionConsistency(): boolean {
  const identityPath = path.join("agent", "core", "identity.yml");
  const agentsPath = "AGENTS.md";
  if (!existsSync(identityPath) || !existsSync(agentsPath)) {
    console.warn("⚠️  Version consistency: identity.yml or AGENTS.md missing — skipped");
    return true;
  }

  const identity = yaml.load(readFileSync(identityPath, "utf-8")) as Record<string, unknown>;
  const canonical = String(identity.version ?? "").trim();
  const agents = readFileSync(agentsPath, "utf-8");
  const headerMatch = agents.match(/^> v([\d.]+)/m);
  const headerVersion = headerMatch?.[1]?.trim() ?? "";

  if (!canonical) {
    console.warn("⚠️  Version consistency: identity.yml has no version field");
    return true;
  }

  if (!headerVersion) {
    console.warn("⚠️  AGENTS.md: missing `> vX.Y.Z` version header line");
    return true;
  }

  if (headerVersion !== canonical) {
    console.warn(
      `⚠️  Version drift: AGENTS.md header v${headerVersion} != identity.yml ${canonical}`
    );
    return true; // soft warn per route-164; hard-fail can be enabled post-M59
  }

  console.log(`✅ Version header: AGENTS.md v${headerVersion} matches identity.yml`);
  return true;
}

// ── Main ───────────────────────────────────────────────────
const args = process.argv.slice(2);
if (args.length === 0) {
  // No args: run all command-file scans
  runPlaceholderScan();
  runFrontmatterScan();
  runParityCheck();
  const sizeOk = validateAgentsMdSize();
  const sessionsValid = validateSessionsMemory();
  validateVersionConsistency();
  checkStaleness(); // informational — non-blocking, does not affect exit code
  process.exit(sizeOk && sessionsValid && (process.exitCode ?? 0) === 0 ? 0 : 1);
}

let overallFailed = false;

for (const taskFile of args) {
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
