---
name: slice-to-issues
description: Takes a feature — from its existing implementation doc/PRD, or by searching the codebase and docs itself when none exists — and divides it into a reasonable, feature-driven number of independently verifiable slices (3-4 is the typical default, more when a feature genuinely needs it, never padded to 10-15), each both testable on its own and a substantial real milestone, with acceptance criteria and dependencies. Saves and shows the slice document, then stops — only a separate, explicit go-ahead afterward creates one GitHub issue per slice with the dependency links wired between them. One self-contained skill covering doc discovery through issue creation — not a hand-off between separate planning and issue-creation skills. Use when asked to "turn this feature/implementation into GitHub issues", "slice this into issues", "break this into verifiable pieces and file issues", or similar.
---

# Slice to Issues

## Overview

One skill, start to finish: find or build the feature's context, cut it into small pieces small enough to implement and verify independently, get sign-off on the slice list, then file one GitHub issue per slice with real dependency links between them. Distinct from `planning-and-task-breakdown` (produces a task list for an agent to execute directly, no GitHub issues, no approval gate) and `github-issue-planning` (a heavier Epic/Feature/Story/Enabler hierarchy that assumes a finished plan already exists) — this is the flat, single-level, doc-to-issues pipeline for when the deliverable is literally "one issue per verifiable piece of this feature," with nothing to chain by hand.

## When to Use

- A feature (implemented, or with an implementation doc/PRD already written) needs to be broken into independently verifiable slices and tracked as GitHub issues
- No implementation doc exists yet, and the ask is still "slice this feature into issues" — this skill finds the context itself rather than requiring a separate planning step first
- NOT when the deliverable is a task list for an agent to execute directly in this session, with no GitHub issues involved — use `planning-and-task-breakdown`
- NOT when the team needs the full Epic/Feature/Story/Enabler hierarchy with priority/value scoring and board placement — use `github-issue-planning`
- NOT for issues unrelated to slicing a feature (bug reports, one-off chores) — this skill is specifically for turning one feature into its verifiable pieces

## Process

### 1. Locate the feature's context

Check the project's external output location (see `references/external-output-paths.md`) for an existing `features/<feature-slug>/implementation-plan.md` or `prd.md`. If found, that's the source of truth — read it in full before slicing.

If nothing exists for the named feature, don't stop and ask for a planning step to be run first — build the context directly: explore the codebase (`Glob`/`Grep`/`Read`) for the routes, models, components, and tests that already relate to the feature, and read any docs that mention it. From that exploration, draft a short working summary (what the feature does, its main components, its natural seams) — enough to slice accurately, not a full PRD. Save this summary alongside the slice list (Step 5) so the reasoning behind the slicing is traceable later, not just the slice list itself.

### 2. Cut the feature into a small number of independently verifiable slices

"Verifiable" here means two things together, not one: each slice must be **testable on its own** (its correctness can be confirmed independent of the other slices), and it must be **a real milestone** — a substantial, meaningful piece of the feature, not a tiny mechanical step. A slice that's only testable but trivial (e.g. "add one field to a schema") isn't what this skill produces; neither is a slice that's substantial but untestable in isolation.

