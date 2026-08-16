---
description: Start spec-driven development — write a structured specification before writing code
---

Invoke the agent-harness:spec-driven-development skill.

Begin by understanding what the user wants to build. Ask clarifying questions about:
1. The objective and target users
2. Core features and acceptance criteria
3. Tech stack preferences and constraints
4. Known boundaries (what to always do, ask first about, and never do)

Whenever a clarifying question or open question has a small set of distinct answers (a choice between approaches, yes/no, pick-one-of-N), ask it with the AskUserQuestion tool instead of printing it as text — including the "Open Questions" checkpoint before implementation starts. Only fall back to plain text for questions that genuinely need a freeform answer.

Then generate a structured spec covering all six core areas: objective, commands, project structure, code style, testing strategy, and boundaries.

Save every spec under `docs/specs/<feature-slug>/SPEC.md`. If `docs/`, `docs/specs/`, or the feature's subfolder don't exist yet, create them — that's the standard home for specs in this project, not the project root. Check whether a spec folder for this feature already exists before writing — if so, confirm with the user whether to update it in place or create a new one (e.g. `docs/specs/<feature-slug>-2/SPEC.md`). Never overwrite an unrelated existing spec by defaulting to a generic root-level `SPEC.md`. Confirm the chosen path and content with the user before proceeding.
