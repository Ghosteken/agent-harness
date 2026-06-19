---
name: using-agent-harness
type: meta
description: Intent router for agent-harness — maps what the user describes to the right agent persona and skill. Use when starting any task to determine which agent and skill should handle it.
---

# Using Agent Harness

This meta-skill routes user intent to the correct agent persona and skill scope. Read it at the start of any session or when a user describes a task without specifying an agent or command.

## Two Entry Paths (Both Supported)

**Path 1 — Slash commands (explicit, backwards-compatible):**
Users can always invoke a command directly. Commands route straight to their skill — no agent lookup needed.

| Command | Invokes | Purpose |
|---------|---------|---------|
| `/spec` | `spec-driven-development` | Write a structured spec before coding |
| `/plan` | `planning-and-task-breakdown` | Break work into tasks with acceptance criteria |
| `/build` | `incremental-implementation` + `test-driven-development` | Implement the next task (or whole plan with `auto`) |
| `/test` | `test-driven-development` | TDD loop — red, green, refactor |
| `/review` | `code-review-and-quality` | Five-axis code review before merge |
| `/ship` | `shipping-and-launch` | Fan-out to code-reviewer + security-auditor + test-engineer |
| `/webperf` | `performance-optimization` | Web performance audit via web-performance-auditor |
| `/code-simplify` | `code-simplification` | Simplify without changing behavior |

Commands are always valid. When a user types one, follow it directly — skip the intent routing below.

---

**Path 2 — Intent routing (natural language):**
When a user describes what they want to build, fix, or review — without using a slash command — match their words against the keyword table below to determine:

1. **Which agent to invoke** (the *who*)
2. **Which skill to start with** (the *how*)
3. **Which command applies** (the *when*)

## Intent → Agent → Skill Routing Table

### API & Integration Work
**Trigger words:** API, endpoint, REST, GraphQL, OpenAPI, Swagger, versioning, rate limiting, JWT, OAuth, pagination, contract, webhook, idempotent, CRUD, HTTP, request/response

→ **Agent:** `api-developer`
→ **Start with skill:** `api-and-interface-design` or `spec-driven-development`
→ **Command:** `/spec` then `/build`

---

### Database & Data Storage
**Trigger words:** database, schema, table, migration, SQL, query, index, PostgreSQL, MySQL, MongoDB, Redis, ORM, Prisma, Drizzle, normalization, foreign key, join, slow query, NoSQL

→ **Agent:** `db-architect`
→ **Start with skill:** `database-design` or `database-migration`
→ **Command:** `/spec` then `/build`

---

### Infrastructure, CI/CD & Deployment
**Trigger words:** Docker, Kubernetes, Terraform, CI/CD, pipeline, deploy, container, GitHub Actions, GitOps, Helm, secrets, environment variables, infrastructure, IaC, Ansible, SLO, incident, monitoring, alerting

→ **Agent:** `senior-devops`
→ **Start with skill:** `ci-cd-and-automation` or `docker-expert`
→ **Command:** `/build` or `/ship`

---

### Frontend & UI
**Trigger words:** component, React, Next.js, Vue, Tailwind, CSS, HTML, UI, UX, accessibility, WCAG, keyboard navigation, state management, Zustand, Redux, re-render, bundle, design system, dark mode, responsive, animation

→ **Agent:** `senior-frontend-engineer`
→ **Start with skill:** `frontend-ui-engineering` or `react-best-practices`
→ **Command:** `/spec` then `/build`

---

### Cloud Architecture
**Trigger words:** cloud, AWS, Azure, GCP, multi-region, disaster recovery, high availability, IAM, cost optimization, serverless, Lambda, Cloud Run, CloudFormation, auto-scaling, Well-Architected, CDN, VPC, vendor lock-in

→ **Agent:** `senior-cloud-architect`
→ **Start with skill:** `cloud-architect` or `documentation-and-adrs`
→ **Command:** `/spec` or `/build`

---

### Backend Services & APIs
**Trigger words:** backend, service, microservice, async, message queue, Kafka, RabbitMQ, cache, Redis, gRPC, Go, Golang, Node.js, Python, FastAPI, Django, circuit breaker, background job, event sourcing, CQRS, worker