**3-4 slices is the reasonable default for a typical feature — not a hard ceiling.** The actual goal is a small number of substantial, independently-workable milestones, never a long checklist of tiny tasks. If a feature genuinely has 5 or 6 real, independent milestones, produce 5 or 6 — don't force-merge pieces that aren't actually one milestone just to hit a target number. The test cuts both ways: don't split a feature into 10-15 slices when several of them aren't independently substantial (that's over-slicing, merge those back together), and don't compress 6 genuinely separate milestones down to 4 by mashing unrelated ones together (that's under-slicing in the other direction, forced to fit a number instead of the actual shape of the feature). Splitting by layer (all schema, then all API, then all UI) violates independent verifiability regardless of count — reject that shape outright. At the other extreme, a feature small enough to genuinely be one milestone produces one slice — don't pad a single unit of work into 3 just to hit the default.

For each slice, capture:
- **Title** — short, specific, one thing (a title needing "and" is two slices, not one)
- **Description** — one paragraph, what this slice delivers
- **Acceptance criteria** — specific, testable conditions (not "implement X")
- **Verification** — how to confirm this slice works on its own, independent of the others
- **Dependencies** — which other slices (by title, not yet by issue number) this one is blocked by, or "None"

### 3. Save the slice document and show it — then stop

Save the full slice list (titles, descriptions, acceptance criteria, verification steps, and the dependency graph between them) to `slices/<feature-slug>-slices.md` in the project's external output location (see `references/external-output-paths.md`) — this document must exist as soon as it's shown, not only after approval. Then present it in full to the user and **stop.** Do not create anything on GitHub in this same pass, and do not treat silence or a vague acknowledgment as approval.

This is a genuine stopping point, not a pause within one continuous action — the next step may come back as a completely separate invocation, later in the conversation or in a new session entirely. If the user asks for changes (split a slice further, merge two, reorder), revise the saved document and re-present it, still without touching GitHub.

### 4. On a distinct, explicit go-ahead, create one issue per slice

Only a clear, separate instruction to proceed (e.g. "create the issues based on these", "go ahead", "looks good, file them") triggers this step — never assume it from Step 3 alone. If this arrives as its own invocation rather than a continuation of the same turn, re-read the saved `slices/<feature-slug>-slices.md` as the source of truth instead of re-deriving the slices from scratch — the document from Step 3 is what was approved, not a fresh pass over the codebase.

Before creating anything, check for issues that might already exist for this feature (`gh issue list --search "<feature-slug>"` or by the label below) — if a prior run already filed some or all of these slices, don't file duplicates; report what's already there and create only what's missing.

Apply one common label to every issue from this run — `feature:<feature-slug>` (create the label first via `gh label create` if it doesn't exist yet) — so all of this feature's slices are filterable as a group directly in GitHub, not only in the local record.

**Nothing sent to GitHub may reference this skill, agent-harness, or any internal tooling — see "External content stays project-only" below.** Every issue's title, body, and labels read as if a person on the project wrote them directly: pure project/feature context, nothing about how the issue was produced.

Create issues via `gh issue create`, in an order where every slice's dependencies already have real issue numbers before it's created (foundation slices first) — a slice referencing a not-yet-created issue is a broken link. Each issue body includes the description, the acceptance-criteria checklist, and an explicit **Blocked by #N** line for each real dependency (never prose like "needs the schema first"). Confirm the target repo before creating anything if it isn't already unambiguous from context.

### 5. Update the record and report back

Update `slices/<feature-slug>-slices.md` with each slice's resulting issue number, and tell the user every issue created, its number/URL, and which slice it corresponds to. Any mention of this skill, the slice document, or what comes next belongs in this chat reply — never inside the slice document itself or an issue body (see `references/no-internal-tooling-in-output.md`).

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "There's no implementation doc, I'll ask the user to run a planning skill first" | Searching the codebase directly for enough context to slice accurately is this skill's own job — that's the whole point of being one self-contained skill instead of a hand-off. |
| "I'll slice by layer, it's simpler to reason about" | A layer-sliced piece (all schema, or all API) can't be independently verified — vertical slices are the only shape that satisfies "verifiable independently." |
| "The slices are obviously fine, I'll just create the issues" | Creating GitHub issues is a public, side-effectful action — present the list and wait for explicit approval every time, not just when a slice looks risky. |
| "I'll describe dependencies in the issue body prose" | "Needs the schema first" disappears the moment someone other than you reads the issue — write real `Blocked by #N` links once the referenced issue exists. |
| "I'll create all the issues in the order I listed them" | An issue can only reference a real number for something already created — create foundation/dependency slices first, or a later issue's Blocked-by link points at nothing. |
| "This is basically what planning-and-task-breakdown or github-issue-planning already do" | Those are close in spirit but produce different artifacts for different consumers (an in-session task list; a full 5-level hierarchy) — neither is "one issue per verifiable slice" with a built-in context-discovery fallback and approval gate. |
| "I'll make each acceptance-criterion item its own slice, more granularity is safer" | That produces 10-15 tiny slices instead of a small number of real milestones — the goal is substantial, independently-workable pieces, not maximum granularity. |
| "This feature has 6 genuine milestones, but I should merge some to land on 4" | 3-4 is a reasonable default, not a quota — forcing unrelated milestones together to hit a number produces a worse breakdown than just having 6 real slices. Let genuine scope decide the count. |
| "The user's already reviewing it, I can just go ahead and create the issues in the same breath" | Showing the document is not the same event as approving it — wait for a distinct, explicit go-ahead, even if it seems like the obvious next step. |
| "The approval came back later, I'll just re-slice from the codebase again to be safe" | The saved slice document from Step 3 is what was actually shown and approved — re-deriving from scratch on the follow-up risks creating issues for a different breakdown than the one the user signed off on. |
| "I'll just create the issues, duplicates are easy enough to close later" | Checking first is one search call — filing duplicates creates real cleanup work and confusion for whoever's tracking the repo's issues, not a harmless redundancy. |
| "A common label is extra ceremony, the issue body is enough" | Without a common label, these issues aren't findable as a group in GitHub itself once the local record is forgotten. |
| "I'll link the issue back to the internal slice doc / SKILL.md for traceability" | Anything posted to GitHub reads as project content only — a link back to this skill's internal artifact, or any mention of this skill by name, doesn't belong in public-facing content (see `references/no-internal-tooling-in-output.md`). |
| "I'll note in the saved document that it's ready for github-issue-planning or breakdown-feature-implementation" | That's chat-reply content, not document content — a saved document is for the project, not for routing between skills. |

## Red Flags

- Slicing proceeded without checking for (or building) real feature context first
- Slices defined by layer (schema/API/UI) rather than as independent vertical pieces
- 10-15 slices produced because pieces were split finer than "substantial, independently-workable milestone" actually requires
- Genuinely separate milestones forced together just to land on 3-4, rather than letting the feature's real scope decide the count
- A slice that's testable but trivial, or substantial but not independently verifiable — either one fails the "verifiable" bar this skill uses
- A slice with no acceptance criteria, or acceptance criteria that just restates the title
- GitHub issues created before the slice list was explicitly approved, or created in the same breath as showing the document without a distinct go-ahead
- Issues created from a fresh re-slice instead of the saved, previously-shown slice document
- An issue created that references a dependency issue that doesn't exist yet
- A dependency written as prose instead of an explicit `Blocked by #N` link
- Issues created without checking whether some or all of them already exist from a prior run
- Issues created with no common label to group them
- An issue, label, or the saved document mentioning this skill, "agent-harness," the plugin, or any other skill by name
- The slice record never saved, leaving no trace of why the feature was cut the way it was

## Verification

- [ ] Feature context was either read from an existing doc or built directly from the codebase — never invented
- [ ] Every slice is a vertical, independently verifiable piece — none split by layer
- [ ] The slice count reflects the feature's genuine number of independent milestones — typically 3-4, but more when truly warranted, never padded to 10-15 or force-compressed to hit a number
- [ ] Every slice is both independently testable and a substantial real milestone — not merely one or the other
- [ ] Every slice has a title, description, acceptance criteria, verification step, and explicit dependencies (or "None")
- [ ] The slice document was saved and shown, and the skill stopped there — no GitHub action taken in the same pass
- [ ] Issue creation only happened after a distinct, explicit go-ahead, using the saved slice document as source of truth (re-read, not re-derived, if it came as a separate invocation)
- [ ] Existing issues for this feature were checked for before creating anything, and only missing slices were filed
- [ ] Every created issue carries the `feature:<feature-slug>` label
- [ ] Nothing sent to GitHub, and nothing in the saved slice document, mentions this skill, "agent-harness," the plugin, or any other skill by name
- [ ] Issues were created in dependency order, with real `Blocked by #N` links, never prose dependencies or forward references to not-yet-created issues
- [ ] The slice record was updated with resulting issue numbers once created
- [ ] The user was told every issue created, its number/URL, and which slice it maps to

## See Also

- `planning-and-task-breakdown` — for a task list an agent executes directly in this session, with no GitHub issues involved
- `github-issue-planning` — for the fuller Epic/Feature/Story/Enabler hierarchy with priority/value scoring and board placement, once a plan already exists
- `incremental-implementation` — vertical-slicing principle this skill's Step 2 also applies
- `references/external-output-paths.md` — where this skill's output lives
- `references/no-internal-tooling-in-output.md` — the project-only rule for generated documents and anything posted to GitHub
