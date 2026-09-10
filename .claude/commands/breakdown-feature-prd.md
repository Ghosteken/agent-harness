---
description: Write product-facing feature PRDs grounded in project context or docs — for every feature in that context, or for one named feature
---

Invoke the agent-harness:breakdown-feature-prd skill.

Determine the mode from the request: a whole-project sweep (context/docs, or "the codebase", given with no single feature named) or a single named feature. For a sweep, read whatever docs/context were pointed at and explore the codebase to enumerate the candidate feature list — then confirm that list with the user (use the AskUserQuestion tool when the choice is small and discrete) before drafting any individual doc. Never invent a feature list or PRD content the provided context doesn't support.

For each feature, draft: Feature Name, Goal (Problem/Solution/Impact), User Personas, User Stories (`As a <persona>, I want to <action> so I can <benefit>`), Requirements (Functional and Non-Functional), Acceptance Criteria (Given/When/Then), and Out of Scope. Ask rather than invent when the context doesn't say — especially for Impact metrics.

Save each feature's PRD to `features/<feature-slug>/prd.md` in the project's external output location (see `references/external-output-paths.md`) — never inside the project's own repo. Check whether a doc for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one. Create or update `features/README.md` as a running index — one line per feature, with a link and one-sentence summary — every time a feature doc is written. Tell the user the full path(s) written, and that each `prd.md` is ready to hand to `/breakdown-feature-implementation`, `/spec`, `/build`, or any other spec-consuming command.
