#!/usr/bin/env node
/**
 * validate-skills.js
 *
 * Validates skills against the rules in docs/skill-anatomy.md.
 *
 * Default mode: validates only the skills listed in scripts/agent-scopes.json
 * (the curated scopes for each agent persona).
 *
 * Full mode (--all): validates every skill in skills/.
 *
 * Checks (errors block CI):
 *   - SKILL.md exists in every skill directory
 *   - YAML frontmatter present with 'name' and 'description' fields
 *   - frontmatter 'name' matches the directory name
 *   - description does not exceed 1024 characters
 *   - required sections are present
 *
 * Checks (warnings, do not block CI):
 *   - cross-skill references point to known skills
 *
 * Exit codes: 0 = all clear, 1 = one or more errors
 */

'use strict';

const fs   = require('fs');
const path = require('path');

// ─── Config ──────────────────────────────────────────────────────────────────

const SKILLS_DIR   = path.resolve(__dirname, '..', 'skills');
const SCOPES_FILE  = path.resolve(__dirname, 'agent-scopes.json');

const MAX_DESCRIPTION_LENGTH = 1024;

// Sections every standard SKILL.md must contain.
// Each entry is an array of acceptable heading strings — the first
// match wins, so you can list canonical + legacy aliases.
const REQUIRED_SECTIONS = [
  ['## Overview'],
  ['## When to Use'],
  ['## Common Rationalizations'],
  ['## Red Flags'],
  ['## Verification'],
];

// Skills that are intentionally exempt from section checks.
// Exemptions live HERE, not in skill frontmatter, so contributors
// cannot bypass the validator by editing their own skill file.
// Every entry must have a documented reason.
const SECTION_EXEMPT_SKILLS = {
  'using-agent-skills': 'Meta-skill — orchestrates other skills; When-to-Use and Verification are not applicable to a routing document.',
  'idea-refine':        'Legacy structure predating skill-anatomy.md — uses How-It-Works/Usage/Anti-patterns instead of standard headings.',
};

