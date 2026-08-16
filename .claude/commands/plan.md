---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the agent-harness:planning-and-task-breakdown skill.

Read the existing spec (`docs/specs/<feature-slug>/SPEC.md`, or legacy `SPEC.md`, or equivalent) and the relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save every plan under `docs/plans/<feature-slug>-plan.md` (task list, if kept separately, as `docs/plans/<feature-slug>-todo.md`). If `docs/` and/or `docs/plans/` don't exist yet, create them. Check whether a plan for this feature already exists before writing — if so, confirm with the user whether to update it in place or create a new one.
