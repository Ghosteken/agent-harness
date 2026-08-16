# Skills Directory

This folder holds agent-harness's curated skill set: **174 skills** — the 24 hand-authored lifecycle skills, a role-scoped extension set defined in [`scripts/agent-scopes.json`](../scripts/agent-scopes.json), and a couple of skills restored because other kept skills depend on them (e.g. `multi-agent-brainstorming`, required by `brainstorming`'s handoff rule).

## What Are Skills?

Skills are specialized instruction sets that teach the agent how to handle specific tasks — expert knowledge modules loaded on demand via the `Skill` tool.

## Folder Structure

Each skill lives in its own folder:

```
skills/
├── skill-name/
│   ├── SKILL.md             # Main skill definition (required)
│   ├── scripts/              # Helper scripts (optional)
│   ├── examples/             # Usage examples (optional)
│   └── resources/            # Templates & resources (optional)
```

Only `SKILL.md` is required.

## How Skills Are Curated

This directory is intentionally small. `agent-harness` started from a bulk import of ~1,550 community skills; the long tail (persona skills, single-integration automations, marketing/SEO niches, unrelated verticals) has been moved to `archive/skills-community/` — still in the repo, still browsable, but no longer exposed to the agent via the plugin's skill glob.

The set that remains here is:
1. **24 core lifecycle skills** — `using-agent-harness` (the intent router and pre-flight mandate) plus 23 others covering the full define → plan → build → verify → review → ship lifecycle. See root [`CLAUDE.md`](../CLAUDE.md) and [`README.md`](../README.md) for the full list.
2. **A handful of cross-cutting process skills** the router treats as always-relevant regardless of domain: `brainstorming`, `planning-and-task-breakdown`, `executing-plans`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `subagent-driven-development`.
3. **Role-scoped extension skills** — each of the 12 agent personas (`agents/*.md`) has a ~20-skill scope defined in `scripts/agent-scopes.json`, validated by `scripts/validate-skills.js`.

## How to Use Skills

The `using-agent-harness` meta-skill is injected into every session and routes user intent to the right skill automatically — see its **Intent → Agent → Skill Routing Table**. You can also invoke any skill directly, or use a slash command (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`, `/webperf`, `/code-simplify`) to route straight to it.

## Finding Skills

```bash
ls skills/                      # browse the curated set
ls skills/ | grep "keyword"     # search by keyword
cat scripts/agent-scopes.json   # see the full per-persona scope
```

Looking for something not in this list? Check `archive/skills-community/` — it holds the rest of the original bulk import, unexposed but not deleted.

## Creating a New Skill

1. Read [`CONTRIBUTING.md`](../CONTRIBUTING.md)
2. Follow [`docs/skill-anatomy.md`](../docs/skill-anatomy.md) for the required structure
3. Add it to the relevant persona's list in `scripts/agent-scopes.json` if it should be exposed to that agent

## Documentation

- [Getting Started](../docs/getting-started.md)
- [Skill Anatomy](../docs/skill-anatomy.md)
- [Agent Personas](../docs/agents.md)
