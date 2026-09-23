---
name: project-scaffolding
description: Scaffolds a new project's initial file/folder structure, tooling, and config based on its tech stack and project type (a Python service, a Next.js app, a monorepo, a CLI tool, etc.) — asking which stack and project type apply before generating anything, rather than assuming. Use when asked to "scaffold a project", "set up a new [stack] project", "bootstrap this repo", "create the initial structure for", or similar, before meaningful code exists.
---

# Project Scaffolding

## Overview

Creates a new project's starting structure — folder layout, package/dependency config, linter/formatter setup, a minimal working entry point, and test scaffolding — grounded in the real, current conventions for its actual tech stack and project type, not a generic template. Unlike most skills in this library, its output belongs inside the project's own repo — scaffolding a project *is* creating the project's files, so this is one of the deliberate exceptions to the external-output-path convention (alongside `context-engineering` and `figma-design-to-code`).

## When to Use

- A new project (or a new package/app inside an existing monorepo) needs its initial structure, and nothing meaningful exists yet
- The user names a stack, framework, or project type ("a Next.js app," "a Python FastAPI service," "a pnpm monorepo") — or needs to be asked which applies
- NOT when the project already has real code and structure — that's an existing codebase, not a scaffold; use `acquire-codebase-knowledge` to understand it instead
- NOT when what to build is still unclear — scaffolding sets up *how* the code will be organized, not *what* it does; run `spec-driven-development` first if the feature set itself isn't decided yet

## Process

### 1. Determine stack, project type, and structure — before generating anything

Use the `AskUserQuestion` tool, batched, before creating a single file:

- **Language/runtime** (if not already stated) — Python, TypeScript/Node, Go, etc.
- **Framework** (if applicable to the stack) — Next.js, FastAPI/Django, NestJS/Express, or none (plain library/CLI).
- **Application layer** — frontend only, backend only, or full-stack (both) — whenever the stack/framework alone doesn't settle it (Next.js, SvelteKit, and similar can legitimately be any of the three; FastAPI or a CLI tool usually doesn't need asking). This decides whether frontend and backend get separate top-level structures or a single one.
- **Project topology** — single app/package, or a monorepo/workspace (and if a monorepo: which workspace tool — pnpm workspaces, npm workspaces, Turborepo, Nx, a uv workspace).
- **Package manager** — npm/pnpm/yarn/bun, pip/poetry/uv, Go modules, etc.

Skip asking anything the user already stated directly — same rule `breakdown-feature-implementation` uses for resolving its stack: stated beats detected beats asked. If the project directory already has *some* files (a partial start, not a full codebase), detect and match what's already there instead of re-asking.

### 2. Confirm the plan before writing

List exactly what will be created — the folder tree, the key config files, the initial dependencies — and confirm it with the user before generating anything. Scaffolding writes many files in one pass; that's expensive to undo compared to one file at a time, so the confirmation gate matters more here than in most skills.

### 3. Create the structure

