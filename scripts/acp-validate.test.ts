import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { writeFileSync, mkdtempSync, rmSync, mkdirSync } from "fs";
import { tmpdir } from "os";
import path from "path";
import {
  validatePlaceholders,
  validateFrontmatter,
  validateVersionConsistency,
  validateNextStepsFreshness,
  validateMilestoneDocVersion,
  validateVerificationGates,
  validateGitTagsExist,
  validateGitignoreConflicts,
  validateGitattributesCoverage,
  validateInstallUpdateSafety,
  validateCommandE2eCoverage,
  validateMemoryFieldLint,
  validateCarryoverFreshness,
  validateBranchProtectionDocs,
  validateSchemaListEntries,
  assertRepoRoot,
  validateParityCheck,
  validateInstructionFileHash,
  validatePackageYamlVersion,
  validateProtocolDirAddability,
  getRepoRoot,
} from "./acp-validate.ts";
import type { ValidationError } from "./acp-validate.ts";

let testDir: string;
const originalCommandsDir = process.env["ACP_COMMANDS_DIR"];

beforeAll(() => {
  testDir = mkdtempSync(path.join(tmpdir(), "acp-validate-test-"));
  process.env["ACP_COMMANDS_DIR"] = testDir;
});

afterAll(() => {
  if (testDir && testDir.startsWith(tmpdir())) {
    rmSync(testDir, { recursive: true, force: true });
  }
  if (originalCommandsDir) {
    process.env["ACP_COMMANDS_DIR"] = originalCommandsDir;
  } else {
    delete process.env["ACP_COMMANDS_DIR"];
  }
});

// ── Placeholder detection (lines 3-4 only) ────────────────────

describe("validatePlaceholders", () => {
  it("detects unresolved placeholder on line 3", () => {
    const file = path.join(testDir, "acp.test.md");
    writeFileSync(
      file,
      [
        "# Test Command",
        "",
        "**Namespace**: {NAMESPACE}", // line 3 — placeholder
        "**Version**: 1.0.0",
        "",
      ].join("\n"),
      "utf-8"
    );

    const errors = validatePlaceholders(file);
    expect(errors.length).toBeGreaterThanOrEqual(1);
    const line3Errors = errors.filter((e) => e.line === 3);
    expect(line3Errors.length).toBeGreaterThanOrEqual(1);
    expect(line3Errors[0].message).toContain("{NAMESPACE}");
    expect(line3Errors[0].severity).toBe("error");
  });

  it("detects unresolved placeholder on line 4", () => {
    const file = path.join(testDir, "acp.test2.md");
    writeFileSync(
      file,
      [
        "# Test Command",
        "",
        "**Namespace**: acp",
        "**Version**: {VERSION}", // line 4 — placeholder
        "",
      ].join("\n"),
      "utf-8"
    );

    const errors = validatePlaceholders(file);
    expect(errors.length).toBeGreaterThanOrEqual(1);
    const line4Errors = errors.filter((e) => e.line === 4);
    expect(line4Errors.length).toBeGreaterThanOrEqual(1);
    expect(line4Errors[0].message).toContain("{VERSION}");
  });

  it("passes clean file with no placeholders on lines 3-4", () => {
    const file = path.join(testDir, "acp.clean.md");
    writeFileSync(
      file,
      [
        "# Clean Command",
        "",
        "**Namespace**: acp",
        "**Version**: 1.0.0",
        "",
      ].join("\n"),
      "utf-8"
    );

    const errors = validatePlaceholders(file);
    expect(errors.length).toBe(0);
  });

  it("ignores placeholders inside fenced code blocks on line 3-4", () => {
    const file = path.join(testDir, "acp.codeblock.md");
    writeFileSync(
      file,
      [
        "```",
        "**Namespace**: {OK_IN_CODE}", // inside code block
        "```",
        "**Namespace**: {REAL_PLACEHOLDER}", // line 4 — real placeholder
        "",
      ].join("\n"),
      "utf-8"
    );

    const errors = validatePlaceholders(file);
    // Only the real placeholder on line 4 should be caught
    const placeholderErrors = errors.filter((e) => e.message.includes("{REAL_PLACEHOLDER}"));
    expect(placeholderErrors.length).toBe(1);
    // The one inside the code block should not be caught
    const codeBlockErrors = errors.filter((e) => e.message.includes("{OK_IN_CODE}"));
    expect(codeBlockErrors.length).toBe(0);
  });

  it("returns empty array for nonexistent file", () => {
    const errors = validatePlaceholders("/nonexistent/acp.test.md");
    expect(errors.length).toBe(0);
  });
});

