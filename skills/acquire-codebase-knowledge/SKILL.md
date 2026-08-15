---
name: acquire-codebase-knowledge
description: Maps an unfamiliar codebase into seven evidence-backed documents (stack, structure, architecture, conventions, integrations, testing, concerns) instead of a single freeform summary. Use when asked to map, document, or onboard into an existing codebase — "map this codebase," "document this architecture," "onboard me to this repo." Not for routine feature implementation, bug fixes, or narrow edits unless repository-level discovery is explicitly requested.
---

# Acquire Codebase Knowledge

## Overview

"Get familiar with this codebase" usually produces a shallow, unstructured summary that misses exactly the things a newcomer needs and can't be checked against anything. This skill instead produces seven fixed documents, each scoped to one question a new contributor actually asks, with every claim traced back to a file, config value, or command output. What can't be determined gets marked `[TODO]`; what depends on team intent rather than the code gets marked `[ASK USER]` — the summary is honest about what it doesn't know instead of quietly guessing.

## When to Use

- Asked to map, document, or produce onboarding material for an existing codebase
- Starting substantial work in a codebase with no existing architecture documentation
- A codebase's documentation is stale or missing and repository-level discovery is explicitly wanted
- NOT for a routine feature implementation, bug fix, or narrow edit — read only what that task needs; running this full process for a one-line change is disproportionate

## Process

### 1. Read intent before code

Search for and read `README`, `PRD`, `TRD`, `ROADMAP`, `SPEC`, and `DESIGN` documents first, and summarize what the project claims about itself before reading a line of source. This summary becomes the thing you check the code against in every later step — a README that turns out to describe a different architecture than what's actually there is itself a finding, not a fact to repeat.

### 2. Investigate each of the seven areas

Work through STACK, STRUCTURE, ARCHITECTURE, CONVENTIONS, INTEGRATIONS, TESTING, and CONCERNS in that order — later documents build on facts established in earlier ones (you can't state INTEGRATIONS accurately without STACK's dependency list already in hand). See `references/codebase-knowledge-templates.md` for what each document must cover, the investigation order and evidence sources for each, and the gotchas that produce false claims if skipped (monorepos, stale READMEs, path aliases, generated output, dev-vs-runtime dependencies).

If the user names a focus area ("architecture only," "testing and concerns"), still read intent documents in full first, then fully complete the named area(s) before doing a lighter pass on the rest — every document still needs its required sections present, with unknowns marked `[TODO]` rather than left blank.

### 3. Populate the seven documents

Write `STACK.md`, `STRUCTURE.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `INTEGRATIONS.md`, `TESTING.md`, and `CONCERNS.md` to `docs/codebase/`. Every non-trivial claim needs a short evidence pointer (a file path, a config key, a command's output) — a claim with no evidence pointer is a guess, not a documented fact. Mark anything undeterminable `[TODO]` and anything requiring team intent `[ASK USER]`, per the convention in `references/codebase-knowledge-templates.md`.

### 4. Validate before presenting

Check every document against the checklist in `references/codebase-knowledge-templates.md`: no empty required section, no unsupported claim, every unknown properly marked. Fix and re-check until all seven pass — don't present a document with a gap and call it done.

### 5. Present findings and open questions

Summarize all seven documents, then list every `[ASK USER]` item as a numbered question, and separately call out any place where the intent documents from Step 1 diverged from what the code actually shows.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The README already explains the architecture" | Cross-check it against the actual file structure before repeating it — READMEs describe intent, and intent drifts from reality. |
| "I can infer the database from a variable name like `dbUrl`" | Check the manifest for the actual client library (`pg`, `mongoose`, `prisma`, ...) instead of pattern-matching a name. |
| "One clean summary is faster than seven documents" | The seven-document split is what makes each one answerable and checkable — a single freeform summary is exactly the shallow, unstructured output this skill exists to avoid. |
| "I'll fill in the gap with what's probably true" | That's exactly what `[TODO]` and `[ASK USER]` prevent. An unverified guess presented as fact is worse than an honest gap. |
| "This is a big repo, I'll skip the intent documents" | Skipping Step 1 removes the only thing later steps get checked against — do it first, even briefly. |

## Red Flags

- A document with a claim that has no evidence pointer
- An unknown filled in with a plausible guess instead of marked `[TODO]`
- A team-intent question answered instead of marked `[ASK USER]` and surfaced to the user
- Directory conventions documented from `dist/`, `build/`, or another generated output directory
- A monorepo documented as if its root manifest were the whole stack
- Presenting the seven documents without running the Step 4 validation pass first

## Verification

- [ ] All seven documents exist in `docs/codebase/` with every required section present
- [ ] Every non-trivial claim carries an evidence pointer to a real file, config value, or command output
- [ ] Every undeterminable fact is marked `[TODO]`, not guessed
- [ ] Every team-intent question is marked `[ASK USER]` and listed in the final summary
- [ ] Intent-vs-reality divergences from Step 1 are explicitly called out, not silently resolved in the code's favor

## See Also

- `references/codebase-knowledge-templates.md` — the seven document templates, investigation order, and gotchas
- `source-driven-development` — for verifying framework-specific patterns against official docs once you're implementing, rather than mapping the codebase as a whole
- `context-engineering` — for managing what stays in context during the implementation work this skill's output feeds into