Generate the folder layout, package/dependency manifest, linter/formatter config, a minimal working entry point (not a placeholder that doesn't run), `.gitignore`, and test scaffolding — following that stack and framework's real, current conventions. For a monorepo: the workspace config, the `apps/`/`packages/` layout, and shared base configs (tsconfig, eslint) that apps/packages extend rather than duplicate.

**Tests and git hooks are part of every scaffold, not an optional extra.** Include the test runner already wired up with at least one real, passing test against the entry point (a genuine smoke test, not an empty test directory with nothing in it) — see `test-driven-development` for what a real test looks like versus a placeholder. Install and configure a pre-commit git hook — Husky for a Node/TypeScript project, or that ecosystem's real equivalent otherwise (e.g. `pre-commit` for Python, `lefthook` if the project already uses it) — running lint and the test suite before every commit, not just present as an installed dependency with no hook actually wired to run.

**Structure by concern, not by convenience.** Every layer gets dedicated folders for its own distinct responsibilities, matching that stack's real convention — a backend separates routes/controllers from services/business logic from models/data access from config; a frontend separates components from pages/routes from hooks from lib/api-clients/utils. Never collapse these into one flat folder or a single catch-all file, even for a minimal starting scaffold — the tree itself should make the separation obvious, not just file naming within one folder. For a full-stack project, keep frontend and backend as clearly separated top-level concerns — either their own packages in a monorepo, or clearly separated top-level folders — never intermixed in one undifferentiated structure.

Ground every generated file in the ecosystem's actual current convention, not a remembered one that may be stale — if genuinely unsure of a specific version or convention, ask rather than guess.

### 4. Verify it actually runs

Install dependencies and run the stack's equivalent of a smoke test — the dev server starts, the entry point runs, the test suite's at-least-one real test actually passes (not zero tests, not an error), and the git hook actually fires on a trial commit and runs lint/tests. A scaffold that doesn't actually run — or whose test or hook is present but silently does nothing — is a broken deliverable, not a starting point.

### 5. Hand off

Tell the user what was created and where. Point to the natural next step: `spec-driven-development` if the feature set isn't defined yet, or straight into `incremental-implementation`/`test-driven-development` if it is.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can guess the stack from context" | A wrong guess means regenerating everything — ask via `AskUserQuestion` up front; that's one round before dozens of files, not after. |
| "I'll use a generic folder structure that works for any stack" | Every ecosystem has its own real convention (Next.js's `app/` router, a Python package's `src/` layout) — a generic structure reads as unfamiliar to anyone who actually knows that stack. |
| "I don't need to confirm the plan, I'll just build it" | Scaffolding writes many files in one pass — confirm the plan first, the same way a large diff gets reviewed before it lands, not after. |
| "The files are there, that's good enough" | A scaffold that doesn't actually install and run is a broken starting point — verify it before calling it done. |
| "I'll skip the monorepo tooling setup, they can add it later" | A monorepo without its workspace config isn't a monorepo yet — set that up as part of the scaffold, not as a follow-up. |
| "It's small right now, I'll put everything in one folder" | A scaffold models the structure the project grows into — separation of concerns is far cheaper to keep in place from the start than to retrofit once real code has accumulated in one flat folder. |
| "It's a full-stack-capable framework, I don't need to ask which layer" | The framework name alone doesn't settle it — some can legitimately be frontend-only, backend-only, or full-stack; ask when it's genuinely ambiguous rather than assuming full-stack by default. |
| "An empty test directory is enough, they'll add real tests later" | A test suite with nothing in it doesn't prove the test runner is actually wired correctly — include one real, passing smoke test now, the same way the entry point itself has to actually run, not just exist. |
| "I'll add the git hook package but skip wiring an actual hook script" | An installed-but-unconfigured Husky/pre-commit dependency enforces nothing — the hook has to actually fire and run lint/tests on a real commit, not just sit in `package.json`. |

## Red Flags

- Files generated before the stack/project type was confirmed
- A generic structure that doesn't match the actual ecosystem's real convention
- No confirmation of the plan before writing dozens of files
- A scaffold that was never actually run/installed to confirm it works
- A monorepo missing its workspace config
- A flat structure with no dedicated folder per concern (routes, services, models, components, etc.)
- Frontend and backend code intermixed in one undifferentiated structure on a full-stack project
- Application layer (frontend/backend/full-stack) assumed instead of asked, on a framework where it was genuinely ambiguous
- An empty test directory with no real test in it
- Husky (or the ecosystem's equivalent) installed as a dependency but no hook script actually wired to run on commit

## Verification

- [ ] Stack, project type, application layer (frontend/backend/full-stack), and topology were determined via `AskUserQuestion` (or already stated), not guessed
- [ ] The generated structure has dedicated folders per concern (routes/services/models, or components/pages/hooks/lib, as applicable) — not a flat or catch-all layout
- [ ] On a full-stack project, frontend and backend are clearly separated (own packages or own top-level folders), not intermixed
- [ ] At least one real, passing test exists against the entry point — not an empty test directory
- [ ] A pre-commit git hook (Husky, or the ecosystem's real equivalent) is installed, actually wired to run lint/tests, and was confirmed to fire on a trial commit
- [ ] Any partial existing files in the project were detected and matched, not overwritten or ignored
- [ ] The planned structure was confirmed with the user before any file was written
- [ ] Every generated file follows that stack/framework's real, current convention
- [ ] The scaffold was actually installed and run to confirm it works, not just assumed to
- [ ] The user was told what was created and the natural next step

## See Also

- `spec-driven-development` — upstream, if the feature set itself isn't decided yet; this skill sets up *how* code is organized, not *what* it does
- `context-engineering` — for agent rules files (`.cursorrules`, `AGENTS.md`, etc.), a related but distinct kind of in-repo setup
- `incremental-implementation` / `test-driven-development` — the natural next step once the scaffold exists
- `acquire-codebase-knowledge` — for understanding an *existing* codebase's structure, rather than creating a new one
