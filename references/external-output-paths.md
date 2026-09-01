# External Output Paths

Skills that produce planning or documentation artifacts write them **outside the current project's repository** — never into a path git in this project tracks, and never into a merely-gitignored path inside it either. This applies uniformly, including to Architecture Decision Records and codebase-knowledge maps, whose usual value comes from being committed; overriding that for this harness is a deliberate choice, not an oversight.

## Root location

```
~/.agent-harness/projects/<project-slug>/
```

Windows: `%USERPROFILE%\.agent-harness\projects\<project-slug>\`

`<project-slug>` is the current project's directory name, lowercased and hyphenated (e.g. a project at `/home/x/My Cool App` becomes `my-cool-app`). If a git remote exists, prefer the repo name parsed from it — more stable across clones and local renames than the directory name. If it's genuinely ambiguous, ask once and reuse the answer for the rest of the session.

Create the root and any subdirectory on first write. None of this is expected to pre-exist.

## Per-skill subpaths

| Skill | Path (relative to the project's external root) |
|---|---|
| `interview-me` | `intent/[topic].md` |
| `idea-refine` | `ideas/[idea-name].md` |
| `spec-driven-development` | `specs/<feature-slug>/SPEC.md` |
| `planning-and-task-breakdown` | `plans/<feature-slug>-plan.md` (+ `-todo.md` if a separate task list is kept) |
| `feature-doc` | `features/<feature-slug>/<actor-slug>/{feature-spec,implementation-guide,test-cases}.md`, plus an index at `features/README.md` |
| `deep-dive` | `deep-dives/<topic-slug>.md` |
| `documentation-and-adrs` | `decisions/NNNN-title.md` |
| `acquire-codebase-knowledge` | `codebase/{STACK,STRUCTURE,ARCHITECTURE,CONVENTIONS,INTEGRATIONS,TESTING,CONCERNS}.md` |

## Conventions every producer follows

- Check whether output for this topic/feature already exists at its path before writing; if so, ask whether to update it in place or create a new variant (whatever numbering pattern that skill already used for its in-repo case still applies here).
- Tell the user the full external path once the file is written — it won't show up in `ls` or `git status` inside the project, so silence about where it went is a real gap, not a minor omission.
- Never write these artifacts into a path under the project root itself, even a gitignored one. The point is that they live somewhere git in this project has no relationship to at all, not merely that git ignores them.

## Skills that read these artifacts back

`quality-assurance`, `requesting-code-review`, and `subagent-driven-development` (among others) may need to locate a spec or plan another skill produced. Check the external location above first. Only fall back to an in-repo path if the user says the artifact was placed there manually.