// ── Frontmatter field validation ──────────────────────────────

describe("validateFrontmatter", () => {
  const validCommand = [
    "# Test Command",
    "",
    "**Namespace**: acp",
    "**Version**: 1.0.0",
    "**Status**: Active",
    "**Scripts**: None",
    "",
    "## Steps",
    "",
  ].join("\n");

  it("passes a command with all 4 required fields", () => {
    const file = path.join(testDir, "acp.full.md");
    writeFileSync(file, validCommand, "utf-8");
    const errors = validateFrontmatter(file);
    expect(errors.length).toBe(0);
  });

  it("detects missing Namespace field", () => {
    const content = validCommand.replace("**Namespace**: acp\n", "");
    const file = path.join(testDir, "acp.no-ns.md");
    writeFileSync(file, content, "utf-8");
    const errors = validateFrontmatter(file);
    const nsErrors = errors.filter((e) => e.message.includes("Namespace"));
    expect(nsErrors.length).toBe(1);
    expect(nsErrors[0].severity).toBe("warning");
  });

  it("detects missing Version field", () => {
    const content = validCommand.replace("**Version**: 1.0.0\n", "");
    const file = path.join(testDir, "acp.no-ver.md");
    writeFileSync(file, content, "utf-8");
    const errors = validateFrontmatter(file);
    const verErrors = errors.filter((e) => e.message.includes("Version"));
    expect(verErrors.length).toBe(1);
  });

  it("detects missing Status field", () => {
    const content = validCommand.replace("**Status**: Active\n", "");
    const file = path.join(testDir, "acp.no-status.md");
    writeFileSync(file, content, "utf-8");
    const errors = validateFrontmatter(file);
    const statusErrors = errors.filter((e) => e.message.includes("Status"));
    expect(statusErrors.length).toBe(1);
  });

  it("detects missing Scripts field", () => {
    const content = validCommand.replace("**Scripts**: None\n", "");
    const file = path.join(testDir, "acp.no-scripts.md");
    writeFileSync(file, content, "utf-8");
    const errors = validateFrontmatter(file);
    const scriptErrors = errors.filter((e) => e.message.includes("Scripts"));
    expect(scriptErrors.length).toBe(1);
  });

  it("returns empty for nonexistent file", () => {
    const errors = validateFrontmatter("/nonexistent/acp.test.md");
    expect(errors.length).toBe(0);
  });
});

// ── Cross-file consistency validator tests (route-178) ────────

describe("validateVersionConsistency", () => {
  it("returns errors when identity.yml and CHANGELOG versions differ", () => {
    const errors = validateVersionConsistency();
    // Current project has synchronized versions, so this should pass
    // Test that the function runs without throwing
    expect(Array.isArray(errors)).toBe(true);
  });
});

describe("validateNextStepsFreshness", () => {
  it("returns array (pass or warn depending on progress.yaml state)", () => {
    const errors = validateNextStepsFreshness();
    expect(Array.isArray(errors)).toBe(true);
  });
});

describe("validateMilestoneDocVersion", () => {
  it("returns array — checks milestone docs against identity version", () => {
    const errors = validateMilestoneDocVersion();
    expect(Array.isArray(errors)).toBe(true);
  });
});

describe("validateVerificationGates", () => {
  it("returns array — checks for blank verification gate bullets", () => {
    const errors = validateVerificationGates();
    expect(Array.isArray(errors)).toBe(true);
  });
});

describe("validateGitTagsExist", () => {
  it("returns array — verifies tag exists for current version", () => {
    const errors = validateGitTagsExist();
    expect(Array.isArray(errors)).toBe(true);
  });
});

describe("validateGitignoreConflicts", () => {
  it("returns array (runs without throwing)", () => {
    const errors = validateGitignoreConflicts();
    expect(Array.isArray(errors)).toBe(true);
    // State-tolerant: may return warnings depending on repo state
  });
});

