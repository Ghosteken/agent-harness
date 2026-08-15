# agent-harness

This is the agent-harness project — a production-grade collection of engineering skills and specialist agent personas for AI coding assistants.

## Project Structure

```
skills/            → Curated skills (SKILL.md per directory) exposed to the agent
archive/           → Pre-prune bulk-import skills and tooling, kept but not exposed
agents/            → Specialist agent personas (12 total — see below)
hooks/             → Session lifecycle hooks
.claude/commands/  → Slash commands for Claude Code
commands/          → Slash commands for Antigravity CLI
.gemini/commands/  → Slash commands for Gemini CLI
.claude-plugin/    → Plugin manifest (plugin.json) and marketplace listing
scripts/           → Skill validation (validate-skills.js), agent-scopes.json, install/build scripts
references/        → Supplementary checklists (testing, performance, security, accessibility, orchestration)
docs/              → Setup guides for different tools
CONTRIBUTING.md    → Guidelines for adding or editing skills
```

## Agent Personas

| Agent | Role | Primary Scope |
|-------|------|--------------|
| `code-reviewer` | Senior Staff Engineer | Five-axis code review |
| `security-auditor` | Security Engineer | Vulnerability detection, OWASP |
| `test-engineer` | QA Engineer | Test strategy, coverage analysis |
| `web-performance-auditor` | Web Performance Engineer | Core Web Vitals audit |
| `api-developer` | Senior API Engineer | REST/GraphQL, spec-first, auth, versioning |
| `db-architect` | Senior Database Architect | Schema design, indexing, migrations |
| `senior-devops` | Senior DevOps Engineer | CI/CD, IaC, containers, GitOps |
| `senior-frontend-engineer` | Senior Frontend Engineer | React/TS, accessibility, Core Web Vitals |
| `senior-cloud-architect` | Senior Cloud Architect | Multi-region, IAM, HA/DR, cost optimisation |
| `senior-backend-engineer` | Senior Backend Engineer | Service architecture, async, queues, caching |
| `ai-ml-engineer` | AI/ML Engineer | Prompt engineering, RAG, LLM evaluation |
| `senior-qa-engineer` | Senior QA Engineer | Feature verification, fix validation, regression checks |

## Skills by Phase

**Define:** interview-me, grilling, idea-refine, spec-driven-development, feature-doc, design-doc-diagramming, excalidraw-diagramming, acquire-codebase-knowledge
**Plan:** planning-and-task-breakdown, github-issue-planning
**Build:** incremental-implementation, test-driven-development, context-engineering, source-driven-development, doubt-driven-development, frontend-ui-engineering, api-and-interface-design
**Verify:** browser-testing-with-devtools, debugging-and-error-recovery
**Review:** code-review-and-quality, code-simplification, security-and-hardening, performance-optimization
**Ship:** git-workflow-and-versioning, ci-cd-and-automation, deprecation-and-migration, documentation-and-adrs, observability-and-instrumentation, shipping-and-launch

## Conventions

- Every skill lives in `skills/<name>/SKILL.md`
- YAML frontmatter with `name` and `description` fields
- Description starts with what the skill does (third person), followed by trigger conditions ("Use when...")
- Every skill has: Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification
- References are in `references/`, not inside skill directories
- Supporting files only created when content exceeds 100 lines

## Commands

- `npm test` — Not applicable (this is a documentation project)
- Validate: Check that all SKILL.md files have valid YAML frontmatter with name and description

## Boundaries

- Always: Follow the skill-anatomy.md format for new skills
- Never: Add skills that are vague advice instead of actionable processes
- Never: Duplicate content between skills — reference other skills instead
