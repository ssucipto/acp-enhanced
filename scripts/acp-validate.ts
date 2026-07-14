import matter from "gray-matter";
import yaml from "js-yaml";
import { readFileSync, existsSync, readdirSync, statSync } from "fs";
import path from "path";

// ── Shared types ─────────────────────────────────────────────
export interface ValidationError {
  file: string;
  line: number;
  message: string;
  severity: "error" | "warning";
}

// ── Placeholder detection ─────────────────────────────────────
// Env var ACP_COMMANDS_DIR overrides default — used in tests
const COMMANDS_DIR = process.env["ACP_COMMANDS_DIR"] ?? path.join("agent", "commands");

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

// ── Version consistency (identity.yml ↔ AGENTS.md ↔ CLAUDE.md ↔ CHANGELOG) ────
export function validateVersionConsistency(): ValidationError[] {
  const errors: ValidationError[] = [];
  const identityPath = path.join("agent", "core", "identity.yml");
  const files: Record<string, string> = {};

  // Extract version from identity.yml
  if (existsSync(identityPath)) {
    const identity = yaml.load(readFileSync(identityPath, "utf-8")) as Record<string, unknown>;
    const ver = String(identity.version ?? "").trim();
    if (ver) files["identity.yml"] = ver;
  }

  // AGENTS.md first line
  if (existsSync("AGENTS.md")) {
    const raw = readFileSync("AGENTS.md", "utf8");
    const match = raw.match(/^> v([\d.]+)/m);
    if (match) files["AGENTS.md"] = match[1];
  }

  // CLAUDE.md first line
  if (existsSync("CLAUDE.md")) {
    const raw = readFileSync("CLAUDE.md", "utf8");
    const match = raw.match(/^> v([\d.]+)/m);
    if (match) files["CLAUDE.md"] = match[1];
  }

  // CHANGELOG.md first release entry
  if (existsSync("CHANGELOG.md")) {
    const raw = readFileSync("CHANGELOG.md", "utf8");
    const match = raw.match(/^## \[([\d.]+)\]/m);
    if (match) files["CHANGELOG.md"] = match[1];
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
const PROGRESS_PATH = path.join("agent", "progress.yaml");

function loadProgressSafe(): Record<string, any> | null {
  if (!existsSync(PROGRESS_PATH)) return null;
    const raw = readFileSync(PROGRESS_PATH, "utf-8").replace(/\r/g, "");
  try {
    return yaml.load(raw) as Record<string, any>;
  } catch {
    console.warn("⚠️  progress.yaml: YAML parse failed (duplicate keys suspected) — using line-based fallback");
    const milestones: Record<string, any> = {};
    const lines = raw.split("\n");
    let currentMid: string | null = null;
    let currentBlock: string[] = [];
    for (const line of lines) {
      const mKeyMatch = line.match(/^\s{2}(M\d{1,2}):\s*$/);
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

  const milestones = progressYaml.milestones as Record<string, any> | undefined;
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
    if (!existsSync(docFile)) continue; // handled by validateFilePointers

    const docContent = readFileSync(docFile, "utf-8");
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
const SCHEMAS_DIR = process.env["ACP_SCHEMAS_DIR"] ?? path.join("agent", "schemas");
// Map schema files to data files they validate
const SCHEMA_DATA_MAP: Record<string, string> = {
  "progress.schema.yaml": "agent/progress.yaml",
  "session.schema.yaml": "agent/memory/sessions.md",
  "lessons.schema.yaml": "agent/memory/lessons.md",
  "decisions.schema.yaml": "agent/memory/decisions.md",
  "audit-carryovers.schema.yaml": "agent/memory/audit-carryovers.md",
  // milestone.schema.yaml validates route-task frontmatter (id/title/status), not progress.yaml milestones map
};

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

      if (!existsSync(dataFile)) {
        console.log(`⚠️  Schema ${schemaFile}: data file ${dataFile} not found — skipping`);
        continue;
      }

      const dataContent = readFileSync(dataFile, "utf8");
      // sessions.md / lessons.md are multi-document YAML lists; try loading as-is
      let dataYaml: unknown;
      try {
        dataYaml = yaml.load(dataContent);
      } catch {
        // If YAML parse fails, that's a pre-existing error from other validators
        continue;
      }

      if (!dataYaml) continue;

      const errors = validateYamlAgainstSchema(dataYaml, schema, dataFile);
      if (errors.length > 0) {
        for (const err of errors) {
          const prefix = err.severity === "error" ? "❌" : "⚠️";
          console.log(`${prefix} ${err.file}: ${err.message}  [schema: ${schemaFile}]`);
          if (err.severity === "error") allOk = false;
        }
      } else {
        console.log(`✅ Schema ${schemaFile}: ${dataFile} valid`);
      }
    } catch (err) {
      console.error(`❌ Schema enforcement error: ${schemaFile} — ${err instanceof Error ? err.message : err}`);
      allOk = false;
    }
  }

  return allOk;
}

// ── Cross-file Consistency Validators (route-178) ──────────────

const IDENTITY_PATH = "agent/core/identity.yml";

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

  const milestonesDir = "agent/milestones";
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
  const milestonesDir = "agent/milestones";
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
    const { execSync } = require("child_process");
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
      const { execSync } = require("child_process");
      execSync(`git check-ignore "${tp}"`, {
        cwd: process.cwd(),
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
  const attrPath = ".gitattributes";
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

  const milestones = progressYaml.milestones as Record<string, any> | undefined;
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
      if (!existsSync(docFile)) {
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
  if (!existsSync(handoffPath)) {
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
      const { execSync } = require("child_process");
      execSync(`git merge-base --is-ancestor ${gitCommit} HEAD`, {
        cwd: process.cwd(),
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
if (isDirectExecution()) {
if (args.length === 0) {
  // No args: run all command-file scans
  runPlaceholderScan();
  runFrontmatterScan();
  runParityCheck();
  const sizeOk = validateAgentsMdSize();
  const sessionsValid = validateSessionsMemory();
  const versionOk = validateVersionConsistency().length === 0;
  const statusOk = validateStatusConsistency();
  const pointersOk = validateFilePointers();
  const handoffOk = runActiveHandoffValidation();
  const schemasOk = runSchemaEnforcement();
  const consistencyOk = runConsistencyScan();
  checkStaleness(); // informational — non-blocking, does not affect exit code
  process.exit(sizeOk && sessionsValid && versionOk && statusOk && pointersOk && handoffOk && schemasOk && consistencyOk && (process.exitCode ?? 0) === 0 ? 0 : 1);
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
}
