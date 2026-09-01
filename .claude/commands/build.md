---
description: Implement tasks incrementally — build, test, verify, propose commit. Add "auto" to run the whole plan in one approved pass.
---

Invoke the agent-harness:incremental-implementation and agent-harness:test-driven-development skills.

## Modes

- **`/build`** — implement the *next* pending task, then stop (careful, one slice at a time).
- **`/build auto`** — generate the plan if needed, get a single approval, then implement *every* task without stopping between them.

`$ARGUMENTS` selects the mode. Treat `auto` (canonical) or `all` as autonomous mode; anything else (or empty) is the default single-task mode. Note: autonomous mode is not faster *per task* — it runs the same test-driven loop — it only removes the human stepping *between* tasks.

**Never run `git commit` (or `git add` followed by a commit) yourself, in either mode, unless the user explicitly asks you to commit in that message.** Stage nothing implicitly and commit nothing implicitly — draft a commit message and tell the user the change is ready, then leave the actual commit to them.

## Default: one task

Pick the next pending task from the plan. Then:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Draft a commit message and tell the user the change is ready to commit — do not run `git commit` yourself
8. Mark the task complete and stop

## Autonomous: the whole plan (`/build auto`)

Use this once a spec exists and you want to collapse plan + build into one run. It removes the manual stepping between tasks — **not** the verification, and **not** the no-auto-commit rule. Every task still earns a passing test; none earns an agent-run commit.

1. **Require a spec.** Look only for a spec at a known path: `specs/<feature-slug>/SPEC.md` under the project's external output location (see `references/external-output-paths.md`), or (legacy) `SPEC.md` at the repo root. A README or arbitrary doc does **not** count. If none exists, stop and tell the user to run `/spec` first — do not invent requirements.
2. **Establish a clean baseline.** Run `git status --porcelain`. Planning artifacts live outside the repo now, so they never appear here — if there are any uncommitted changes at all, stop and ask the user how to handle them; do not commit, stash, or discard anything yourself. This task-boundary check protects the rollback guarantee below from absorbing unrelated local work.
3. **Plan if needed.** If there is no `plans/<feature-slug>-plan.md` at the external output location, invoke agent-harness:planning-and-task-breakdown to generate one.
4. **Single checkpoint.** Present the full plan and wait for an unambiguous affirmative (e.g. "approve", "go", "yes"). Treat hedged responses ("looks reasonable", "I guess") as **not** approved. This is the only human gate — after approval, run autonomously through implementation (but still never auto-commit).
5. **Execute every task in dependency order.** Use each task's declared dependencies; if they aren't explicit, execute in the order the plan lists them. For each task, run the full default loop above (RED → GREEN → regression → build → draft commit message → mark complete). Since nothing gets committed automatically, the per-task "clean rollback" property now lives in the task-status log and diffs you present, not in git history — call this out to the user, and suggest they commit after each task (or batch) themselves if they want that guarantee restored as real git history.
6. **Stop and ask the user** (do not push through) when:
   - a test can't be made to pass or the build breaks without an obvious fix → follow agent-harness:debugging-and-error-recovery
   - the spec is ambiguous, or a task needs a decision the spec doesn't cover
   - a task is high-risk or irreversible — auth/permission changes, destructive data migrations, payments, deletions, deploys, anything touching secrets, **or anything that would be hard to undo without a commit history to revert to** → follow agent-harness:doubt-driven-development and get explicit sign-off before continuing

   After the user resolves a blocker, they re-invoke `/build auto` — it resumes from the next pending task.
7. **Summarize at the end:** tasks completed, tests added, commit messages proposed (not yet run), and anything skipped, flagged, or left for the user.

If any step fails, follow the agent-harness:debugging-and-error-recovery skill.
