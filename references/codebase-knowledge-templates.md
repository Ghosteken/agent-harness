# Codebase Knowledge Templates

Reference material for the `acquire-codebase-knowledge` skill: the seven documents
it produces, what each one must answer, and the marking convention that keeps
every claim traceable to evidence instead of assumption.

## The marking convention

Every document uses two markers instead of guessing:

- `[TODO]` — a fact that's determinable from the codebase but hasn't been checked yet, or genuinely can't be determined from what's available (no config file states it, no test exercises it).
- `[ASK USER]` — a question whose answer depends on team intent rather than anything in the repository (why a pattern was chosen, whether a workaround is load-bearing or historical, what the roadmap is).

Every non-trivial claim needs a one-line evidence pointer to the file, config key, or command output it came from. A claim with no evidence pointer is a guess wearing a fact's clothes.

## The seven documents

### STACK.md
Language(s) and runtime versions, frameworks, every dependency (production and dev, kept separate — a linter in `devDependencies` is not part of the runtime stack), package manager, and build tooling. Evidence source: manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, ...), lockfiles for exact resolved versions.

### STRUCTURE.md
Directory layout with a one-line purpose per top-level directory, entry points (where execution starts for each runnable target), and the key files a newcomer needs to find first. For a monorepo, map each workspace/package separately — a root manifest with no dependencies of its own is a red flag that the real stacks live one level down.

### ARCHITECTURE.md
The layers or components the system is actually built from (not the ones a README claims), the patterns in use (MVC, hexagonal, event-driven, ...), and how data flows between the major pieces. State only what the directory structure and imports actually show — an aspirational architecture described in a doc but contradicted by the code is a finding for CONCERNS.md, not a fact for this document.

### CONVENTIONS.md
Naming conventions, formatting rules (and the tool that enforces them, if any), error-handling patterns, and import/module organization actually observed in the code — not what a style guide says should happen, if the code doesn't follow it.

### INTEGRATIONS.md
External APIs called, databases and their client libraries, auth providers, and monitoring/observability services wired in. Evidence source: dependency manifests cross-referenced with actual client instantiation in code, plus `.env.example`/`.env.template` for the environment variables an integration requires (secrets themselves are never committed, but the required variable names usually are).

### TESTING.md
Test frameworks in use, how test files are organized relative to source, and the mocking/stubbing strategy the existing tests actually follow. A TODO comment inside a test file is a coverage gap, not production technical debt — keep the two separate.

### CONCERNS.md
Technical debt, known bugs, security risks, and performance bottlenecks — each with an evidence pointer. Files that show up disproportionately often in recent commit history are worth flagging here even without a specific known issue: high change frequency is itself a signal of fragility or hidden complexity.

## Investigation order

1. Read intent documents first — README, PRD/TRD/spec/design docs, roadmap — and summarize what the project claims about itself before reading a line of source. This gives you something to check the code against, rather than a blank slate.
2. Scan the manifest(s), lockfile(s), and directory tree to establish STACK and STRUCTURE with hard evidence.
3. Read entry points and follow imports outward to establish ARCHITECTURE.
4. Sample enough files across the codebase (not just one) to state CONVENTIONS with confidence — a pattern seen once is an anecdote, not a convention.
5. Cross-reference dependencies against actual usage for INTEGRATIONS.
6. Read the test suite's own structure for TESTING.
7. CONCERNS accumulates from everything above — don't treat it as a separate pass.

## Common gotchas

- **Monorepos** — a root `package.json` with no meaningful `dependencies` is a router, not the stack; check `workspaces`/`packages/`/`apps/` and document each sub-package's stack independently.
- **A stale README** — often describes the intended architecture, not the current one. Treat README architecture claims as a hypothesis to verify against the file tree, not as fact.
- **Path aliases** — a `tsconfig.json`/bundler `paths` config means an import like `@/lib/foo` doesn't map directly onto the filesystem; resolve the alias before documenting where something actually lives.
- **Generated output** — never document conventions observed in `dist/`, `build/`, `.next/`, `__pycache__/`, or any other generated directory; these are artifacts of the source, not the source's own convention.
- **`devDependencies` are not the runtime stack** — a linter, formatter, or test framework listed there belongs in a "dev tooling" note, not the production STACK.md entry.

## Validation before finishing

Before presenting the seven documents as complete:

- No required section in any document is empty.
- No claim lacks an evidence pointer.
- Every unknown uses `[TODO]`, not a filled-in guess.
- Every team-intent question uses `[ASK USER]`, listed as a numbered question in the final summary alongside any place where the intent documents and the actual code diverge.
