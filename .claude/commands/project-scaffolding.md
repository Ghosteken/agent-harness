---
description: Scaffold a new project's folder structure, tooling, and config based on its tech stack and project type
---

Invoke the agent-harness:project-scaffolding skill.

Before generating anything, use the AskUserQuestion tool (batched, not one at a time) to determine whatever wasn't already stated directly: language/runtime, framework (if applicable), project topology (single app/package vs. a monorepo/workspace, and which workspace tool if so), and package manager. Skip asking anything already stated. If the project directory already has some partial files, detect and match those conventions instead of re-asking.

List exactly what will be created — folder tree, key config files, initial dependencies — and confirm it with the user before writing anything; scaffolding writes many files in one pass, so this confirmation matters more here than in most skills.

Then generate the folder layout, package/dependency manifest, linter/formatter config, a minimal working entry point (not a non-functional placeholder), `.gitignore`, and test scaffolding, following that stack and framework's real, current conventions — never a generic structure. For a monorepo, set up the actual workspace config and shared base configs as part of the scaffold, not as a follow-up.

Install dependencies and run the stack's equivalent of a smoke test to confirm the scaffold actually works before calling it done. Tell the user what was created and the natural next step — `/spec` if the feature set isn't defined yet, or straight into `/build`/`/test` if it is.
