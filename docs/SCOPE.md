# Agent Harness Skill Scopes

`agent-harness` exposes a curated set of **174 skills** to the agent — the 24 hand-authored lifecycle skills, a role-scoped extension set, and a couple of skills restored from archive because other kept skills functionally depend on them. This replaces an earlier draft of this document that described ~40 aspirational "packs" and activation scripts (`activate-skills.sh`, `data/scopes.json`) that were never actually implemented in this repository. What's described below is the real, working mechanism.

## How scoping actually works

- **[`scripts/agent-scopes.json`](../scripts/agent-scopes.json)** is the source of truth. It defines a ~20-skill scope for each of the 12 agent personas in `agents/`:

  | Persona | Role |
  |---|---|
  | `api-developer` | Senior API Engineer |
  | `db-architect` | Senior Database Architect |
  | `senior-devops` | Senior DevOps Engineer |
  | `senior-frontend-engineer` | Senior Frontend Engineer |
  | `senior-cloud-architect` | Senior Cloud Architect |
  | `senior-backend-engineer` | Senior Backend Engineer |
  | `ai-ml-engineer` | AI/ML Engineer |
  | `code-reviewer` | Senior Staff Engineer |
  | `security-auditor` | Security Engineer |
  | `test-engineer` | QA Engineer |
  | `web-performance-auditor` | Web Performance Engineer |
  | `senior-qa-engineer` | Senior QA Engineer |

- **[`scripts/validate-skills.js`](../scripts/validate-skills.js)** validates this curated set by default (pass `--all` to validate every skill directory, including archived ones, if you're restoring something).
- **`skills/`** contains only the 178 skills this scheme resolves to — everything else from the original bulk import lives in **`archive/skills-community/`**, unexposed to the agent but still browsable and restorable (`git mv` it back into `skills/` if you need it).
- **`using-agent-harness/SKILL.md`** is the entry point: its Intent → Agent → Skill routing table maps natural-language requests to a persona + starting skill, and its Cross-Cutting Skills section lists the process skills (`brainstorming`, `planning-and-task-breakdown`, `systematic-debugging`, etc.) that apply regardless of domain.

## Using a scope

You don't need to "activate" anything — the skills in `skills/` are always available. To work primarily as one persona:

1. Read that persona's file in `agents/` for its full behavioral brief.
2. Check its skill list in `scripts/agent-scopes.json` for what it reaches for.
3. Invoke skills directly (`Use skill-name...` / `@skill-name`, depending on your AI assistant), or let `using-agent-harness`'s routing table pick automatically from your request.

## Adding a skill to a scope

Edit `scripts/agent-scopes.json`, add the skill name to the relevant persona's `skills` array, and make sure the skill directory exists under `skills/` (pull it out of `archive/skills-community/` first if it's archived). Run `node scripts/validate-skills.js` to confirm it validates.