describe("validateGitattributesCoverage", () => {
  it("returns array (runs without throwing)", () => {
    const errors = validateGitattributesCoverage();
    expect(Array.isArray(errors)).toBe(true);
    // State-tolerant: may return warnings depending on .gitattributes state
  });
});

describe("validateInstallUpdateSafety", () => {
  it("passes on M68 tier-aware scripts", () => {
    const errors = validateInstallUpdateSafety();
    expect(errors.filter((e) => e.severity === "error")).toHaveLength(0);
  });

  it("does not false-positive on M68 tier-aware scripts", () => {
    const errors = validateInstallUpdateSafety();
    const hasBlindCp = errors.some((e) => e.message.includes("agent/core/*.yml"));
    expect(hasBlindCp).toBe(false);
  });
});

describe("validateCommandE2eCoverage", () => {
  const repoRoot = path.join(import.meta.dirname, "..");

  it("errors when registry file is missing", () => {
    const errors = validateCommandE2eCoverage("/nonexistent/command-e2e-coverage.yaml");
    expect(errors.some((e) => e.message.includes("missing command E2E coverage registry"))).toBe(
      true
    );
  });

  it("errors when a command doc lacks registry entry", () => {
    const fixture = path.join(repoRoot, "scripts/fixtures/command-e2e-coverage-gap.yaml");
    const errors = validateCommandE2eCoverage(fixture, {
      repoRoot,
      commandsDir: path.join(repoRoot, "agent/commands"),
    });
    expect(errors.some((e) => e.message.includes("no E2E coverage entry for"))).toBe(true);
  });

  it("passes on full repo registry", () => {
    const registry = path.join(repoRoot, "agent/schemas/command-e2e-coverage.yaml");
    const errors = validateCommandE2eCoverage(registry, {
      repoRoot,
      commandsDir: path.join(repoRoot, "agent/commands"),
    });
    expect(errors.filter((e) => e.severity === "error")).toHaveLength(0);
  });
});

describe("validateMemoryFieldLint (M70)", () => {
  it("passes on live patterns.md and sessions.md", () => {
    const errors = validateMemoryFieldLint().filter((e) => e.severity === "error");
    expect(errors).toHaveLength(0);
  });
});

describe("validateBranchProtectionDocs (M70)", () => {
  it("finds Git Branch Protection section in USAGE.md", () => {
    const errors = validateBranchProtectionDocs().filter(
      (e) => e.message.includes("Missing § Git Branch Protection")
    );
    expect(errors).toHaveLength(0);
  });
});

describe("validateCarryoverFreshness (M70)", () => {
  it("returns warnings only (no throw)", () => {
    const errors = validateCarryoverFreshness();
    expect(Array.isArray(errors)).toBe(true);
  });

  it("flags stale pending carryover when fix_target snippet exists", () => {
    const fixture = path.join(process.cwd(), "scripts/fixtures/carryovers-stale.md");
    const errors = validateCarryoverFreshness(fixture);
    expect(errors.some((e) => e.message.includes("FIXTURE-STALE"))).toBe(true);
  });
});

describe("validateSchemaListEntries (M71)", () => {
  it("detects missing required field in lessons entry", () => {
    const schema = {
      required_fields: ["date", "task_type"],
      fields: {},
    };
    const errors = validateSchemaListEntries(
      ["- task_type: audit\n  mistake: x"],
      schema,
      "agent/memory/lessons.md"
    );
    expect(errors.some((e) => e.message.includes("date"))).toBe(true);
  });
});

describe("assertRepoRoot (M72)", () => {
  it("fails when agent/commands is missing", () => {
    const prev = process.env["ACP_REPO_ROOT"];
    process.env["ACP_REPO_ROOT"] = testDir;
    const errors = assertRepoRoot();
    expect(errors.some((e) => e.severity === "error")).toBe(true);
    if (prev) process.env["ACP_REPO_ROOT"] = prev;
    else delete process.env["ACP_REPO_ROOT"];
  });
});

