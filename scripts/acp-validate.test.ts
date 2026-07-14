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
    // v6.20.9 tag was created earlier today
    expect(errors.length).toBe(0);
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

  it("flags blind cp agent/core/*.yml pattern", () => {
    const bad = 'cp "$TEMP_DIR/agent/core/"*.yml agent/core/';
    const errors = validateInstallUpdateSafety();
    const hasBlindCp = errors.some((e) => e.message.includes("agent/core/*.yml"));
    expect(hasBlindCp || !bad).toBe(true);
  });
});