// Regex patterns that indicate an explicit cross-skill reference.
// Only these patterns trigger the dead-reference warning — generic
// backtick strings in code blocks are intentionally excluded.
const SKILL_REF_PATTERNS = [
  /\buse the `([a-z][a-z0-9-]+[a-z0-9])` skill/g,
  /\bfollow the `([a-z][a-z0-9-]+[a-z0-9])` skill/g,
  /\binvoke the `([a-z][a-z0-9-]+[a-z0-9])` skill/g,
  /\bcontinue with `([a-z][a-z0-9-]+[a-z0-9])`/g,
  /\buse `([a-z][a-z0-9-]+[a-z0-9])` skill/g,
  /`([a-z][a-z0-9-]+[a-z0-9])` skill\b/g,
  /`([a-z][a-z0-9-]+[a-z0-9])` persona\b/g,
  /\bsee `([a-z][a-z0-9-]+[a-z0-9])`/g,
  /──→ ([a-z][a-z0-9-]+[a-z0-9])\b/g,          // ASCII diagram arrows
  /→ `([a-z][a-z0-9-]+[a-z0-9])`/g,
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Parse YAML-style frontmatter from the top of a markdown file.
 * Returns a key→value object, or null if no frontmatter block found.
 * Values are stripped of surrounding quotes.
 */
function parseFrontmatter(content) {
  const match = content.match(/^---[ \t]*\r?\n([\s\S]*?)\r?\n---[ \t]*\r?\n/);
  if (!match) return null;

  const result = {};
  for (const line of match[1].split(/\r?\n/)) {
    const colonIdx = line.indexOf(':');
    if (colonIdx === -1) continue;
    const key   = line.slice(0, colonIdx).trim();
    const value = line.slice(colonIdx + 1).trim().replace(/^['"]|['"]$/g, '');
    if (key) result[key] = value;
  }
  return result;
}

/**
 * Collect all explicit skill cross-references from content.
 * Only matches against the SKILL_REF_PATTERNS list to avoid
 * false-positives from inline code snippets.
 */
function extractSkillReferences(content) {
  const refs = new Set();
  for (const pattern of SKILL_REF_PATTERNS) {
    // Reset lastIndex for global regexes
    pattern.lastIndex = 0;
    let m;
    while ((m = pattern.exec(content)) !== null) {
      refs.add(m[1]);
    }
  }
  return refs;
}

// ─── Validator ───────────────────────────────────────────────────────────────

// warnSections: when true, missing required sections become warnings instead of
// errors. Used in scoped mode so skills pending anatomy migration don't block CI.
function validateSkill(dirName, knownSkills, warnSections) {
  const errors   = [];
  const warnings = [];
  let   exempt   = false;
  const skillPath = path.join(SKILLS_DIR, dirName, 'SKILL.md');

  if (!fs.existsSync(skillPath)) {
    errors.push('Missing SKILL.md');
    return { errors, warnings, exempt };
  }

  let content;
  try {
    content = fs.readFileSync(skillPath, 'utf8');
  } catch (err) {
    errors.push(`Unreadable SKILL.md: ${err.message}`);
    return { errors, warnings, exempt };
  }

  // ── Frontmatter ──────────────────────────────────────────────────────────
  const fm = parseFrontmatter(content);
  if (!fm) {
    errors.push('Missing or malformed YAML frontmatter (expected --- block at top of file)');
    return { errors, warnings, exempt };
  }

  if (!fm.name) {
    errors.push("Frontmatter missing required field: 'name'");
  } else if (fm.name !== dirName) {
    errors.push(`Frontmatter name '${fm.name}' does not match directory name '${dirName}'`);
  }

  if (!fm.description) {
    errors.push("Frontmatter missing required field: 'description'");
  } else if (fm.description.length > MAX_DESCRIPTION_LENGTH) {
    errors.push(
      `Description is ${fm.description.length} chars — exceeds the ${MAX_DESCRIPTION_LENGTH}-char limit` +
      ` (agents inject this into the system prompt)`
    );
  }

  // ── Exemption guard ──────────────────────────────────────────────────────
  if (fm.type === 'meta' || fm.exempt === 'sections') {
    if (!SECTION_EXEMPT_SKILLS[dirName]) {
      errors.push(
        `Frontmatter declares 'type: meta' or 'exempt: sections' but '${dirName}' is not in ` +
        `the validator's SECTION_EXEMPT_SKILLS allowlist. ` +
        `Add an entry to scripts/validate-skills.js with a documented reason.`
      );
    }
  }

  // ── Required sections ────────────────────────────────────────────────────
  exempt = dirName in SECTION_EXEMPT_SKILLS;

  if (!exempt) {
    for (const aliases of REQUIRED_SECTIONS) {
      const found = aliases.some(heading => content.includes(heading));
      if (!found) {
        const msg = `Missing required section: ${aliases[0]}`;
        // In scoped mode, section gaps are warnings (pending compliance) so CI
        // still passes. Use --all --strict to treat them as hard errors.
        if (warnSections) {
          warnings.push(msg);
        } else {
          errors.push(msg);
        }
      }
    }
  }

  // ── Cross-skill references ───────────────────────────────────────────────
  const refs = extractSkillReferences(content);
  for (const ref of refs) {
    if (!knownSkills.has(ref)) {
      warnings.push(`Dead cross-reference: \`${ref}\` is not a known skill`);
    }
  }

  return { errors, warnings, exempt };
}

// ─── Main ────────────────────────────────────────────────────────────────────

function main() {
  const validateAll  = process.argv.includes('--all');
  const strictMode   = process.argv.includes('--strict');
  // In scoped mode, missing sections are warnings (pending compliance) unless
  // --strict is also passed. In --all mode, sections are always hard errors
  // unless someone explicitly passes --all without --strict (non-default).
  const warnSections = !validateAll && !strictMode;

  if (!fs.existsSync(SKILLS_DIR)) {
    console.error(`ERROR: skills directory not found at ${SKILLS_DIR}`);
    process.exit(1);
  }

  // ── Resolve which skills to validate ─────────────────────────────────────
  let skillDirs;
  let agentScopeMap = {};   // skill → [agent, ...]

  if (validateAll) {
    skillDirs = fs.readdirSync(SKILLS_DIR)
      .filter(d => fs.statSync(path.join(SKILLS_DIR, d)).isDirectory())
      .sort();
    console.log(`Mode: full — validating all ${skillDirs.length} skills in skills/\n`);
  } else {
    if (!fs.existsSync(SCOPES_FILE)) {
      console.error(`ERROR: scope file not found at ${SCOPES_FILE}`);
      console.error(`Run with --all to validate every skill, or create ${SCOPES_FILE}.`);
      process.exit(1);
    }

    let scopeData;
    try {
      scopeData = JSON.parse(fs.readFileSync(SCOPES_FILE, 'utf8'));
    } catch (err) {
      console.error(`ERROR: could not parse ${SCOPES_FILE}: ${err.message}`);
      process.exit(1);
    }

    const scopedSet = new Set();
    for (const [agentName, agentDef] of Object.entries(scopeData.agents || {})) {
      for (const skill of agentDef.skills || []) {
        scopedSet.add(skill);
        if (!agentScopeMap[skill]) agentScopeMap[skill] = [];
        agentScopeMap[skill].push(agentName);
      }
    }

    skillDirs = [...scopedSet].sort();
    const agentCount = Object.keys(scopeData.agents || {}).length;
    const strictNote = strictMode ? ', strict (sections = errors)' : ', section gaps = warnings';
    console.log(`Mode: scoped — validating ${skillDirs.length} skills across ${agentCount} agent scopes${strictNote}`);
    console.log(`(Run with --all to validate all skills, --strict to promote section gaps to errors)\n`);
  }

  const knownSkills = new Set(skillDirs);

  let totalErrors      = 0;
  let totalWarnings    = 0;
  let missingDirs      = 0;
  let pendingCompliance = 0;

  for (const dirName of skillDirs) {
    // Check directory exists (scoped skills might reference skills not yet in repo)
    if (!fs.existsSync(path.join(SKILLS_DIR, dirName))) {
      const agents = agentScopeMap[dirName] ? ` [scope: ${agentScopeMap[dirName].join(', ')}]` : '';
      console.log(`  ✗  ${dirName}${agents}`);
      console.log(`       ERROR: Directory not found in skills/ — remove from agent-scopes.json or add the skill`);
      totalErrors++;
      missingDirs++;
      continue;
    }

    const { errors, warnings, exempt } = validateSkill(dirName, knownSkills, warnSections);
    totalErrors   += errors.length;
    totalWarnings += warnings.length;

    const agents = agentScopeMap[dirName] ? ` [${agentScopeMap[dirName].join(', ')}]` : '';

    const hasSectionWarningsOnly = errors.length === 0 && warnings.length > 0 &&
      warnings.every(w => w.startsWith('Missing required section:'));

    if (errors.length === 0 && warnings.length === 0) {
      const tag = exempt ? ' (section checks exempt)' : '';
      console.log(`  ✓  ${dirName}${tag}${agents}`);
    } else if (hasSectionWarningsOnly && warnSections) {
      // Suppress per-warning noise for pending-compliance skills — just mark them
      pendingCompliance++;
      console.log(`  ○  ${dirName} (pending anatomy compliance)${agents}`);
    } else {
      const icon = errors.length > 0 ? '  ✗ ' : '  ⚠ ';
      console.log(`${icon} ${dirName}${agents}`);
      for (const msg of errors)   console.log(`       ERROR: ${msg}`);
      for (const msg of warnings) console.log(`       WARN:  ${msg}`);
    }
  }

  const status = totalErrors > 0 ? 'FAILED' : totalWarnings > 0 ? 'PASSED WITH WARNINGS' : 'PASSED';
  console.log(`\n${skillDirs.length} skills checked — ${totalErrors} error(s), ${totalWarnings} warning(s) — ${status}`);
  if (missingDirs > 0) {
    console.log(`(${missingDirs} skill(s) listed in agent-scopes.json do not exist in skills/ yet)`);
  }
  if (pendingCompliance > 0) {
    console.log(`(${pendingCompliance} skill(s) pending anatomy compliance — usable by agents, run --strict to see details)`);
  }

  if (totalErrors > 0) process.exit(1);
}

// Surface unexpected failures (fs errors, bad symlinks, …) as a structured
// one-line CI error instead of an uncaught stack trace.
try {
  main();
} catch (err) {
  console.error(`\nERROR: validate-skills failed unexpectedly: ${err.message}`);
  process.exit(1);
}