→ **Agent:** `senior-backend-engineer`
→ **Start with skill:** `backend-architect` or `api-and-interface-design`
→ **Command:** `/spec` then `/build`

---

### AI / ML Features
**Trigger words:** AI, LLM, GPT, Claude, Anthropic, prompt, RAG, vector, embedding, fine-tuning, agent, LangChain, LangGraph, evaluation, hallucination, guardrail, tool use, function calling, AI safety, semantic search, chatbot

→ **Agent:** `ai-ml-engineer`
→ **Start with skill:** `spec-driven-development` or `llm-app-patterns`
→ **Command:** `/spec` then `/build`

---

### Code Review & Quality
**Trigger words:** review, check my code, is this good, feedback on, before merge, pull request, PR, clean up, refactor, simplify, code smell, technical debt

→ **Agent:** `code-reviewer`
→ **Start with skill:** `code-review-and-quality`
→ **Command:** `/review`

---

### Security
**Trigger words:** security, vulnerability, audit, hack, inject, XSS, SQL injection, CSRF, auth bypass, secure, harden, OWASP, CVE, token, password, encryption, sensitive data

→ **Agent:** `security-auditor`
→ **Start with skill:** `security-and-hardening`
→ **Command:** `/review` or `/ship`

---

### Testing
**Trigger words:** test, spec, coverage, failing test, bug proof, unit test, integration test, E2E, Cypress, Playwright, Jest, pytest, mock, stub, test suite

→ **Agent:** `test-engineer`
→ **Start with skill:** `test-driven-development`
→ **Command:** `/test`

---

### Web Performance
**Trigger words:** slow, performance, LCP, INP, CLS, Core Web Vitals, Lighthouse, bundle size, lazy load, preload, render blocking, TTFB, speed

→ **Agent:** `web-performance-auditor`
→ **Start with skill:** `performance-optimization`
→ **Command:** `/webperf`

---

## Lifecycle Commands

When the user describes a full feature (not just one concern), follow the lifecycle:

| Phase | Command | Agent(s) | Skills |
|-------|---------|----------|--------|
| Define | `/spec` | domain agent | `spec-driven-development` |
| Plan | `/plan` | domain agent | `planning-and-task-breakdown` |
| Build | `/build` | domain agent | `incremental-implementation` + `test-driven-development` |
| Verify | `/test` | `test-engineer` | `test-driven-development` |
| Review | `/review` | `code-reviewer` | `code-review-and-quality` |
| Ship | `/ship` | `code-reviewer` + `security-auditor` + `test-engineer` | `shipping-and-launch` |

## Routing Decision Process

1. **Read the user's message** — extract the domain nouns and action verbs
2. **Match against the keyword table** — find the strongest signal category
3. **Check for multiple concerns** — if the task spans multiple domains (e.g. "build a secure API with a database"), route to the primary domain agent first; surface secondary concerns in their skill invocations
4. **State the route** — tell the user which agent and skill you're invoking and why
5. **Invoke the agent/skill** — do not implement without first routing

## Multiple Domain Signals

When a request spans multiple domains, apply this priority order:
1. Security concerns → always surface to `security-auditor`
2. Primary build domain → route to domain agent
3. Testing → `test-engineer` at the end
4. Review → `code-reviewer` before ship

**Example:** "Build a user registration endpoint with password hashing and email verification"
- Primary: `api-developer` (endpoint)
- Secondary: `security-auditor` (password hashing)
- Lifecycle: `/spec` → `/build` → `/test` → `/ship`

## Anti-Patterns

Do not:
- Implement without routing first
- Skip the domain agent for "simple" tasks
- Route everything to `code-reviewer` — that is for review, not build
- Invoke multiple agents sequentially yourself — use `/ship` for fan-out

## Relationship to Other Skills

This skill is the **entry point**. After routing, hand off to the domain agent which then uses its `## When to Invoke Skills` table to pull the right skill from its scope.

```
User intent → using-agent-harness (this skill) → Agent persona → Skill
```
