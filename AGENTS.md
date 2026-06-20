# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Cursor, Copilot, Antigravity, etc.) when working with code in this repository.

## Repository Overview

agent-harness is a production-grade collection of engineering skills and specialist agent personas for AI coding assistants (Claude Code, Cursor, Copilot, Gemini CLI, and others). Skills are step-by-step workflows that encode what senior engineers do consistently. Agent personas are specialist roles that apply those skills from a specific engineering perspective.

## Agent Personas

twelve specialist personas are available in `agents/`. Each persona adopts a single engineering role and operates within its curated skill scope.

| Persona | Role | Trigger |
|---------|------|---------|
| `code-reviewer` | Senior Staff Engineer | Review any code change before merge |
| `security-auditor` | Security Engineer | Security audit, vulnerability detection |
| `test-engineer` | QA Engineer | Test strategy and coverage analysis |
| `web-performance-auditor` | Web Performance Engineer | Core Web Vitals and loading performance |
| `api-developer` | Senior API Engineer | API design, contract review, integration |
| `db-architect` | Senior Database Architect | Schema design, queries, migrations |
| `senior-devops` | Senior DevOps Engineer | Pipelines, IaC, containers, incidents |
| `senior-frontend-engineer` | Senior Frontend Engineer | UI components, accessibility, bundle size |
| `senior-cloud-architect` | Senior Cloud Architect | Cloud design, IAM, DR, cost |
| `senior-backend-engineer` | Senior Backend Engineer | Services, async, queues, caching |
| `ai-ml-engineer` | AI/ML Engineer | Prompts, RAG, LLM evaluation, AI safety |
| `senior-qa-engineer` | Senior QA Engineer | Feature verification, fix validation, regression checks |

**Architecture:** `Command` → invokes `Agent persona` → persona invokes `Skill(s)`.

Each persona's Composition block (in its `.md` file) lists its curated skill scope — the 20 skills it may invoke. When an agent is active, invoke a skill from its scope by name: `Use skill <skill-name> to...`. Skills outside an agent's scope can be invoked manually or via a slash command at any time. The full scope registry is at `scripts/agent-scopes.json`.

## OpenCode Integration

OpenCode uses a **skill-driven execution model** powered by the `skill` tool and this repository's `/skills` directory.

### Core Rules

- If a task matches a skill, you MUST invoke it
- Skills are located in `skills/<skill-name>/SKILL.md`
- Never implement directly if a skill applies
- Always follow the skill instructions exactly (do not partially apply them)

### Intent → Skill Mapping

When the user describes a task without naming an agent or command, map their words to the right agent and entry-point skill. The `using-agent-harness` skill handles routing automatically — the table below is the reference.

#### API & Integration
**Keywords:** API, endpoint, REST, GraphQL, OpenAPI, Swagger, versioning, rate limiting, JWT, OAuth, pagination, contract, webhook, idempotent, CRUD, HTTP method, request/response schema
→ `api-developer` → `api-and-interface-design`, `spec-driven-development`

#### Database & Data Storage
**Keywords:** database, schema, table, migration, SQL, query, index, slow query, PostgreSQL, MySQL, MongoDB, Redis, ORM, Prisma, Drizzle, normalization, foreign key, join, NoSQL, transaction
→ `db-architect` → `database-design`, `database-migration`

#### Infrastructure, CI/CD & Deployment
**Keywords:** Docker, Kubernetes, Terraform, CI/CD, pipeline, deploy, container, GitHub Actions, GitOps, Helm, secrets, environment variables, IaC, SLO, incident, monitoring, alerting, blue-green, canary
→ `senior-devops` → `ci-cd-and-automation`, `git-workflow-and-versioning`

#### Frontend & UI
**Keywords:** component, React, Next.js, Vue, Tailwind, CSS, HTML, UI, UX, accessibility, WCAG, keyboard navigation, state management, Zustand, Redux, re-render, bundle, design system, responsive, animation
→ `senior-frontend-engineer` → `frontend-ui-engineering`, `react-best-practices`