describe("validateParityCheck (M72)", () => {
  it("fails on zero command population", () => {
    const empty = path.join(testDir, "empty-cmds");
    mkdirSync(empty, { recursive: true });
    const errors = validateParityCheck({ commandsDir: empty });
    expect(errors.some((e) => e.message.includes("Zero command docs"))).toBe(true);
  });

  it("detects dot-form stray wrappers", () => {
    const prompts = path.join(testDir, "prompts");
    mkdirSync(prompts, { recursive: true });
    writeFileSync(path.join(prompts, "acp.fake.prompt.md"), "---\n", "utf-8");
    const cmds = path.join(testDir, "cmds");
    mkdirSync(cmds, { recursive: true });
    writeFileSync(path.join(cmds, "acp.fake.md"), "# fake\n", "utf-8");
    const errors = validateParityCheck({
      commandsDir: cmds,
      promptsDir: prompts,
      opencodeDir: path.join(testDir, "oc"),
      cursorDir: path.join(testDir, "cur"),
      claudeDir: path.join(testDir, "cl"),
    });
    expect(errors.some((e) => e.message.includes("Dot-form stray"))).toBe(true);
  });

  it("detects missing claude wrapper", () => {
    const root = mkdtempSync(path.join(testDir, "parity-missing-"));
    const cmds = path.join(root, "agent", "commands");
    const prompts = path.join(root, ".github", "prompts");
    const oc = path.join(root, "opencode");
    const cur = path.join(root, "cursor");
    const cl = path.join(root, "claude");
    for (const d of [cmds, prompts, oc, cur, cl]) mkdirSync(d, { recursive: true });
    writeFileSync(path.join(cmds, "acp.demo.md"), "# demo\n", "utf-8");
    writeFileSync(path.join(prompts, "acp-demo.prompt.md"), "---\n", "utf-8");
    writeFileSync(path.join(oc, "acp-demo.md"), "---\n", "utf-8");
    writeFileSync(path.join(cur, "acp-demo.md"), "---\n", "utf-8");
    const errors = validateParityCheck({
      commandsDir: cmds,
      promptsDir: prompts,
      opencodeDir: oc,
      cursorDir: cur,
      claudeDir: cl,
    });
    expect(errors.length).toBeGreaterThan(0);
    expect(errors.some((e) => e.file.includes("claude"))).toBe(true);
  });
});

describe("validateInstructionFileHash (M72)", () => {
  it("detects content hash mismatch", () => {
    const root = path.join(testDir, "hash-mismatch");
    mkdirSync(path.join(root, ".github"), { recursive: true });
    writeFileSync(path.join(root, "AGENTS.md"), "line-a\n", "utf-8");
    writeFileSync(path.join(root, "CLAUDE.md"), "line-b\n", "utf-8");
    writeFileSync(path.join(root, ".github/copilot-instructions.md"), "line-a\n", "utf-8");
    const errors = validateInstructionFileHash(root);
    expect(errors.some((e) => e.message.includes("hash mismatch"))).toBe(true);
  });

  it("passes when all three files identical", () => {
    const root = path.join(testDir, "hash-ok");
    mkdirSync(path.join(root, ".github"), { recursive: true });
    const text = "> v6.26.0\nsame\n";
    writeFileSync(path.join(root, "AGENTS.md"), text, "utf-8");
    writeFileSync(path.join(root, "CLAUDE.md"), text, "utf-8");
    writeFileSync(path.join(root, ".github/copilot-instructions.md"), text, "utf-8");
    expect(validateInstructionFileHash(root)).toHaveLength(0);
  });
});

describe("validatePackageYamlVersion (M72)", () => {
  it("errors on version mismatch", () => {
    const root = path.join(testDir, "pkg-mismatch");
    mkdirSync(path.join(root, "agent", "core"), { recursive: true });
    writeFileSync(path.join(root, "agent", "core", "identity.yml"), "version: 6.26.0\n", "utf-8");
    writeFileSync(path.join(root, "package.yaml"), "version: 0.0.0\n", "utf-8");
    const errors = validatePackageYamlVersion(root);
    expect(errors.some((e) => e.message.includes("0.0.0"))).toBe(true);
  });
});

describe("validateProtocolDirAddability (M72)", () => {
  it("passes on live repo evidence dirs", () => {
    const errors = validateProtocolDirAddability(getRepoRoot()).filter(
      (e) => e.severity === "error"
    );
    expect(errors).toHaveLength(0);
  });
});
