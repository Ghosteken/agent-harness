<div align="center">

![Agent Harness logo](assets/agent.jpg)

# Agent Harness

**Production-grade engineering skills for AI coding agents.**

Skills encode the workflows, quality gates, and best practices that senior engineers use when building software packaged so AI agents follow them consistently across every phase of development.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-174-brightgreen)](docs/SCOPE.md)
[![Agent Personas](https://img.shields.io/badge/agent%20personas-12-orange)](docs/agents.md)
[![Slash Commands](https://img.shields.io/badge/slash%20commands-7-blueviolet)](#commands)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-6B4FBB)](docs/getting-started.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[Quick Start](#quick-start) • [Commands](#commands) • [Skills](#skills) • [Agent Personas](#agent-personas) • [How It Works](#how-it-works-end-to-end-workflow) • [Contributing](#contributing)

</div>

```
  DEFINE          PLAN           BUILD          VERIFY         REVIEW          SHIP
 ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
 │ Idea │ ───▶ │ Spec │ ───▶ │ Code │ ───▶ │ Test │ ───▶ │  QA  │ ───▶ │  Go  │
 │Refine│      │  PRD │      │ Impl │      │Debug │      │ Gate │      │ Live │
 └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
  /spec          /plan          /build        /test         /review       /ship
```

---

## Commands

7 slash commands that map to the development lifecycle. Each one activates the right skills automatically.

| What you're doing | Command | Key principle |
|-------------------|---------|---------------|
| Define what to build | `/spec` | Spec before code |
| Plan how to build it | `/plan` | Small, atomic tasks |
| Build incrementally | `/build` | One slice at a time |
| Prove it works | `/test` | Tests are proof |
| Review before merge | `/review` | Improve code health |
| Simplify the code | `/code-simplify` | Clarity over cleverness |
| Ship to production | `/ship` | Faster is safer |

Want fewer manual steps once the spec exists? **`/build auto`** generates the plan and implements every task in a single approved pass — you approve the plan once, then it runs autonomously. It removes the human stepping *between* tasks, not the verification: every task is still test-driven and committed individually, and it pauses on failures or risky steps.

Skills also activate automatically based on what you're doing — designing an API triggers `api-and-interface-design`, building UI triggers `frontend-ui-engineering`, and so on.

---

## 🚀 Quick Start

<details>
<summary><b>Claude Code (recommended)</b></summary>

**Marketplace install:**

```bash
/plugin marketplace add https://github.com/Ghosteken/agent-harness.git
/plugin install agent-harness
```

**Direct CLI install:**

```bash
claude plugin install https://github.com/Ghosteken/agent-harness.git --scope user
```

> **Authentication issues?** If you encounter Git or SSH errors, using the full HTTPS URL as shown above is the most robust method. It bypasses SSH configuration and uses standard HTTPS cloning.

**Local / development:**

```bash
git clone https://github.com/Ghosteken/agent-harness.git
claude --plugin-dir /path/to/agent-harness
```

**Script installer (local clone → global install):**

```bash
bash scripts/install.sh --global   # macOS / Linux / Git Bash
.\scripts\install.ps1 -Global      # Windows PowerShell
```

**Claude desktop upload (`.plugin` file):**

Use `agent-harness.plugin` at the repo root. To rebuild it after making changes:

```bash
bash scripts/build-plugin.sh                        # macOS / Linux / Git Bash
.\scripts\build-plugin.ps1                          # Windows PowerShell
.\scripts\build-plugin.ps1 -Out "C:\Desktop\agent-harness.plugin"  # custom output path
```

Then in Claude desktop: **Settings → Extensions → Upload local plugin** → select the `.plugin` file.

</details>

<details>
<summary><b>Cursor</b></summary>

Copy any `SKILL.md` into `.cursor/rules/`, or reference the full `skills/` directory. See [docs/cursor-setup.md](docs/cursor-setup.md).

</details>

<details>
<summary><b>Antigravity CLI</b></summary>

Install as a native plugin for skills, subagents, and slash commands. See [docs/antigravity-setup.md](docs/antigravity-setup.md).

**Install from the repo:**

```bash
agy plugin install https://github.com/Ghosteken/agent-harness.git
```

**Install from a local clone:**

```bash
git clone https://github.com/Ghosteken/agent-harness.git
agy plugin install ./agent-harness
```

</details>

<details>
<summary><b>Gemini CLI</b></summary>

Install as native skills for auto-discovery, or add to `GEMINI.md` for persistent context. See [docs/gemini-cli-setup.md](docs/gemini-cli-setup.md).

**Install from the repo:**

```bash
gemini skills install https://github.com/Ghosteken/agent-harness.git --path skills
```

**Install from a local clone:**

```bash
gemini skills install ./agent-harness/skills/
```

</details>

<details>
<summary><b>Windsurf</b></summary>

Add skill contents to your Windsurf rules configuration. See [docs/windsurf-setup.md](docs/windsurf-setup.md).

</details>

<details>
<summary><b>OpenCode</b></summary>

Uses agent-driven skill execution via AGENTS.md and the `skill` tool.

See [docs/opencode-setup.md](docs/opencode-setup.md).

</details>

<details>
<summary><b>GitHub Copilot</b></summary>

Use agent definitions from `agents/` as Copilot personas and skill content in `.github/copilot-instructions.md`. See [docs/copilot-setup.md](docs/copilot-setup.md).

</details>

<details>
  <summary><b>Kiro IDE & CLI </b></summary>
  Skills for Kiro reside under ".kiro/skills/" and can be stored under Project or Global level. Kiro also supports Agents.md. See Kiro docs at https://kiro.dev/docs/skills/
</details>

<details>
<summary><b>Codex / Other Agents</b></summary>

Skills are plain Markdown - they work with any agent that accepts system prompts or instruction files. See [docs/getting-started.md](docs/getting-started.md).

</details>



---

## 🛠️ Skills

The library contains a curated set of **174 skills** across every engineering domain — the rest of the original bulk import lives in `archive/skills-community/`, unexposed but recoverable. The commands above are built on a **24-skill core** — 23 lifecycle workflow skills plus the `using-agent-harness` meta-skill — that runs the spec → plan → build → review → ship cycle. Every specialist skill in the library can also be invoked directly or through an agent scope (see [`docs/SCOPE.md`](docs/SCOPE.md)).

### Core Lifecycle Skills

### Meta - Discover which skill applies

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [using-agent-harness](skills/using-agent-harness/SKILL.md) | Maps incoming work to the right skill workflow and defines shared operating rules | Starting a session or deciding which skill applies |

### Define - Clarify what to build

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [interview-me](skills/interview-me/SKILL.md) | One-question-at-a-time interview that extracts what the user actually wants instead of what they think they should want, until ~95% confidence | The ask is underspecified, or the user invokes "interview me" |
| [grilling](skills/grilling/SKILL.md) | Maps a plan or decision as a tree and interrogates a whole round of unblocked questions at once | Stress-testing a plan with multiple branching sub-decisions, or the user says "grill me" |
| [idea-refine](skills/idea-refine/SKILL.md) | Structured divergent/convergent thinking to turn vague ideas into concrete proposals | You have a rough concept that needs exploration |
| [deep-dive](skills/deep-dive/SKILL.md) | Builds a decision tree from a one-line feature idea and interrogates it in batched rounds scaled to its real size, producing a ready-to-use prompt plus a detailed spec file | A short idea implies a whole feature domain with many independent sub-decisions — role-based access, multi-tenancy, notifications, payments |
| [spec-driven-development](skills/spec-driven-development/SKILL.md) | Write a PRD covering objectives, commands, structure, code style, testing, and boundaries before any code | Starting a new project, feature, or significant change |
| [feature-doc](skills/feature-doc/SKILL.md) | Interview + produce a feature spec, implementation guide, and test cases per feature/actor, grounded in the project's own docs | A feature needs more structure than a single PRD — multiple actors, traceable rules, Gherkin test cases |
| [design-doc-diagramming](skills/design-doc-diagramming/SKILL.md) | Picks the right Mermaid diagram type for the content, drafts and validates it, and assembles it into an architecture/API/feature/database/system design doc | Writing or updating a design doc, or converting existing code/config into an architecture or deployment diagram |
| [excalidraw-diagramming](skills/excalidraw-diagramming/SKILL.md) | Generates a directly-editable `.excalidraw` diagram file with hand-computed element positions | A standalone, editable diagram file is wanted rather than Mermaid embedded in a doc |
| [acquire-codebase-knowledge](skills/acquire-codebase-knowledge/SKILL.md) | Maps an unfamiliar codebase into seven evidence-backed documents (stack, structure, architecture, conventions, integrations, testing, concerns) | Asked to map, document, or onboard into an existing codebase |

### Plan - Break it down

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [planning-and-task-breakdown](skills/planning-and-task-breakdown/SKILL.md) | Decompose specs into small, verifiable tasks with acceptance criteria and dependency ordering | You have a spec and need implementable units |
| [github-issue-planning](skills/github-issue-planning/SKILL.md) | Turns a completed spec into a GitHub Issues hierarchy (Epic → Feature → Story/Enabler → Task) with dependencies, priorities, and board placement | The team tracks work in GitHub Issues/Projects and needs that specific artifact shape |

### Build - Write the code

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [incremental-implementation](skills/incremental-implementation/SKILL.md) | Thin vertical slices - implement, test, verify, commit. Feature flags, safe defaults, rollback-friendly changes | Any change touching more than one file |
| [test-driven-development](skills/test-driven-development/SKILL.md) | Red-Green-Refactor, test pyramid (80/15/5), test sizes, DAMP over DRY, Beyonce Rule, browser testing | Implementing logic, fixing bugs, or changing behavior |
| [context-engineering](skills/context-engineering/SKILL.md) | Feed agents the right information at the right time - rules files, context packing, MCP integrations | Starting a session, switching tasks, or when output quality drops |
| [source-driven-development](skills/source-driven-development/SKILL.md) | Ground every framework decision in official documentation - verify, cite sources, flag what's unverified | You want authoritative, source-cited code for any framework or library |
| [doubt-driven-development](skills/doubt-driven-development/SKILL.md) | Adversarial fresh-context review of every non-trivial decision in-flight - CLAIM → EXTRACT → DOUBT → RECONCILE → STOP, with optional user-authorized cross-model escalation | Stakes are high (production, security, irreversible), working in unfamiliar code, or a confident output is cheaper to verify now than to debug later |
| [frontend-ui-engineering](skills/frontend-ui-engineering/SKILL.md) | Component architecture, design systems, state management, responsive design, WCAG 2.1 AA accessibility | Building or modifying user-facing interfaces |
| [api-and-interface-design](skills/api-and-interface-design/SKILL.md) | Contract-first design, Hyrum's Law, One-Version Rule, error semantics, boundary validation | Designing APIs, module boundaries, or public interfaces |

### Verify - Prove it works

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [browser-testing-with-devtools](skills/browser-testing-with-devtools/SKILL.md) | Chrome DevTools MCP for live runtime data - DOM inspection, console logs, network traces, performance profiling | Building or debugging anything that runs in a browser |
| [debugging-and-error-recovery](skills/debugging-and-error-recovery/SKILL.md) | Five-step triage: reproduce, localize, reduce, fix, guard. Stop-the-line rule, safe fallbacks | Tests fail, builds break, or behavior is unexpected |

### Review - Quality gates before merge

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [code-review-and-quality](skills/code-review-and-quality/SKILL.md) | Five-axis review, change sizing (~100 lines), severity labels (Nit/Optional/FYI), review speed norms, splitting strategies | Before merging any change |
| [code-simplification](skills/code-simplification/SKILL.md) | Chesterton's Fence, Rule of 500, reduce complexity while preserving exact behavior | Code works but is harder to read or maintain than it should be |
| [security-and-hardening](skills/security-and-hardening/SKILL.md) | OWASP Top 10 prevention, auth patterns, secrets management, dependency auditing, three-tier boundary system | Handling user input, auth, data storage, or external integrations |
| [performance-optimization](skills/performance-optimization/SKILL.md) | Measure-first approach - Core Web Vitals targets, profiling workflows, bundle analysis, anti-pattern detection | Performance requirements exist or you suspect regressions |

### Ship - Deploy with confidence

| Skill | What It Does | Use When |
|-------|-------------|----------|
| [git-workflow-and-versioning](skills/git-workflow-and-versioning/SKILL.md) | Trunk-based development, atomic commits, change sizing (~100 lines), the commit-as-save-point pattern | Making any code change (always) |
| [ci-cd-and-automation](skills/ci-cd-and-automation/SKILL.md) | Shift Left, Faster is Safer, feature flags, quality gate pipelines, failure feedback loops | Setting up or modifying build and deploy pipelines |
| [deprecation-and-migration](skills/deprecation-and-migration/SKILL.md) | Code-as-liability mindset, compulsory vs advisory deprecation, migration patterns, zombie code removal | Removing old systems, migrating users, or sunsetting features |
| [documentation-and-adrs](skills/documentation-and-adrs/SKILL.md) | Architecture Decision Records, API docs, inline documentation standards - document the *why* | Making architectural decisions, changing APIs, or shipping features |
| [observability-and-instrumentation](skills/observability-and-instrumentation/SKILL.md) | Structured logging, RED metrics, OpenTelemetry tracing, symptom-based alerting - instrument as you build | Adding telemetry, or shipping anything that runs in production |
| [shipping-and-launch](skills/shipping-and-launch/SKILL.md) | Pre-launch checklists, feature flag lifecycle, staged rollouts, rollback procedures, monitoring setup | Preparing to deploy to production |

---

## 🧑‍💻 Agent Personas

12 specialist personas — each adopts a single engineering role and operates within a curated skill scope.

### Quality & Review Personas

| Agent | Role | Best for |
|-------|------|----------|
| [code-reviewer](agents/code-reviewer.md) | Senior Staff Engineer | Five-axis code review before merge |
| [security-auditor](agents/security-auditor.md) | Security Engineer | Vulnerability detection, OWASP assessment |
| [test-engineer](agents/test-engineer.md) | QA Specialist | Test strategy, coverage analysis, Prove-It pattern |
| [web-performance-auditor](agents/web-performance-auditor.md) | Web Performance Engineer | Core Web Vitals audit; run via `/webperf` |
| [senior-qa-engineer](agents/senior-qa-engineer.md) | Senior QA Engineer | Feature verification, fix validation, regression checks |

### Engineering Domain Personas

| Agent | Role | Best for |
|-------|------|----------|
| [api-developer](agents/api-developer.md) | Senior API Engineer | REST/GraphQL design, OpenAPI spec-first, auth, error contracts |
| [db-architect](agents/db-architect.md) | Senior Database Architect | Schema design, indexing, migrations, query optimisation |
| [senior-devops](agents/senior-devops.md) | Senior DevOps Engineer | CI/CD pipelines, IaC, containerisation, GitOps |
| [senior-frontend-engineer](agents/senior-frontend-engineer.md) | Senior Frontend Engineer | React/TS components, WCAG accessibility, Core Web Vitals |
| [senior-cloud-architect](agents/senior-cloud-architect.md) | Senior Cloud Architect | Multi-region design, IAM, HA/DR, cost optimisation |
| [senior-backend-engineer](agents/senior-backend-engineer.md) | Senior Backend Engineer | Service architecture, async patterns, message queues, caching |
| [ai-ml-engineer](agents/ai-ml-engineer.md) | AI/ML Engineer | Prompt engineering, RAG, LLM evaluation, AI safety |

See [docs/agents.md](docs/agents.md) for the decision matrix, orchestration rules, and how personas compose with skills and slash commands.

---

## 📋 Reference Checklists

Quick-reference material that skills pull in when needed:

| Reference | Covers |
|-----------|--------|
| [testing-patterns.md](references/testing-patterns.md) | Test structure, naming, mocking, React/API/E2E examples, anti-patterns |
| [security-checklist.md](references/security-checklist.md) | Pre-commit checks, auth, input validation, headers, CORS, OWASP Top 10 |
| [performance-checklist.md](references/performance-checklist.md) | Core Web Vitals targets, frontend/backend checklists, measurement commands |
| [accessibility-checklist.md](references/accessibility-checklist.md) | Keyboard nav, screen readers, visual design, ARIA, testing tools |
| [orchestration-patterns.md](references/orchestration-patterns.md) | Endorsed and anti-pattern agent orchestration — who's allowed to invoke whom |
| [external-output-paths.md](references/external-output-paths.md) | Where every file-producing skill writes its output — always outside the project's repo |
| [coding-patterns.md](references/coding-patterns.md) | Structural patterns for build/plan/spec work — clear main path, boundaries around external systems, unrepresentable invalid states, decisions separated from actions, useful errors |

---

## ⚙️ How Skills Work

Every skill follows a consistent anatomy:

```
┌─────────────────────────────────────────────────┐
│  SKILL.md                                       │
│                                                 │
│  ┌─ Frontmatter ─────────────────────────────┐  │
│  │ name: lowercase-hyphen-name               │  │
│  │ description: Guides agents through [task].│  │
│  │              Use when…                    │  │
│  └───────────────────────────────────────────┘  │                                                                                                
│  Overview         → What this skill does        │
│  When to Use      → Triggering conditions       │
│  Process          → Step-by-step workflow       │
│  Rationalizations → Excuses + rebuttals         │
│  Red Flags        → Signs something's wrong     │
│  Verification     → Evidence requirements       │
└─────────────────────────────────────────────────┘
```

**Key design choices:**

- **Process, not prose.** Skills are workflows agents follow, not reference docs they read. Each has steps, checkpoints, and exit criteria.
- **Anti-rationalization.** Every skill includes a table of common excuses agents use to skip steps (e.g., "I'll add tests later") with documented counter-arguments.
- **Verification is non-negotiable.** Every skill ends with evidence requirements - tests passing, build output, runtime data. "Seems right" is never sufficient.
- **Progressive disclosure.** The `SKILL.md` is the entry point. Supporting references load only when needed, keeping token usage minimal.

---

## 🔄 How It Works: End-to-End Workflow

Agent Harness uses a three-layer architecture. Understanding the layers helps you get the most out of it.

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1 — Commands  (the WHEN)                                 │
│  /spec  /plan  /build  /test  /review  /code-simplify  /ship    │
│  User-facing entry points. Each command knows which agent and   │
│  skill(s) to activate for a given phase of the lifecycle.       │
└──────────────────────────┬──────────────────────────────────────┘
                           │ invokes
┌──────────────────────────▼──────────────────────────────────────┐
│  Layer 2 — Agent Personas  (the WHO)                            │
│  api-developer  /  senior-backend-engineer  /  code-reviewer    │
│  Each persona adopts a single engineering role and perspective.  │
│  It holds a curated scope of skills for its domain.             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ invokes
┌──────────────────────────▼──────────────────────────────────────┐
│  Layer 3 — Skills  (the HOW)                                    │
│  spec-driven-development / test-driven-development / etc.       │
│  Step-by-step workflows with checkpoints, exit criteria, and    │
│  anti-rationalization guards. The process knowledge lives here. │
└─────────────────────────────────────────────────────────────────┘
```

### Step-by-step: Building an API Feature

Here is how responsibilities flow from layer to layer when you build a new API endpoint:

**Step 1 — Define the spec**
```
User: /spec "add a user authentication endpoint"
```
→ `/spec` command activates the `spec-driven-development` skill  
→ Skill produces `specs/<feature-slug>/SPEC.md` in the project's external output location (see [references/external-output-paths.md](references/external-output-paths.md)) covering: objective, endpoint contract, auth scheme, error codes, test strategy

**Step 2 — Plan the tasks**
```
User: /plan
```
→ `/plan` command activates `planning-and-task-breakdown` skill  
→ Skill decomposes the spec into atomic, verifiable tasks with acceptance criteria  
→ Produces `plans/<feature-slug>-plan.md` (+ `plans/<feature-slug>-todo.md` if a separate task list is kept) in the project's external output location

**Step 3 — Build incrementally**
```
User: /build
```
→ `/build` command activates the `api-developer` agent persona  
→ `api-developer` consults its skill scope, invokes `test-driven-development` first (write failing tests)  
→ Then invokes `incremental-implementation` (implement one slice at a time)  
→ Each task: RED → GREEN → commit → mark done

**Step 4 — Review from multiple perspectives**
```
User: /review
```
→ `/review` activates `code-reviewer` persona  
→ `code-reviewer` applies the `code-review-and-quality` skill  
→ Five-axis assessment: correctness · readability · architecture · security · performance

**Step 5 — Ship with confidence**
```
User: /ship
```
→ `/ship` fans out THREE personas in parallel:
- `code-reviewer` → code quality report  
- `security-auditor` → vulnerability audit (applies `security-and-hardening` skill)  
- `test-engineer` → coverage report  

→ Main agent merges all reports → single go/no-go decision with rollback plan

### Responsibility Summary

| What you type | Who picks it up | What they do |
|---------------|-----------------|--------------|
| `/spec` | `spec-driven-development` skill | Writes the spec before any code |
| `/plan` | `planning-and-task-breakdown` skill | Decomposes spec into tasks |
| `/build` | `api-developer` or `senior-backend-engineer` persona | Invokes TDD + incremental-implementation skills |
| `/review` | `code-reviewer` persona | Five-axis review via `code-review-and-quality` skill |
| `/ship` | Three personas in parallel | Each applies its domain skill; main agent synthesises |

### Which persona for which work?

| Work type | Persona to invoke |
|-----------|------------------|
| REST or GraphQL endpoint | `api-developer` |
| Database schema or migration | `db-architect` |
| CI/CD pipeline or Dockerfile | `senior-devops` |
| React component or accessibility | `senior-frontend-engineer` |
| Cloud architecture or IaC | `senior-cloud-architect` |
| Backend service or async job | `senior-backend-engineer` |
| LLM integration or RAG system | `ai-ml-engineer` |
| Pre-merge code review | `code-reviewer` |
| Security audit | `security-auditor` |
| Test coverage analysis | `test-engineer` |
| Web performance audit | `web-performance-auditor` |
| Feature verification or fix validation | `senior-qa-engineer` |

### Intent → Skill routing

> **How agents get involved differs by platform.** In **Claude Code**, only skills fire automatically from your words — agents never activate unless you name one explicitly (e.g. "use the api-developer agent") or run a slash command. In **OpenCode / Cursor / Copilot**, the agent column below applies — the platform routes your intent to the agent first, which then invokes the skill.

**Domain intents:**

| If you say... | Skill(s) invoked (Claude Code) | Agent auto-invoked (OpenCode / Cursor) |
|---|---|---|
| API, endpoint, REST, GraphQL, JWT, OAuth, webhook | `api-and-interface-design`, `spec-driven-development` | `api-developer` |
| database, schema, migration, SQL, query, index, ORM | `database-design`, `database-migration` | `db-architect` |
| Docker, Kubernetes, CI/CD, pipeline, deploy, IaC | `ci-cd-and-automation`, `git-workflow-and-versioning` | `senior-devops` |
| component, React, CSS, accessibility, WCAG, bundle | `frontend-ui-engineering`, `react-best-practices` | `senior-frontend-engineer` |
| cloud, AWS, Azure, GCP, IAM, multi-region, serverless | `cloud-architect`, `documentation-and-adrs` | `senior-cloud-architect` |
| backend, microservice, async, Kafka, cache, Redis | `backend-architect`, `api-and-interface-design` | `senior-backend-engineer` |
| AI, LLM, prompt, RAG, vector, embedding, hallucination | `spec-driven-development`, `llm-app-patterns` | `ai-ml-engineer` |
| review, check my code, feedback, before merge, PR | `code-review-and-quality` | `code-reviewer` |
| security, vulnerability, XSS, OWASP, harden, CVE | `security-and-hardening` | `security-auditor` |
| test, coverage, unit test, E2E, Jest, Playwright, mock | `test-driven-development` | `test-engineer` |
| verify, QA, does this work, confirm the fix, smoke test | `quality-assurance` | `senior-qa-engineer` |
| slow, LCP, INP, CLS, Core Web Vitals, Lighthouse | `performance-optimization` | `web-performance-auditor` |

**Cross-cutting intents** (skill only on both platforms — no agent):

| If you say... | Skill(s) invoked |
|---|---|
| build, implement, add, create, new feature | `spec-driven-development` → domain agent → `incremental-implementation` → `test-driven-development` |
| plan this, how should I approach, break this down, plan, tasks, roadmap, where do I start | `planning-and-task-breakdown` |
| execute the plan, follow the plan, implement the plan | `executing-plans` |
| bug, broken, not working, crash, something is wrong, root cause | `systematic-debugging` |
| simplify, clean up, reduce complexity, hard to read | `code-simplification` |
| brainstorm, ideas for, what are the options, explore approaches | `brainstorming` |
| someone reviewed my code, here are review comments, address these comments | `receiving-code-review` |
| request a review, ready for review, PR is ready | `requesting-code-review` |
| I'm done, implementation complete, ready to merge, all tests pass | `finishing-a-development-branch` |
| it works, looks good, should be fixed, I think it's done | `verification-before-completion` |

---

## 📁 Project Structure

```
agent-harness/
├── skills/                            # 24 core lifecycle skills + curated specialist skills (178 total)
│   ├── interview-me/                  #   Define
│   ├── idea-refine/                   #   Define
│   ├── spec-driven-development/       #   Define
│   ├── planning-and-task-breakdown/   #   Plan
│   ├── incremental-implementation/    #   Build
│   ├── context-engineering/           #   Build
│   ├── source-driven-development/     #   Build
│   ├── doubt-driven-development/      #   Build
│   ├── frontend-ui-engineering/       #   Build
│   ├── test-driven-development/       #   Build
│   ├── api-and-interface-design/      #   Build
│   ├── browser-testing-with-devtools/ #   Verify
│   ├── debugging-and-error-recovery/  #   Verify
│   ├── code-review-and-quality/       #   Review
│   ├── code-simplification/           #   Review
│   ├── security-and-hardening/        #   Review
│   ├── performance-optimization/      #   Review
│   ├── git-workflow-and-versioning/   #   Ship
│   ├── ci-cd-and-automation/          #   Ship
│   ├── deprecation-and-migration/     #   Ship
│   ├── documentation-and-adrs/        #   Ship
│   ├── observability-and-instrumentation/ # Ship
│   ├── shipping-and-launch/           #   Ship
│   └── using-agent-harness/           #   Meta
├── agents/                            # 12 specialist personas
│   ├── code-reviewer.md               #   Quality & review
│   ├── security-auditor.md            #   Quality & review
│   ├── test-engineer.md               #   Quality & review
│   ├── web-performance-auditor.md     #   Quality & review
│   ├── senior-qa-engineer.md          #   Quality & review
│   ├── api-developer.md               #   Engineering domain
│   ├── db-architect.md                #   Engineering domain
│   ├── senior-devops.md               #   Engineering domain
│   ├── senior-frontend-engineer.md    #   Engineering domain
│   ├── senior-cloud-architect.md      #   Engineering domain
│   ├── senior-backend-engineer.md     #   Engineering domain
│   └── ai-ml-engineer.md              #   Engineering domain
├── references/                        # 11 supplementary checklists
├── hooks/                             # Session lifecycle hooks
├── .claude/commands/                  # 8 slash commands (Claude Code)
├── .gemini/commands/                  # Slash commands (Gemini CLI)
├── commands/                          # Slash commands (Antigravity CLI)
├── .claude-plugin/plugin.json          # Plugin manifest
└── docs/                              # Setup guides per tool
```

---

## 💡 Why Agent Harness?

> AI coding agents default to the shortest path — which often means skipping specs, tests, security reviews, and the practices that make software reliable. Agent Harness gives agents structured workflows that enforce the same discipline senior engineers bring to production code.

Each skill encodes hard-won engineering judgment: *when* to write a spec, *what* to test, *how* to review, and *when* to ship. These aren't generic prompts - they're the kind of opinionated, process-driven workflows that separate production-quality work from prototype-quality work.

Skills bake in best practices from Google's engineering culture — including concepts from [Software Engineering at Google](https://abseil.io/resources/swe-book) and Google's [engineering practices guide](https://google.github.io/eng-practices/). You'll find Hyrum's Law in API design, the Beyonce Rule and test pyramid in testing, change sizing and review speed norms in code review, Chesterton's Fence in simplification, trunk-based development in git workflow, Shift Left and feature flags in CI/CD, and a dedicated deprecation skill treating code as a liability. These aren't abstract principles — they're embedded directly into the step-by-step workflows agents follow.

---

## 🤝 Contributing

Skills should be **specific** (actionable steps, not vague advice), **verifiable** (clear exit criteria with evidence requirements), **battle-tested** (based on real workflows), and **minimal** (only what's needed to guide the agent).

See [docs/skill-anatomy.md](docs/skill-anatomy.md) for the format specification and [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

<div align="center">

## 📄 License

**MIT** — use these skills in your projects, teams, and tools.

<sub>Built by [Nicholas Aigberua](https://github.com/Ghosteken) · If this saved you time, consider starring the repo ⭐</sub>

</div>