#### Cloud Architecture
**Keywords:** cloud, AWS, Azure, GCP, multi-region, disaster recovery, high availability, IAM, cost optimization, serverless, Lambda, Cloud Run, CloudFormation, auto-scaling, Well-Architected, VPC, vendor lock-in
→ `senior-cloud-architect` → `cloud-architect`, `documentation-and-adrs`

#### Backend Services
**Keywords:** backend, service, microservice, async, message queue, Kafka, RabbitMQ, cache, Redis, gRPC, Go, Golang, Node.js, Python, FastAPI, Django, circuit breaker, background job, event sourcing, CQRS, worker
→ `senior-backend-engineer` → `backend-architect`, `api-and-interface-design`

#### AI / ML Features
**Keywords:** AI, LLM, GPT, Claude, Anthropic, prompt, RAG, vector, embedding, fine-tuning, agent, LangChain, LangGraph, evaluation, hallucination, guardrail, tool use, function calling, semantic search, chatbot
→ `ai-ml-engineer` → `spec-driven-development`, `llm-app-patterns`

#### Code Review & Quality
**Keywords:** review, check my code, is this good, feedback, before merge, pull request, PR, refactor, simplify, code smell, technical debt
→ `code-reviewer` → `code-review-and-quality`

#### Security
**Keywords:** security, vulnerability, audit, XSS, SQL injection, CSRF, auth bypass, secure, harden, OWASP, CVE, token, password, encryption, sensitive data, prompt injection
→ `security-auditor` → `security-and-hardening`

#### Testing
**Keywords:** test, coverage, failing test, bug proof, unit test, integration test, E2E, Cypress, Playwright, Jest, pytest, mock, stub, test suite
→ `test-engineer` → `test-driven-development`

#### QA Verification
**Keywords:** verify, QA, does this work, check if it works, make sure nothing is broken, confirm the fix, regression check, validate the feature, feature verification, working as expected, verify all fixes, end-to-end check, smoke test, sanity check, verify all the fixes are in place, is this working, confirm this is fixed
→ `senior-qa-engineer` → `quality-assurance`

#### Web Performance
**Keywords:** slow, performance, LCP, INP, CLS, Core Web Vitals, Lighthouse, bundle size, lazy load, render blocking, TTFB, page speed
→ `web-performance-auditor` → `performance-optimization`

#### General Feature / New Functionality
**Keywords:** build, implement, add, create, new feature (without a domain keyword above)
→ `spec-driven-development`, then domain agent, then `incremental-implementation`, `test-driven-development`

#### Planning / Breakdown
**Keywords:** plan, break down, tasks, roadmap, how do I approach, where do I start
→ `planning-and-task-breakdown`

#### Bug / Error
**Keywords:** bug, broken, error, not working, unexpected, crash, failing, regression
→ `debugging-and-error-recovery`

#### Simplification / Cleanup
**Keywords:** simplify, clean up, reduce complexity, too complex, hard to read, refactor
→ `code-simplification`

### Lifecycle Mapping (Implicit Commands)

OpenCode does not support slash commands like `/spec` or `/plan`.

Instead, the agent must internally follow this lifecycle:

- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → `incremental-implementation` + `test-driven-development`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch`

### Execution Model

For every request:

1. Determine if any skill applies (even 1% chance)
2. Invoke the appropriate skill using the `skill` tool
3. Follow the skill workflow strictly
4. Only proceed to implementation after required steps (spec, plan, etc.) are complete

### Anti-Rationalization

The following thoughts are incorrect and must be ignored:

- "This is too small for a skill"
- "I can just quickly implement this"
- "I’ll gather context first"

Correct behavior:

- Always check for and use skills first

This ensures OpenCode behaves similarly to Claude Code with full workflow enforcement.

## Orchestration: Personas, Skills, and Commands

This repo has three composable layers. They have different jobs and should not be confused:

- **Skills** (`skills/<name>/SKILL.md`) — workflows with steps and exit criteria. The *how*. Mandatory hops when an intent matches.
- **Personas** (`agents/<role>.md`) — roles with a perspective and an output format. The *who*.
- **Slash commands** (`.claude/commands/*.md`) — user-facing entry points. The *when*. The orchestration layer.

Composition rule: **the user (or a slash command) is the orchestrator. Personas do not invoke other personas.** A persona may invoke skills.

The only multi-persona orchestration pattern this repo endorses is **parallel fan-out with a merge step** — used by `/ship` to run `code-reviewer`, `security-auditor`, and `test-engineer` concurrently and synthesize their reports. Do not build a "router" persona that decides which other persona to call; that's the job of slash commands and intent mapping.

See [docs/agents.md](docs/agents.md) for the decision matrix and [references/orchestration-patterns.md](references/orchestration-patterns.md) for the full pattern catalog.

**Claude Code interop:** the personas in `agents/` work as Claude Code subagents (auto-discovered from this plugin's `agents/` directory) and as Agent Teams teammates (referenced by name when spawning). Two platform constraints align with our rules: subagents cannot spawn other subagents, and teams cannot nest. Plugin agents silently ignore the `hooks`, `mcpServers`, and `permissionMode` frontmatter fields.

## Creating a New Skill

### Directory Structure

```
skills/
  {skill-name}/           # kebab-case directory name
    SKILL.md              # Required: skill definition
    scripts/              # Required: executable scripts
      {script-name}.sh    # Bash scripts (preferred)
  {skill-name}.zip        # Required: packaged for distribution
```

### Naming Conventions

- **Skill directory**: `kebab-case` (e.g. `web-quality`)
- **SKILL.md**: Always uppercase, always this exact filename
- **Scripts**: `kebab-case.sh` (e.g., `deploy.sh`, `fetch-logs.sh`)
- **Zip file**: Must match directory name exactly: `{skill-name}.zip`

### SKILL.md Format

```markdown
---
name: {skill-name}
description: {One sentence describing what the skill does, followed by one or more "Use when" trigger conditions. Include trigger phrases like "Deploy my app" or "Check logs" when helpful.}
---

# {Skill Title}

{Brief overview of what the skill does and why it matters.}

## How It Works

{Numbered list explaining the skill's workflow}

Equivalent headings like `Workflow`, `Core Process`, or `When to Use` are fine when they communicate the same structure clearly.

## Usage (Optional)

Include this section only if the skill ships runnable helpers under `scripts/`. Markdown-only skills can omit both the section and the directory entirely.

```bash
bash /mnt/skills/user/{skill-name}/scripts/{script}.sh [args]
```

**Arguments:**
- `arg1` - Description (defaults to X)

**Examples:**
{Show 2-3 common usage patterns}

## Output

{Show example output users will see}

## Present Results to User

{Template for how Claude should format results when presenting to users}

## Troubleshooting

{Common issues and solutions, especially network/permissions errors}
```

### Best Practices for Context Efficiency

Skills are loaded on-demand — only the skill name and description are loaded at startup. The full `SKILL.md` loads into context only when the agent decides the skill is relevant. To minimize context usage:

- **Keep SKILL.md under 500 lines** — put detailed reference material in separate files
- **Write specific descriptions** — helps the agent know exactly when to activate the skill
- **Use progressive disclosure** — reference supporting files that get read only when needed
- **Prefer scripts over inline code** — script execution doesn't consume context (only output does)
- **File references work one level deep** — link directly from SKILL.md to supporting files

### Script Requirements

- Use `#!/bin/bash` shebang
- Use `set -e` for fail-fast behavior
- Write status messages to stderr: `echo "Message" >&2`
- Write machine-readable output (JSON) to stdout
- Include a cleanup trap for temp files
- Reference the script path as `/mnt/skills/user/{skill-name}/scripts/{script}.sh`

### Creating the Zip Package

After creating or updating a skill:

```bash
cd skills
zip -r {skill-name}.zip {skill-name}/
```

### End-User Installation

Document these two installation methods for users:

**Claude Code:**
```bash
cp -r skills/{skill-name} ~/.claude/skills/
```

**claude.ai:**
Add the skill to project knowledge or paste SKILL.md contents into the conversation.

If the skill requires network access, instruct users to add required domains at `claude.ai/settings/capabilities`.
